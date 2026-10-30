import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_soloud/flutter_soloud.dart';

import 'controller.dart';

/// Web Audio osilatör seslerinin karşılığı: tonlar bellekte WAV olarak üretilir.
class SoloudAudio implements GameAudio {
  static const _rate = 44100;
  final _sounds = <String, AudioSource>{};
  final _loading = <String>{};
  bool _starting = false;
  bool _ready = false;

  @override
  bool get ready => _ready;

  @override
  void start() {
    if (_ready || _starting) return;
    _starting = true;
    SoLoud.instance.init().then((_) => _ready = true).catchError((_) => _starting = false);
  }

  /// Sinüs bip: kazanç `gain`den 0.001'e üstel düşer (exponentialRampToValueAtTime).
  @override
  void beep(double freq, double duration, double gain) {
    start();
    if (!_ready) return;
    final f = (freq / 10).round() * 10.0;
    final key = 'beep-$f-${(duration * 1000).round()}';
    _play(key, gain, () => _wav(duration, (t) => sin(2 * pi * f * t) * pow(.001 / .025, t / duration)));
  }

  /// Üçgen dalga müzik notası: .03 sn'de tepeye çıkar, .4 sn'de söner, .45 sn'de durur.
  @override
  void note(double freq, double gain) {
    if (!_ready) return;
    final key = 'note-$freq';
    _play(key, gain, () {
      const floor = .0001 / .016;
      return _wav(.45, (t) {
        final env = t < .03 ? pow(floor, 1 - t / .03) : (t < .4 ? pow(floor, (t - .03) / .37) : floor);
        final phase = (t * freq) % 1;
        final triangle = 4 * (phase < .5 ? phase : 1 - phase) - 1;
        return triangle * env;
      });
    });
  }

  void _play(String key, double gain, Uint8List Function() build) {
    final sound = _sounds[key];
    if (sound != null) {
      SoLoud.instance.play(sound, volume: gain);
      return;
    }
    if (_loading.contains(key)) return;
    _loading.add(key);
    SoLoud.instance
        .loadMem('$key.wav', build())
        .then((source) {
          _sounds[key] = source;
          _loading.remove(key);
          SoLoud.instance.play(source, volume: gain);
        })
        .catchError((_) {
          _loading.remove(key);
        });
  }

  static Uint8List _wav(double seconds, double Function(double t) sample) {
    final count = (seconds * _rate).round();
    final data = ByteData(44 + count * 2);
    void str(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        data.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    str(0, 'RIFF');
    data.setUint32(4, 36 + count * 2, Endian.little);
    str(8, 'WAVE');
    str(12, 'fmt ');
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little);
    data.setUint16(22, 1, Endian.little);
    data.setUint32(24, _rate, Endian.little);
    data.setUint32(28, _rate * 2, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    str(36, 'data');
    data.setUint32(40, count * 2, Endian.little);
    for (var i = 0; i < count; i++) {
      final v = sample(i / _rate).clamp(-1.0, 1.0);
      data.setInt16(44 + i * 2, (v * 32767).round(), Endian.little);
    }
    return data.buffer.asUint8List();
  }
}
