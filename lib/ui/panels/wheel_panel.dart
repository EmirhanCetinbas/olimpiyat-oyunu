import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/data.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// Çarkıfelek: gerçek ödül dilimleriyle çizilmiş çark; günlük ücretsiz ya da biletli çeviriş.
class WheelPanel extends StatelessWidget {
  const WheelPanel(this.c, {super.key});
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final used = c.state.spinDate == c.todayKey;
    Widget status(String label, String value, {required bool ok}) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: flatCardDecoration(radius: 14, color: ok ? const Color(0xFFE6FBD9) : GameColors.row),
        child: Column(
          children: [
            Text(value, style: gameText(17, color: ok ? GameColors.greenShade : GameColors.ink, height: 1.1)),
            Text(label, style: gameText(12, color: GameColors.slate, height: 1.1)),
          ],
        ),
      ),
    );
    return Column(
      children: [
        PrizeWheel(size: 210, labels: [for (final p in wheelPrizes) p.label.replaceFirst(' ', '\n')]),
        const SizedBox(height: 10),
        Row(
          children: [
            status('Günlük çeviriş', used ? 'Kullanıldı' : 'Hazır', ok: !used),
            const SizedBox(width: 8),
            status('Çark bileti', '${c.state.spinTickets}', ok: c.state.spinTickets > 0),
          ],
        ),
        ActionButton(
          used ? '1 biletle çevir' : 'Ücretsiz çevir',
          full: true,
          onTap: c.spinWheel,
          enabled: !(used && c.state.spinTickets < 1),
        ),
      ],
    );
  }
}
