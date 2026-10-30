import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../components/components.dart';
import '../../game/data.dart';
import '../theme/theme.dart';
import 'runner_avatar.dart';

/// `.race-call`: başlat düğmesi ve (koşu/okçulukta) bilgi etiketi; branşa göre yerleşir.
class RaceCall extends StatelessWidget {
  const RaceCall({super.key, required this.c, required this.layout});
  final GameController c;
  final PercentLayout layout;

  @override
  Widget build(BuildContext context) {
    final branch = c.state.branch;
    final blurred = branch == 'sprint' || branch == 'archery';
    final animal = animals[c.state.selected];
    // Sahanın ortasında: senin sporcun (çerçevesiyle), kısa çağrı ve başlat düğmesi.
    final hero = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RunnerAvatar(animalId: c.state.selected, player: true, size: 44, branch: 'longjump', cosmetic: c.state.selectedCosmetic),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(animal.name, style: gameText(16, color: GameColors.ink, height: 1.1)),
              Text(c.raceCallText, style: gameText(12.5, color: GameColors.slate, height: 1.15)),
            ],
          ),
        ),
      ],
    );
    return Positioned.fill(
      child: ColoredBox(
        color: blurred ? Colors.transparent : const Color(0x40071D27),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: layout.width * .84),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
                  decoration: flatCardDecoration(radius: 16, color: const Color(0xF5FFFBED)),
                  child: hero,
                ),
              ),
              const SizedBox(height: 10),
              RaisedButton(c.startText, onTap: c.beginRace, height: 46, fontSize: 20),
            ],
          ),
        ),
      ),
    );
  }
}
