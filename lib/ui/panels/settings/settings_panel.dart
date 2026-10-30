import 'package:flutter/material.dart';

import '../../../game/controller.dart';
import '../../components/components.dart';
import '../../theme/theme.dart';
import 'prefs_controls.dart';
import 'prefs_layout.dart';

/// Ayarlar: tamamen kodla kurulan panel (görsel ya da koordinat yaması yok).
class SettingsPanel extends StatelessWidget {
  const SettingsPanel(this.c, {super.key});
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final s = c.state;
    final narrow = MediaQuery.sizeOf(context).width <= 360;
    final switchWidth = narrow ? 96.0 : 108.0;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF0B2635), width: 3),
        borderRadius: BorderRadius.circular(25),
        gradient: const RadialGradient(
          center: Alignment(-.4, -.5),
          radius: 1.1,
          colors: [Color(0xFFFFFBED), Color(0xFFFFF5DF)],
          stops: [0, .75],
        ),
        boxShadow: const [BoxShadow(color: Color(0x20061D25), offset: Offset(0, 8))],
      ),
      padding: EdgeInsets.fromLTRB(narrow ? 9 : 12, 0, narrow ? 9 : 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Heading(onClose: c.closeModal),
          PrefsSection(
            title: 'SES',
            rows: [
              PrefsRow(
                icon: 'music',
                label: 'MÜZİK',
                wide: true,
                control: PrefsSlider(value: s.musicVolume, label: 'Müzik', onChanged: c.setMusicVolume),
              ),
              PrefsRow(
                icon: 'sound',
                label: 'SES',
                wide: true,
                control: PrefsSlider(value: s.sound ? s.soundVolume : 0, label: 'Ses', onChanged: c.setSoundVolume),
              ),
              PrefsRow(
                icon: 'vibration',
                label: 'TİTREŞİM',
                wide: true,
                control: PrefsSwitch(value: s.vibration, label: 'Titreşim', onChanged: c.setVibration, width: switchWidth),
              ),
            ],
          ),
          PrefsSection(
            title: 'OYUN',
            rows: [
              PrefsRow(
                icon: 'shoe',
                label: 'OTOMATİK YARIŞ',
                control: PrefsSwitch(value: s.auto, label: 'Otomatik yarış', onChanged: c.setAutoSetting, width: switchWidth),
              ),
              PrefsRow(
                icon: 'pause',
                label: 'OYUNU DURAKLAT',
                control: PrefsSwitch(value: c.paused, label: 'Oyunu duraklat', onChanged: c.setPaused, width: switchWidth),
              ),
            ],
          ),
          PrefsSection(
            title: 'KAYIT',
            rows: [
              PrefsRow(
                icon: 'save',
                label: 'CİHAZ KAYDI',
                control: PrefsStatus(active: c.storageOK),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                Expanded(
                  child: PrefsActionTile(icon: 'support', label: 'DESTEK', onTap: c.openSupport),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PrefsActionTile(icon: 'reset', label: 'İLERLEMEYİ\nSIFIRLA', onTap: c.askReset),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'SÜRÜM 1.0',
              textAlign: TextAlign.center,
              style: nunito(11, color: const Color(0xFF7B8988), height: 14 / 11),
            ),
          ),
        ],
      ),
    );
  }
}

/// AYARLAR başlığı ve yeşil kapat düğmesi.
class _Heading extends StatelessWidget {
  const _Heading({required this.onClose});
  final VoidCallback onClose;

  static const _shadowOffsets = [
    Offset(-2, -2),
    Offset(0, -2),
    Offset(2, -2),
    Offset(2, 0),
    Offset(2, 2),
    Offset(0, 3),
    Offset(-2, 2),
    Offset(-2, 0),
  ];

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width <= 360;
    final short = ScreenMetrics.of(context).short;
    return LayoutBuilder(
      builder: (context, box) {
        return Padding(
          padding: EdgeInsets.only(left: box.maxWidth * (narrow ? .08 : .11), bottom: short ? 8 : 10),
          child: Row(
            children: [
              Expanded(
                child: BannerTitle(
                  'AYARLAR',
                  semanticsLabel: 'Ayarlar',
                  fontSize: vwClamp(context, 27, 7.7, 38),
                  weight: 900,
                  height: 1.12,
                  gradient: angleGradient(
                    170,
                    const [Color(0xFFFF8270), Color(0xFFFF6456), Color(0xFFFF6254), Color(0xFFFF5347)],
                    const [0, .2, .7, 1],
                  ),
                  borderColor: const Color(0xFF0A2033),
                  radius: 21,
                  padding: EdgeInsets.fromLTRB(3, short ? 7 : 9, 3, short ? 9 : 11),
                  shadows: const [BoxShadow(color: Color(0x75D4C39A), offset: Offset(0, 5))],
                  insets: const [Inset(Color(0xFFFFAD9F), dy: 5), Inset(Color(0xFFE34137), dy: -4)],
                  textShadows: [for (final o in _shadowOffsets) Shadow(color: const Color(0xFF102633), offset: o)],
                ),
              ),
              SizedBox(width: narrow ? 7 : 10),
              RoundCloseButton.settings(onTap: onClose, semanticLabel: 'Ayarları kapat'),
            ],
          ),
        );
      },
    );
  }
}
