import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../components/components.dart';

/// Mağaza: oyun içi ödüller.
class ShopPanel extends StatelessWidget {
  const ShopPanel(this.c, {super.key});
  final GameController c;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const PanelText('Oyun içi ödüller. Gerçek para ile satın alma yok.'),
      ListRow(
        children: [
          const RowTitle('Günlük ödül', small: '7 günlük ödül takvimi'),
          ActionButton('Aç', onTap: () => c.openPanel('daily-rewards')),
        ],
      ),
      ListRow(
        children: [
          const RowTitle('Sponsor paketi', small: '+₺10.000 · 5 elmas'),
          ActionButton('Al', onTap: c.buyCoins, enabled: c.state.gems >= 5),
        ],
      ),
    ],
  );
}
