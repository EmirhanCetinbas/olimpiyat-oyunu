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
    return LayoutBuilder(
      builder: (context, box) {
        return ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 33),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: box.maxWidth * (risk ? .43 : .63)),
                  child: Text(c.raceStatus, style: nunito(10, height: 1.15)),
                ),
                if (risk)
                  Pressable(
                    onTap: c.toggleRisk,
                    child: Pill(
                      c.state.weightRisk == 'record' ? 'Rekor denemesi' : 'Güvenli kilo',
                      style: nunito(9, color: const Color(0xFF0E3852)),
                      color: const Color(0xFFFFF5D4),
                      borderColor: const Color(0xFF24465A),
                      borderWidth: 2,
                      padding: const EdgeInsets.all(4),
                    ),
                  ),
                Pressable(
                  onTap: c.toggleAuto,
                  semanticLabel: 'Otomatik ${c.state.auto ? 'açık' : 'kapalı'}',
                  child: GBox(
                    color: const Color(0xBBFAFFDF),
                    borderColor: const Color(0xFF477927),
                    borderWidth: 1,
                    radius: 7,
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    child: Text.rich(
                      TextSpan(
                        style: nunito(9),
                        children: [
                          const TextSpan(text: '↻ Otomatik '),
                          TextSpan(
                            text: c.state.auto ? 'AÇIK' : 'KAPALI',
                            style: nunito(9, color: const Color(0xFF178D2C)),
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
      },
    );
  }
}
