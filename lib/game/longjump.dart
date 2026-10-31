part of 'controller.dart';

// Koordinatlar ekranı değil, boş 1536×1024 arena görselini izler.
const _jumpStartX = 10.3, _jumpTakeoffX = 60.6, _jumpTrackY = 64.0, _jumpPitX = 65.5, _jumpPitWidth = 30.0, _jumpBenchY = 85.5;
const jumpColors = [0xFFFFBE13, 0xFF27BDF6, 0xFFEF6955, 0xFFBF70EF, 0xFF18B87B, 0xFFFF8B27];

({double x, double y}) jumpBench(int i) => (x: 24.0 + i * 7, y: _jumpBenchY);

/// [span]: kum havuzunun temsil ettiği metre; uzun atlayışlar havuzdan taşmasın diye büyür.
({double x, double y}) jumpLanding(double metres, int i, [double span = 10]) =>
    (x: _jumpPitX + metres / span * _jumpPitWidth, y: 52.0 + i * 5);

/// longjump.js
extension LongJumpLogic on GameController {
  void _placeJumpAvatar(int i, ({double x, double y}) p, [bool airborne = false]) {
    if (i >= runnerPos.length) return;
    runnerPos[i]
      ..x = p.x
      ..y = p.y
      ..jump = false
      ..airborne = airborne;
  }

  void positionJumpAvatars() {
    for (var i = 0; i < runnerPos.length; i++) {
      _placeJumpAvatar(i, jumpBench(i));
    }
    final r = race;
    if (r == null || r.branch != 'longjump') return;
    final j = r.jump!, i = j.turn;
    if (i >= r.ids.length) return;
    final bench = jumpBench(i), start = (x: _jumpStartX, y: _jumpTrackY);
    final land = jumpLanding(j.distances[i], i, jumpSpan), t = (j.time / j.duration).clamp(0.0, 1.0);
    var p = bench;
    if (j.phase == 'ready') p = (x: bench.x + (start.x - bench.x) * t, y: bench.y + (start.y - bench.y) * t);
    if (j.phase == 'runup') p = (x: start.x + (_jumpTakeoffX - start.x) * t, y: start.y);
    if (j.phase == 'flight') {
      p = (x: _jumpTakeoffX + (land.x - _jumpTakeoffX) * t, y: start.y + (land.y - start.y) * t - sin(t * pi) * 12);
    }
    if (j.phase == 'landed') p = land;
    if (j.phase == 'return') p = (x: land.x + (bench.x - land.x) * t, y: land.y + (bench.y - land.y) * t);
    _placeJumpAvatar(i, p, j.phase == 'flight');
  }

  /// Her yükseltme ölçülen mesafeyi etkiler; tüm yarışma başlangıç anlık görüntüsünü kullanır.
  double longJumpDistance(int id, List<int> levels, [double? noise]) {
    final n = noise ?? rand();
    final bonus = (levels[0] - 1) * .007 + (levels[1] - 1) * .009 + (levels[2] - 1) * .016 + (levels[3] - 1) * .011;
    return ((4.7 + n * 1.3) * specialty('longjump', id) * (1 + bonus) * 100).round() / 100;
  }

  UpgradeResult beginLongJump() {
    if (race != null || paused) return const UpgradeResult(false, reason: 'Yarış zaten sürüyor');
    resultDelay = 0;
    jumpCompleted = [];
    final ids = lineup(shuffle: true), levels = [...state.longJumpLevels];
    final campus = [for (var i = 0; i < 3; i++) campusRank('jump', i)];
    final trainingCard = consumeTrainingCard('longjump');
    double campusBonus(List<int> c) => 1 + c.fold(0, (n, v) => n + v) * .01;
    race = Race(
      branch: 'longjump',
      phase: 'jumping',
      ids: ids,
      playerLane: ids.indexOf(state.selected),
      jump: JumpRound(
        levels: levels,
        campus: campus,
        distances: [
          for (final id in ids)
            id == state.selected
                ? longJumpDistance(id, levels) * (campusBonus(campus) + (trainingCard ? cardBoost : 0))
                : longJumpDistance(id, rivalLevels(levels)) * campusBonus(rivalCampus(campus)),
        ],
      ),
    );
    // Kum havuzu ölçeği: en uzun atlayış (hamle payı dahil) havuzun sonuna yakın düşer; tur bitince de korunur.
    jumpSpan = max(10, race!.jump!.distances.reduce(max) * 1.08);
    runners();
    stadiumIdle = false;
    raceCallHidden = true;
    liveTagHidden = false;
    raceStatus = '${animals[ids[0]].name} başlangıç çizgisine geliyor.';
    beep(500);
    update();
    _changed();
    return const UpgradeResult(true);
  }

  void advanceLongJump(double dt) {
    final r = race!, j = r.jump!;
    r.elapsed += dt;
    j.time += dt;
    if (j.time >= j.duration) {
      j.time = 0;
      if (j.phase == 'ready') {
        j.phase = 'runup';
        j.duration = 3 / (1 + (j.levels[0] - 1) * .015 + (j.levels[1] - 1) * .01);
        if (r.ids[j.turn] != state.selected) {
          j.duration = 3;
        } else {
          offerMove('longjump', j.duration, 'Sıçra!');
        }
        raceStatus = '${animals[r.ids[j.turn]].name} yaklaşıyor · ${j.turn + 1}/6';
      } else if (j.phase == 'runup') {
        if (r.ids[j.turn] == state.selected) {
          j.distances[j.turn] *= 1 + moveQuality() * moveEffect['longjump']!;
          clearMove();
        }
        j.phase = 'flight';
        j.duration = 1.1;
        beep(750, .06);
      } else if (j.phase == 'flight') {
        j.phase = 'landed';
        j.duration = .85;
        final result = JumpResult(r.ids[j.turn], (j.distances[j.turn] * 100).round() / 100);
        j.results.add(result);
        jumpCompleted = [...j.results];
        raceStatus = '${animals[result.id].name} · ${jumpMetres(result.metres)}';
        beep(650, .06);
      } else if (j.phase == 'landed') {
        j.phase = 'return';
        j.duration = .7;
      } else if (j.phase == 'return') {
        j.turn++;
        if (j.turn == r.ids.length) {
          finishLongJump();
          return;
        }
        j.phase = 'ready';
        j.duration = .7;
        raceStatus = '${animals[r.ids[j.turn]].name} sıradaki sporcu.';
      }
    }
    positionJumpAvatars();
    updateLongJumpHUD();
  }

  void updateLongJumpHUD() {
    if (state.branch != 'longjump') return;
    final best = jumpCompleted.isEmpty ? null : jumpCompleted.map((r) => r.metres).reduce(max);
    timerText = race != null
        ? 'DENEME'
        : best != null
        ? 'EN İYİ ${jumpMetres(best)}'
        : 'DENEME';
  }

  void finishLongJump() {
    final results = [...race!.jump!.results];
    final player = results.firstWhere((r) => r.id == state.selected);
    // JS Array.sort kararlıdır; eşit mesafelerde ilk atlayan önde kalır.
    final sorted = [...results]
      ..sort((a, b) => a.metres != b.metres ? b.metres.compareTo(a.metres) : results.indexOf(a).compareTo(results.indexOf(b)));
    final place = sorted.indexWhere((r) => r.id == state.selected) + 1;
    state.races++;
    gainXp(place == 1 ? 30 : 15);
    if (place == 1) state.wins++;
    if (isMedal('longjump', place)) state.medals++;
    if (state.races % 5 == 0) {
      state.chests++;
      state.skillPoints++;
    }
    final record = player.metres > state.bestJump;
    state.bestJump = max(state.bestJump, player.metres);
    recordTournament('longjump', place);
    final reward = raceReward(place);
    state.money += reward;
    race = null;
    positionJumpAvatars();
    stadiumIdle = true;
    liveTagHidden = true;
    raceStatus = '$place. sıra · ${jumpMetres(player.metres)} · +₺${fmt(reward)}';
    raceCallHidden = false;
    raceCallText = '$place. sıra · ${jumpMetres(player.metres)}';
    startText = 'Tekrar Atla ▶';
    resultDelay = state.auto ? 6 : 0;
    presentResult(
      RaceResult(
        branch: 'longjump',
        place: place,
        total: results.length,
        value: jumpMetres(player.metres),
        reward: reward,
        xp: place == 1 ? 30 : 15,
        record: record,
      ),
      '$place. sıra · ${jumpMetres(player.metres)} · +₺${fmt(reward)}',
    );
    save();
    update();
  }

  void showJumpResult(int i) {
    if (i < 0 || i >= jumpCompleted.length) return;
    final result = jumpCompleted[i];
    toast('${animals[result.id].name} · ${jumpMetres(result.metres)}');
  }
}
