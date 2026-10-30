part of 'controller.dart';

({double x, double y}) archeryBench(int i) => (x: 30.0 + i * 10, y: 87.0);
double archeryRow(int i) => 31.4 + i * 9.1;

/// archery.js: arena görseli dekordur; oklar, portreler ve puanlar canlı arayüzdür.
extension ArcheryLogic on GameController {
  int archeryShot(int id, List<int> levels, [double? noise, List<int> campus = const [0, 0, 0], int arrow = 0]) {
    final n = noise ?? rand();
    final accuracy = .47 + (levels[0] - 1) * .014 + (levels[2] - 1) * .009 + (levels[3] - 1) * .006 + (specialty('archery', id) - 1) * 2;
    final power = (levels[1] - 1) * .008;
    final offset = (n - .5).abs() * 2;
    return (10 - offset * 8 + accuracy * 2 + power * 4 + campus[0] * .32 + campus[1] * .3 + (arrow == 2 ? campus[2] * .42 : 0))
        .round()
        .clamp(1, 10);
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
    final ids = lineup(), levels = [...state.archeryLevels];
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
                  final points = archeryShot(id, player ? levels : const [1, 1, 1, 1], rand(), player ? campus : const [0, 0, 0], arrow);
                  return player && trainingCard ? min(10, points + 1) : points;
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
          a.shots[a.turn][a.arrow] = min(10, a.shots[a.turn][a.arrow] + (moveQuality() * 2).round());
          clearMove();
        }
        a.phase = 'flight';
        a.duration = .85;
        beep(620, .05);
      } else if (a.phase == 'flight') {
        a.phase = 'hit';
        a.duration = .55;
        final points = a.shots[a.turn][a.arrow];
        a.scores[a.turn].add(points);
        raceStatus = '$name · $points puan · toplam ${a.scores[a.turn].reduce((n, v) => n + v)}';
        beep(870, .1);
      } else if (a.phase == 'hit') {
        a.arrow++;
        if (a.arrow < 3) {
          a.phase = 'aim';
          a.duration = 1.5;
          if (id == state.selected) offerMove('archery', a.duration, 'Nişanı bırak!');
        } else {
          a.results.add(ArcheryResult(id, a.scores[a.turn].reduce((n, v) => n + v)));
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
    final place = 1 + results.where((r) => r.points > player.points).length;
    state.races++;
    state.xp += place == 1 ? 30 : 15;
    if (place == 1) state.wins++;
    if (place <= 3) state.medals++;
    if (state.races % 5 == 0) {
      state.chests++;
      state.skillPoints++;
    }
    state.bestArchery = max(state.bestArchery, player.points);
    recordTournament('archery', place);
    final reward = (_placeReward(place) * (1 + campusRank('stadium', 2) * .03)).round();
    state.money += reward;
    race = null;
    positionArcheryAvatars();
    archeryArrowHidden = true;
    stadiumIdle = true;
    liveTagHidden = true;
    final summary = '$place. sıra · ${player.points} puan';
    raceStatus = '$summary · +₺${fmt(reward)}';
    raceCallHidden = false;
    raceCallText = summary;
    startText = 'Tekrar Atış ▶';
    resultDelay = state.auto ? 6 : 0;
    toast('$summary · +₺${fmt(reward)}');
    save();
    update();
  }
}
