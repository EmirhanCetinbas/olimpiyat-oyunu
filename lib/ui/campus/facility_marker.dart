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
              style: nunito(size, weight: 1000, color: GameColors.text),
              maxLines: 1,
              gradient: vGradient(const [Color(0xFFFFFEFA), Color(0xFFFFEBC7)]),
              borderColor: const Color(0xFF14334A),
              borderWidth: 2,
              radius: 11,
              shadows: const [BoxShadow(color: Color(0xFFB9A67C), offset: Offset(0, 2))],
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            ),
            Transform.translate(
              offset: const Offset(0, -1),
              child: Pill(
                level,
                style: nunito(size * .9, weight: 1000, color: Colors.white),
                maxLines: 1,
                color: const Color(0xFF0D304D),
                borderColor: const Color(0xFF132C3F),
                borderWidth: 2,
                radius: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
