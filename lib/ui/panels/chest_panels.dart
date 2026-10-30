import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/data.dart';
import '../../game/state.dart';
import '../components/components.dart';
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
    Widget chestRow(String name, int count, String type) => ListRow(
      children: [
        RowTitle('$name ×$count'),
        ActionButton('Aç', onTap: () => c.pressOpenChest(type), enabled: count >= 1),
      ],
    );
    return Column(
      children: [
        const PanelText('Çantaların envanterde. Her 5 yarışta yeni bir Spor Çantası kazanırsın.'),
        chestRow('Spor Çantası', s.chests, 'normal'),
        chestRow('Kupa Çantası', s.cupChests, 'cup'),
        chestRow('Şampiyon Çantası', s.championChests, 'champion'),
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
    child: GBox(
      constraints: const BoxConstraints(minHeight: 112),
      gradient: vGradient(const [Color(0xFFFFF8DB), Color(0xFFFFCC63)]),
      borderColor: const Color(0xFF122C3D),
      borderWidth: 3,
      radius: 14,
      insets: const [Inset(Colors.white, dy: 3)],
      shadows: const [BoxShadow(color: Color(0x44142D36), offset: Offset(0, 4))],
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const EmojiArt('🎁', size: 39),
          const SizedBox(height: 4),
          Text('${index + 1}. Çanta', style: gameText(11, color: GameColors.ink)),
        ],
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF142D42), width: 3),
              borderRadius: BorderRadius.circular(16),
              gradient: const RadialGradient(
                radius: .75,
                colors: [Color(0xFFFFF4AD), Color(0xFFFFD25D), Color(0xFFF7AE3F)],
                stops: [0, .65, 1],
              ),
            ),
            child: Column(
              children: [
                EmojiArt(prize.icon, size: 55),
                const SizedBox(height: 8),
                Text(
                  prize.label,
                  textAlign: TextAlign.center,
                  style: gameText(18, color: GameColors.ink),
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
              Expanded(
                child: Text('✨ ${cosmeticNames[s.cosmetics[k]]}', style: gameText(14, color: GameColors.ink)),
              ),
              ActionButton(s.selectedCosmetic == s.cosmetics[k] ? 'Seçili' : 'Seç', onTap: () => c.selectCosmetic(s.cosmetics[k])),
            ],
          ),
      ],
    );
  }
}
