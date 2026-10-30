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
            Expanded(child: Text(c.raceStatus, style: nunito(11, height: 1.15))),
            const SizedBox(width: 6),
            if (risk) ...[
              Pressable(
                onTap: c.toggleRisk,
                minTapSize: minTapTarget,
                semanticLabel: 'Halter denemesi: ${c.state.weightRisk == 'record' ? 'rekor' : 'güvenli'}',
                child: Pill(
                  c.state.weightRisk == 'record' ? 'Rekor denemesi' : 'Güvenli kilo',
                  style: nunito(11, color: const Color(0xFF0E3852)),
                  color: const Color(0xFFFFF5D4),
                  borderColor: const Color(0xFF24465A),
                  borderWidth: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Pressable(
              onTap: c.toggleAuto,
              minTapSize: minTapTarget,
              semanticLabel: 'Otomatik ${c.state.auto ? 'açık' : 'kapalı'}',
              child: GBox(
                color: const Color(0xBBFAFFDF),
                borderColor: const Color(0xFF477927),
                borderWidth: 1,
                radius: 7,
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                child: Text.rich(
                  TextSpan(
                    style: nunito(11),
                    children: [
                      const TextSpan(text: '↻ Otomatik '),
                      TextSpan(
                        text: c.state.auto ? 'AÇIK' : 'KAPALI',
                        style: nunito(11, color: const Color(0xFF178D2C)),
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
