import 'package:flutter/material.dart';

import '../../game/controller.dart';
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

/// Stadyum başlığı: solda branş etiketi (değiştirme düğmesi yarış şeridinde), ortada yarış/sayaç,
/// sağda takım gücü (sporculara gider).
class _RaceHead extends StatelessWidget {
  const _RaceHead(this.c);
  final GameController c;

  static const _shadow = [Shadow(color: Color(0xBB000000), offset: Offset(0, 1), blurRadius: 2)];

  @override
  Widget build(BuildContext context) {
    final art = c.branchArt;
    return Container(
      height: 52,
      padding: const EdgeInsets.fromLTRB(6, 6, 8, 6),
      color: const Color(0xFF15392F),
      child: Row(
        children: [
          // Branş etiketi (dokununca yine branş penceresi açılır)
          Pressable(
            onTap: () => c.open('branches'),
            semanticLabel: 'Branş: ${c.branchName}, değiştir',
            child: RaisedSurface(
              color: GameColors.navy,
              shade: GameColors.navyShade,
              radius: 13,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 4, 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Art(art, width: 24, height: 24, emojiSize: 20),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 92),
                      child: Text(c.branchName, maxLines: 2, style: gameText(12.5, color: Colors.white, height: 1.05)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Yarış / sayaç
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    c.roundText,
                    maxLines: 1,
                    style: gameText(18, color: const Color(0xFF92D7FF), height: 1, shadows: _shadow),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    c.timerText,
                    maxLines: 1,
                    style: gameText(11.5, color: Colors.white, height: 1.15, shadows: _shadow),
                  ),
                ),
              ],
            ),
          ),
          // Takım gücü
          Pressable(
            onTap: () => c.open('team'),
            semanticLabel: 'Takım gücü ${c.power}, sporcular',
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'TAKIM GÜCÜ',
                  style: gameText(10.5, color: const Color(0xFF91D6FF), height: 1, shadows: _shadow),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Art('team', width: 20, height: 20),
                    const SizedBox(width: 3),
                    Text(
                      '${c.power}',
                      style: gameText(17, color: Colors.white, height: 1, shadows: _shadow),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
