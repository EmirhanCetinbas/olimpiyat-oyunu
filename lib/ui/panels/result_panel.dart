import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/format.dart';
import '../../game/race.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// Yarış sonucu: madalya, sıra, ölçüm, rekor, sayarak artan ödül ve yeniden yarış.
class ResultPanel extends StatelessWidget {
  const ResultPanel(this.c, this.result, {super.key});
  final GameController c;
  final RaceResult result;

  @override
  Widget build(BuildContext context) {
    final r = result;
    return Column(
      children: [
        // Madalya yaylanarak gelir.
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 650),
          curve: Curves.elasticOut,
          builder: (context, t, child) => Transform.scale(
            scale: .4 + .6 * t,
            child: Transform.rotate(angle: (1 - t) * -.4, child: child),
          ),
          child: MedalBadge(place: r.success ? r.place : r.total),
        ),
        const SizedBox(height: 6),
        Text(
          r.success ? '${r.place}. sıra · ${r.total} sporcu' : 'Kaldırış başarısız',
          style: gameText(TextSizes.cardTitle, color: GameColors.ink, height: 1.2),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            Pill(
              r.value,
              style: gameText(20, color: GameColors.ink, height: 1.1),
              color: GameColors.row,
              borderColor: GameColors.ink,
              borderWidth: 2.5,
              radius: 14,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            ),
            if (r.record)
              SizedBox(
                height: 38,
                child: RaisedSurface(
                  color: GameColors.sparkle,
                  shade: const Color(0xFF9A6A00),
                  radius: 13,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 3),
                    child: Center(
                      widthFactor: 1,
                      child: OutlinedText(
                        'YENİ REKOR!',
                        shadowOffset: const Offset(0, 1.5),
                        style: gameText(16, color: Colors.white, height: 1),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Ödüller: para sayarak artar.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: flatCardDecoration(radius: 16, color: const Color(0xFFF0FBE6)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const RewardIcon('money', size: 34),
              const SizedBox(width: 6),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: r.reward.toDouble()),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => Text('+₺${fmt(v)}', style: gameText(24, color: GameColors.greenShade, height: 1.1)),
              ),
              const SizedBox(width: 14),
              Pill(
                '+${r.xp} XP',
                style: gameText(15, color: Colors.white, height: 1.1),
                color: GameColors.blue,
                borderColor: GameColors.ink,
                borderWidth: 2,
                radius: 11,
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: RaisedButton('Tamam', onTap: c.closeModal, tone: ButtonTone.cream, width: double.infinity, height: 48, fontSize: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RaisedButton(
                c.startText.replaceAll('▶', '').trim(),
                onTap: c.raceAgain,
                width: double.infinity,
                height: 48,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
