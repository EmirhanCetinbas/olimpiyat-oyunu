import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

const ink = Color(0xFF10283B);
const textInk = Color(0xFF0B2437);
const outlineWidth = 2.4;

/// Nunito değişken fontu; CSS font-weight 1000 dahil eksen değeri doğrudan verilir.
TextStyle nunito(
  double size, {
  int weight = 900,
  Color color = textInk,
  double? height,
  double? letterSpacing,
  List<Shadow>? shadows,
}) =>
    TextStyle(
      fontFamily: 'Nunito',
      fontSize: size,
      fontWeight: FontWeight.values[(math.min(weight, 900) ~/ 100) - 1],
      fontVariations: [FontVariation('wght', weight.toDouble())],
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      shadows: shadows,
    );

/// text-stroke / çok yönlü text-shadow karşılığı.
List<Shadow> outlineShadows(Color color, double w, {Offset extra = Offset.zero}) => [
      for (final o in const [
        Offset(-1, -1), Offset(0, -1), Offset(1, -1), Offset(1, 0),
        Offset(1, 1), Offset(0, 1), Offset(-1, 1), Offset(-1, 0),
      ])
        Shadow(color: color, offset: o * w),
      if (extra != Offset.zero) Shadow(color: color, offset: extra),
    ];

/// CSS `vw` tabanlı clamp(min, n vw, max).
double vwClamp(BuildContext context, double min, double vw, double max) =>
    (MediaQuery.sizeOf(context).width * vw / 100).clamp(min, max);

/// İç gölge (CSS `inset X Y 0 spread color`, bulanıklıksız).
class Inset {
  const Inset(this.color, {this.dx = 0, this.dy = 0, this.spread = 0});
  final Color color;
  final double dx;
  final double dy;
  final double spread;
}

class _InsetPainter extends CustomPainter {
  _InsetPainter(this.insets, this.radius);
  final List<Inset> insets;
  final BorderRadius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = radius.toRRect(Offset.zero & size);
    canvas.save();
    canvas.clipRRect(outer);
    for (final inset in insets) {
      final inner = radius
          .toRRect(Offset.zero & size)
          .shift(Offset(inset.dx, inset.dy))
          .deflate(inset.spread);
      final path = Path()
        ..fillType = PathFillType.evenOdd
        ..addRRect(outer)
        ..addRRect(inner);
      canvas.drawPath(path, Paint()..color = inset.color);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_InsetPainter old) => old.insets != insets || old.radius != radius;
}

/// Kenarlık, degrade, dış ve iç gölgeleri olan CSS kutusu.
class GBox extends StatelessWidget {
  const GBox({
    super.key,
    this.color,
    this.gradient,
    this.radius = 0,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 0,
    this.border,
    this.shadows = const [],
    this.insets = const [],
    this.padding = EdgeInsets.zero,
    this.width,
    this.height,
    this.constraints,
    this.alignment,
    this.child,
  });

  final Color? color;
  final Gradient? gradient;
  final double radius;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final BoxBorder? border;
  final List<BoxShadow> shadows;
  final List<Inset> insets;
  final EdgeInsets padding;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final r = borderRadius ?? BorderRadius.circular(radius);
    Radius shrink(Radius x) => Radius.circular(math.max(0, x.x - borderWidth));
    final inner = BorderRadius.only(
      topLeft: shrink(r.topLeft),
      topRight: shrink(r.topRight),
      bottomLeft: shrink(r.bottomLeft),
      bottomRight: shrink(r.bottomRight),
    );
    Widget content = Padding(padding: padding, child: alignment != null ? Align(alignment: alignment!, child: child) : child);
    if (insets.isNotEmpty) content = CustomPaint(painter: _InsetPainter(insets, inner), child: content);
    return Container(
      width: width,
      height: height,
      constraints: constraints,
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: r,
        border: border ??
            (borderColor != null && borderWidth > 0 ? Border.all(color: borderColor!, width: borderWidth) : null),
        boxShadow: shadows,
      ),
      child: content,
    );
  }
}

LinearGradient vGradient(List<Color> colors, [List<double>? stops]) =>
    LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors, stops: stops);

/// CSS açılı degrade (ör. 110deg).
LinearGradient angleGradient(double deg, List<Color> colors, [List<double>? stops]) {
  final rad = deg * math.pi / 180;
  final dx = math.sin(rad), dy = -math.cos(rad);
  return LinearGradient(begin: Alignment(-dx, -dy), end: Alignment(dx, dy), colors: colors, stops: stops);
}

// ---- Ortak kutu stilleri ----
const creamGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFFFFEF6), Color(0xFFFFFBE6)],
);
const creamShadows = [BoxShadow(color: Color(0x4518362A), offset: Offset(0, 2))];
const creamInsets = [Inset(Colors.white, dy: 1)];

const greenGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF51EF2F), Color(0xFF08B50D)],
);
const blueGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF3597FF), Color(0xFF1460EB)],
);
const buttonInsets = [Inset(Color(0x63FFFFFF), dy: 2)];
const buttonShadows = [BoxShadow(color: Color(0x66123B42), offset: Offset(0, 2))];
const whiteTextShadow = [Shadow(color: Color(0x33000000), offset: Offset(0, 1))];

/// `button:disabled{filter:saturate(.35);opacity:.7}`
Widget disabledLook(Widget child, {double saturation = .35, double opacity = .7}) {
  final s = saturation;
  const lr = .2126, lg = .7152, lb = .0722;
  final matrix = <double>[
    lr + (1 - lr) * s, lg - lg * s, lb - lb * s, 0, 0, //
    lr - lr * s, lg + (1 - lg) * s, lb - lb * s, 0, 0,
    lr - lr * s, lg - lg * s, lb + (1 - lb) * s, 0, 0,
    0, 0, 0, 1, 0,
  ];
  return Opacity(opacity: opacity, child: ColorFiltered(colorFilter: ColorFilter.matrix(matrix), child: child));
}

/// Gri tonlama filtresi (`grayscale(x)`).
Widget grayscaleLook(Widget child, double amount, {double opacity = 1}) =>
    disabledLook(child, saturation: 1 - amount, opacity: opacity);

/// Bulanık arka plan katmanı.
Widget blurLayer(double sigma, Color color) => ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: ColoredBox(color: color),
      ),
    );
