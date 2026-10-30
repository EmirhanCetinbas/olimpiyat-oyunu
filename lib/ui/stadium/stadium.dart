import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/format.dart';
import '../components/components.dart';
import '../theme/theme.dart';
import 'field.dart';
import 'skill_overlay.dart';

/// `<section class="stadium">`: yarış başlığı ve canlı saha.
class Stadium extends StatelessWidget {
  const Stadium({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final branch = c.state.branch;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF174838),
        border: Border.all(color: GameColors.ink, width: 3),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Color(0x66347A32), offset: Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (branch == 'sprint' || branch == 'archery')
              Positioned.fill(child: Image.asset('assets/images/stadium.png', fit: BoxFit.fill)),
            // Sahne katmanı; başlık yeri boş tutulur.
            Column(
              children: [
                Visibility(visible: false, maintainSize: true, maintainAnimation: true, maintainState: true, child: _RaceHead(c)),
                const RaceField(layer: FieldLayer.below),
              ],
            ),
            // `.stadium.idle:before`: bekleme bulanıklığı tüm stadyumu örter (CSS blur 2.2px).
            if (c.stadiumIdle && (branch == 'sprint' || branch == 'archery'))
              Positioned.fill(child: blurLayer(2.2, const Color(0x22112233))),
            Column(
              children: [
                _RaceHead(c),
                const RaceField(layer: FieldLayer.above),
              ],
            ),
            // Zamanlama hamlesi yalnız sahanın üstünde (başlık şeridinin altında).
            Positioned.fill(
              child: Column(
                children: [
                  Visibility(visible: false, maintainSize: true, maintainAnimation: true, maintainState: true, child: _RaceHead(c)),
                  Expanded(
                    child: Stack(children: [SkillOverlay(c: c)]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `.race-head`: para, tur/sayaç ve takım gücü.
class _RaceHead extends StatelessWidget {
  const _RaceHead(this.c);
  final GameController c;

  static const _darkShadow = [Shadow(color: Color(0xBB000000), offset: Offset(0, 1), blurRadius: 2)];

  @override
  Widget build(BuildContext context) {
    final hurdle = c.state.branch == 'hurdles';
    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            flex: 100,
            child: SizedBox(
              height: 29,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Art('bank', width: 25, height: 25),
                  Text(
                    fmt(c.state.money),
                    style: gameText(
                      15,
                      shadows: const [Shadow(color: Colors.white, offset: Offset(0, 1), blurRadius: 2)],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 115,
            child: Padding(
              padding: const EdgeInsets.all(3.5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    c.roundText,
                    style: gameText(hurdle ? 18 : 19, color: const Color(0xFF92D7FF), height: 1, shadows: _darkShadow),
                  ),
                  Text(
                    c.timerText,
                    style: gameText(hurdle ? 11 : 10, color: Colors.white, height: 1, letterSpacing: .3, shadows: _darkShadow),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 100,
            child: Pressable(
              onTap: () => c.open('team'),
              semanticLabel: 'Takımın',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TAKIMIN',
                    style: gameText(11, color: const Color(0xFF91D6FF), shadows: _darkShadow),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Art('team', width: 22, height: 22),
                      const SizedBox(width: 3),
                      Text(
                        '${c.power}',
                        style: gameText(15, color: Colors.white, shadows: _darkShadow),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
