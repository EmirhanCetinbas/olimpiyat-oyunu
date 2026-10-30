import 'package:flutter/material.dart';

import '../../game/controller.dart';

import '../components/components.dart';
import '../theme/theme.dart';

/// Ödüller sekmesinin açılır menüsü (oklu balon).
class RewardsMenu extends StatelessWidget {
  const RewardsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final width = (MediaQuery.sizeOf(context).width - 32).clamp(0.0, 300.0);
    return Positioned(
      left: 0,
      right: 0,
      bottom: ScreenMetrics.of(context).bottomNavHeight + 12,
      child: Center(
        child: SizedBox(
          width: width,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              const Positioned(bottom: -9, child: _Arrow()),
              GBox(
                color: GameColors.cream,
                borderColor: GameColors.ink,
                borderWidth: 3,
                radius: 17,
                shadows: const [
                  BoxShadow(color: Color(0x65183629), offset: Offset(0, 6)),
                  BoxShadow(color: Color(0x77062327), offset: Offset(0, 10), blurRadius: 25),
                ],
                padding: const EdgeInsets.fromLTRB(9, 4, 9, 9),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MenuItem('🎁 Günlük ödül', () => c.open('daily-rewards')),
                    _MenuItem('🎡 Çarkıfelek', () => c.open('wheel')),
                    _MenuItem('🏅 Başarımlar', () => c.open('achievements')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow();

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: .785398,
    child: Container(
      width: 14,
      height: 14,
      decoration: const BoxDecoration(
        color: GameColors.cream,
        border: Border(
          right: BorderSide(color: GameColors.ink, width: 3),
          bottom: BorderSide(color: GameColors.ink, width: 3),
        ),
      ),
    ),
  );
}

class _MenuItem extends StatelessWidget {
  const _MenuItem(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Pressable(
      onTap: onTap,
      child: GBox(
        gradient: vGradient(const [Color(0xFFFFFEF8), Color(0xFFE7F1EC)]),
        borderColor: const Color(0xFFABB9BD),
        borderWidth: 2,
        radius: 10,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: SizedBox(
          width: double.infinity,
          child: Text(label, style: nunito(15)),
        ),
      ),
    ),
  );
}
