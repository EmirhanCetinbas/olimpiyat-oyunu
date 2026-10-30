import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/format.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// `<header class="top">`: 3 sütun × 2 satır ızgara.
class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final unit = (box.maxWidth - 14) / 3.08;
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
                cell(0, 47, _ProfileButton(c)),
                const SizedBox(width: 7),
                cell(1, 47, _IncomeDisplay(c), align: Alignment.topCenter),
                const SizedBox(width: 7),
                cell(
                  2,
                  47,
                  Padding(padding: const EdgeInsets.only(top: 6), child: _GemsButton(c)),
                  align: Alignment.topCenter,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                cell(0, 44, _QuickButtons(c), align: Alignment.centerLeft),
                const SizedBox(width: 7),
                cell(1, 44, _BoostButton(c)),
                const SizedBox(width: 7),
                cell(2, 44, _BranchButton(c)),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: () => c.open('profile'),
    semanticLabel: 'Profili aç',
    child: CreamBox(
      radius: 12,
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: Row(
        children: [
          Art('avatar', width: 30, height: 34, radius: BorderRadius.circular(6)),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sv. ${c.level}', style: nunito(12, height: 1.2), maxLines: 1, overflow: TextOverflow.clip),
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
  const _IncomeDisplay(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('Gelir /sn', style: nunito(12, height: 1.3)),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          '₺${fmt(c.income())}',
          style: nunito(30, color: const Color(0xFF79F44B), height: 1.05, letterSpacing: -.5, shadows: outlineShadows(GameColors.ink, 1)),
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
    child: CreamBox(
      height: 32,
      child: Stack(
        children: [
          const Positioned(left: 8, top: 0, bottom: 0, child: Center(child: Art('gem', width: 27, height: 27))),
          Center(child: Text(fmt(c.state.gems), style: nunito(18, height: 1))),
        ],
      ),
    ),
  );
}

/// Kare krem düğme (başarımlar, ayarlar).
class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.onTap, required this.label, required this.child, this.dot = false});
  final VoidCallback onTap;
  final String label;
  final Widget child;
  final bool dot;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    semanticLabel: label,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        CreamBox(
          radius: 10,
          width: 42,
          height: 42,
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
  const _QuickButtons(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _SquareButton(onTap: () => c.open('achievements'), label: 'Başarımlar', dot: c.achievementDot, child: const Art('trophy')),
      const SizedBox(width: 6),
      _SquareButton(onTap: () => c.open('settings'), label: 'Ayarlar', child: const Art('gear', width: 30, height: 30)),
    ],
  );
}

class _BoostButton extends StatelessWidget {
  const _BoostButton(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) => GameButton(
    onTap: c.activateBoost,
    enabled: !c.boostDisabled,
    skin: ButtonSkin.blue,
    height: 34,
    padding: const EdgeInsets.symmetric(horizontal: 3),
    alignment: Alignment.center,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        c.boostText,
        style: nunito(13, color: Colors.white, shadows: whiteTextShadow),
      ),
    ),
  );
}

class _BranchButton extends StatelessWidget {
  const _BranchButton(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final art = c.branchArt;
    return Pressable(
      onTap: () => c.open('branches'),
      child: GBox(
        gradient: vGradient(const [Color(0xFF223951), Color(0xFF102134)]),
        borderColor: GameColors.ink,
        borderWidth: outlineWidth,
        radius: 10,
        shadows: const [BoxShadow(color: Color(0x66466933), offset: Offset(0, 2))],
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Art(art, width: 22, height: 26, emojiSize: art == 'swim-wave' ? 23 : 12),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                c.branchName,
                textAlign: TextAlign.center,
                style: nunito(12, color: Colors.white, height: 1.1),
              ),
            ),
            const SizedBox(width: 4),
            Text('⌄', style: nunito(13, color: const Color(0xFF8BABBD))),
          ],
        ),
      ),
    );
  }
}
