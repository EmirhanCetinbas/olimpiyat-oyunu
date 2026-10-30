import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/data.dart';
import '../../game/format.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// Halter: kilogram tabelası, hareketli halter ve sonuç etiketi.
class WeightHud extends StatelessWidget {
  const WeightHud({super.key, required this.c, required this.layout});
  final GameController c;
  final PercentLayout layout;

  @override
  Widget build(BuildContext context) {
    final result = c.weightResultText;
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            layout.point(
              50,
              34,
              Pill(
                c.weightKgText,
                style: nunito(13, color: Colors.white, height: 1),
                gradient: vGradient(const [Color(0xFF536074), Color(0xFF253243)]),
                borderColor: GameColors.ink,
                borderWidth: 2,
                radius: 6,
                insets: const [Inset(Color(0xFFB2BFCA), dy: 1)],
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
              ),
            ),
            layout.point(
              50,
              c.weightBarTop,
              Transform.rotate(
                angle: c.weightBarTilt * 3.14159265 / 180,
                child: Image.asset('assets/images/weights-barbell.png', width: layout.x(40)),
              ),
            ),
            if (result.isNotEmpty)
              layout.point(
                50,
                75,
                Pill(
                  result,
                  style: nunito(
                    11,
                    color: Colors.white,
                    shadows: const [Shadow(color: GameColors.ink, offset: Offset(0, 1))],
                  ),
                  color: c.weightResultFailed ? const Color(0xEDB52D36) : const Color(0xE8168825),
                  radius: 7,
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Okçuluk: uçan ok ve toplam puan.
class ArcheryHud extends StatelessWidget {
  const ArcheryHud({super.key, required this.c, required this.layout});
  final GameController c;
  final PercentLayout layout;

  @override
  Widget build(BuildContext context) {
    final score = c.archeryScoreText;
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (!c.archeryArrowHidden)
              layout.point(
                c.archeryArrowLeft,
                c.archeryArrowTop,
                Text(
                  '➶',
                  style: TextStyle(
                    fontSize: 28,
                    height: 1,
                    color: const Color(0xFFFFCF2C),
                    shadows: [
                      ...outlineShadows(const Color(0xFF14293F), 1.5),
                      const Shadow(color: Color(0xFF102539), offset: Offset(0, 1), blurRadius: 3),
                    ],
                  ),
                ),
              ),
            if (score.isNotEmpty)
              Positioned(
                top: layout.y(24),
                left: 0,
                right: 0,
                child: Center(
                  child: Pill(
                    score,
                    style: nunito(13, color: Colors.white),
                    color: const Color(0xE8142D42),
                    borderColor: const Color(0xFFFFF9D6),
                    borderWidth: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Uzun atlama iniş bayrağı; dokununca mesafeyi gösterir.
class JumpFlag extends StatelessWidget {
  const JumpFlag({super.key, required this.c, required this.index, required this.layout});
  final GameController c;
  final int index;
  final PercentLayout layout;

  @override
  Widget build(BuildContext context) {
    final r = c.jumpCompleted[index];
    final p = jumpLanding(r.metres, index);
    // 18×21 bayrak, 34pt dokunma alanının ortasında (web: translate(-3px,-100%)).
    return Positioned(
      left: layout.x(p.x) - 3 - 8,
      top: layout.y(p.y) - 21 - 6.5,
      child: Pressable(
        onTap: () => c.showJumpResult(index),
        minTapSize: 34,
        semanticLabel: '${animals[r.id].name}: ${jumpMetres(r.metres)}',
        child: SizedBox(
          width: 18,
          height: 21,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Text(
                '⚑',
                style: TextStyle(
                  fontSize: 24,
                  height: 21 / 24,
                  color: Color(jumpColors[index]),
                  shadows: outlineShadows(GameColors.ink, 1),
                ),
              ),
              Positioned(
                left: 8,
                top: 3,
                child: Text('${index + 1}', style: nunito(8, color: GameColors.ink, height: 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
