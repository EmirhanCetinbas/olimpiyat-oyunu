import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/data.dart';
import '../../game/state.dart';
import '../components/components.dart';
import '../stadium/runner_avatar.dart';
import '../theme/theme.dart';

/// Spor Çantaları: bekleyen seçim ya da sahip olunan çantalar.
class ChestsPanel extends StatelessWidget {
  const ChestsPanel(this.c, {super.key});
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final p = c.state.pendingChest;
    if (p != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PanelText('${chestNames[p.type]} · Bir çanta seç.'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _ChestChoice(index: i, onTap: () => c.pressChooseChest(i)),
                  ),
                ],
              ],
            ),
          ),
          const PanelText.muted('Seçimin kaydedilir; menüden çıksan da çanta burada kalır.'),
        ],
      );
    }
    final s = c.state;
    final toNext = 5 - s.races % 5;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ChestTile(type: 'normal', count: s.chests, onOpen: () => c.pressOpenChest('normal')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ChestTile(type: 'cup', count: s.cupChests, onOpen: () => c.pressOpenChest('cup')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ChestTile(type: 'champion', count: s.championChests, onOpen: () => c.pressOpenChest('champion')),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Sonraki Spor Çantası: her 5 yarışta bir.
        Row(
          children: [
            Expanded(
              child: GameProgressBar(value: (5 - toNext) / 5, label: 'Sonraki çanta', height: 14),
            ),
            const SizedBox(width: 8),
            Text('${5 - toNext}/5 yarış', style: gameText(13, color: GameColors.ink, height: 1)),
          ],
        ),
        const SizedBox(height: 6),
        PanelText.muted(
          'Sonraki Spor Çantası $toNext yarış sonra. Kupa Çantası kupadan, Şampiyon Çantası başarımlardan gelir.',
          align: TextAlign.center,
        ),
      ],
    );
  }
}

class _ChestChoice extends StatelessWidget {
  const _ChestChoice({required this.index, required this.onTap});
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    semanticLabel: '${index + 1}. çantayı aç',
    child: SizedBox(
      height: 118,
      child: RaisedSurface(
        color: const Color(0xFFFFD45C),
        shade: const Color(0xFFB27A12),
        radius: 18,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const RewardIcon('gift', size: 52),
              const SizedBox(height: 6),
              Text('${index + 1}. Çanta', style: gameText(14, color: GameColors.ink, height: 1)),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Çanta açıldı: ödül kartı (pop animasyonlu).
class ChestResultPanel extends StatelessWidget {
  const ChestResultPanel(this.c, this.prize, {super.key});
  final GameController c;
  final ChestItem prize;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        builder: (context, t, child) => Opacity(
          opacity: .3 + .7 * t,
          child: Transform.scale(scale: .75 + .25 * t, child: child),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            decoration: flatCardDecoration(radius: 18, color: const Color(0xFFFFF0B8)),
            child: Column(
              children: [
                RewardKindIcon(prize.kind, size: 72),
                const SizedBox(height: 8),
                Text(
                  prize.label,
                  textAlign: TextAlign.center,
                  style: gameText(TextSizes.cardTitle, color: GameColors.ink, height: 1.15),
                ),
              ],
            ),
          ),
        ),
      ),
      ActionButton('Envantere dön', full: true, onTap: () => c.open('inventory')),
    ],
  );
}

/// Çanta kartı: türüne göre renkli kabarık kutu, hediye görseli, adet rozeti ve Aç düğmesi.
class _ChestTile extends StatelessWidget {
  const _ChestTile({required this.type, required this.count, required this.onOpen});
  final String type;
  final int count;
  final VoidCallback onOpen;

  static const _tones = {
    'normal': (Color(0xFFFFD45C), Color(0xFFB27A12)),
    'cup': (Color(0xFF6CC4FF), Color(0xFF1F5E96)),
    'champion': (Color(0xFFC78BF5), Color(0xFF5D2A8C)),
  };

  @override
  Widget build(BuildContext context) {
    final (color, shade) = _tones[type]!;
    final has = count > 0;
    return Column(
      children: [
        SizedBox(
          height: 104,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: has
                    ? RaisedSurface(
                        color: color,
                        shade: shade,
                        radius: 18,
                        child: const Center(child: RewardIcon('gift', size: 62)),
                      )
                    : const RaisedSurface.locked(
                        radius: 18,
                        child: Opacity(opacity: .5, child: Center(child: RewardIcon('gift', size: 62))),
                      ),
              ),
              Positioned(
                right: -4,
                top: -6,
                child: Pill(
                  '×$count',
                  style: gameText(14, color: Colors.white, height: 1.1),
                  color: has ? GameColors.danger : GameColors.lockedShade,
                  borderColor: GameColors.ink,
                  borderWidth: 2,
                  radius: 11,
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          chestNames[type]!,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: gameText(13.5, color: GameColors.ink, height: 1.1),
        ),
        const SizedBox(height: 6),
        RaisedButton('Aç', onTap: onOpen, enabled: has, width: double.infinity, height: 38, fontSize: 16),
      ],
    );
  }
}

/// Avatar çerçeveleri.
class CosmeticsPanel extends StatelessWidget {
  const CosmeticsPanel(this.c, {super.key});
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final s = c.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PanelText("Yeni çerçeveler Şampiyon Çantası'ndan çıkabilir."),
        if (s.cosmetics.isEmpty) const PanelText('Henüz çerçeve kazanmadın.'),
        for (var k = 0; k < s.cosmetics.length; k++)
          ListRow(
            children: [
              // Çerçevenin gerçek rengiyle önizleme.
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: GameColors.row,
                  border: Border.all(color: RunnerAvatar.cosmeticColors[s.cosmetics[k]][0], width: 4),
                  boxShadow: [BoxShadow(color: RunnerAvatar.cosmeticColors[s.cosmetics[k]][1], blurRadius: 6)],
                ),
              ),
              RowTitle(cosmeticNames[s.cosmetics[k]]),
              if (s.selectedCosmetic == s.cosmetics[k])
                const SelectedTag()
              else
                ActionButton('Seç', onTap: () => c.selectCosmetic(s.cosmetics[k])),
            ],
          ),
      ],
    );
  }
}
