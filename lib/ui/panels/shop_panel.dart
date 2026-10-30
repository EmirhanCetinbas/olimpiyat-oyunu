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
          const RewardIcon('calendar', size: 40),
          const RowTitle('Günlük ödül', small: '7 günlük ödül takvimi'),
          ActionButton('Aç', onTap: () => c.openPanel('daily-rewards')),
        ],
      ),
      ListRow(
        children: [
          const RewardIcon('money', size: 40),
          const RowTitle('Sponsor paketi', small: '5 elmas karşılığında +₺10.000'),
          ActionButton('Al', onTap: c.buyCoins, enabled: c.state.gems >= 5),
        ],
      ),
    ],
  );
}
