import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

/// Kenarlıklı küçük etiket (CANLI, KG, puan, seviye, kampüs etiketleri, toast).
class Pill extends StatelessWidget {
  const Pill(
    this.text, {
    super.key,
    required this.style,
    this.color,
    this.gradient,
    this.borderColor,
    this.borderWidth = 0,
    this.radius = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    this.shadows = const [],
    this.insets = const [],
    this.textAlign,
    this.maxLines,
  });

  final String text;
  final TextStyle style;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final double borderWidth;
  final double radius;
  final EdgeInsets padding;
  final List<BoxShadow> shadows;
  final List<Inset> insets;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) => GBox(
    color: color,
    gradient: gradient,
    borderColor: borderColor,
    borderWidth: borderWidth,
    radius: radius,
    padding: padding,
    shadows: shadows,
    insets: insets,
    child: Text(text, style: style, textAlign: textAlign, maxLines: maxLines, softWrap: maxLines == null),
  );
}
