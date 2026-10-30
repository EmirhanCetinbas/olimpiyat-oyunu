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

  // ---- Ortak pencere dili (kabarık yüzeyler ve düz kartlar) ----

  /// Pencere kâğıdı ve satır kartı zemini.
  static const paper = Color(0xFFFFF8E4);
  static const row = Color(0xFFFFFBED);

  /// Kart altı yumuşak gölge ve pencere gölgesi.
  static const cardShadow = Color(0x22082436);
  static const panelShadow = Color(0x33082436);

  /// Kırmızı başlık plakası ve gölgesi.
  static const coral = Color(0xFFFF5F50);
  static const coralShade = Color(0xFFB8322A);

  /// Yeşil kontroller (açık anahtar, kaydırıcı dolgusu, onay).
  static const green = Color(0xFF43D82E);
  static const greenShade = Color(0xFF087520);

  /// Kapalı / kilitli kontroller.
  static const locked = Color(0xFFA9B6BD);
  static const lockedShade = Color(0xFF5C6B74);

  /// Krem ikincil düğmeler.
  static const creamShade = Color(0xFFB69B65);

  /// Kaydırıcı boş çubuğu.
  static const track = Color(0xFFCCD7DD);

  /// Parıltı sarısı (başlık ışınları).
  static const sparkle = Color(0xFFFFCB2E);

  /// Mavi kabarık düğme (2x gelir).
  static const blue = Color(0xFF2F8BFF);
  static const blueShade = Color(0xFF0E3F9E);

  /// Lacivert kabarık düğme (branş seçici).
  static const navy = Color(0xFF1F3A57);
  static const navyShade = Color(0xFF06121F);

  /// Alt menüde seçili sekme zemini.
  static const highlight = Color(0xFFFFE7A0);

  /// Geri alınamaz eylem (sıfırla).
  static const danger = Color(0xFFF2554B);
  static const dangerShade = Color(0xFF8E1F18);
}
