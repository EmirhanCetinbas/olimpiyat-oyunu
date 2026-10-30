import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'colors.dart';

const outlineWidth = 2.4;

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
      final inner = outer.shift(Offset(inset.dx, inset.dy)).deflate(inset.spread);
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
    Widget content = Padding(
      padding: padding,
      child: alignment != null ? Align(alignment: alignment!, child: child) : child,
    );
    if (insets.isNotEmpty) content = CustomPaint(painter: _InsetPainter(insets, inner), child: content);
    return Container(
      width: width,
      height: height,
      constraints: constraints,
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: r,
        border: border ?? (borderColor != null && borderWidth > 0 ? Border.all(color: borderColor!, width: borderWidth) : null),
        boxShadow: shadows,
      ),
      child: content,
    );
  }
}

/// Dikey CSS degradesi (`linear-gradient(a,b)`).
LinearGradient vGradient(List<Color> colors, [List<double>? stops]) =>
    LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors, stops: stops);

/// CSS açılı degrade (ör. 110deg).
LinearGradient angleGradient(double deg, List<Color> colors, [List<double>? stops]) {
  final rad = deg * math.pi / 180;
  final dx = math.sin(rad), dy = -math.cos(rad);
  return LinearGradient(begin: Alignment(-dx, -dy), end: Alignment(dx, dy), colors: colors, stops: stops);
}

/// `--outline` konturlu standart kutu kenarı.
const inkBorderColor = GameColors.ink;
