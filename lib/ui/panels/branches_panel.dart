import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../components/components.dart';

/// Spor branşları ve kupa girişi.
class BranchesPanel extends StatelessWidget {
  const BranchesPanel(this.c, {super.key});
  final GameController c;

  static const _branches = [
    ('sprint', '100 metre koşu'),
    ('hurdles', 'Engelli koşu'),
    ('swim', 'Yüzme'),
    ('longjump', 'Uzun atlama'),
    ('weights', 'Halter'),
    ('archery', 'Okçuluk'),
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const PanelText('Oynamak istediğin yarışı seç.'),
      ActionButton('🏆 Üç Yarışlık Kupa', full: true, onTap: () => c.open('tournament')),
      for (var i = 0; i < _branches.length; i++)
        ListRow(
          children: [
            RowTitle(_branches[i].$2),
            ActionButton(
              c.state.branch == _branches[i].$1 ? 'Seçili' : 'Oyna',
              onTap: () => c.selectBranch(_branches[i].$1),
              enabled: c.race == null,
            ),
          ],
        ),
    ],
  );
}
