import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

/// `.modal-stat`: eşit genişlikte değer/etiket kutuları.
class StatGrid extends StatelessWidget {
  const StatGrid(this.items, {super.key});
  final List<(String value, String label)> items;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 11),
    child: Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: GBox(
              color: const Color(0xFFE7F4D4),
              borderColor: const Color(0xFFBFD3A7),
              borderWidth: 2,
              radius: 10,
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 9),
              child: Column(
                children: [
                  Text(items[i].$1, style: gameText(20, color: GameColors.ink)),
                  Text(
                    items[i].$2,
                    textAlign: TextAlign.center,
                    style: gameText(11, color: GameColors.ink),
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
