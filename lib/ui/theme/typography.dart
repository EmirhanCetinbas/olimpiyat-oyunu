import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'colors.dart';

/// Nunito değişken fontu; CSS font-weight 1000 dahil eksen değeri doğrudan verilir.
TextStyle nunito(
  double size, {
  int weight = 900,
  Color color = GameColors.text,
  double? height,
  double? letterSpacing,
  List<Shadow>? shadows,
}) => TextStyle(
  fontFamily: 'Nunito',
  fontSize: size,
  fontWeight: FontWeight.values[(math.min(weight, 900) ~/ 100) - 1],
  fontVariations: [FontVariation('wght', weight.toDouble())],
  color: color,
  height: height,
  letterSpacing: letterSpacing,
  shadows: shadows,
);

/// Lilita One: pencere başlıkları, bölüm başlıkları, satır etiketleri ve düğme yazıları.
TextStyle display(double size, {Color color = GameColors.text, double? height = 1.1, double? letterSpacing = .2, List<Shadow>? shadows}) =>
    TextStyle(fontFamily: 'LilitaOne', fontSize: size, color: color, height: height, letterSpacing: letterSpacing, shadows: shadows);

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
