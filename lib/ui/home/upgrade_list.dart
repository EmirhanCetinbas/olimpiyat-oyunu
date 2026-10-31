import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/format.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// Yükseltmeler: bölüm başlıklı iki sütunlu kart ızgarası. Kartın üstüne dokunmak açıklamayı,
/// alttaki düğme yükseltmeyi yapar.
class UpgradeList extends StatelessWidget {
  const UpgradeList({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final gap = ScreenMetrics.of(context).compact ? 6.0 : 8.0;
    // Gelir yükseltmeleri (4–5) branştan bağımsız; her branşta görünür.
    Widget grid(int from, int to) => Column(
      children: [
        for (var i = from; i < to; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: gap),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: UpgradeCard(index: i)),
                  SizedBox(width: gap),
                  Expanded(child: i + 1 < to ? UpgradeCard(index: i + 1) : const SizedBox()),
                ],
              ),
            ),
          ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('SPORCU GELİŞİMİ'),
        grid(0, c.activeUpgrades.length),
        const SizedBox(height: 4),
        const _SectionTitle('GELİR'),
        grid(c.activeUpgrades.length, GameController.upgradeCount),
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

/// Tek yükseltme kartı: ikon, ad, seviye ve bilgi işareti; mevcut → sonraki etki;
/// tam genişlikte "Yükselt" + fiyat düğmesi.
class UpgradeCard extends StatelessWidget {
  const UpgradeCard({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final u = c.upgradeDef(index);
    final level = c.upgradeLevel(index);
    final maxed = level >= 100;
    final affordable = c.canUpgrade(index);
    final compact = ScreenMetrics.of(context).compact;
    final icon = compact ? 44.0 : 52.0;
    return _LevelPop(
      level: level,
      child: Container(
        padding: EdgeInsets.fromLTRB(compact ? 6 : 8, compact ? 6 : 8, compact ? 6 : 8, compact ? 7 : 8),
        decoration: flatCardDecoration(radius: 18, color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Pressable(
              onTap: () => c.showInfo(index),
              semanticLabel: '${u.title}, seviye $level, açıklama',
              // Başlık iki satıra kadar sığar; seviye ve bilgi işareti alt satırda (başlık daralmasın).
              child: SizedBox(
                height: compact ? 50 : 57,
                child: Row(
                  children: [
                    Container(
                      width: icon,
                      height: icon,
                      decoration: BoxDecoration(color: const Color(0xFFFFF1D2), borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.center,
                      child: Art(u.icon, width: icon - 8, height: icon - 8, emojiSize: icon * .55),
                    ),
                    SizedBox(width: compact ? 5 : 7),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                u.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: gameText(compact ? 13 : 15, color: GameColors.ink, height: 1.12),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Pill(
                                'Sv. $level',
                                style: gameText(compact ? 11 : 12, color: GameColors.slate, height: 1.3),
                                color: const Color(0xFFEDF1F4),
                                radius: 7,
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                              ),
                              const Spacer(),
                              Icon(Icons.info_rounded, size: compact ? 18 : 21, color: const Color(0xFFB4C0CA)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: compact ? 6 : 8),
            Container(
              height: compact ? 28 : 32,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(color: const Color(0xFFF0F3F6), borderRadius: BorderRadius.circular(9)),
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(c.statValue(index), maxLines: 1, style: gameText(compact ? 14 : 16, color: GameColors.ink, height: 1.1)),
                    if (!maxed) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFF8398AA)),
                      ),
                      Text(
                        c.statValue(index, 1),
                        maxLines: 1,
                        style: gameText(compact ? 14 : 16, color: GameColors.greenShade, height: 1.1),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: compact ? 6 : 8),
            RaisedButton(
              maxed ? 'MAKS.' : 'Yükselt ₺${fmt(c.cost(index))}',
              onTap: () => c.pressUpgrade(index),
              enabled: affordable,
              width: double.infinity,
              height: compact ? 40 : 44,
              content: Padding(
                padding: EdgeInsets.fromLTRB(compact ? 6 : 10, 4, 4, 7),
                child: maxed
                    ? Center(child: _ButtonText('MAKS.', size: compact ? 15 : 17))
                    : Row(
                        children: [
                          Expanded(
                            child: Center(child: _ButtonText('Yükselt', size: compact ? 14 : 17)),
                          ),
                          const SizedBox(width: 4),
                          _PriceTag('₺${fmt(c.cost(index))}', compact: compact, active: affordable),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ButtonText extends StatelessWidget {
  const _ButtonText(this.text, {required this.size});
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: OutlinedText(
      text,
      maxLines: 1,
      shadowOffset: const Offset(0, 1.5),
      style: gameText(size, color: Colors.white, height: 1),
    ),
  );
}

/// Düğmenin sağındaki koyu fiyat cebi: para ikonu ve tutar.
class _PriceTag extends StatelessWidget {
  const _PriceTag(this.price, {required this.compact, required this.active});
  final String price;
  final bool compact, active;

  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(maxWidth: compact ? 74 : 92),
    padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 6),
    decoration: BoxDecoration(
      color: (active ? GameColors.greenShade : GameColors.lockedShade).withValues(alpha: .55),
      borderRadius: BorderRadius.circular(9),
    ),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Art('bank', width: compact ? 17 : 20, height: compact ? 17 : 20),
          const SizedBox(width: 3),
          OutlinedText(
            price,
            maxLines: 1,
            shadowOffset: const Offset(0, 1.5),
            style: gameText(compact ? 14 : 16, color: Colors.white, height: 1),
          ),
        ],
      ),
    ),
  );
}

/// Seviye artınca kart kısa bir yaylanma yapar ve üstünde "+1 Sv" yükselir.
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
              left: 0,
              right: 0,
              top: 10 - 22 * t,
              child: Opacity(
                opacity: (1 - t).clamp(0.0, 1.0),
                child: Center(
                  child: OutlinedText(
                    '+1 Sv',
                    shadowOffset: const Offset(0, 1.5),
                    style: gameText(17, color: const Color(0xFF7DF35A), height: 1),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}
