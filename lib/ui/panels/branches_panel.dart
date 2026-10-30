import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../components/components.dart';

/// Spor branşları ve kupa girişi.
class BranchesPanel extends StatelessWidget {
  const BranchesPanel(this.c, {super.key});
  final GameController c;

  static const _branches = [
    ('sprint', '100 metre koşu', 'shoe'),
    ('hurdles', 'Engelli koşu', 'speed'),
    ('swim', 'Yüzme', 'swim-wave'),
    ('longjump', 'Uzun atlama', 'jump-start'),
    ('weights', 'Halter', 'weight-strength'),
    ('archery', 'Okçuluk', 'archery-bow'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = c.state.tournament;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kupa: ayrı kart, durumu ile.
        ListRow(
          children: [
            const Art('trophy', width: 40, height: 40),
            RowTitle(
              'Üç Yarışlık Kupa',
              small: t != null && t.attempts < 3
                  ? 'Sürüyor · ${t.attempts}/3 yarış, ${t.podiums}/2 madalya'
                  : 'Üç yarışta iki madalya: Kupa Çantası + 1 SP',
            ),
            ActionButton('Aç', onTap: () => c.open('tournament')),
          ],
        ),
        const SizedBox(height: 4),
        const PanelText('Oynamak istediğin yarışı seç.', bottom: 8),
        for (final (id, name, art) in _branches)
          ListRow(
            children: [
              Art(art, width: 36, height: 36, emojiSize: 28),
              RowTitle(name),
              if (c.state.branch == id)
                const SelectedTag()
              else
                ActionButton('Oyna', onTap: () => c.selectBranch(id), enabled: c.race == null),
            ],
          ),
      ],
    );
  }
}
