import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Önerilen en küçük dokunma alanı (Apple HIG 44pt).
const minTapTarget = 44.0;

/// Oyun sütununun en geniş hali (tablette ortalanır).
const maxGameWidth = 500.0;

/// Ekran sınıfları ve mobil yerleşim ölçüleri; tüm ekranlar buradan okur.
class ScreenMetrics {
  ScreenMetrics.of(BuildContext context)
    : size = MediaQuery.sizeOf(context),
      padding = MediaQuery.paddingOf(context),
      viewInsets = MediaQuery.viewInsetsOf(context);

  final Size size;
  final EdgeInsets padding;
  final EdgeInsets viewInsets;

  /// Dar telefonlar (iPhone SE / küçük Android): ≤360pt.
  bool get compact => size.width <= 360;

  /// Kısa ekranlar: ≤690pt yükseklik.
  bool get short => size.height <= 690;

  double get gameWidth => math.min(size.width, maxGameWidth);

  /// Pencere genişliği: tercih edilen değer, ama her iki yanda en az 19pt boşluk kalır.
  double dialogWidth(double preferred) => math.min(preferred, size.width - 38);

  /// Pencere en fazla yüksekliği: güvenli alan ve klavye dışında kalan alan eksi 38pt.
  double dialogMaxHeight([double fraction = 1]) =>
      math.min(size.height * fraction, size.height - 38) - padding.vertical - viewInsets.bottom;

  /// Alt menünün toplam yüksekliği (ikon + etiket + güvenli alan).
  double get bottomNavHeight => (compact ? 51 : 54) + 4 + 2.4 + math.max(5, padding.bottom);
}
