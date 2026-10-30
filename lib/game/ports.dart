/// Platform bağımlılıkları için soyutlamalar (testte bellek içi / sessiz uygulanır).
library;

/// Kalıcı kayıt (localStorage karşılığı).
abstract class GameStorage {
  String? read();

  /// Yazma başarısızsa false döner.
  bool write(String value);
}

class MemoryStorage implements GameStorage {
  MemoryStorage([this.value]);
  String? value;
  @override
  String? read() => value;
  @override
  bool write(String v) {
    value = v;
    return true;
  }
}

/// Web Audio osilatörlerinin karşılığı.
abstract class GameAudio {
  bool get ready;
  void start();
  void beep(double freq, double duration, double gain);
  void note(double freq, double gain);
}
