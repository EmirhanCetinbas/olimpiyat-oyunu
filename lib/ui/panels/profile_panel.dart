import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../components/components.dart';
import '../theme/theme.dart';

class ProfilePanel extends StatefulWidget {
  const ProfilePanel(this.c, {super.key});
  final GameController c;

  @override
  State<ProfilePanel> createState() => _ProfilePanelState();
}

class _ProfilePanelState extends State<ProfilePanel> {
  late final _name = TextEditingController(text: widget.c.state.name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: color, width: 2.5),
  );

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PanelText('Takımının adı'),
        // Ad alanı ve Kaydet tek satırda.
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _name,
                maxLength: 24,
                style: gameText(16, color: GameColors.ink),
                textInputAction: TextInputAction.done,
                onSubmitted: c.saveName,
                decoration: InputDecoration(
                  counterText: '',
                  isDense: true,
                  filled: true,
                  fillColor: GameColors.row,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  semanticCounterText: 'Takım adı',
                  enabledBorder: _border(GameColors.ink),
                  focusedBorder: _border(GameColors.blue),
                ),
              ),
            ),
            const SizedBox(width: 9),
            ActionButton('Kaydet', onTap: () => c.saveName(_name.text)),
          ],
        ),
        StatGrid([('${c.level}', 'Seviye'), ('${c.state.races}', 'Yarış'), ('${c.state.wins}', 'Zafer'), ('${c.state.medals}', 'Madalya')]),
        // Sonraki seviyeye XP (her 100 XP bir seviye).
        Row(
          children: [
            Expanded(child: GameProgressBar(value: (c.state.xp % 100) / 100, label: 'Seviye ilerlemesi', height: 14)),
            const SizedBox(width: 8),
            Text('${c.state.xp % 100} / 100 XP', style: gameText(13, color: GameColors.ink, height: 1)),
          ],
        ),
        const SizedBox(height: 10),
        PanelText.muted(
          c.storageOK
              ? 'İlerlemen otomatik olarak bu cihazda saklanır.'
              : 'Cihaz kaydı kullanılamıyor; oyunu kapatırsan ilerleme kaybolabilir.',
        ),
      ],
    );
  }
}
