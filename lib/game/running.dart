part of 'controller.dart';

/// 100 metre, engelli koşu ve yüzme: başlatma, hız modeli ve bitiş.
extension RunningLogic on GameController {
  UpgradeResult beginRace() {
    if (state.branch == 'archery') return beginArchery();
    if (state.branch == 'weights') return beginWeights();
    if (state.branch == 'longjump') return beginLongJump();
    if (race != null || paused) return const UpgradeResult(false, reason: 'Yarış zaten sürüyor');
    resultDelay = 0;
    const base = 9.3;
    final ids = lineup(shuffle: true), n = ids.length, b = state.branch;
    race = Race(
      branch: b,
      phase: 'countdown',
      countdown: 3,
      progress: List.filled(n, 0),
      times: List.filled(n, null),
      ids: ids,
      playerLane: ids.indexOf(state.selected),
      speeds: [for (final id in ids) base * specialty(b, id) * raceForm()],
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
    if (b == 'sprint') offerMove('sprint', 3.4, 'Çıkış yap!');
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
    gainXp(place == 1 ? 30 : 15);
    if (state.races % 5 == 0) {
      state.chests++;
      state.skillPoints++;
    }
    if (place == 1) state.wins++;
    if (isMedal(state.branch, place)) state.medals++;
    recordTournament(state.branch, place);
    // 100 m rekoru (state.best orijinalde koşu branşlarının ortak süresi; rekor yalnız 100 m'de anlamlı).
    final record = state.branch == 'sprint' && (state.best == null || time < state.best!);
    state.best = state.best == null ? time : min(state.best!, time);
    final total = r.ids.length;
    final reward = raceReward(place);
    state.money += reward;
    clearMove();
    race = null;
    stadiumIdle = true;
    liveTagHidden = true;
    final stopwatchBranch = state.branch == 'hurdles' || state.branch == 'swim';
    timerText = stopwatchBranch ? stopwatch(time) : '${time.toStringAsFixed(2)} sn';
    raceStatus = '$place. oldun · +₺${fmt(reward)} · ${time.toStringAsFixed(2)} sn';
    presentResult(
      RaceResult(
        branch: state.branch,
        place: place,
        total: total,
        value: '${time.toStringAsFixed(2)} sn',
        reward: reward,
        xp: place == 1 ? 30 : 15,
        record: record,
      ),
      '${place == 1
          ? '🏆 Zafer!'
          : isMedal(state.branch, place)
          ? '🏅 Madalya!'
          : '🏁 Yarış bitti'} $place. sıra · +₺${fmt(reward)}',
    );
    beep(place == 1 ? 960 : 540, .18);
    resultDelay = state.auto ? 4 : 0;
    raceCallHidden = false;
    raceCallText = state.auto ? 'Yeni yarış 4 saniye içinde' : '$place. sıra · ${time.toStringAsFixed(2)} sn';
    startText = 'Yeniden Yarış ▶';
    save();
    update();
  }

  /// Yarış ödülü, bütün branşlarda aynı: sıra ödülü × branş gücü (rakipler oyuncunun
  /// düzeyinde yarıştığı için gelişmiş takım daha güçlü rakipleri yener) × kampüs sponsorluğu.
  int raceReward(int place) => (_placeReward(place) * power / 100 * (1 + campusRank('stadium', 2) * .03)).round();

  int _placeReward(int place) => place == 1
      ? 1250
      : place == 2
      ? 850
      : place == 3
      ? 650
      : 400;

  /// Yükseltme, kampüs ve ekipman etkisi her kulvarda aynı formülle; rakipler
  /// kendi düzeylerini [rivalLevels] / [rivalCampus] ile alır.
  double _advanceRunner(Race r, int i, double p, double dt) {
    if (p >= 1) return 1;
    var speed = r.speeds[i];
    final player = i == r.playerLane;
    final campus = player ? r.campus : rivalCampus(r.campus);
    final stars = r.equipmentStars, shoe = stars[0] + r.equipmentLegacy;
    // Çıkış hamlesi yalnızca çıkış bölümünü (ilk 25 m) hızlandırır; diğer hamleler yarışın kalanını.
    final move = state.branch == 'sprint' && p >= .25 ? 0 : r.manualBonus;
    if (player) speed *= 1 + move + (r.trainingCard ? cardBoost : 0);
    if (state.branch == 'hurdles') {
      final h = player ? r.hurdleLevels : rivalLevels(r.hurdleLevels);
      final nearHurdle = hurdleMarks.any((x) => (p - x).abs() < .023);
      if (nearHurdle) speed *= min(.96, .55 + (h[0] - 1) * .025) * (1 + campus[0] * .025);
      speed *= 1 + campus[1] * .01 + (h[1] - 1) * .01 + shoe * .02;
      if (p > .5) speed *= 1 + (h[2] - 1) * .012;
      if (p > .84) speed *= 1 + campus[2] * .01 + (h[3] - 1) * .02;
    } else if (state.branch == 'swim') {
      final l = player ? r.swimLevels : rivalLevels(r.swimLevels);
      speed *= 1 + campus[1] * .01 + (l[1] - 1) * .012;
      if (p < .25) speed *= 1 + campus[0] * .01 + (l[0] - 1) * .02;
      if (p > .5) speed *= 1 + campus[2] * .01 + (l[2] - 1) * .015;
      if (p > .75) speed *= 1 + (l[3] - 1) * .017;
      speed *= 1 + shoe * .012;
    } else {
      final l = player ? r.levels : rivalLevels(r.levels);
      speed *= 1 + campus[1] * .01;
      if (p < .25) speed *= 1 + campus[0] * .01;
      if (p > .8) speed *= 1 + campus[2] * .01;
      speed *= 1 + (l[1] - 1) * .01 + shoe * .03;
      if (p < .25) speed *= (1 + (l[0] - 1) * .02) * (1 + stars[1] * .04);
      if (p > .5) speed *= (1 + (l[2] - 1) * .015) * (1 + stars[2] * .025);
      if (p > .8) speed *= (1 + (l[3] - 1) * .02) * (1 + stars[3] * .04);
    }
    final next = p + speed * dt / 100;
    if (next >= 1) r.times[i] = r.elapsed;
    return min(1, next);
  }
}
