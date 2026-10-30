import 'package:flutter/material.dart';

import '../../game/controller.dart';

import '../../game/data.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// `<nav class="bottom">`: beş sekmeli alt menü.
class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.rewardsTriggerKey});
  final GlobalKey rewardsTriggerKey;

  static const _items = [('inventory', 'Envanter'), ('race', 'Oyun'), ('rewards', 'Ödüller'), ('campus', 'Kampüs'), ('shop', 'Mağaza')];

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    const side = BorderSide(color: GameColors.ink, width: outlineWidth);
    return GBox(
      gradient: creamGradient,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      border: const Border(top: side, left: side, right: side),
      insets: creamInsets,
      padding: EdgeInsets.fromLTRB(3, 4, 3, bottom > 5 ? bottom : 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < _items.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            Expanded(
              child: _NavItem(
                key: i == 2 ? rewardsTriggerKey : null,
                column: i,
                label: _items[i].$2,
                selected: c.navSelected == i,
                onTap: () {
                  if (i == 2) {
                    c.selectNav(2);
                    c.rewardsMenu(!c.rewardsOpen);
                  } else {
                    c.open(_items[i].$1, navIndex: i);
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({super.key, required this.column, required this.label, required this.selected, required this.onTap});
  final int column;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    semanticLabel: label,
    onTap: onTap,
    child: Container(
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsets.only(top: 2, bottom: 3),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFFF1BF) : null,
        borderRadius: BorderRadius.circular(8),
        border: selected ? Border.all(color: const Color(0xFFE2BD48)) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Sprite(navIcon(column), width: 38, height: 38),
          const SizedBox(height: 1),
          Text(label, maxLines: 1, style: nunito(10, weight: 1000, color: const Color(0xFF173548), height: 1.1)),
        ],
      ),
    ),
  );
}
