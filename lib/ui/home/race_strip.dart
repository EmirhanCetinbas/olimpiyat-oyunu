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
              _ToggleChip(
                icon: Icons.fitness_center_rounded,
                label: '',
                value: c.state.weightRisk == 'record' ? 'REKOR' : 'GÜVENLİ',
                on: c.state.weightRisk == 'record',
                onTap: c.toggleRisk,
                semanticLabel: 'Halter denemesi: ${c.state.weightRisk == 'record' ? 'rekor' : 'güvenli'}',
              ),
              const SizedBox(width: 6),
            ],
            _ToggleChip(
              icon: Icons.autorenew_rounded,
              // İki anahtar yan yana olunca yalnız ikon + durum; durum yazısına yer kalsın.
              label: risk ? '' : 'Otomatik',
              value: c.state.auto ? 'AÇIK' : 'KAPALI',
              on: c.state.auto,
              onTap: c.toggleAuto,
              semanticLabel: 'Otomatik ${c.state.auto ? 'açık' : 'kapalı'}',
            ),
          ],
        ),
      ),
    );
  }
}

/// Yarış şeridindeki küçük anahtar: ikon, ad ve durum (açıkken yeşil).
class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.on,
    required this.onTap,
    required this.semanticLabel,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool on;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    minTapSize: minTapTarget,
    semanticLabel: semanticLabel,
    child: Container(
      decoration: flatCardDecoration(radius: 11, borderWidth: 2, color: on ? const Color(0xFFE6FBD9) : GameColors.row),
      padding: const EdgeInsets.fromLTRB(7, 5, 9, 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: on ? GameColors.greenShade : GameColors.slate),
          const SizedBox(width: 4),
          Text.rich(
            TextSpan(
              style: gameText(12, color: GameColors.ink, height: 1.1),
              children: [
                if (label.isNotEmpty) TextSpan(text: '$label '),
                TextSpan(
                  text: value,
                  style: gameText(12, color: on ? GameColors.greenShade : GameColors.slate, height: 1.1),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
