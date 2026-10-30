import 'package:flutter/material.dart';

import '../components/components.dart';
import '../theme/theme.dart';

/// `.race-strip`: yarış durumu, halter risk seçimi ve otomatik yarış anahtarı.
class RaceStrip extends StatelessWidget {
  const RaceStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final risk = c.state.branch == 'weights';
    return ConstrainedBox(
      // Mobil: düğmeler 44pt dokunma alanı alır; şerit yüksekliği onlara göre (web: 33px, 9px yazı).
      constraints: const BoxConstraints(minHeight: minTapTarget),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Row(
          children: [
            Expanded(
              child: Text(c.raceStatus, style: gameText(12, color: GameColors.ink, height: 1.15)),
            ),
            const SizedBox(width: 6),
            if (risk) ...[
              Pressable(
                onTap: c.toggleRisk,
                minTapSize: minTapTarget,
                semanticLabel: 'Halter denemesi: ${c.state.weightRisk == 'record' ? 'rekor' : 'güvenli'}',
                child: Pill(
                  c.state.weightRisk == 'record' ? 'Rekor denemesi' : 'Güvenli kilo',
                  style: gameText(12, color: GameColors.ink, height: 1.1),
                  color: GameColors.row,
                  borderColor: GameColors.ink,
                  borderWidth: 2,
                  radius: 11,
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Pressable(
              onTap: c.toggleAuto,
              minTapSize: minTapTarget,
              semanticLabel: 'Otomatik ${c.state.auto ? 'açık' : 'kapalı'}',
              child: Container(
                decoration: flatCardDecoration(radius: 11, borderWidth: 2),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                child: Text.rich(
                  TextSpan(
                    style: gameText(12, color: GameColors.ink, height: 1.1),
                    children: [
                      const TextSpan(text: '↻ Otomatik '),
                      TextSpan(
                        text: c.state.auto ? 'AÇIK' : 'KAPALI',
                        style: gameText(12, color: c.state.auto ? GameColors.greenShade : GameColors.slate, height: 1.1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
