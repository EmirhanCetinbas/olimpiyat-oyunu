import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/format.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// Uzun aradan dönüş: sen yokken toplanan gelir, süre ve topla düğmesi.
class WelcomePanel extends StatelessWidget {
  const WelcomePanel(this.c, this.earnings, {super.key});
  final GameController c;
  final OfflineEarnings earnings;

  String get _away {
    final minutes = (earnings.seconds / 60).floor(), hours = minutes ~/ 60;
    if (hours == 0) return '$minutes dakika';
    return minutes % 60 == 0 ? '$hours saat' : '$hours saat ${minutes % 60} dakika';
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      // Para yığını yaylanarak gelir.
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 650),
        curve: Curves.elasticOut,
        builder: (context, t, child) => Transform.scale(scale: .4 + .6 * t, child: child),
        child: const RewardIcon('money', size: 92),
      ),
      const SizedBox(height: 8),
      PanelText('Sen yokken takımın $_away boyunca gelir topladı.', align: TextAlign.center, bottom: 10),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: flatCardDecoration(radius: 16, color: const Color(0xFFF0FBE6)),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: earnings.money.toDouble()),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Text('+₺${fmt(v)}', style: gameText(30, color: GameColors.greenShade, height: 1.1)),
          ),
        ),
      ),
      if (earnings.capped) ...[
        const SizedBox(height: 8),
        const PanelText.muted('Çevrimdışı gelir en çok 8 saat birikir.', align: TextAlign.center),
      ] else
        const SizedBox(height: 14),
      RaisedButton('Topla', onTap: c.collectWelcome, width: double.infinity, height: 50, fontSize: 19),
    ],
  );
}
