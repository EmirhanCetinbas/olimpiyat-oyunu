// Özel alan adlandırılmış parametreyle başlatılamadığı için:
// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'achievements.dart';
import 'data.dart';
import 'format.dart';
import 'ports.dart';
import 'race.dart';
import 'state.dart';
import 'track.dart';

export 'achievements.dart';
export 'ports.dart';
export 'track.dart';

part 'moves.dart';
part 'chests.dart';
part 'longjump.dart';
part 'weights.dart';
part 'archery.dart';
part 'campus.dart';
part 'navigation.dart';
part 'rewards.dart';
part 'inventory.dart';
part 'settings.dart';
part 'scene.dart';
part 'running.dart';
part 'rivals.dart';

/// Çevrimdışı kazanç (karşılama penceresi).
class OfflineEarnings {
  const OfflineEarnings(this.money, this.seconds);
  final int money;
  final double seconds;

  /// Süre [offlineLimit]e takıldı mı.
  bool get capped => seconds >= offlineLimit;
}

class UpgradeResult {
  const UpgradeResult(this.ok, {this.reason, this.level});
  final bool ok;
  final String? reason;
  final int? level;
}

const offlineLimit = 8 * 3600;

/// Bedava 2x gelir: süresi ve (başlattıktan sonra) yeniden kullanma beklemesi; kupon da bir süre ekler.
const boostMs = 3 * 60 * 1000, boostCooldownMs = 15 * 60 * 1000;

/// Antrenman kartının bir yarışlık etkisi: hız/mesafe/kilo çarpanı ve okçulukta oka eklenen halka değeri.
const cardBoost = .05, cardArchery = 1.5;

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
      _welcomeTimer = Timer(const Duration(milliseconds: 700), () => showWelcome(earned, away.toDouble()));
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
  RaceResult? lastResult;
  List<JumpResult> jumpCompleted = [];
  double jumpSpan = 10;
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
  String moveFeedback = '';
  bool moveFeedbackPerfect = false;
  double moveFeedbackTime = 0;
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

  /// Kampüs haritasının son kamera görünümü (oturum boyunca).
  List<double>? campusView;
  String campusSelection = 'sprint';
  bool campusDialogOpen = false;

  Timer? _toastTimer;
  Timer? _welcomeTimer;
  Timer? _levelTimer;
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
    _levelTimer?.cancel();
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

  /// Yükseltme dizinleri: 0–3 seçili branşın yükseltmeleri, 4–5 gelir yükseltmeleri ([incomeUpgrades]).
  static const upgradeCount = 6;

  UpgradeDef upgradeDef(int i) => i < 4 ? activeUpgrades[i] : incomeUpgrades[i - 4];

  /// Gelir seviyeleri `state.levels[4]` ve `[5]`te; branş seviyeleri branşın listesinde.
  List<int> _levelList(int i) => i < 4 ? upgradeLevels : state.levels;

  int upgradeLevel(int i) => _levelList(i)[i];

  int cost(int i) => (upgradeDef(i).base * pow(1.19, upgradeLevel(i) - 1)).round();
  ({int level, int into, int need}) get levelInfo => levelProgress(state.xp);
  int get level => levelInfo.level;

  int campusRank(String id, int i) {
    final list = state.campusUpgrades[id];
    if (list == null || i < 0 || i >= list.length) return 0;
    return list[i].clamp(0, 5);
  }

  double passiveIncome() =>
      15 +
      state.levels[4] * incomeUpgrades[0].income! * (1 + campusRank('stadium', 0) * .05) +
      state.levels[5] * incomeUpgrades[1].income! * (1 + campusRank('stadium', 1) * .05);

  int income() => (passiveIncome() * (now < state.boostUntil ? 2 : 1)).round();

  /// Yükseltme kartındaki değer: yükseltmenin yarıştaki gerçek, birikmiş etkisi
  /// (yarış formüllerindeki katsayılarla aynı; bkz. running/longjump/weights/archery).
  String statValue(int i, [int next = 0]) {
    final lv = upgradeLevel(i) + next, n = lv - 1;
    String pct(num v) => '+%${trNumber(v, 1)}';
    final income = upgradeDef(i).income;
    if (income != null) return '+₺${fmt(income * lv * (1 + campusRank('stadium', i - 4) * .05))}/sn';
    switch (state.branch) {
      case 'sprint':
        return pct(n * const [2, 1, 1.5, 2][i]);
      case 'hurdles':
        // Engel Ritmi: engelin üstünde korunan hız oranı.
        if (i == 0) return '%${trNumber(min(96, 55 + n * 2.5), 1)}';
        return pct(n * const [0, 1, 1.2, 2][i]);
      case 'swim':
        return pct(n * const [2, 1.2, 1.5, 1.7][i]);
      case 'longjump':
        return pct(n * const [.7, .9, 1.6, 1.1][i]);
      case 'weights':
        // Kilo yüzdesi (Temel Güç, Son Hamle) ya da başarı şansı puanı (Kavrama, Denge).
        return pct(n * const [2.5, .8, .9, 1][i]);
      case 'archery':
        // Ok başına isabet: isabet × 2 (Nişan, Rüzgâr, Son Atış), güç × 4 (Yay); bkz. archeryAim.
        return '+${trNumber(n * const [.028, .032, .018, .012][i], 2)} isabet';
    }
    return '';
  }

  int _levelSum(List<int> l) => l.fold(0, (sum, n) => sum + n - 1);

  String get _campusKey => state.branch == 'longjump' ? 'jump' : state.branch;

  /// Takım gücü: seçili branşın yükseltmelerinden, kampüs kademelerinden ve
  /// o branşta gerçekten etkili ekipman yıldızlarından oluşan gelişim puanı.
  int get power {
    final branchLevels = upgradeLevels.sublist(0, 4);
    final equipment = switch (state.branch) {
      'sprint' => state.equipmentStars.reduce((a, b) => a + b) + state.equipmentLegacy,
      'hurdles' || 'swim' => state.equipmentStars[0] + state.equipmentLegacy,
      _ => 0,
    };
    final campus = [0, 1, 2].fold(0, (n, i) => n + campusRank(_campusKey, i));
    return 100 + _levelSum(branchLevels) * 12 + equipment * 10 + campus * 10;
  }

  String get roundText {
    switch (state.branch) {
      case 'longjump':
        final r = race;
        return '${r?.branch == 'longjump'
            ? min(6, r!.jump!.turn + 1)
            : jumpCompleted.isNotEmpty
            ? 6
            : 1} / 6';
      case 'weights':
        final w = race?.weights;
        return '${w != null
            ? w.turn + 1
            : weightCompleted.isNotEmpty
            ? 6
            : 1} / 6';
      case 'archery':
        final a = race?.archery;
        return '${a != null
            ? a.turn + 1
            : archeryCompleted.isNotEmpty
            ? 6
            : 1} / 6';
      case 'hurdles':
      case 'swim':
        return '${race?.place ?? 1} / 6';
    }
    return 'YARIŞ ${state.races + 1}';
  }

  String get boostText {
    final remain = state.boostUntil - now, cool = state.boostReady - now;
    if (remain > 0) return '2x · ${shortDuration(remain)}';
    if (cool > 0) return '2x · ${shortDuration(cool)}';
    return '2x Aktif Et';
  }

  bool get boostDisabled => state.boostReady - now > 0;

  /// 2x gelir şu an etkin mi.
  bool get boostActive => now < state.boostUntil;

  /// Alt menü rozetleri: oyuncunun alabileceği bir şey var mı.
  bool get rewardsBadge => achievementDot || !dayClaimed || state.spinDate != todayKey;
  bool get inventoryBadge =>
      state.pendingChest != null ||
      state.chests + state.cupChests + state.championChests > 0 ||
      (state.equipmentParts >= partsPerStar && state.equipmentStars.any((s) => s < maxStars));
  bool get campusBadge => campusFacilities.any((f) => canUpgradeFacility(f.id));

  bool get achievementDot => achievements.any((a) => a.done(state) && !state.claims.contains(a.id));

  String get branchName => switch (state.branch) {
    'swim' => 'YÜZME',
    'hurdles' => 'ENGELLİ KOŞU',
    'longjump' => 'UZUN ATLAMA',
    'weights' => 'HALTER',
    'archery' => 'OKÇULUK',
    _ => '100 METRE',
  };

  String get branchArt => 'branch-${state.branch}';

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
      final away = min(offlineLimit, (now - _hiddenAt) / 1000);
      final earned = (away * passiveIncome()).floor();
      state.money += earned;
      _hiddenAt = 0;
      if (away > 60) showWelcome(earned, away.toDouble());
    }
    update();
    _changed();
  }

  // ---- Yükseltmeler ----
  UpgradeResult upgrade(int i) {
    if (i < 0 || i >= upgradeCount) throw ArgumentError('Geçersiz yükseltme');
    final levels = _levelList(i), item = upgradeDef(i);
    if (levels[i] >= 100) return const UpgradeResult(false, reason: 'Maksimum seviye');
    final price = cost(i);
    if (state.money < price) {
      toast('Bu yükseltme için biraz daha gelir biriktir.');
      return const UpgradeResult(false, reason: 'Yetersiz para');
    }
    state.money -= price;
    levels[i]++;
    gainXp(5);
    save();
    update();
    beep(820);
    toast('${item.title} → Sv. ${levels[i]}');
    return UpgradeResult(true, level: levels[i]);
  }

  bool canUpgrade(int i) => state.money >= cost(i) && upgradeLevel(i) < 100;

  /// game.js `update()`: yalnızca HUD sayaç metinleri; diğer değerler arayüzde türetilir.
  void update() {
    if (state.branch == 'longjump') updateLongJumpHUD();
    if (state.branch == 'archery') updateArcheryHUD();
    if (state.branch == 'weights') updateWeightHUD();
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
            // 100 m çıkış hamlesi "BAŞLA!" anını kapsar; sonucu yarış içinde uygulanır.
            r.manualBonus = 0;
            if (state.branch != 'sprint') clearMove();
            r.moveOffered = false;
            r.phase = 'running';
            r.elapsed = 0;
            timerText = stopwatchBranch ? '◴ 00:00' : '0.00 sn';
            raceStatus = 'Yarış sürüyor · ${animals[state.selected].name} takımını temsil ediyor';
            beep(900, .15);
          }
        } else {
          r.elapsed += dt;
          if (stopwatchBranch && !r.moveOffered && r.progress[r.playerLane] > (state.branch == 'hurdles' ? .55 : .4)) {
            r.moveOffered = true;
            if (state.branch == 'hurdles') {
              offerMove('hurdles', 1.5, 'Engeli geç!');
            } else {
              offerMove('swim', 1.5, 'Güçlü kulaç!');
            }
          }
          final move = activeMove;
          // Dokunulduğu an (ya da süre bitince) bonus uygulanır.
          if (move != null && move.tapped) {
            r.manualBonus = moveQuality() * moveEffect[state.branch]!;
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

  // ---- Ana ekran eylemleri ----
  void pressUpgrade(int i) {
    upgrade(i);
    _changed();
  }

  void activateBoost() {
    if (now >= state.boostReady) {
      state.boostUntil = now + boostMs;
      state.boostReady = now + boostCooldownMs;
      save();
      update();
      toast('3 dakika boyunca gelir iki katı!');
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

  void pressTournamentStart() {
    if (startTournament()) toast('Kupa başladı! Üç yarışta iki madalya kazan.');
    openPanel('tournament');
  }
}
