import 'package:flutter/widgets.dart';

import '../theme/theme.dart';
import 'raised_surface.dart';

/// Eşit genişlikte değer/etiket kartları (seviye, yarış, zafer…).
class StatGrid extends StatelessWidget {
  const StatGrid(this.items, {super.key});
  final List<(String value, String label)> items;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: flatCardDecoration(radius: 15),
              child: Column(
                children: [
                  Text(items[i].$1, style: gameText(TextSizes.counter, color: GameColors.ink, height: 1.15)),
                  Text(
                    items[i].$2,
                    textAlign: TextAlign.center,
                    style: gameText(12, color: GameColors.slate, height: 1.1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
