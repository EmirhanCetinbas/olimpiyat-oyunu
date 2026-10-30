import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/format.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// `<header class="top">`: 3 sütun × 2 satır ızgara; dar ekranda sıkışır.
class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final compact = ScreenMetrics.of(context).compact;
    final gap = compact ? 4.0 : 7.0;
    return LayoutBuilder(
      builder: (context, box) {
        final unit = (box.maxWidth - gap * 2) / 3.08;
        final cols = [unit, unit, unit * 1.08];
        Widget cell(int col, double height, Widget child, {Alignment align = Alignment.center}) => SizedBox(
          width: cols[col],
          height: height,
          child: Align(alignment: align, child: child),
        );
        return Column(
          children: [
            Row(
              children: [
                cell(0, 47, _ProfileButton(c, compact: compact)),
                SizedBox(width: gap),
                cell(1, 47, _IncomeDisplay(c, compact: compact), align: Alignment.topCenter),
                SizedBox(width: gap),
                cell(
                  2,
                  47,
                  Padding(padding: const EdgeInsets.only(top: 6), child: _GemsButton(c)),
                  align: Alignment.topCenter,
                ),
              ],
            ),
            SizedBox(height: compact ? 4 : 5),
            Row(
              children: [
                cell(0, 44, _QuickButtons(c, compact: compact), align: Alignment.centerLeft),
                SizedBox(width: gap),
                cell(1, 44, _BoostButton(c)),
                SizedBox(width: gap),
                cell(2, 44, _BranchButton(c, compact: compact)),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton(this.c, {required this.compact});
  final GameController c;
  final bool compact;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: () => c.open('profile'),
    semanticLabel: 'Profili aç',
    child: _FlatBox(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: Row(
        children: [
          Art('avatar', width: 30, height: 34, radius: BorderRadius.circular(6)),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sv. ${c.level}', style: gameText(compact ? 11 : 12, height: 1.2), maxLines: 1, overflow: TextOverflow.clip),
                const SizedBox(height: 2),
                GameProgressBar.xp(value: (c.state.xp % 100) / 100),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _IncomeDisplay extends StatelessWidget {
  const _IncomeDisplay(this.c, {required this.compact});
  final GameController c;
  final bool compact;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('Gelir /sn', style: gameText(12, height: 1.3)),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: OutlinedText(
          '₺${fmt(c.income())}',
          maxLines: 1,
          shadowOffset: const Offset(0, 2),
          style: gameText(compact ? 27 : 30, color: const Color(0xFF79F44B), height: 1.05),
        ),
      ),
    ],
  );
}

class _GemsButton extends StatelessWidget {
  const _GemsButton(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: () => c.open('shop'),
    semanticLabel: 'Elmas mağazası',
    child: _FlatBox(
      height: 34,
      padding: const EdgeInsets.only(left: 6, right: 4),
      child: Row(
        children: [
          const Art('gem', width: 26, height: 26),
          const SizedBox(width: 6),
          Expanded(
            child: Text(fmt(c.state.gems), style: gameText(18, color: GameColors.ink, height: 1)),
          ),
          // Mağazaya git işareti
          const SizedBox(
            width: 22,
            height: 22,
            child: RaisedSurface.green(radius: 11, child: Icon(Icons.add_rounded, size: 16, color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}

/// Kare krem düğme (başarımlar, ayarlar).
class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.onTap, required this.label, required this.child, required this.compact, this.dot = false});
  final VoidCallback onTap;
  final String label;
  final Widget child;
  final bool compact;
  final bool dot;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    semanticLabel: label,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        _FlatBox(
          width: compact ? 38 : 42,
          height: compact ? 40 : 42,
          padding: const EdgeInsets.all(3),
          child: Center(child: child),
        ),
        if (dot)
          Positioned(
            right: -3,
            top: -4,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5557),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF931C2B), width: 1.5),
              ),
            ),
          ),
      ],
    ),
  );
}

class _QuickButtons extends StatelessWidget {
  const _QuickButtons(this.c, {required this.compact});
  final GameController c;
  final bool compact;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _SquareButton(
        onTap: () => c.open('achievements'),
        label: 'Başarımlar',
        dot: c.achievementDot,
        compact: compact,
        child: const Art('trophy'),
      ),
      const SizedBox(width: 6),
      _SquareButton(onTap: () => c.open('settings'), label: 'Ayarlar', compact: compact, child: const Art('gear', width: 30, height: 30)),
    ],
  );
}

class _BoostButton extends StatelessWidget {
  const _BoostButton(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final enabled = !c.boostDisabled;
    final label = Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 3),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: OutlinedText(
            c.boostText,
            maxLines: 1,
            shadowOffset: const Offset(0, 1.5),
            style: gameText(14.5, color: Colors.white, height: 1),
          ),
        ),
      ),
    );
    return Pressable(
      onTap: c.activateBoost,
      enabled: enabled,
      semanticLabel: c.boostText,
      disabledSaturation: 1,
      disabledOpacity: 1,
      child: SizedBox(
        height: 42,
        child: enabled
            ? RaisedSurface(color: GameColors.blue, shade: GameColors.blueShade, radius: 14, child: label)
            : RaisedSurface.locked(radius: 14, child: label),
      ),
    );
  }
}

class _BranchButton extends StatelessWidget {
  const _BranchButton(this.c, {required this.compact});
  final GameController c;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final art = c.branchArt;
    return Pressable(
      onTap: () => c.open('branches'),
      semanticLabel: 'Branş seç: ${c.branchName}',
      child: SizedBox(
        height: 42,
        child: RaisedSurface(
          color: GameColors.navy,
          shade: GameColors.navyShade,
          radius: 14,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Art(art, width: 22, height: 26, emojiSize: art == 'swim-wave' ? 23 : 12),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    c.branchName,
                    textAlign: TextAlign.center,
                    style: gameText(compact ? 12 : 13, color: Colors.white, height: 1.05),
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(Icons.expand_more_rounded, size: 18, color: Color(0xFF9DB9CC)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Üst bardaki düz kart (profil, elmas, kare düğmeler).
class _FlatBox extends StatelessWidget {
  const _FlatBox({required this.child, this.width, this.height, this.padding = EdgeInsets.zero});
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) =>
      Container(width: width, height: height, padding: padding, decoration: flatCardDecoration(radius: 14, borderWidth: 2.5), child: child);
}
