import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// `.race-call`: başlat düğmesi ve (koşu/okçulukta) bilgi etiketi; branşa göre yerleşir.
class RaceCall extends StatelessWidget {
  const RaceCall({super.key, required this.c, required this.layout});
  final GameController c;
  final PercentLayout layout;

  @override
  Widget build(BuildContext context) {
    final branch = c.state.branch;
    // Tüm branşlarda aynı yer: sahanın ortasında bilgi etiketi + başlat düğmesi.
    // 100 m ve okçulukta stadyum zaten bulanık; diğer arenalarda hafif karartma sporcuların üstünü örtmeden odak verir.
    final blurred = branch == 'sprint' || branch == 'archery';
    final label = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: layout.width * .82),
      child: Pill(
        c.raceCallText,
        style: gameText(13.5, color: GameColors.ink, height: 1.15),
        textAlign: TextAlign.center,
        color: const Color(0xF5FFFBED),
        borderColor: GameColors.ink,
        borderWidth: 2,
        radius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      ),
    );
    return Positioned.fill(
      child: ColoredBox(
        color: blurred ? Colors.transparent : const Color(0x40071D27),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              label,
              const SizedBox(height: 10),
              RaisedButton(c.startText, onTap: c.beginRace, height: 46, fontSize: 20),
            ],
          ),
        ),
      ),
    );
  }
}
