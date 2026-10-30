import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'outlined_text.dart';
import 'raised_surface.dart';

/// Kurdeleli madalya: 1 altın, 2 gümüş, 3 bronz, diğerleri gri; ortada sıra numarası.
class MedalBadge extends StatelessWidget {
  const MedalBadge({super.key, required this.place, this.size = 96});
  final int place;
  final double size;

  static const _tones = [
    (Color(0xFFFFC83D), Color(0xFF9A6A00)),
    (Color(0xFFD3DCE3), Color(0xFF5E6E7A)),
    (Color(0xFFE59A5B), Color(0xFF7A4012)),
  ];

  @override
  Widget build(BuildContext context) {
    final (color, shade) = place >= 1 && place <= 3 ? _tones[place - 1] : (GameColors.locked, GameColors.lockedShade);
    final ribbon = place <= 3;
    Widget strap(double angle, Color c) => Transform.rotate(
      angle: angle,
      child: Container(
        width: size * .26,
        height: size * .5,
        decoration: BoxDecoration(
          color: c,
          border: Border.all(color: GameColors.ink, width: 2.5),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
    return SizedBox(
      width: size,
      height: size * 1.25,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          if (ribbon) ...[
            Positioned(top: 0, left: size * .22, child: strap(.3, GameColors.coral)),
            Positioned(top: 0, right: size * .22, child: strap(-.3, GameColors.blue)),
          ],
          SizedBox(
            width: size,
            height: size,
            child: RaisedSurface(
              color: color,
              shade: shade,
              radius: size / 2,
              lip: 5,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: OutlinedText(
                    '$place',
                    shadowOffset: const Offset(0, 3),
                    style: gameText(size * .46, color: Colors.white, height: 1),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
