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
    const side = BorderSide(color: GameColors.ink, width: 2.7);
    return Container(
      decoration: const BoxDecoration(
        color: GameColors.paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: side, left: side, right: side),
        boxShadow: [BoxShadow(color: GameColors.panelShadow, offset: Offset(0, -2), blurRadius: 6)],
      ),
      padding: EdgeInsets.fromLTRB(4, 5, 4, bottom > 5 ? bottom : 5),
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
                badge: switch (i) {
                  0 => c.inventoryBadge,
                  2 => c.rewardsBadge,
                  3 => c.campusBadge,
                  _ => false,
                },
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
  const _NavItem({super.key, required this.column, required this.label, required this.selected, required this.onTap, this.badge = false});

  /// Alınabilir bir şey var: ikonun sağ üstünde kırmızı nokta.
  final bool badge;
  final int column;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compact = ScreenMetrics.of(context).compact;
    return Pressable(
      semanticLabel: badge ? '$label, yeni' : label,
      onTap: onTap,
      // Seçili sekme kabarık sarı karo üstünde durur.
      child: _SelectedTile(
        selected: selected,
        child: Container(
          constraints: BoxConstraints(minHeight: compact ? 51 : 54),
          padding: const EdgeInsets.only(top: 2, bottom: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Sprite(navIcon(column), width: compact ? 33 : 38, height: compact ? 33 : 38),
                  if (badge) const Positioned(right: -4, top: -2, child: NotificationDot()),
                ],
              ),
              const SizedBox(height: 1),
              Text(label, maxLines: 1, style: gameText(11.5, color: GameColors.ink, height: 1.1)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedTile extends StatelessWidget {
  const _SelectedTile({required this.selected, required this.child});
  final bool selected;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      selected ? RaisedSurface(color: GameColors.highlight, shade: GameColors.creamShade, radius: 14, glossy: false, child: child) : child;
}
