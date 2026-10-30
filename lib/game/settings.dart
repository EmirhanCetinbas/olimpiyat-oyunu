part of 'controller.dart';

/// Ayarlar, takım adı ve ilerleme sıfırlama.
extension SettingsLogic on GameController {
  void saveName(String value) {
    final trimmed = value.trim();
    state.name = trimmed.isEmpty ? 'Pati Takımı' : (trimmed.length > 24 ? trimmed.substring(0, 24) : trimmed);
    save();
    toast('Takım adı kaydedildi.');
  }

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
}
