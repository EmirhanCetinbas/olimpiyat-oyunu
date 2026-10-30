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
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color, width: 2),
  );

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PanelText('Takımının adı'),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 10),
          child: TextField(
            controller: _name,
            maxLength: 24,
            style: nunito(14, color: GameColors.ink),
            decoration: InputDecoration(
              counterText: '',
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(8),
              semanticCounterText: 'Takım adı',
              enabledBorder: _border(const Color(0xFF89A79A)),
              focusedBorder: _border(const Color(0xFFFFCA39)),
            ),
          ),
        ),
        ActionButton('Kaydet', onTap: () => c.saveName(_name.text)),
        StatGrid([('${c.level}', 'Seviye'), ('${c.state.races}', 'Yarış'), ('${c.state.wins}', 'Zafer')]),
        PanelText.muted(
          c.storageOK
              ? 'İlerlemen otomatik olarak bu cihazda saklanır.'
              : 'Cihaz kaydı kullanılamıyor; oyunu kapatırsan ilerleme kaybolabilir.',
        ),
      ],
    );
  }
}
