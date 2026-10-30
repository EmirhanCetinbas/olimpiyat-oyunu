part of 'controller.dart';

({double x, double y}) weightBench(int i) => (x: 27.0 + i * 9, y: 81.5);

/// weights.js: sahne yalnızca dekordur; sporcular, halter ve kilogram canlı bileşenlerdir.
extension WeightsLogic on GameController {
  WeightAttempt weightAttempt(int id, List<int> levels, [double? noise, double? roll]) {
    final n = noise ?? rand(), r = roll ?? rand();
    final strength = 1 + (levels[0] - 1) * .025 + (levels[3] - 1) * .01;
    final kg = max(20, ((70 + n * 25) * strength * specialty('weights', id) * const [.98, 1, 1.07, .94, 1.02, 1][id] / 5).round() * 5);
    final chance = min(.98, .72 + (levels[1] - 1) * .008 + (levels[2] - 1) * .009 + (levels[3] - 1) * .003);
    return WeightAttempt(kg: kg, chance: chance, roll: r, success: r < chance);
  }

  void positionWeightAvatars() {
    for (var i = 0; i < runnerPos.length; i++) {
      final p = weightBench(i);
      runnerPos[i]
        ..x = p.x
        ..y = p.y
        ..jump = false
        ..airborne = false;
    }
    var barY = 66.0, tilt = 0.0;
    final r = race;
    if (r?.branch == 'weights') {
      final w = r!.weights!, i = w.turn, t = (w.time / w.duration).clamp(0.0, 1.0);
      final bench = weightBench(i), stage = (x: 50.0, y: 55.0);
      var p = stage;
      final success = w.attempts[i].success;
      if (w.phase == 'walk') p = (x: bench.x + (stage.x - bench.x) * t, y: bench.y + (stage.y - bench.y) * t);
      if (w.phase == 'pull') barY = 66 - 8 * t;
      if (w.phase == 'push') {
        barY = success ? 58 - 13 * t : 58 + 8 * t;
        tilt = success ? 0 : sin(t * pi) * 8;
      }
      if (w.phase == 'hold') barY = success ? 45 : 66;
      if (w.phase == 'lower') barY = success ? 45 + 21 * t : 66;
      if (w.phase == 'return') p = (x: stage.x + (bench.x - stage.x) * t, y: stage.y + (bench.y - stage.y) * t);
      if (i < runnerPos.length) {
        runnerPos[i]
          ..x = p.x
          ..y = p.y;
      }
    }
    weightBarTop = barY;
    weightBarTilt = tilt;
  }

  void renderWeightArena() {
    startText = 'Kaldırışa Başla ▶';
    raceStatus = 'Sporcular sırayla kaldırır · En yüksek başarılı kilo kazanır.';
    positionWeightAvatars();
    updateWeightHUD();
  }

  void updateWeightHUD() {
    if (state.branch != 'weights') return;
    timerText = 'DENEME';
  }

  String get weightKgText {
    final w = race?.weights;
    final player = weightCompleted.where((r) => r.id == state.selected).firstOrNull;
    return '${w != null ? w.attempts[w.turn].kg : player?.kg ?? 80} KG';
  }

  String get weightResultText {
    final w = race?.weights;
    if (w != null) {
      final current = weightCompleted.where((r) => r.id == race!.ids[w.turn]).firstOrNull;
      return current == null ? '' : (current.success ? '✓ BAŞARILI' : '✕ BAŞARISIZ');
    }
    final player = weightCompleted.where((r) => r.id == state.selected).firstOrNull;
    return player == null ? '' : (player.success ? '✓ ${player.kg} KG' : '✕ BAŞARISIZ');
  }

  bool get weightResultFailed {
    final w = race?.weights;
    final success = w != null
        ? (weightCompleted.isEmpty ? null : weightCompleted.last.success)
        : weightCompleted.where((r) => r.id == state.selected).firstOrNull?.success;
    return success != true;
  }

  UpgradeResult beginWeights() {
    if (race != null || paused) return const UpgradeResult(false, reason: 'Yarış zaten sürüyor');
    resultDelay = 0;
    weightCompleted = [];
    final ids = lineup(), levels = [...state.weightLevels];
    final campus = [for (var i = 0; i < 3; i++) campusRank('weights', i)];
    final trainingCard = consumeTrainingCard('weights');
    race = Race(
      branch: 'weights',
      phase: 'lifting',
      ids: ids,
      playerLane: ids.indexOf(state.selected),
      weights: WeightsRound(levels: levels, campus: campus, attempts: [
        for (final id in ids)
          () {
            final attempt = weightAttempt(id, id == state.selected ? levels : const [1, 1, 1, 1]);
            if (id == state.selected) {
              final risk = state.weightRisk == 'record';
              attempt.kg = (attempt.kg * (1 + campus[0] * .01 + campus[2] * .006 + (trainingCard ? .03 : 0)) * (risk ? 1.15 : 1) / 5).round() * 5;
              attempt.chance = min(.98, max(.12, attempt.chance + campus[1] * .009 - (risk ? .18 : 0)));
              attempt.success = attempt.roll < attempt.chance;
            }
            return attempt;
          }(),
      ]),
    );
    runners();
    stadiumIdle = false;
    raceCallHidden = true;
    liveTagHidden = false;
    raceStatus = '${animals[ids[0]].name} platforma geliyor.';
    update();
    _changed();
    return const UpgradeResult(true);
  }

  void advanceWeights(double dt) {
    final r = race!, w = r.weights!;
    r.elapsed += dt;
    w.time += dt;
    if (w.time >= w.duration) {
      w.time = 0;
      final id = r.ids[w.turn], a = animals[id], attempt = w.attempts[w.turn];
      if (w.phase == 'walk') {
        w.phase = 'ready';
        w.duration = .5;
        raceStatus = '${a.name} · ${attempt.kg} KG hazırlanıyor.';
      } else if (w.phase == 'ready') {
        w.phase = 'pull';
        w.duration = 1.2;
        beep(500, .05);
      } else if (w.phase == 'pull') {
        w.phase = 'push';
        w.duration = 1;
        if (id == state.selected) offerMove('weights', 1, 'Kaldır!');
      } else if (w.phase == 'push') {
        if (id == state.selected) {
          attempt.success = attempt.success || moveQuality() > .7;
          clearMove();
        }
        w.phase = 'hold';
        w.duration = .85;
        w.results.add(WeightResult(id, attempt.kg, attempt.success));
        weightCompleted = [...w.results];
        raceStatus = '${a.name} · ${attempt.kg} KG · ${attempt.success ? 'Başarılı!' : 'Kaldıramadı'}';
        beep(attempt.success ? 850 : 300, .1);
      } else if (w.phase == 'hold') {
        w.phase = 'lower';
        w.duration = .6;
      } else if (w.phase == 'lower') {
        w.phase = 'return';
        w.duration = .7;
      } else if (w.phase == 'return') {
        w.turn++;
        if (w.turn == r.ids.length) {
          finishWeights();
          return;
        }
        w.phase = 'walk';
        w.duration = .8;
        raceStatus = '${animals[r.ids[w.turn]].name} sıradaki sporcu.';
      }
    }
    positionWeightAvatars();
    updateWeightHUD();
  }

  void finishWeights() {
    final results = [...race!.weights!.results];
    final player = results.firstWhere((r) => r.id == state.selected);
    final place = player.success ? 1 + results.where((r) => r.success && r.kg > player.kg).length : results.length;
    state.races++;
    state.xp += place == 1 ? 30 : 15;
    if (player.success && place == 1) state.wins++;
    if (player.success && place <= 3) state.medals++;
    if (state.races % 5 == 0) {
      state.chests++;
      state.skillPoints++;
    }
    if (player.success) state.bestWeight = max(state.bestWeight, player.kg);
    recordTournament('weights', place);
    final reward = (_placeReward(place) * (1 + campusRank('stadium', 2) * .03)).round();
    state.money += reward;
    race = null;
    positionWeightAvatars();
    stadiumIdle = true;
    liveTagHidden = true;
    final summary = player.success ? '$place. sıra · ${player.kg} KG' : 'Kaldırış başarısız';
    raceStatus = '$summary · +₺${fmt(reward)}';
    raceCallHidden = false;
    raceCallText = summary;
    startText = 'Tekrar Kaldır ▶';
    resultDelay = state.auto ? 6 : 0;
    toast('$summary · +₺${fmt(reward)}');
    save();
    update();
  }
}
