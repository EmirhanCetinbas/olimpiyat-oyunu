import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/data.dart';
import '../components/components.dart';

/// Hayvan takımı: sporcu seçimi.
class TeamPanel extends StatelessWidget {
  const TeamPanel(this.c, {super.key});
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final s = c.state;
    return Column(
      children: [
        for (var i = 0; i < animals.length; i++)
          ListRow(
            locked: s.races < animals[i].unlock,
            children: [
              Art(animals[i].art, width: 36, height: 36, radius: BorderRadius.circular(18)),
              RowTitle(animals[i].name, small: '${animals[i].trait} · Uzmanlık: ${specialtyLabel(i)}'),
              ActionButton(
                s.races < animals[i].unlock
                    ? '${animals[i].unlock} yarış'
                    : s.selected == i
                    ? 'Seçili'
                    : 'Seç',
                onTap: () => c.selectAnimal(i),
                enabled: s.races >= animals[i].unlock && c.race == null,
              ),
            ],
          ),
        if (c.race != null) const PanelText.muted('Sporcunu yarış bitince değiştirebilirsin.'),
      ],
    );
  }
}
