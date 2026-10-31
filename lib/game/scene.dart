part of 'controller.dart';

/// Sporcu dizilişi, sahne yerleşimi ve branş değiştirme (renderHurdles / positionRunners).
extension SceneLogic on GameController {
  /// Sahadaki sporcular: oyuncu önde, kalan yerler diğer sporcularla dolar.
  /// [shuffle]: yarış başında rakipler rastgele seçilir (100 m'de beş rakipten üçü koşar).
  List<int> lineup({bool shuffle = false}) {
    final others = [
      for (var i = 0; i < animals.length; i++)
        if (i != state.selected) i,
    ];
    if (shuffle) others.shuffle(_random);
    return [state.selected, ...others].sublist(0, fieldSize(state.branch));
  }

  void runners() {
    runnerIds = race?.ids ?? lineup();
    runnerPos = [for (final _ in runnerIds) RunnerPos(0, 0)];
    positionRunners([for (final _ in runnerIds) 0.0]);
  }

  void positionRunners(List<double> ps) {
    if (state.branch == 'archery') return positionArcheryAvatars();
    if (state.branch == 'weights') return positionWeightAvatars();
    if (state.branch == 'longjump') return positionJumpAvatars();
    for (var i = 0; i < ps.length && i < runnerPos.length; i++) {
      final p = ps[i];
      final pos = state.branch == 'swim'
          ? (x: swimStartX + p * (swimFinishX - swimStartX), y: swimLaneY(i))
          : state.branch == 'hurdles'
          ? (x: hurdleX(p), y: hurdleLaneY(i))
          : SprintTrack.point(p, i);
      runnerPos[i]
        ..x = pos.x
        ..y = pos.y
        ..airborne = false
        ..jump = state.branch == 'hurdles' && race?.phase == 'running' && hurdleMarks.any((h) => (p - h).abs() < .018);
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
}
