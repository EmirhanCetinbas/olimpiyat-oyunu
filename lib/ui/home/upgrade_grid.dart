import 'package:flutter/material.dart';

import '../../game/controller.dart';

import '../../game/format.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// `.upgrades`: iki sütunlu yükseltme kartları.
class UpgradeGrid extends StatelessWidget {
  const UpgradeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final count = GameScope.of(context).activeUpgrades.length;
    return Column(
      children: [
        for (var row = 0; row < count; row += 2) ...[
          if (row > 0) const SizedBox(height: 6),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: UpgradeCard(index: row)),
                const SizedBox(width: 6),
                Expanded(child: row + 1 < count ? UpgradeCard(index: row + 1) : const SizedBox()),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// `.upgrade`: başlık, seviye, değer değişimi ve yükselt düğmesi.
class UpgradeCard extends StatelessWidget {
  const UpgradeCard({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final u = c.activeUpgrades[index];
    final compact = ScreenMetrics.of(context).compact;
    final level = c.upgradeLevels[index];
    return GBox(
      gradient: vGradient(const [Color(0xFFFFFDEE), Color(0xFFFFFEEF)]),
      borderColor: GameColors.ink,
      borderWidth: outlineWidth,
      radius: 14,
      shadows: const [BoxShadow(color: Color(0xFF43873B), offset: Offset(0, 2))],
      padding: compact ? const EdgeInsets.symmetric(horizontal: 5, vertical: 6) : const EdgeInsets.fromLTRB(6, 7, 6, 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  _IconBox(art: u.icon, emojiSize: c.state.branch == 'swim' ? 24 : 16),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 11, bottom: 2),
                          child: Text(u.title, style: nunito(compact ? 11 : 12, weight: 700, height: 1.02, letterSpacing: -.25)),
                        ),
                        Pill(
                          'Sv. $level',
                          style: nunito(10, color: const Color(0xFF56728E)),
                          color: const Color(0xFFE4EBEE),
                          radius: 3,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 16pt görsel, 32pt dokunma alanının ortasında.
              Positioned(
                right: -10,
                top: -11,
                child: _InfoButton(onTap: () => c.showInfo(index), label: '${u.title} hakkında'),
              ),
            ],
          ),
          const SizedBox(height: 5),
          _StatChange(from: c.statValue(index), to: c.statValue(index, 1)),
          const SizedBox(height: 5),
          _UpgradeButton(
            cost: level >= 100 ? 'MAKS.' : '₺${fmt(c.cost(index))}',
            enabled: c.canUpgrade(index),
            onTap: () => c.pressUpgrade(index),
          ),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.art, required this.emojiSize});
  final String art;
  final double emojiSize;

  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      gradient: vGradient(const [Color(0xFFFFF9E4), Color(0xFFFFEDC7)]),
      borderRadius: BorderRadius.circular(9),
      boxShadow: const [BoxShadow(color: Color(0x3017382C), offset: Offset(0, 1), blurRadius: 2)],
    ),
    alignment: Alignment.center,
    child: Art(art, width: 29, height: 29, emojiSize: emojiSize, radius: BorderRadius.circular(6)),
  );
}

class _InfoButton extends StatelessWidget {
  const _InfoButton({required this.onTap, required this.label});
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    semanticLabel: label,
    minTapSize: 32,
    child: Container(
      width: 16,
      height: 16,
      decoration: const BoxDecoration(color: Color(0xFF8397B0), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text('i', style: nunito(10, color: Colors.white, height: 1)),
    ),
  );
}

class _StatChange extends StatelessWidget {
  const _StatChange({required this.from, required this.to});
  final String from;
  final String to;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: const Color(0xFFEEF0ED),
      border: Border.all(color: const Color(0xFFD1D9DB)),
      borderRadius: BorderRadius.circular(6),
    ),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(from, style: nunito(13)),
          const SizedBox(width: 6),
          Text('➜', style: nunito(13, color: const Color(0xFF8398AA))),
          const SizedBox(width: 6),
          Text(to, style: nunito(13, color: const Color(0xFF00A328))),
        ],
      ),
    ),
  );
}

class _UpgradeButton extends StatelessWidget {
  const _UpgradeButton({required this.cost, required this.enabled, required this.onTap});
  final String cost;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.sizeOf(context).width.clamp(0.0, 500.0) - 22) / 2;
    return GameButton(
      onTap: onTap,
      enabled: enabled,
      skin: ButtonSkin.primary.copyWith(borderWidth: 1.5, radius: 7),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minHeight: 28),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  'Yükselt',
                  style: nunito(13, weight: 1000, color: Colors.white, shadows: whiteTextShadow),
                ),
              ),
            ),
            Container(
              constraints: BoxConstraints(minWidth: .44 * (cardWidth - 27.8)),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              decoration: BoxDecoration(
                gradient: vGradient(const [Color(0xFF12B927), Color(0xFF078D18)]),
                borderRadius: BorderRadius.circular(5),
                border: const Border(left: BorderSide(color: Color(0xFF087F1B))),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Art('bank', width: 18, height: 18),
                  const SizedBox(width: 3),
                  Text(
                    cost,
                    style: nunito(10, color: Colors.white, shadows: whiteTextShadow),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
