import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../components/components.dart';
import '../theme/theme.dart';
import 'image_panel.dart';

/// Günlük ödül: yedi günlük takvim görseli ve canlı gün düğmeleri.
class DailyPanel extends StatelessWidget {
  const DailyPanel(this.c, {super.key});
  final GameController c;

  static const _spots = [
    [4.5, 45.4, 21.0, 7.0],
    [29.5, 45.4, 20.0, 7.0],
    [52.4, 45.4, 20.0, 7.0],
    [76.0, 45.4, 20.0, 7.0],
    [5.0, 77.5, 20.0, 7.0],
    [30.0, 77.5, 20.0, 7.0],
    [58.0, 77.0, 36.0, 7.0],
  ];

  @override
  Widget build(BuildContext context) {
    final step = c.state.dailyStep % 7;
    final claimed = c.dayClaimed;
    return ImagePanel(
      image: 'assets/images/daily-panel-exact.png',
      aspectRatio: 864 / 910,
      onClose: c.closeModal,
      masks: const [
        [4.5, 45.3, 21.5, 7.2],
        [34.5, 44.8, 9, 7],
        [58, 44.8, 9, 7],
        [81.5, 44.8, 9, 7],
        [11.5, 76, 8.5, 8],
        [37, 76, 8.5, 8],
        [57.5, 76, 37, 8],
      ],
      overlays: (context, layout) => [
        for (var i = 0; i < _spots.length; i++)
          layout.area(
            _spots[i],
            _DayButton(day: i, taken: i < step, ready: i == step && !claimed, tomorrow: i == step && claimed, onClaim: c.claimDaily),
          ),
      ],
    );
  }
}

class _DayButton extends StatelessWidget {
  const _DayButton({required this.day, required this.taken, required this.ready, required this.tomorrow, required this.onClaim});
  final int day;
  final bool taken;
  final bool ready;
  final bool tomorrow;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final green = ready || taken;
    final text = taken
        ? '✓'
        : ready
        ? 'AL'
        : tomorrow
        ? 'YARIN'
        : '🔒';
    return Pressable(
      onTap: ready ? onClaim : null,
      enabled: ready,
      disabledOpacity: 1,
      semanticLabel:
          '${day + 1}. gün: ${taken
              ? 'Alındı'
              : ready
              ? 'Ödülü al'
              : 'Kilitli'}',
      child: Container(
        decoration: green
            ? BoxDecoration(
                gradient: vGradient(const [Color(0xFF68F33C), Color(0xFF04B921)]),
                border: Border.all(color: const Color(0xFF104B19), width: 2),
                borderRadius: BorderRadius.circular(30),
              )
            : null,
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: nunito(
              vwClamp(context, 13, 4, 25),
              color: green ? Colors.white : const Color(0xFF16334A),
              height: 1,
              shadows: green ? const [Shadow(color: Color(0xFF16571C), offset: Offset(0, 2))] : null,
            ),
          ),
        ),
      ),
    );
  }
}
