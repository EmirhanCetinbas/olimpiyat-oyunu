import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/data.dart';
import '../../game/format.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// Çaylaklar Ligi: sezon ve rekorlar.
class LeaguePanel extends StatelessWidget {
  const LeaguePanel(this.c, {super.key});
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final s = c.state;
    final value = nunito(14, color: GameColors.ink);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PanelText('Her 10 yarış bir sezon. Madalyalar ve rekorlar takımının ilerlemesini gösterir.'),
        StatGrid([('${s.races ~/ 10 + 1}', 'Sezon'), ('${s.races % 10}/10', 'Yarış'), ('${s.medals}', 'Madalya')]),
        ListRow(
          children: [
            const RowTitle('En iyi derecen'),
            Text(s.best != null ? '${s.best!.toStringAsFixed(2)} sn' : 'Henüz yok', style: value),
          ],
        ),
        ListRow(
          last: true,
          children: [
            const RowTitle('Toplam zafer'),
            Text('${s.wins}', style: value),
          ],
        ),
        const PanelText.muted('Rakipler bilgisayar tarafından yönetilir.'),
      ],
    );
  }
}

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

/// Antrenman kampı.
class CampPanel extends StatelessWidget {
  const CampPanel(this.c, {super.key});
  final GameController c;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const PanelText('Kampı büyüt; takım gücünü ve sporcularının gelişimini artır.'),
      StatGrid([('${c.state.camp}', 'Kamp seviyesi'), ('${100 + (c.state.camp - 1) * 10}', 'Kamp gücü'), ('+10', 'Sonraki seviye')]),
      ActionButton('Kampı geliştir · ₺${fmt(c.campCost())}', full: true, onTap: c.buyCamp, enabled: c.state.money >= c.campCost()),
    ],
  );
}
