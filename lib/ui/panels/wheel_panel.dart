import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../components/components.dart';

/// Çarkıfelek: günlük ücretsiz ya da biletli çeviriş.
class WheelPanel extends StatelessWidget {
  const WheelPanel(this.c, {super.key});
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final used = c.state.spinDate == c.todayKey;
    return Column(
      children: [
        const Text('🎡', textAlign: TextAlign.center, style: TextStyle(fontSize: 90, height: 1.3)),
        PanelText(
          'Günlük ücretsiz çeviriş ${used ? 'kullanıldı' : 'hazır'}. Ek bilet: ${c.state.spinTickets}',
          align: TextAlign.center,
          size: 15,
        ),
        ActionButton(
          used ? '1 biletle çevir' : 'Ücretsiz çevir',
          full: true,
          onTap: c.spinWheel,
          enabled: !(used && c.state.spinTickets < 1),
        ),
        const SizedBox(height: 8),
        const PanelText('₺5K–₺20K, elmas veya çark bileti kazan.', align: TextAlign.center, size: 12, color: Color(0xFF536B85), bottom: 0),
      ],
    );
  }
}
