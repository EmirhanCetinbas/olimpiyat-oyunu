part of 'controller.dart';

({double x, double y}) archeryBench(int i) => (x: 30.0 + i * 10, y: 87.0);
double archeryRow(int i) => 31.4 + i * 9.1;

/// Okun halkadaki değerinden puanı (1–10).
int archeryPoints(double ring) => ring.floor().clamp(1, 10);

/// Tam merkez (X): eşit puanda sıralamayı X sayısı belirler.
bool archeryX(double ring) => ring >= 10.5;

/// archery.js: arena görseli dekordur; oklar, portreler ve puanlar canlı arayüzdür.
extension ArcheryLogic on GameController {
  /// İsabet (ok başına): yükseltme, kampüs ve uzmanlıktan doğrusal olarak gelir.
  double archeryAim(int id, List<int> levels, [List<int> campus = const [0, 0, 0], int arrow = 0]) {
    final accuracy = .47 + (levels[0] - 1) * .014 + (levels[2] - 1) * .009 + (levels[3] - 1) * .006 + (specialty('archery', id) - 1) * 6;
    final power = (levels[1] - 1) * .008;
    return accuracy * 2 + power * 4 + campus[0] * .32 + campus[1] * .3 + (arrow == 2 ? campus[2] * .42 : 0);
  }

  /// Okun halkadaki değeri (1–10,99). İsabet arttıkça sapma daralır: oklar 10'a
  /// giderek yaklaşır ama hiçbir seviyede her ok garanti 10 olmaz.
  double archeryShot(int id, List<int> levels, [double? noise, List<int> campus = const [0, 0, 0], int arrow = 0]) {
    final offset = ((noise ?? rand()) - .5).abs() * 2;
    final spread = 9 / (1 + archeryAim(id, levels, campus, arrow) / 4);
    return max(1, 10.99 - offset * spread);
  }

  void positionArcheryAvatars() {
    for (var i = 0; i < runnerPos.length; i++) {
      final p = archeryBench(i);
      runnerPos[i]
        ..x = p.x
        ..y = p.y
        ..jump = false
        ..airborne = false;
    }
    final a = race?.branch == 'archery' ? race!.archery : null;
    if (a == null) return;
    final i = a.turn, t = min(1.0, a.time / a.duration), bench = archeryBench(i), stage = (x: 22.0, y: archeryRow(i));
    var pos = stage;
    if (a.phase == 'walk') pos = (x: bench.x + (stage.x - bench.x) * t, y: bench.y + (stage.y - bench.y) * t);
    if (a.phase == 'return') pos = (x: stage.x + (bench.x - stage.x) * t, y: stage.y + (bench.y - stage.y) * t);
    if (i < runnerPos.length) {
      runnerPos[i]
        ..x = pos.x
        ..y = pos.y;
    }
    archeryArrowTop = archeryRow(i);
    archeryArrowLeft = a.phase == 'flight'
        ? 26 + 56 * t
        : a.phase == 'hit'
        ? 82
        : 26;
    archeryArrowHidden = !['flight', 'hit'].contains(a.phase);
  }

  void renderArcheryArena() {
    timerText = 'ATIŞ';
    startText = 'Atışa Başla ▶';
    raceStatus = 'Sporcular sırayla atış yapar · En yüksek puan kazanır.';
    updateArcheryHUD();
  }

  void updateArcheryHUD() {
    if (state.branch != 'archery') return;
    final a = race?.archery;
    timerText = a != null ? 'OK ${min(3, a.arrow + 1)}/3' : 'ATIŞ';
  }

  String get archeryScoreText {
    final a = race?.archery;
    if (a != null && a.scores[a.turn].isNotEmpty) return '${a.scores[a.turn].reduce((n, v) => n + v)} / 30';
    if (archeryCompleted.isNotEmpty) return '${archeryCompleted.last.points} / 30';
    return '';
  }

  UpgradeResult beginArchery() {
    if (race != null || paused) return const UpgradeResult(false, reason: 'Yarış zaten sürüyor');
    resultDelay = 0;
    archeryCompleted = [];
    final ids = lineup(shuffle: true), levels = [...state.archeryLevels];
    final campus = [for (var i = 0; i < 3; i++) campusRank('archery', i)];
    final trainingCard = consumeTrainingCard('archery');
    race = Race(
      branch: 'archery',
      phase: 'shooting',
      ids: ids,
      playerLane: 0,
      archery: ArcheryRound(
        levels: levels,
        campus: campus,
        scores: [for (final _ in ids) <int>[]],
        shots: [
          for (final id in ids)
            [
              for (var arrow = 0; arrow < 3; arrow++)
                () {
                  final player = id == state.selected;
                  final ring = archeryShot(id, player ? levels : rivalLevels(levels), rand(), player ? campus : rivalCampus(campus), arrow);
                  return player && trainingCard ? min(10.99, ring + cardArchery) : ring;
                }(),
            ],
        ],
      ),
    );
    runners();
    stadiumIdle = false;
    raceCallHidden = true;
    liveTagHidden = false;
    raceStatus = '${animals[ids[0]].name} atış çizgisine geliyor.';
    update();
    _changed();
    return const UpgradeResult(true);
  }

  void advanceArchery(double dt) {
    final r = race!, a = r.archery!;
    r.elapsed += dt;
    a.time += dt;
    if (a.time >= a.duration) {
      a.time = 0;
      final id = r.ids[a.turn], name = animals[id].name;
      if (a.phase == 'walk') {
        a.phase = 'aim';
        a.duration = 1.5;
        raceStatus = '$name · ${a.arrow + 1}. ok · nişan alıyor.';
        if (id == state.selected) offerMove('archery', a.duration, 'Nişanı bırak!');
      } else if (a.phase == 'aim') {
        if (id == state.selected) {
          a.shots[a.turn][a.arrow] = min(10.99, a.shots[a.turn][a.arrow] + moveQuality() * moveEffect['archery']!);
          clearMove();
        }
        a.phase = 'flight';
        a.duration = .85;
        beep(620, .05);
      } else if (a.phase == 'flight') {
        a.phase = 'hit';
        a.duration = .55;
        final ring = a.shots[a.turn][a.arrow], points = archeryPoints(ring);
        a.scores[a.turn].add(points);
        raceStatus = '$name · $points puan${archeryX(ring) ? ' (X)' : ''} · toplam ${a.scores[a.turn].reduce((n, v) => n + v)}';
        beep(870, .1);
      } else if (a.phase == 'hit') {
        a.arrow++;
        if (a.arrow < 3) {
          a.phase = 'aim';
          a.duration = 1.5;
          if (id == state.selected) offerMove('archery', a.duration, 'Nişanı bırak!');
        } else {
          final shots = a.shots[a.turn];
          a.results.add(
            ArcheryResult(id, a.scores[a.turn].reduce((n, v) => n + v), shots.where(archeryX).length, shots.reduce((n, v) => n + v)),
          );
          archeryCompleted = [...a.results];
          a.phase = 'return';
          a.duration = .7;
        }
      } else if (a.phase == 'return') {
        a.turn++;
        if (a.turn == r.ids.length) {
          finishArchery();
          return;
        }
        a.phase = 'walk';
        a.duration = .8;
        raceStatus = '${animals[r.ids[a.turn]].name} sıradaki sporcu.';
      }
      if (a.phase == 'walk') a.arrow = 0;
    }
    positionArcheryAvatars();
    updateArcheryHUD();
  }

  void finishArchery() {
    final results = race!.archery!.results;
    final player = results.firstWhere((r) => r.id == state.selected);
    final place = 1 + results.where((r) => r.beats(player)).length;
    state.races++;
    gainXp(place == 1 ? 30 : 15);
    if (place == 1) state.wins++;
    if (isMedal('archery', place)) state.medals++;
    if (state.races % 5 == 0) {
      state.chests++;
      state.skillPoints++;
    }
    final record = player.points > state.bestArchery;
    state.bestArchery = max(state.bestArchery, player.points);
    recordTournament('archery', place);
    final reward = raceReward(place);
    state.money += reward;
    race = null;
    positionArcheryAvatars();
    archeryArrowHidden = true;
    stadiumIdle = true;
    liveTagHidden = true;
    final xs = player.x > 0 ? ' · ${player.x}X' : '';
    final summary = '$place. sıra · ${player.points} puan$xs';
    raceStatus = '$summary · +₺${fmt(reward)}';
    raceCallHidden = false;
    raceCallText = summary;
    startText = 'Tekrar Atış ▶';
    resultDelay = state.auto ? 6 : 0;
    presentResult(
      RaceResult(
        branch: 'archery',
        place: place,
        total: results.length,
        value: '${player.points} / 30 puan$xs',
        reward: reward,
        xp: place == 1 ? 30 : 15,
        record: record,
      ),
      '$summary · +₺${fmt(reward)}',
    );
    save();
    update();
  }
}
