import 'package:flutter/material.dart';

import '../components/components.dart';
import '../theme/theme.dart';

/// `.campus-marker`: tesis adı ve seviye etiketi.
class FacilityMarker extends StatelessWidget {
  const FacilityMarker({
    super.key,
    required this.label,
    required this.level,
    required this.maxWidth,
    required this.semanticLabel,
    required this.onTap,
  });

  final String label;
  final String level;
  final double maxWidth;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = vwClamp(context, 10, 2.8, 17);
    return Pressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 70, maxWidth: maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Pill(
              label,
              style: gameText(size, color: GameColors.ink),
              maxLines: 1,
              color: GameColors.row,
              borderColor: GameColors.ink,
              borderWidth: 2.5,
              radius: 12,
              shadows: const [BoxShadow(color: GameColors.cardShadow, offset: Offset(0, 2.5), blurRadius: 3)],
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            ),
            Transform.translate(
              offset: const Offset(0, -1),
              child: Pill(
                level,
                style: gameText(size * .9, color: Colors.white),
                maxLines: 1,
                color: GameColors.navy,
                borderColor: GameColors.ink,
                borderWidth: 2.5,
                radius: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
