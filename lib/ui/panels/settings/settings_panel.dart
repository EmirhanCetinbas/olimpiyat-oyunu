import 'package:flutter/material.dart';

import '../../../game/controller.dart';
import '../../components/components.dart';
import '../../theme/theme.dart';
import 'prefs_controls.dart';
import 'prefs_layout.dart';

/// Ayarlar: ortak pencere dilinin (GameModal) örnek ekranı; tamamen kodla kurulur.
class SettingsPanel extends StatelessWidget {
  const SettingsPanel(this.c, {super.key});
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final s = c.state;
    final m = ScreenMetrics.of(context);
    final switchWidth = PrefsMetrics.switchWidth(m.compact);
    final sliderWidth = PrefsMetrics.sliderWidth(m.compact);
    return GameModal(
      title: 'AYARLAR',
      onClose: c.closeModal,
      closeLabel: 'Ayarları kapat',
      padding: EdgeInsets.fromLTRB(m.compact ? 9 : 12, m.short ? 30 : 36, m.compact ? 9 : 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrefsSection(
            title: 'SES',
            rows: [
              PrefsRow(
                icon: 'music',
                label: 'MÜZİK',
                control: PrefsSlider(value: s.musicVolume, label: 'Müzik', onChanged: c.setMusicVolume, width: sliderWidth),
              ),
              PrefsRow(
                icon: 'sound',
                label: 'SES',
                control: PrefsSlider(value: s.sound ? s.soundVolume : 0, label: 'Ses', onChanged: c.setSoundVolume, width: sliderWidth),
              ),
              PrefsRow(
                icon: 'vibration',
                label: 'TİTREŞİM',
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
                control: PrefsStatus(active: c.storageOK, width: PrefsMetrics.statusWidth(m.compact)),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: PrefsActionTile(icon: 'support', label: 'DESTEK', onTap: c.openSupport),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: PrefsActionTile(icon: 'reset', label: 'İLERLEMEYİ\nSIFIRLA', onTap: c.askReset),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'SÜRÜM 1.0',
              textAlign: TextAlign.center,
              style: gameText(14, color: const Color(0xFF7D8A90), height: 1.1, letterSpacing: .6),
            ),
          ),
        ],
      ),
    );
  }
}
