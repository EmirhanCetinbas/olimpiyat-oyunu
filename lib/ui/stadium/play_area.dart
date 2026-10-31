import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../components/components.dart';
import '../home/race_strip.dart';
import 'stadium.dart';

/// Oyun alanı: stadyum ve altındaki yarış şeridi. Zamanlama hamlesi açıkken bu alanın
/// herhangi bir yerine dokunmak hamleyi yapar (alttaki düğmeler o kısa süre için devre dışı).
class PlayArea extends StatelessWidget {
  const PlayArea({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final move = c.activeMove;
    final active = !c.skillMoveHidden && move != null && !move.tapped;
    return Stack(
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RepaintBoundary(child: Stadium()),
            RaceStrip(),
          ],
        ),
        if (active)
          Positioned.fill(
            child: Semantics(
              button: true,
              label: c.skillButtonText,
              child: GestureDetector(behavior: HitTestBehavior.opaque, onTapDown: (_) => c.tapMove()),
            ),
          ),
      ],
    );
  }
}
