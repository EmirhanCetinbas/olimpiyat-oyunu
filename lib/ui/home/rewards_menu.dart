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
              Container(
                decoration: BoxDecoration(
                  color: GameColors.paper,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: GameColors.ink, width: 3),
                  boxShadow: const [BoxShadow(color: Color(0x55062327), offset: Offset(0, 8), blurRadius: 18)],
                ),
                padding: const EdgeInsets.fromLTRB(10, 2, 10, 10),
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
        color: GameColors.paper,
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
    padding: const EdgeInsets.only(top: 8),
    child: Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: flatCardDecoration(radius: 14),
        child: Text(label, style: gameText(16.5, color: GameColors.ink, height: 1.1)),
      ),
    ),
  );
}
