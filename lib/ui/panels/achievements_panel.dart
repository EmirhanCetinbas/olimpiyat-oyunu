import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../components/components.dart';
import '../theme/theme.dart';
import 'image_panel.dart';

/// Başarımlar: sağlanan görsel, üzerinde tek canlı kontrol katmanı.
class AchievementsPanel extends StatelessWidget {
  const AchievementsPanel(this.c, {super.key});
  final GameController c;

  static const _tops = [30.7, 47.0, 63.2, 79.4];
  static const _goals = [1, 3, 5, 3];

  @override
  Widget build(BuildContext context) {
    final s = c.state;
    final values = [s.races, s.wins, s.levels[4], s.levels[5]];
    return ImagePanel(
      image: 'assets/images/achievements-panel-exact.png',
      aspectRatio: 729 / 861,
      onClose: c.closeModal,
      masks: const [
        [7, 16, 87, 5.5],
        [86, 26, 10.5, 10],
        [86, 42, 10.5, 10],
        [86, 58.2, 10.5, 10],
        [86, 74.4, 10.5, 10],
        [22.5, 33, 40.5, 4.2],
        [22.5, 49.3, 40.5, 4.2],
        [22.5, 65.5, 40.5, 4.2],
        [22.5, 81.7, 40.5, 4.2],
      ],
      overlays: (context, layout) => [
        layout.rect(8, 16.6, 72, 4, GameProgressBar(value: s.claims.length / achievements.length, label: 'Alınan başarımlar')),
        layout.rect(
          82,
          17,
          13,
          5,
          Center(
            child: Text(
              '${s.claims.length} / ${achievements.length}',
              style: nunito(vwClamp(context, 12, 3, 18), weight: 1000, color: const Color(0xFF07192E), height: 1),
            ),
          ),
        ),
        for (var i = 0; i < achievements.length; i++) ...[
          layout.rect(
            23.2,
            _tops[i] + 2,
            39,
            4,
            _ProgressRow(done: values[i].clamp(0, _goals[i]), goal: _goals[i], label: achievements[i].title),
          ),
          layout.rect(86, _tops[i] - 4, 10, 8, _ClaimButton(c, i)),
        ],
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.done, required this.goal, required this.label});
  final int done;
  final int goal;
  final String label;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, row) {
      return Row(
        children: [
          SizedBox(
            width: row.maxWidth * .8,
            height: row.maxHeight * .72,
            child: GameProgressBar(value: done / goal, label: label),
          ),
          SizedBox(width: row.maxWidth * .04),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('$done / $goal', style: nunito(vwClamp(context, 10, 2.5, 15), color: GameColors.ink)),
            ),
          ),
        ],
      );
    },
  );
}

class _ClaimButton extends StatelessWidget {
  const _ClaimButton(this.c, this.i);
  final GameController c;
  final int i;

  @override
  Widget build(BuildContext context) {
    final a = achievements[i];
    final taken = c.state.claims.contains(a.id), ready = a.done(c.state) && !taken;
    final semantic =
        '${a.title}: ${taken
            ? 'Alındı'
            : ready
            ? 'Ödülü al'
            : 'Kilitli'}';
    if (!taken && !ready) {
      return Pressable(
        onTap: null,
        enabled: false,
        semanticLabel: semantic,
        child: Center(
          child: Text(
            '🔒',
            style: TextStyle(fontSize: vwClamp(context, 17, 4, 24), color: const Color(0xFF123450)),
          ),
        ),
      );
    }
    return Pressable(
      onTap: ready ? () => c.claimAchievement(a.id) : null,
      enabled: ready,
      semanticLabel: semantic,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: vGradient(taken ? const [Color(0xFF45E654), Color(0xFF00AD24)] : const [Color(0xFF70EF49), Color(0xFF08BC27)]),
          border: Border.all(color: taken ? const Color(0xFF126332) : const Color(0xFF0C5820), width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          taken ? '✓' : 'AL',
          style: nunito(
            vwClamp(context, 10, 2.4, 15),
            color: Colors.white,
            height: 1,
            shadows: const [Shadow(color: Color(0xFF143C1D), offset: Offset(0, 1))],
          ),
        ),
      ),
    );
  }
}
