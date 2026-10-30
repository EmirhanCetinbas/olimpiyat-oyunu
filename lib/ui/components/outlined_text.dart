import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

/// Kalın konturlu karikatür yazısı: kontur ayrı katmanda çizilir, harfler bozulmaz
/// (CSS text-stroke + çok yönlü gölge yerine).
class OutlinedText extends StatelessWidget {
  const OutlinedText(
    this.text, {
    super.key,
    required this.style,
    this.strokeColor = GameColors.ink,
    this.strokeWidth = 3,
    this.shadowOffset = const Offset(0, 2),
    this.textAlign = TextAlign.center,
    this.maxLines,
    this.semanticsLabel,
  });

  final String text;

  /// Dolgu stili (renk dahil).
  final TextStyle style;
  final Color strokeColor;

  /// Harf dışına taşan kontur kalınlığı.
  final double strokeWidth;

  /// Konturun altına düşen koyu gölge (sıfırsa yok).
  final Offset shadowOffset;
  final TextAlign textAlign;
  final int? maxLines;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    TextStyle stroke(Offset offset) => TextStyle(
      fontFamily: style.fontFamily,
      fontSize: style.fontSize,
      fontWeight: style.fontWeight,
      fontVariations: style.fontVariations,
      height: style.height,
      letterSpacing: style.letterSpacing,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 2
        ..strokeJoin = StrokeJoin.round
        ..color = strokeColor,
    );
    Widget layer(TextStyle s, {Offset offset = Offset.zero}) => Transform.translate(
      offset: offset,
      child: Text(text, style: s, textAlign: textAlign, maxLines: maxLines, softWrap: maxLines != 1),
    );
    return Semantics(
      label: semanticsLabel ?? text,
      excludeSemantics: true,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (shadowOffset != Offset.zero) layer(stroke(shadowOffset), offset: shadowOffset),
          layer(stroke(Offset.zero)),
          layer(style.copyWith(shadows: const [])),
        ],
      ),
    );
  }
}
