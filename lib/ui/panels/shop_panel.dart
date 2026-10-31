import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/data.dart';
import '../../game/format.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// Mağaza: oyun içi teklif kartları (gerçek parayla satın alma yok).
class ShopPanel extends StatelessWidget {
  const ShopPanel(this.c, {super.key});
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final dailyReady = !c.dayClaimed, gems = c.state.gems;
    Widget price(String key, VoidCallback onTap) =>
        RaisedButton('${shopPrices[key]} elmas', onTap: onTap, enabled: gems >= shopPrices[key]!, width: double.infinity, height: 40);
    Widget pair(Widget a, Widget b) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: a),
          const SizedBox(width: 9),
          Expanded(child: b),
        ],
      ),
    );
    return Column(
      children: [
        pair(
          _Offer(
            title: 'Günlük ödül',
            art: const RewardIcon('calendar', size: 64),
            detail: dailyReady ? 'Bugünün ödülü hazır' : 'Yarın yeni ödül',
            highlight: dailyReady,
            button: RaisedButton(dailyReady ? 'Al' : 'Gör', onTap: () => c.openPanel('daily-rewards'), width: double.infinity, height: 40),
          ),
          _Offer(
            title: 'Sponsor paketi',
            art: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RewardIcon('gem', size: 34),
                Icon(Icons.arrow_forward_rounded, color: GameColors.slate),
                RewardIcon('money', size: 44),
              ],
            ),
            // 10 dakikalık pasif gelir: ilerledikçe değeri korunur.
            detail: '₺${fmt(c.sponsorAmount)} · 10 dk gelir',
            button: price('coins', c.buyCoins),
          ),
        ),
        const SizedBox(height: 9),
        pair(
          _Offer(
            title: 'Spor Çantası',
            art: const RewardKindIcon('chest', size: 60),
            detail: '3 seçenekten birini al',
            button: price('chest', c.buyChest),
          ),
          _Offer(
            title: 'Antrenman kartı',
            art: const RewardKindIcon('card', size: 60),
            detail: '${branchLabel(c.state.branch)}\nbir yarışlık +%${trNumber(cardBoost * 100)}',
            button: price('card', c.buyTrainingCard),
          ),
        ),
        const SizedBox(height: 10),
        const PanelText.muted('Oyun içi ödüller. Gerçek para ile satın alma yok.', align: TextAlign.center),
      ],
    );
  }
}

class _Offer extends StatelessWidget {
  const _Offer({required this.title, required this.art, required this.detail, required this.button, this.highlight = false});
  final String title;
  final Widget art;
  final String detail;
  final Widget button;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(8, 10, 8, 9),
    decoration: flatCardDecoration(radius: 18, color: highlight ? const Color(0xFFF0FBE6) : GameColors.row),
    child: Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: gameText(16.5, color: GameColors.ink, height: 1.1),
        ),
        const SizedBox(height: 8),
        SizedBox(height: 66, child: Center(child: art)),
        const SizedBox(height: 6),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: gameText(13, color: GameColors.slate, height: 1.2),
        ),
        const Spacer(),
        const SizedBox(height: 8),
        button,
      ],
    ),
  );
}
