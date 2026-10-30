import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/data.dart';
import '../components/components.dart';

/// Üç yarışlık kupa.
class TournamentPanel extends StatelessWidget {
  const TournamentPanel(this.c, {super.key});
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final t = c.state.tournament;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PanelText(t != null ? 'Branş: ${branchLabel(t.branch)}' : 'Seçili branşta üç yarışlık kupa başlat.'),
        StatGrid([('${t?.attempts ?? 0}/3', 'Yarış'), ('${t?.podiums ?? 0}/2', 'Gerekli madalya'), ('${c.state.tournamentCups}', 'Kupa')]),
        const PanelText.muted('Üç yarışta en az iki kez ilk üçe gir: Kupa Çantası ve 1 SP kazan.'),
        ActionButton(
          t != null && t.attempts >= 3 ? 'Yeni turnuva' : 'Turnuvayı başlat',
          full: true,
          onTap: c.pressTournamentStart,
          enabled: !(c.race != null || (t != null && t.attempts < 3)),
        ),
      ],
    );
  }
}
