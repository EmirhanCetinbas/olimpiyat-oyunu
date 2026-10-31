import 'package:flutter/material.dart';

import '../../game/data.dart';
import '../components/components.dart';

/// `.runner`: yuvarlak yüz avatarı; oyuncu, kozmetik çerçeve ve branş görünümleri.
class RunnerAvatar extends StatelessWidget {
  const RunnerAvatar({
    super.key,
    required this.animalId,
    required this.player,
    required this.size,
    required this.branch,
    required this.cosmetic,
    this.airborne = false,
    this.jumping = false,
  });

  final int animalId;
  final bool player;
  final double size;
  final String branch;
  final int cosmetic;
  final bool airborne;
  final bool jumping;

  @override
  Widget build(BuildContext context) {
    // Uzun atlama ve halterde mavi konturlu "yuvarlak" görünüm kullanılır.
    final round = branch == 'longjump' || branch == 'weights';
    final Color border;
    final double borderWidth;
    final Color background;
    List<BoxShadow> shadows;
    if (round) {
      border = player ? const Color(0xFFFFC226) : const Color(0xFF0763AB);
      borderWidth = 2;
      background = const Color(0xFFEFFAFF);
      shadows = player
          ? const [BoxShadow(color: Colors.white, spreadRadius: 1), BoxShadow(color: Color(0xFFFFDD45), blurRadius: 5)]
          : const [
              BoxShadow(color: Colors.white, spreadRadius: 1),
              BoxShadow(color: Color(0x5510283B), offset: Offset(0, 2), blurRadius: 2),
            ];
      if (airborne) {
        shadows = const [
          BoxShadow(color: Color(0xFF9DE9FF), spreadRadius: 2),
          BoxShadow(color: Color(0x6610283B), offset: Offset(0, 4), blurRadius: 6),
        ];
      }
    } else {
      border = player ? const Color(0xFFFFB900) : const Color(0xFF172637);
      borderWidth = 1.5;
      background = const Color(0xFFF4F9EC);
      shadows = player
          ? const [BoxShadow(color: Colors.white, spreadRadius: 1.5), BoxShadow(color: Color(0xFFFFE94E), blurRadius: 8)]
          : const [BoxShadow(color: Color(0x44000000), offset: Offset(0, 1))];
    }
    if (jumping) shadows = [...shadows, const BoxShadow(color: Colors.white, blurRadius: 5)];
    final faceSize = size - borderWidth * 2 - 2;
    final small = branch == 'hurdles' || branch == 'swim';
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AvatarFrame(
            cosmetic: player ? cosmetic : -1,
            size: size,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: background,
                border: Border.all(color: border, width: borderWidth),
                boxShadow: shadows,
              ),
              child: Center(
                child: Art(animals[animalId].art, width: faceSize, height: faceSize, radius: BorderRadius.circular(size)),
              ),
            ),
          ),
          if (player && !round)
            Positioned(
              left: small ? 4 : 6,
              top: small ? -12 : -14,
              child: Text(
                '▼',
                style: TextStyle(
                  fontSize: small ? 9 : 11,
                  height: 1,
                  color: const Color(0xFFFFE44A),
                  shadows: const [Shadow(color: Color(0xFF15273C), offset: Offset(0, 1))],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
