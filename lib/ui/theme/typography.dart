import 'package:flutter/widgets.dart';

import 'colors.dart';

/// Oyunun tek yazı ailesi: Baloo 2 ExtraBold. Türkçe harflerin (Ğ, İ, Ş) hepsi aynı fontta çizilir;
/// başka fonttan yedek harf aynı kelimeye karışmaz (duck-gacha kararı).
const gameFontFamily = 'Baloo2';
const gameFontFallback = ['Arial'];

/// Yazı ölçeği (duck-gacha tasarım dili): yeni ekranlar bu değerlerden seçer.
abstract final class TextSizes {
  /// Pencere / ekran başlığı (başlık plakası).
  static const title = 33.0;

  /// Bölüm başlığı (SES, OYUN…).
  static const section = 23.0;

  /// Kart / satır başlığı.
  static const cardTitle = 18.0;

  /// Gövde metni.
  static const body = 14.5;

  /// Sayaç (para, elmas).
  static const counter = 21.0;

  /// En küçük etiket; bunun altına inilmez.
  static const min = 11.0;
}

/// Oyun yazısı. Tek ağırlık (800) vardır; vurgu boyut ve renkle verilir.
TextStyle gameText(double size, {Color color = GameColors.text, double? height, double? letterSpacing, List<Shadow>? shadows}) => TextStyle(
  fontFamily: gameFontFamily,
  fontFamilyFallback: gameFontFallback,
  fontSize: size,
  fontWeight: FontWeight.w800,
  color: color,
  height: height,
  letterSpacing: letterSpacing,
  shadows: shadows,
);

/// Konturlu etiketin kontur kalınlığı (harf dışına taşan kısım): büyük başlıkta 2.2, küçükte boyuta göre.
double outlineFor(double size) => (size >= 30 ? 4.4 : size * .17 + .8) / 2;

/// text-stroke / çok yönlü text-shadow karşılığı.
List<Shadow> outlineShadows(Color color, double w, {Offset extra = Offset.zero}) => [
  for (final o in const [
    Offset(-1, -1),
    Offset(0, -1),
    Offset(1, -1),
    Offset(1, 0),
    Offset(1, 1),
    Offset(0, 1),
    Offset(-1, 1),
    Offset(-1, 0),
  ])
    Shadow(color: color, offset: o * w),
  if (extra != Offset.zero) Shadow(color: color, offset: extra),
];

/// Beyaz düğme metni gölgesi (`text-shadow:0 1px #0003`).
const whiteTextShadow = [Shadow(color: Color(0x33000000), offset: Offset(0, 1))];

/// CSS `vw` tabanlı clamp(min, n vw, max).
double vwClamp(BuildContext context, double min, double vw, double max) => (MediaQuery.sizeOf(context).width * vw / 100).clamp(min, max);

/// Türkçe büyük harf (i → İ, ı → I); başlık plakaları için.
String trUpper(String text) => text.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
