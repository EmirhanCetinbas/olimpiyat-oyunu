import 'package:flutter/painting.dart';

/// Oyunun tekrar eden renkleri (style.css değişkenleri ve sık kullanılan değerler).
abstract final class GameColors {
  /// `--ink`: kontur ve koyu metin.
  static const ink = Color(0xFF10283B);

  /// `:root` metin rengi.
  static const text = Color(0xFF0B2437);

  /// Ayarlar paneli metin/kontur rengi.
  static const panelInk = Color(0xFF0C2034);

  /// `--cream`: pencere ve menü zemini.
  static const cream = Color(0xFFFFFCED);

  /// Görsel panellerde gömülü kontrolü örten krem.
  static const mask = Color(0xFFFFF9E9);

  /// `.green` düğme konturu.
  static const greenBorder = Color(0xFF168D25);

  /// `.modal-action` konturu.
  static const actionBorder = Color(0xFF1C7332);

  /// `.muted` metin.
  static const muted = Color(0xFF66806D);

  /// Kart açıklamaları (`small`).
  static const slate = Color(0xFF57738A);

  /// Oyun arka planı (yeşil) ve dış zemin.
  static const grass = Color(0xFF86D850);
  static const page = Color(0xFF173D35);
}
