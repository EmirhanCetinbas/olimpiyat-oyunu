import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// Yarış şeridi: üstte yarış durumu; altta solda otomatik anahtarı, sağda (başparmağın
/// kolay eriştiği yerde) kart ve halter anahtarları ile branş değiştirme düğmesi.
class RaceStrip extends StatelessWidget {
  const RaceStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final risk = c.state.branch == 'weights';
    final cards = c.state.trainingCards[c.state.branch] ?? 0, armed = c.state.armedCards.contains(c.state.branch);
    final compact = risk && cards > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(1, 5, 1, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(c.raceStatus, maxLines: 2, style: gameText(12, color: GameColors.ink, height: 1.15)),
          const SizedBox(height: 4),
          Row(
            children: [
              _ToggleChip(
                icon: Icons.autorenew_rounded,
                // Üç anahtar yan yana olunca yalnız ikon + durum.
                label: compact ? '' : 'Otomatik',
                value: c.state.auto ? 'AÇIK' : 'KAPALI',
                on: c.state.auto,
                onTap: c.toggleAuto,
                semanticLabel: 'Otomatik ${c.state.auto ? 'açık' : 'kapalı'}',
              ),
              const Spacer(),
              // Antrenman kartı: elde kart varsa sonraki yarış için hazırlanır.
              if (cards > 0) ...[
                _ToggleChip(
                  icon: Icons.style_rounded,
                  label: '',
                  value: compact ? (armed ? '✓' : '×$cards') : (armed ? 'KART ✓' : 'KART ×$cards'),
                  on: armed,
                  onTap: () => c.toggleTrainingCard(c.state.branch),
                  semanticLabel: 'Antrenman kartı: ${armed ? 'sonraki yarışta kullanılacak' : '$cards kart, hazırla'}',
                ),
                const SizedBox(width: 6),
              ],
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
              _BranchButton(c),
            ],
          ),
        ],
      ),
    );
  }
}

/// Branş değiştirme: seçili branşın ikonu ve adı, değiştir işaretiyle.
class _BranchButton extends StatelessWidget {
  const _BranchButton(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: () => c.open('branches'),
    minTapSize: minTapTarget,
    semanticLabel: 'Branş: ${c.branchName}, değiştir',
    child: SizedBox(
      height: minTapTarget,
      child: RaisedSurface(
        color: GameColors.navy,
        shade: GameColors.navyShade,
        radius: 13,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(7, 0, 7, 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Art(c.branchArt, width: 24, height: 24, emojiSize: 20),
              const SizedBox(width: 5),
              Text(c.branchName, maxLines: 1, style: gameText(13, color: Colors.white, height: 1)),
              const SizedBox(width: 4),
              const Icon(Icons.swap_horiz_rounded, size: 20, color: Color(0xFF9DD5FF)),
            ],
          ),
        ),
      ),
    ),
  );
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
