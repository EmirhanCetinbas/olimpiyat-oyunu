import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/format.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// Yükseltmeler: bölüm başlıklı satır listesi. Alınabilir satırlar yeşil zeminle öne çıkar;
/// satıra dokunmak açıklamayı, düğme yükseltmeyi yapar.
class UpgradeList extends StatelessWidget {
  const UpgradeList({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    // Gelir yükseltmeleri (4–5) branştan bağımsız; her branşta görünür.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('SPORCU GELİŞİMİ'),
        for (var i = 0; i < c.activeUpgrades.length; i++) UpgradeRow(index: i),
        const SizedBox(height: 4),
        const _SectionTitle('GELİR'),
        for (var i = c.activeUpgrades.length; i < GameController.upgradeCount; i++) UpgradeRow(index: i),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 2, 0, 6),
    child: Align(
      alignment: Alignment.centerLeft,
      child: OutlinedText(
        text,
        shadowOffset: const Offset(0, 2),
        style: gameText(19, color: Colors.white, height: 1.1, letterSpacing: .5),
      ),
    ),
  );
}

/// Tek yükseltme satırı: ikon, ad + seviye, mevcut → sonraki etki, fiyatlı düğme.
class UpgradeRow extends StatelessWidget {
  const UpgradeRow({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final u = c.upgradeDef(index);
    final level = c.upgradeLevel(index);
    final maxed = level >= 100;
    final affordable = c.canUpgrade(index);
    final compact = ScreenMetrics.of(context).compact;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _LevelPop(
        level: level,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 7, 7, 7),
          decoration: flatCardDecoration(radius: 18, color: affordable ? const Color(0xFFF0FBE6) : GameColors.row),
          child: Row(
            children: [
              Expanded(
                child: Pressable(
                  onTap: () => c.showInfo(index),
                  semanticLabel: '${u.title}, seviye $level, açıklama',
                  child: Row(
                    children: [
                      Container(
                        width: compact ? 42 : 48,
                        height: compact ? 42 : 48,
                        decoration: BoxDecoration(color: const Color(0xFFFFF1D2), borderRadius: BorderRadius.circular(13)),
                        alignment: Alignment.center,
                        child: Art(u.icon, width: compact ? 32 : 38, height: compact ? 32 : 38, emojiSize: compact ? 24 : 28),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    u.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: gameText(compact ? 15 : 16, color: GameColors.ink, height: 1.1),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Pill(
                                  'Sv.$level',
                                  style: gameText(11.5, color: GameColors.slate, height: 1.2),
                                  color: const Color(0xFFE6ECEF),
                                  radius: 7,
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(c.statValue(index), maxLines: 1, style: gameText(13.5, color: GameColors.slate, height: 1.1)),
                                ),
                                if (!maxed) ...[
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 3),
                                    child: Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF8398AA)),
                                  ),
                                  Flexible(
                                    child: Text(
                                      c.statValue(index, 1),
                                      maxLines: 1,
                                      style: gameText(14.5, color: GameColors.greenShade, height: 1.1),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              RaisedButton(
                maxed ? 'MAKS.' : 'Yükselt ₺${fmt(c.cost(index))}',
                onTap: () => c.pressUpgrade(index),
                enabled: affordable,
                width: compact ? 88 : 98,
                height: 44,
                content: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!maxed) ...[const Art('bank', width: 20, height: 20), const SizedBox(width: 3)],
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: OutlinedText(
                            maxed ? 'MAKS.' : '₺${fmt(c.cost(index))}',
                            shadowOffset: const Offset(0, 1.5),
                            style: gameText(16, color: Colors.white, height: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Seviye artınca satır kısa bir yaylanma yapar ve üstünde "+1 Sv" yükselir.
class _LevelPop extends StatefulWidget {
  const _LevelPop({required this.level, required this.child});
  final int level;
  final Widget child;

  @override
  State<_LevelPop> createState() => _LevelPopState();
}

class _LevelPopState extends State<_LevelPop> with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));

  @override
  void didUpdateWidget(_LevelPop old) {
    super.didUpdateWidget(old);
    if (widget.level > old.level) _anim.forward(from: 0);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    child: widget.child,
    builder: (context, child) {
      final t = _anim.value;
      final bump = _anim.isAnimating ? math.sin(math.min(t * 2, 1) * math.pi) * .035 : 0.0;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Transform.scale(scale: 1 + bump, child: child),
          if (_anim.isAnimating)
            Positioned(
              right: 110,
              top: -6 - 22 * t,
              child: Opacity(
                opacity: (1 - t).clamp(0.0, 1.0),
                child: OutlinedText(
                  '+1 Sv',
                  shadowOffset: const Offset(0, 1.5),
                  style: gameText(17, color: const Color(0xFF7DF35A), height: 1),
                ),
              ),
            ),
        ],
      );
    },
  );
}
