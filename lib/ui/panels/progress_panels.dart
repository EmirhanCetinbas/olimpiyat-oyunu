import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/data.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// Üç yarışlık kupa: üç yarış yuvası (kazanılan sıra madalya olarak), ödül ve başlat.
class TournamentPanel extends StatelessWidget {
  const TournamentPanel(this.c, {super.key});
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final t = c.state.tournament;
    final running = t != null && t.attempts < 3;
    final finished = t != null && t.attempts >= 3;
    final won = finished && t.podiums >= 2;
    Widget slot(int i) {
      final place = t != null && i < t.places.length ? t.places[i] : null;
      final played = t != null && i < t.attempts;
      return Expanded(
        child: Column(
          children: [
            SizedBox(
              height: 78,
              child: Center(
                child: place != null
                    ? MedalBadge(place: place, medal: isMedal(t!.branch, place), size: 58)
                    : Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEDE6D4),
                          border: Border.all(color: const Color(0xFFC9BC9C), width: 2.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(played ? '✓' : '${i + 1}', style: gameText(22, color: const Color(0xFFA89A78), height: 1)),
                      ),
              ),
            ),
            Text('${i + 1}. yarış', style: gameText(12.5, color: GameColors.slate, height: 1.1)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Text(
          t != null ? branchLabel(t.branch) : 'Seçili branş: ${branchLabel(c.state.branch)}',
          style: gameText(TextSizes.cardTitle, color: GameColors.ink, height: 1.2),
        ),
        const SizedBox(height: 8),
        Row(children: [slot(0), slot(1), slot(2)]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: flatCardDecoration(radius: 16, color: won ? const Color(0xFFF0FBE6) : GameColors.row),
          child: Row(
            children: [
              const RewardIcon('gift', size: 38),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  won
                      ? 'Kupa kazanıldı: Kupa Çantası ve 1 SP alındı!'
                      : 'Üç yarışta en az 2 kez ${medalPlaces(fieldSize(t?.branch ?? c.state.branch)) == 2 ? 'ilk ikiye' : 'ilk üçe'} gir: Kupa Çantası + 1 SP',
                  style: gameText(13.5, color: GameColors.ink, height: 1.2),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Text('${t?.podiums ?? 0}/2', style: gameText(20, color: GameColors.greenShade, height: 1)),
                  Text('madalya', style: gameText(11, color: GameColors.slate, height: 1)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text('Toplam kupa: ${c.state.tournamentCups}', style: gameText(13, color: GameColors.slate, height: 1.2)),
        ActionButton(
          running ? 'Kupa sürüyor · yarışa başla' : (finished ? 'Yeni kupa başlat' : 'Kupayı başlat'),
          full: true,
          onTap: running ? c.closeModal : c.pressTournamentStart,
          enabled: c.race == null,
        ),
      ],
    );
  }
}
