part of 'controller.dart';

/// Sporcu dizilişi, sahne yerleşimi ve branş değiştirme (renderHurdles / positionRunners).
extension SceneLogic on GameController {
  List<int> lineup() {
    final ids = [
      state.selected,
      for (var i = 0; i < animals.length; i++)
        if (i != state.selected) i,
    ];
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
        ..jump = state.branch == 'hurdles' && race?.phase == 'running' && const [.2, .42, .64, .84].any((h) => (p - h).abs() < .018);
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
