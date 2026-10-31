part of 'controller.dart';

/// Rekor denemesi: kilo çarpanı ve başarı şansından düşülen pay.
const recordKg = 1.10, recordChancePenalty = .25;

({double x, double y}) weightBench(int i) => (x: 27.0 + i * 9, y: 81.5);

/// weights.js: sahne yalnızca dekordur; sporcular, halter ve kilogram canlı bileşenlerdir.
extension WeightsLogic on GameController {
  WeightAttempt weightAttempt(int id, List<int> levels, [double? noise, double? roll]) {
    final n = noise ?? rand(), r = roll ?? rand();
    final strength = 1 + (levels[0] - 1) * .025 + (levels[3] - 1) * .01;
    final kg = max(20, ((70 + n * 25) * strength * specialty('weights', id) / 5).round() * 5);
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
    final ids = lineup(shuffle: true), levels = [...state.weightLevels];
    final campus = [for (var i = 0; i < 3; i++) campusRank('weights', i)];
    final trainingCard = consumeTrainingCard('weights');
    race = Race(
      branch: 'weights',
      phase: 'lifting',
      ids: ids,
      playerLane: ids.indexOf(state.selected),
      weights: WeightsRound(
        levels: levels,
        campus: campus,
        attempts: [
          for (final id in ids)
            () {
              final player = id == state.selected;
              final c = player ? campus : rivalCampus(campus);
              final attempt = weightAttempt(id, player ? levels : rivalLevels(levels));
              final risk = player && state.weightRisk == 'record';
              final card = player && trainingCard ? cardBoost : 0;
              attempt.kg = (attempt.kg * (1 + c[0] * .01 + c[2] * .006 + card) * (risk ? recordKg : 1) / 5).round() * 5;
              attempt.chance = min(.98, max(.12, attempt.chance + c[1] * .009 - (risk ? recordChancePenalty : 0)));
              attempt.success = attempt.roll < attempt.chance;
              return attempt;
            }(),
        ],
      ),
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
        // Oyuncunun kaldırışında hamle için biraz daha uzun süre (imleç iki kez gidip gelir).
        w.duration = id == state.selected ? 1.6 : 1;
        if (id == state.selected) offerMove('weights', w.duration, 'Kaldır!');
      } else if (w.phase == 'push') {
        if (id == state.selected) {
          attempt.success = attempt.roll < min(.99, attempt.chance + moveQuality() * moveEffect['weights']!);
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
    // Başarısız kaldırış, başarılı olanların hepsinin ardından sayılır (herkes başarısızsa ortak 1.);
    // zafer, madalya, kupa ve sıra ödülü yine de başarılı kaldırış ister.
    final successes = results.where((r) => r.success).length;
    final place = player.success ? 1 + results.where((r) => r.success && r.kg > player.kg).length : 1 + successes;
    final won = player.success && place == 1;
    state.races++;
    gainXp(won ? 30 : 15);
    if (won) state.wins++;
    if (player.success && isMedal('weights', place)) state.medals++;
    if (state.races % 5 == 0) {
      state.chests++;
      state.skillPoints++;
    }
    final record = player.success && player.kg > state.bestWeight;
    if (player.success) state.bestWeight = max(state.bestWeight, player.kg);
    recordTournament('weights', place, success: player.success);
    final reward = raceReward(player.success ? place : results.length);
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
    presentResult(
      RaceResult(
        branch: 'weights',
        place: place,
        total: results.length,
        value: '${player.kg} KG',
        reward: reward,
        xp: won ? 30 : 15,
        record: record,
        success: player.success,
      ),
      '$summary · +₺${fmt(reward)}',
    );
    save();
    update();
  }
}
