import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'data.dart';
import 'format.dart';
import 'race.dart';
import 'state.dart';

part 'moves.dart';
part 'chests.dart';
part 'longjump.dart';
part 'weights.dart';
part 'archery.dart';
part 'campus.dart';

/// Kalıcı kayıt (localStorage karşılığı).
abstract class GameStorage {
  String? read();

  /// Yazma başarısızsa false döner.
  bool write(String value);
}

class MemoryStorage implements GameStorage {
  MemoryStorage([this.value]);
  String? value;
  @override
  String? read() => value;
  @override
  bool write(String v) {
    value = v;
    return true;
  }
}

/// Web Audio osilatörlerinin karşılığı.
abstract class GameAudio {
  bool get ready;
  void start();
  void beep(double freq, double duration, double gain);
  void note(double freq, double gain);
}

enum ModalStyle { normal, reward, exactAchievements, exactDaily, settings }

class ModalSpec {
  const ModalSpec(this.key, this.title, {this.style = ModalStyle.normal, this.arg});
  final String key;
  final String title;
  final ModalStyle style;
  final Object? arg;
}

class Achievement {
  const Achievement(this.id, this.title, this.detail, this.reward, this.done);
  final String id;
  final String title;
  final String detail;
  final int reward;
  final bool Function(GameState s) done;
}

final achievements = [
  Achievement('first', 'İlk Yarış', '1 yarış yap', 10000, (s) => s.races >= 1),
  Achievement('fast-paws', 'Hızlı Patiler', '3 yarış kazan', 25000, (s) => s.wins >= 3),
  Achievement('full-stand', 'Dolu Tribün', 'Tribünü 5. seviyeye yükselt', 40000, (s) => s.levels[4] >= 5),
  Achievement('ticket-office', 'Bilet Gişesi', 'Bileti 3. seviyeye yükselt', 35000, (s) => s.levels[5] >= 3),
];

class UpgradeResult {
  const UpgradeResult(this.ok, {this.reason, this.level});
  final bool ok;
  final String? reason;
  final int? level;
}

const offlineLimit = 8 * 3600;

/// game.js'in tamamı: oyun durumu, yarış döngüsü ve tüm eylemler.
/// DOM'a yazılan metinler burada alan olarak tutulur; arayüz bunları çizer.
class GameController extends ChangeNotifier {
  GameController({required GameStorage storage, this.audio, Random? random, int Function()? clock})
      : _storage = storage,
        _random = random ?? Random(),
        _clock = clock ?? (() => DateTime.now().millisecondsSinceEpoch) {
    state = GameState.initial(now);
    try {
      final raw = _storage.read();
      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is Map && decoded['version'] == 1) state = GameState.load(decoded, now);
      }
    } catch (_) {
      storageOK = false;
    }
    final away = min(offlineLimit, max(0, (now - state.last) / 1000));
    if (away > 60) {
      final earned = (away * passiveIncome()).floor();
      state.money += earned;
      _welcomeTimer = Timer(const Duration(milliseconds: 700), () => toast('Tekrar hoş geldin! Çevrimdışı gelir: ₺${fmt(earned)}'));
    }
    renderHurdles();
    update();
    save();
  }

  final GameStorage _storage;
  final GameAudio? audio;
  final Random _random;
  final int Function() _clock;
  void Function(int ms)? vibrate;

  int get now => _clock();
  double rand() => _random.nextDouble();

  late GameState state;
  bool storageOK = true;
  String inventoryTab = 'athletes';
  String activeModal = '';
  Race? race;
  double sinceSave = 0;
  double resultDelay = 0;
  bool paused = false;
  ActiveMove? activeMove;
  List<JumpResult> jumpCompleted = [];
  List<WeightResult> weightCompleted = [];
  List<ArcheryResult> archeryCompleted = [];

  // ---- DOM metinleri / görünürlükleri ----
  String timerText = 'HAZIR';
  String raceStatus = 'Çitanı geliştir, başlangıç çizgisine gel.';
  String raceCallText = 'İlk madalyan seni bekliyor!';
  String startText = 'Yarışa Başla ▶';
  bool raceCallHidden = false;
  bool liveTagHidden = true;
  bool stadiumIdle = true;
  bool skillMoveHidden = true;
  String skillButtonText = 'Hamle!';
  double skillMeter = 0;
  List<int> runnerIds = [];
  List<RunnerPos> runnerPos = [];
  double weightBarTop = 66;
  double weightBarTilt = 0;
  bool archeryArrowHidden = true;
  double archeryArrowLeft = 26;
  double archeryArrowTop = 0;

  // ---- Katmanlar ----
  String toastText = '';
  bool toastVisible = false;
  ModalSpec? modal;
  bool rewardsOpen = false;
  int navSelected = 1;
  bool campusOpen = false;
  String campusSelection = 'sprint';
  bool campusDialogOpen = false;

  Timer? _toastTimer;
  Timer? _welcomeTimer;
  Timer? _musicTimer;
  int _musicStep = 0;
  bool hidden = false;
  int _hiddenAt = 0;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _toastTimer?.cancel();
    _welcomeTimer?.cancel();
    _musicTimer?.cancel();
    super.dispose();
  }

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  // ---- Türetilmiş değerler ----
  List<UpgradeDef> get activeUpgrades => switch (state.branch) {
        'archery' => archeryUpgrades,
        'weights' => weightUpgrades,
        'longjump' => longJumpUpgrades,
        'swim' => swimUpgrades,
        'hurdles' => hurdleUpgrades,
        _ => sprintUpgrades,
      };

  List<int> get upgradeLevels => switch (state.branch) {
        'archery' => state.archeryLevels,
        'weights' => state.weightLevels,
        'longjump' => state.longJumpLevels,
        'swim' => state.swimLevels,
        'hurdles' => state.hurdleLevels,
        _ => state.levels,
      };

  int cost(int i) => (activeUpgrades[i].base * pow(1.19, upgradeLevels[i] - 1)).round();
  int get level => 1 + state.xp ~/ 100;

  int campusRank(String id, int i) {
    final list = state.campusUpgrades[id];
    if (list == null || i < 0 || i >= list.length) return 0;
    return list[i].clamp(0, 5);
  }

  double passiveIncome() =>
      15 +
      state.levels[4] * sprintUpgrades[4].income! * (1 + campusRank('stadium', 0) * .05) +
      state.levels[5] * sprintUpgrades[5].income! * (1 + campusRank('stadium', 1) * .05);

  int income() => (passiveIncome() * (now < state.boostUntil ? 2 : 1)).round();

  String statValue(int i, [int next = 0]) {
    final lv = upgradeLevels[i] + next;
    switch (state.branch) {
      case 'archery':
        return '+${trNumber((lv - 1) * const [1.4, .8, .9, .6][i], 1)}%';
      case 'weights':
        return '+${trNumber((lv - 1) * const [2.5, .8, .9, 1][i], 1)}%';
      case 'longjump':
        return '+${trNumber((lv - 1) * const [.7, .9, 1.6, 1.1][i], 1)}%';
    }
    final income = activeUpgrades[i].income;
    if (income != null) return '+₺${fmt(income * lv)}/sn';
    return '${20 + lv * 2}%';
  }

  int _levelSum(List<int> l) => l.fold(0, (sum, n) => sum + n - 1);

  int get power => switch (state.branch) {
        'longjump' => 100 + _levelSum(state.longJumpLevels) * 12,
        'archery' => 100 + _levelSum(state.archeryLevels) * 12,
        'weights' => 100 + _levelSum(state.weightLevels) * 12,
        _ => 100 +
            _levelSum(state.levels.sublist(0, 4)) * 12 +
            (state.equipmentStars.reduce((a, b) => a + b) + state.equipmentLegacy) * 10 +
            (state.camp - 1) * 10,
      };

  String get roundText {
    switch (state.branch) {
      case 'longjump':
        final r = race;
        return '${r?.branch == 'longjump' ? min(6, r!.jump!.turn + 1) : jumpCompleted.isNotEmpty ? 6 : 1} / 6';
      case 'weights':
        final w = race?.weights;
        return '${w != null ? w.turn + 1 : weightCompleted.isNotEmpty ? 6 : 1} / 6';
      case 'archery':
        final a = race?.archery;
        return '${a != null ? a.turn + 1 : archeryCompleted.isNotEmpty ? 6 : 1} / 6';
      case 'hurdles':
      case 'swim':
        return '${race?.place ?? 1} / 6';
    }
    return '${state.races + 1}';
  }

  String get boostText {
    final remain = state.boostUntil - now, cool = state.boostReady - now;
    if (remain > 0) return '2x · ${(remain / 1000).ceil()} sn';
    if (cool > 0) return '2x · ${(cool / 1000).ceil()} sn';
    return '2x Aktif Et';
  }

  bool get boostDisabled => state.boostReady - now > 0;

  bool get achievementDot => achievements.any((a) => a.done(state) && !state.claims.contains(a.id));

  String get branchName => switch (state.branch) {
        'swim' => 'YÜZME',
        'hurdles' => 'ENGELLİ KOŞU',
        'longjump' => 'UZUN ATLAMA',
        'weights' => 'HALTER',
        'archery' => 'OKÇULUK',
        _ => '100 METRE',
      };

  String get branchArt => switch (state.branch) {
        'swim' => 'swim-wave',
        'hurdles' => 'speed',
        'longjump' => 'jump-start',
        'weights' => 'weight-strength',
        'archery' => 'archery-bow',
        _ => 'shoe',
      };

  String get arenaImage => switch (state.branch) {
        'swim' => 'assets/images/swim-arena.png',
        'hurdles' => 'assets/images/hurdle-arena.png',
        'longjump' => 'assets/images/jump-arena.png',
        'weights' => 'assets/images/weights-arena.png',
        'archery' => 'assets/images/archery-arena.png',
        _ => 'assets/images/stadium.png',
      };

  String get todayKey => istanbulDayKey(now);
  bool get dayClaimed => state.daily != 0 && istanbulDayKey(state.daily) == todayKey;

  // ---- Altyapı ----
  void toast(String text) {
    toastText = text;
    toastVisible = true;
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(seconds: 3), () {
      toastVisible = false;
      _changed();
    });
    _changed();
  }

  void save() {
    state.last = now;
    var ok = false;
    try {
      ok = _storage.write(jsonEncode(state.toJson()));
    } catch (_) {}
    if (!ok) {
      if (storageOK) toast('Cihaz kaydı kapalı; ilerleme bu oturumda tutuluyor.');
      storageOK = false;
    }
  }

  void beep([double freq = 600, double duration = .08]) {
    if (!state.sound || state.soundVolume <= 0) return;
    audio?.beep(freq, duration, max(.0001, .025 * state.soundVolume));
  }

  void startMusic() {
    audio?.start();
    _musicTimer ??= Timer.periodic(const Duration(milliseconds: 500), (_) => _musicTick());
  }

  void _musicTick() {
    final a = audio;
    if (a == null || !a.ready || hidden || paused || state.musicVolume <= 0) return;
    const notes = [261.63, 329.63, 392.0, 329.63, 293.66, 349.23, 440.0, 349.23];
    a.note(notes[_musicStep++ % notes.length], max(.0001, .016 * state.musicVolume));
  }

  /// Her düğme dokunuşu (game.js son click dinleyicisi: navigator.vibrate(12)).
  void buttonFeedback() {
    if (state.vibration) vibrate?.call(12);
  }

  void appHidden() {
    save();
    hidden = true;
    _hiddenAt = now;
  }

  void appVisible() {
    hidden = false;
    if (_hiddenAt != 0 && !paused) {
      state.money += min(offlineLimit, (now - _hiddenAt) / 1000) * passiveIncome();
      _hiddenAt = 0;
    }
    update();
    _changed();
  }

  // ---- Yükseltmeler ----
  UpgradeResult upgrade(int i) {
    if (i < 0 || i >= activeUpgrades.length) throw ArgumentError('Geçersiz yükseltme');
    final levels = upgradeLevels, item = activeUpgrades[i];
    if (levels[i] >= 100) return const UpgradeResult(false, reason: 'Maksimum seviye');
    final price = cost(i);
    if (state.money < price) {
      toast('Bu yükseltme için biraz daha gelir biriktir.');
      return const UpgradeResult(false, reason: 'Yetersiz para');
    }
    state.money -= price;
    levels[i]++;
    state.xp += 5;
    save();
    update();
    beep(820);
    toast('${item.title} → Sv. ${levels[i]}');
    return UpgradeResult(true, level: levels[i]);
  }

  bool canUpgrade(int i) => state.money >= cost(i) && upgradeLevels[i] < 100;

  /// game.js `update()`: yalnızca HUD sayaç metinleri; diğer değerler arayüzde türetilir.
  void update() {
    if (state.branch == 'longjump') updateLongJumpHUD();
    if (state.branch == 'archery') updateArcheryHUD();
    if (state.branch == 'weights') updateWeightHUD();
  }

  // ---- Sporcular ve sahne ----
  List<int> lineup() {
    final ids = [state.selected, for (var i = 0; i < animals.length; i++) if (i != state.selected) i];
    return ids.sublist(0, state.branch == 'sprint' ? 4 : 6);
  }

  void runners() {
    runnerIds = lineup();
    runnerPos = [for (final _ in runnerIds) RunnerPos(0, 0)];
    positionRunners([for (final _ in runnerIds) 0.0]);
  }

  /// Oval yol stadyum çizimini izler; kulvar kaydırmaları sporcuları pistte tutar.
  static ({double x, double y}) point(double progress, int lane) {
    final rx = 20 - lane * 2.25, ry = 25 - lane * 3.4, cy = 52.5, t = (progress % 1) * 6;
    double x, y;
    if (t < 1) {
      final a = -t * pi / 2;
      x = 74 + rx * cos(a);
      y = cy + ry * sin(a);
    } else if (t < 2) {
      x = 74 - (t - 1) * 48;
      y = cy - ry;
    } else if (t < 4) {
      final a = -pi / 2 - (t - 2) * pi / 2;
      x = 26 + rx * cos(a);
      y = cy + ry * sin(a);
    } else if (t < 5) {
      x = 26 + (t - 4) * 48;
      y = cy + ry;
    } else {
      final a = pi / 2 - (t - 5) * pi / 2;
      x = 74 + rx * cos(a);
      y = cy + ry * sin(a);
    }
    return (x: x, y: y);
  }

  void positionRunners(List<double> ps) {
    if (state.branch == 'archery') return positionArcheryAvatars();
    if (state.branch == 'weights') return positionWeightAvatars();
    if (state.branch == 'longjump') return positionJumpAvatars();
    for (var i = 0; i < ps.length && i < runnerPos.length; i++) {
      final p = ps[i];
      final pos = state.branch == 'swim'
          ? (x: 7.2 + p * 86, y: 38.0 + i * 8)
          : state.branch == 'hurdles'
              ? (x: 5.1 + p * 85, y: 35.5 + i * 9.2)
              : point(p, i);
      runnerPos[i]
        ..x = pos.x
        ..y = pos.y
        ..airborne = false
        ..jump = state.branch == 'hurdles' &&
            race?.phase == 'running' &&
            const [.2, .42, .64, .84].any((h) => (p - h).abs() < .018);
    }
  }

  /// game.js `renderHurdles`: branşa göre sahneyi ve metinleri hazırlar.
  void renderHurdles() {
    final hurdle = state.branch == 'hurdles', swim = state.branch == 'swim';
    timerText = hurdle || swim ? '◴ 00:00' : 'HAZIR';
    if (race == null) {
      raceCallText = swim
          ? 'Altı sporcu havuzda, yarışa hazır!'
          : hurdle
              ? 'Altı sporcu, dört engel: başlangıç çizgisine gel!'
              : 'İlk madalyan seni bekliyor!';
      raceStatus = swim
          ? 'Yüzme hazır. Kronometre çıkışta başlar.'
          : hurdle
              ? 'Engelli koşu hazır. Kronometre çıkışta başlar.'
              : 'Çitanı geliştir, başlangıç çizgisine gel.';
    }
    if (state.branch == 'longjump') {
      timerText = 'DENEME';
      startText = 'Atlayışa Başla ▶';
      raceStatus = 'Sporcular sırayla atlar · Bayraklara dokunarak mesafeyi gör.';
    }
    if (state.branch == 'weights') renderWeightArena();
    if (state.branch == 'archery') renderArcheryArena();
    runners();
    update();
  }

  void selectBranch(String branch) {
    if (race != null) {
      toast('Branşı yarış bitince değiştirebilirsin.');
      return;
    }
    if (!branches.contains(branch)) return;
    if (branch == 'longjump' && state.branch != 'longjump') jumpCompleted = [];
    if (branch == 'weights' && state.branch != 'weights') weightCompleted = [];
    if (branch == 'archery' && state.branch != 'archery') archeryCompleted = [];
    state.branch = branch;
    clearMove();
    resultDelay = 0;
    renderHurdles();
    raceCallHidden = false;
    raceCallText = branch == 'swim'
        ? 'Altı sporcu havuzda, yarışa hazır!'
        : branch == 'hurdles'
            ? 'Altı sporcu, dört engel: başlangıç çizgisine gel!'
            : 'İlk madalyan seni bekliyor!';
    startText = 'Yarışa Başla ▶';
    raceStatus = branch == 'swim'
        ? 'Yüzme hazır. Kronometre çıkışta başlar.'
        : branch == 'hurdles'
            ? 'Engelli koşu hazır. Kronometre çıkışta başlar.'
            : 'Çitanı geliştir, başlangıç çizgisine gel.';
    if (branch == 'longjump') {
      startText = 'Atlayışa Başla ▶';
      raceStatus = 'Sporcular sırayla atlar · Bayraklara dokunarak mesafeyi gör.';
    }
    if (branch == 'archery') {
      startText = 'Atışa Başla ▶';
      raceStatus = 'Sporcular sırayla atış yapar · En yüksek puan kazanır.';
    }
    if (branch == 'weights') {
      startText = 'Kaldırışa Başla ▶';
      raceStatus = 'Sporcular sırayla kaldırır · En yüksek başarılı kilo kazanır.';
    }
    modal = null;
    save();
    _changed();
  }

  // ---- Koşu, engelli koşu ve yüzme ----
  UpgradeResult beginRace() {
    if (state.branch == 'archery') return beginArchery();
    if (state.branch == 'weights') return beginWeights();
    if (state.branch == 'longjump') return beginLongJump();
    if (race != null || paused) return const UpgradeResult(false, reason: 'Yarış zaten sürüyor');
    resultDelay = 0;
    const base = 9.3;
    final ids = lineup(), n = ids.length, b = state.branch;
    race = Race(
      branch: b,
      phase: 'countdown',
      countdown: 3,
      progress: List.filled(n, 0),
      times: List.filled(n, null),
      ids: ids,
      playerLane: ids.indexOf(state.selected),
      speeds: [
        for (final id in ids)
          id == state.selected
              ? base * animals[id].speed * specialty(b, id)
              : base * (.96 + rand() * .12 + min(state.wins * .003, .12)),
      ],
      levels: [...state.levels],
      hurdleLevels: [...state.hurdleLevels],
      swimLevels: [...state.swimLevels],
      equipmentStars: [...state.equipmentStars],
      equipmentLegacy: state.equipmentLegacy,
      campus: [for (var i = 0; i < 3; i++) campusRank(b, i)],
      trainingCard: consumeTrainingCard(b),
    );
    runners();
    stadiumIdle = false;
    raceCallHidden = true;
    liveTagHidden = false;
    timerText = b == 'hurdles' || b == 'swim' ? '◴ 00:00' : '3';
    raceStatus = 'Hazırlan… 3, 2, 1!';
    if (b == 'sprint') offerMove('sprint', 2.4, 'Çıkış yap!');
    beep(400);
    _changed();
    return const UpgradeResult(true);
  }

  void finishRace() {
    final r = race!;
    final playerLane = r.playerLane;
    final order = [for (var i = 0; i < r.times.length; i++) (i: i, time: r.times[i] ?? r.elapsed)]
      ..sort((a, b) => a.time != b.time ? a.time.compareTo(b.time) : a.i.compareTo(b.i));
    final place = order.indexWhere((x) => x.i == playerLane) + 1;
    final time = order.firstWhere((x) => x.i == playerLane).time;
    state.races++;
    state.xp += place == 1 ? 30 : 15;
    if (state.races % 5 == 0) {
      state.chests++;
      state.skillPoints++;
    }
    if (place == 1) state.wins++;
    if (place <= 3) state.medals++;
    recordTournament(state.branch, place);
    state.best = state.best == null ? time : min(state.best!, time);
    final reward = (_placeReward(place) * (1 + (state.races / 10).floor() * .1) * (1 + campusRank('stadium', 2) * .03)).round();
    state.money += reward;
    clearMove();
    race = null;
    stadiumIdle = true;
    liveTagHidden = true;
    final stopwatchBranch = state.branch == 'hurdles' || state.branch == 'swim';
    timerText = stopwatchBranch ? stopwatch(time) : '${time.toStringAsFixed(2)} sn';
    raceStatus = '$place. oldun · +₺${fmt(reward)} · ${time.toStringAsFixed(2)} sn';
    toast('${place == 1 ? '🏆 Zafer!' : place <= 3 ? '🏅 Madalya!' : '🏁 Yarış bitti'} $place. sıra · +₺${fmt(reward)}');
    beep(place == 1 ? 960 : 540, .18);
    resultDelay = state.auto ? 4 : 0;
    raceCallHidden = false;
    raceCallText = state.auto ? 'Yeni yarış 4 saniye içinde' : '$place. sıra · ${time.toStringAsFixed(2)} sn';
    startText = 'Yeniden Yarış ▶';
    save();
    update();
  }

  int _placeReward(int place) => place == 1
      ? 1250
      : place == 2
          ? 850
          : place == 3
              ? 650
              : 400;

  double _advanceRunner(Race r, int i, double p, double dt) {
    if (p >= 1) return 1;
    var speed = r.speeds[i];
    final player = i == r.playerLane;
    if (player) speed *= 1 + r.manualBonus + (r.trainingCard ? .03 : 0);
    if (state.branch == 'hurdles') {
      final h = r.hurdleLevels;
      final nearHurdle = const [.2, .42, .64, .84].any((x) => (p - x).abs() < .023);
      if (nearHurdle) speed *= player ? min(.96, .55 + (h[0] - 1) * .025) : .58;
      if (player) {
        speed *= 1 + r.campus[1] * .01 + (h[1] - 1) * .01 + (r.equipmentStars[0] + r.equipmentLegacy) * .02;
        if (p > .5) speed *= 1 + (h[2] - 1) * .012;
        if (p > .84) speed *= 1 + r.campus[2] * .01 + (h[3] - 1) * .02;
        if (nearHurdle) speed *= 1 + r.campus[0] * .025;
      }
    } else if (state.branch == 'swim') {
      if (player) {
        final l = r.swimLevels;
        speed *= 1 + r.campus[1] * .01 + (l[1] - 1) * .012;
        if (p < .25) speed *= 1 + r.campus[0] * .01 + (l[0] - 1) * .02;
        if (p > .5) speed *= 1 + r.campus[2] * .01 + (l[2] - 1) * .015;
        if (p > .75) speed *= 1 + (l[3] - 1) * .017;
        speed *= 1 + (r.equipmentStars[0] + r.equipmentLegacy) * .012;
      }
    } else if (player) {
      final l = r.levels;
      speed *= 1 + r.campus[1] * .01;
      if (p < .25) speed *= 1 + r.campus[0] * .01;
      if (p > .8) speed *= 1 + r.campus[2] * .01;
      speed *= 1 + (l[1] - 1) * .01 + (r.equipmentStars[0] + r.equipmentLegacy) * .03;
      if (p < .25) speed *= (1 + (l[0] - 1) * .02) * (1 + r.equipmentStars[1] * .04);
      if (p > .5) speed *= (1 + (l[2] - 1) * .015) * (1 + r.equipmentStars[2] * .025);
      if (p > .8) speed *= (1 + (l[3] - 1) * .02) * (1 + r.equipmentStars[3] * .04);
    }
    final next = p + speed * dt / 100;
    if (next >= 1) r.times[i] = r.elapsed;
    return min(1, next);
  }

  /// requestAnimationFrame döngüsü.
  void tick(double dt) {
    dt = min(dt, .1);
    if (!paused) {
      tickMove(dt);
      state.money += income() * dt;
      final r = race;
      if (r != null) {
        final stopwatchBranch = state.branch == 'hurdles' || state.branch == 'swim';
        if (r.branch == 'archery') {
          advanceArchery(dt);
        } else if (r.branch == 'weights') {
          advanceWeights(dt);
        } else if (r.branch == 'longjump') {
          advanceLongJump(dt);
        } else if (r.phase == 'countdown') {
          final prev = r.countdown.ceil();
          r.countdown -= dt;
          if (state.branch == 'sprint') timerText = '${max(1, r.countdown.ceil())}';
          if (r.countdown.ceil() != prev) beep(500);
          if (r.countdown <= 0) {
            r.manualBonus = state.branch == 'sprint' ? moveQuality() * .06 : 0;
            clearMove();
            r.moveOffered = false;
            r.phase = 'running';
            r.elapsed = 0;
            timerText = stopwatchBranch ? '◴ 00:00' : '0.00 sn';
            raceStatus = 'Yarış sürüyor · ${animals[state.selected].name} takımını temsil ediyor';
            beep(900, .15);
          }
        } else {
          r.elapsed += dt;
          if (stopwatchBranch && !r.moveOffered && r.progress[r.playerLane] > .4) {
            r.moveOffered = true;
            offerMove(state.branch, 1.5, state.branch == 'hurdles' ? 'Engeli geç!' : 'Güçlü kulaç!');
          }
          final move = activeMove;
          if (move != null && move.elapsed >= move.duration) {
            r.manualBonus = moveQuality() * .06;
            clearMove();
          }
          r.progress = [for (var i = 0; i < r.progress.length; i++) _advanceRunner(r, i, r.progress[i], dt)];
          if (stopwatchBranch) {
            var ahead = 0;
            for (var i = 0; i < r.progress.length; i++) {
              if (i != r.playerLane && r.progress[i] > r.progress[r.playerLane]) ahead++;
            }
            r.place = 1 + ahead;
          }
          positionRunners(r.progress);
          timerText = stopwatchBranch ? stopwatch(r.elapsed) : '${r.elapsed.toStringAsFixed(2)} sn';
          if (r.progress.every((p) => p >= 1)) finishRace();
        }
      } else if (resultDelay > 0 && state.auto) {
        resultDelay -= dt;
        raceCallText = 'Yeni yarış ${max(1, resultDelay.ceil())} saniye içinde';
        if (resultDelay <= 0) beginRace();
      }
    }
    sinceSave += dt;
    if (sinceSave > .4) update();
    if (sinceSave >= 5) {
      sinceSave = 0;
      save();
    }
    _changed();
  }

  // ---- Paneller ----
  void rewardsMenu(bool open) {
    rewardsOpen = open;
    _changed();
  }

  void selectNav(int index) {
    navSelected = index;
    _changed();
  }

  /// `data-open` düğmeleri.
  void open(String key, {int? navIndex}) {
    if (navIndex != null) selectNav(navIndex);
    beep(620, .04);
    openPanel(key);
  }

  void openPanel(String key) {
    rewardsMenu(false);
    activeModal = key;
    switch (key) {
      case 'race':
        modal = null;
      case 'profile':
        modal = const ModalSpec('profile', 'Profil');
      case 'inventory':
        modal = const ModalSpec('inventory', 'Envanter');
      case 'chests':
        modal = const ModalSpec('chests', 'Spor Çantaları');
      case 'cosmetics':
        modal = const ModalSpec('cosmetics', 'Avatar Çerçeveleri');
      case 'campus':
        openCampus();
      case 'achievements':
        modal = const ModalSpec('achievements', 'Başarımlar', style: ModalStyle.exactAchievements);
      case 'daily-rewards':
        modal = const ModalSpec('daily-rewards', 'Günlük Ödül', style: ModalStyle.exactDaily);
      case 'wheel':
        modal = const ModalSpec('wheel', 'Çarkıfelek', style: ModalStyle.reward);
      case 'settings':
        modal = const ModalSpec('settings', 'Ayarlar', style: ModalStyle.settings);
      case 'team':
        modal = const ModalSpec('team', 'Hayvan Takımın');
      case 'league':
        modal = const ModalSpec('league', 'Çaylaklar Ligi');
      case 'tournament':
        modal = const ModalSpec('tournament', 'Üç Yarışlık Kupa');
      case 'equipment':
        inventoryTab = 'equipment';
        openPanel('inventory');
      case 'camp':
        modal = const ModalSpec('camp', 'Antrenman Kampı');
      case 'shop':
        modal = const ModalSpec('shop', 'Mağaza');
      case 'branches':
        modal = const ModalSpec('branches', 'Spor Branşları');
    }
    _changed();
  }

  /// `panel()` ile açılan, activeModal'ı değiştirmeyen pencereler.
  void panel(String key, String title, {Object? arg}) {
    modal = ModalSpec(key, title, arg: arg);
    _changed();
  }

  void closeModal() {
    modal = null;
    _changed();
  }

  void showInfo(int i) => panel('info', activeUpgrades[i].title, arg: i);

  // ---- Eylemler ----
  void pressUpgrade(int i) {
    upgrade(i);
    _changed();
  }

  void activateBoost() {
    if (now >= state.boostReady) {
      state.boostUntil = now + 30000;
      state.boostReady = now + 90000;
      save();
      update();
      toast('30 saniye boyunca gelir iki katı!');
    }
  }

  void toggleAuto() {
    state.auto = !state.auto;
    if (!state.auto) resultDelay = 0;
    save();
    update();
    _changed();
  }

  void toggleRisk() {
    if (race != null) return;
    state.weightRisk = state.weightRisk == 'record' ? 'safe' : 'record';
    save();
    _changed();
  }

  void saveName(String value) {
    final trimmed = value.trim();
    state.name = trimmed.isEmpty ? 'Pati Takımı' : (trimmed.length > 24 ? trimmed.substring(0, 24) : trimmed);
    save();
    toast('Takım adı kaydedildi.');
  }

  void selectAnimal(int i) {
    if (race == null && i >= 0 && i < animals.length && state.races >= animals[i].unlock) {
      state.selected = i;
      runners();
      save();
      openPanel(activeModal == 'inventory' ? 'inventory' : 'team');
      toast('${animals[i].name} takım liderin oldu.');
    }
  }

  void setInventoryTab(String tab) {
    inventoryTab = tab;
    openPanel('inventory');
  }

  void claimAchievement(String id) {
    final a = achievements.where((x) => x.id == id).firstOrNull;
    if (a != null && a.done(state) && !state.claims.contains(a.id)) {
      state.claims.add(a.id);
      state.money += a.reward;
      if (['fast-paws', 'full-stand'].contains(a.id)) state.championChests++;
      save();
      update();
      openPanel('achievements');
      toast('Başarım ödülü alındı!');
    }
  }

  void grant(Prize prize) {
    state.money += prize.money;
    state.gems += prize.gems;
    state.spinTickets += prize.tickets;
    save();
    update();
  }

  void claimDaily() {
    if (!dayClaimed) {
      final prize = dailyPrizes[state.dailyStep % 7];
      state.daily = now;
      state.dailyStep++;
      grant(prize);
      openPanel('daily-rewards');
      toast('${prize.label} kazandın!');
    }
  }

  void spinWheel() {
    if (state.spinDate != todayKey || state.spinTickets > 0) {
      if (state.spinDate == todayKey) {
        state.spinTickets--;
      } else {
        state.spinDate = todayKey;
      }
      final prize = wheelPrizes[_random.nextInt(wheelPrizes.length)];
      grant(prize);
      openPanel('wheel');
      toast('Çark ödülün: ${prize.label}');
    }
  }

  void buyCoins() {
    if (state.gems >= 5) {
      state.gems -= 5;
      state.money += 10000;
      save();
      update();
      openPanel('shop');
      toast('+₺10.000 sponsor geliri!');
    }
  }

  int equipmentCost(int i) {
    final stars = state.equipmentStars[i];
    return (equipmentItems[i].base * const [1, 2.5, 6, 6][stars]).round();
  }

  bool buyEquipment(int i, {bool useParts = false}) {
    if (i < 0 || i >= equipmentItems.length) return false;
    if (state.equipmentStars[i] >= 3) return false;
    final price = equipmentCost(i);
    if (useParts) {
      if (state.equipmentParts < 5) return false;
      state.equipmentParts -= 5;
    } else {
      if (state.money < price) return false;
      state.money -= price;
    }
    state.equipmentStars[i]++;
    state.xp += 5;
    save();
    update();
    toast('${equipmentItems[i].name} → ${state.equipmentStars[i]} yıldız');
    return true;
  }

  void pressEquipment(int i, {bool useParts = false}) {
    if (buyEquipment(i, useParts: useParts)) openPanel('inventory');
  }

  int campCost() => (2500 * pow(1.5, state.camp - 1)).round();

  void buyCamp() {
    if (state.money >= campCost()) {
      state.money -= campCost();
      state.camp++;
      save();
      update();
      openPanel(activeModal == 'campus' ? 'campus' : 'camp');
    }
  }

  void useBoostToken() {
    if (state.boostTokens > 0) {
      state.boostTokens--;
      state.boostUntil = max(now, state.boostUntil) + 30000;
      save();
      update();
      openPanel('inventory');
      toast('2x gelir 30 saniye uzatıldı!');
    }
  }

  void selectCosmetic(int i) {
    if (state.cosmetics.contains(i)) {
      state.selectedCosmetic = i;
      save();
      runners();
      openPanel('cosmetics');
    }
  }

  void pressTournamentStart() {
    if (startTournament()) toast('Kupa başladı! Üç yarışta iki madalya kazan.');
    openPanel('tournament');
  }

  void openSupport() => panel('support', 'Destek');
  void askReset() => panel('reset', 'İlerleme sıfırlansın mı?');

  void confirmReset() {
    state = GameState.initial(now);
    clearMove();
    race = null;
    resultDelay = 0;
    paused = false;
    jumpCompleted = [];
    weightCompleted = [];
    archeryCompleted = [];
    save();
    renderHurdles();
    update();
    timerText = 'HAZIR';
    raceCallHidden = false;
    raceCallText = 'İlk madalyan seni bekliyor!';
    startText = 'Yarışa Başla ▶';
    liveTagHidden = true;
    stadiumIdle = true;
    modal = null;
    toast('Yeni takımın hazır.');
  }

  // ---- Ayarlar ----
  void setAutoSetting(bool value) {
    state.auto = value;
    save();
    update();
    _changed();
  }

  void setPaused(bool value) {
    paused = value;
    raceStatus = paused ? 'Oyun duraklatıldı.' : 'Oyun devam ediyor.';
    save();
    update();
    _changed();
  }

  void setVibration(bool value) {
    state.vibration = value;
    if (state.vibration) vibrate?.call(40);
    save();
    _changed();
  }

  void setMusicVolume(double value) {
    state.musicVolume = value;
    startMusic();
    save();
    _changed();
  }

  void setSoundVolume(double value) {
    state.soundVolume = value;
    state.sound = value > 0;
    beep();
    save();
    _changed();
  }

  void showJumpResult(int i) {
    if (i < 0 || i >= jumpCompleted.length) return;
    final result = jumpCompleted[i];
    toast('${animals[result.id].name} · ${jumpMetres(result.metres)}');
  }
}
