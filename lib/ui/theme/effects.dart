import 'dart:ui';

import 'package:flutter/widgets.dart';

/// `filter:saturate(s); opacity:o` (ör. `button:disabled`).
Widget saturated(Widget child, {double saturation = .35, double opacity = .7}) {
  final s = saturation;
  const lr = .2126, lg = .7152, lb = .0722;
  final matrix = <double>[
    lr + (1 - lr) * s, lg - lg * s, lb - lb * s, 0, 0, //
    lr - lr * s, lg + (1 - lg) * s, lb - lb * s, 0, 0,
    lr - lr * s, lg - lg * s, lb + (1 - lb) * s, 0, 0,
    0, 0, 0, 1, 0,
  ];
  return Opacity(
    opacity: opacity,
    child: ColorFiltered(colorFilter: ColorFilter.matrix(matrix), child: child),
  );
}

/// `backdrop-filter: blur()` + yarı saydam renk katmanı.
Widget blurLayer(double sigma, Color color) => ClipRect(
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
    child: ColoredBox(color: color),
  ),
);
