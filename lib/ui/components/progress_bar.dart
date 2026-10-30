import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Yuvarlak uçlu ilerleme çubuğu (XP, başarımlar).
class GameProgressBar extends StatelessWidget {
  const GameProgressBar({
    super.key,
    required this.value,
    this.label,
    this.height,
    this.trackColor = const Color(0xFFDCE2EB),
    this.borderColor = const Color(0xFF9CAAC0),
    this.borderWidth = 1,
    this.radius = 20,
    this.fill = const [Color(0xFF69FC6D), Color(0xFF06C622)],
    this.fillInsets = const [Inset(Color(0xFFC8FFB8), dy: 2)],
    this.animate = false,
  });

  /// XP çubuğu (`.xp`).
  const GameProgressBar.xp({super.key, required this.value})
    : label = null,
      height = 8,
      trackColor = const Color(0xFFD4DCE3),
      borderColor = const Color(0xFF7A9498),
      borderWidth = 1.5,
      radius = 8,
      fill = const [Color(0xFF73F344), Color(0xFF12B422)],
      fillInsets = const [],
      animate = true;

  final double value;
  final String? label;
  final double? height;
  final Color trackColor;
  final Color borderColor;
  final double borderWidth;
  final double radius;
  final List<Color> fill;
  final List<Inset> fillInsets;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final factor = value.clamp(0.0, 1.0);
    final bar = GBox(gradient: vGradient(fill), radius: radius, insets: fillInsets);
    return Semantics(
      label: label,
      value: '${(factor * 100).round()}%',
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: trackColor,
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Align(
            alignment: Alignment.centerLeft,
            child: animate
                ? AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 500),
                    widthFactor: factor,
                    heightFactor: 1,
                    child: bar,
                  )
                : FractionallySizedBox(widthFactor: factor, heightFactor: 1, child: bar),
          ),
        ),
      ),
    );
  }
}
