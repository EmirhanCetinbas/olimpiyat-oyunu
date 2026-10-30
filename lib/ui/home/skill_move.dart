import 'package:flutter/material.dart';

import '../../game/controller.dart';

import '../components/components.dart';
import '../theme/theme.dart';

/// `.skill-move`: zamanlama çubuğu ve hamle düğmesi.
class SkillMove extends StatelessWidget {
  const SkillMove({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    if (c.skillMoveHidden) return const SizedBox.shrink();
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 43),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(3, 4, 3, 7),
        child: Row(
          children: [
            Expanded(child: _TimingTrack(meter: c.skillMeter)),
            const SizedBox(width: 8),
            RaisedButton(c.skillButtonText, onTap: c.tapMove, height: 38, minWidth: 112, fontSize: 15),
          ],
        ),
      ),
    );
  }
}

class _TimingTrack extends StatelessWidget {
  const _TimingTrack({required this.meter});
  final double meter;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final w = box.maxWidth - 4;
      return Container(
        height: 15,
        decoration: BoxDecoration(
          border: Border.all(color: GameColors.ink, width: 2),
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFFFA9D4C), Color(0xFFF8EF88), Color(0xFF55DC43), Color(0xFF55DC43), Color(0xFFF8EF88), Color(0xFFFA9D4C)],
            stops: [0, .4, .48, .52, .6, 1],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: w * .43,
                width: w * .14,
                top: 0,
                bottom: 0,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.symmetric(vertical: BorderSide(color: Colors.white, width: 2)),
                  ),
                ),
              ),
              Positioned(
                left: w * meter,
                top: -2,
                bottom: -2,
                width: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: GameColors.ink),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
