import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../components/components.dart';

/// Yükseltme açıklaması (kartlardaki "i").
class InfoPanel extends StatelessWidget {
  const InfoPanel(this.c, this.index, {super.key});
  final GameController c;
  final int index;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      PanelText(c.activeUpgrades[index].desc),
      const PanelText.muted(
        'Karttaki değer, yükseltmenin yarıştaki gerçek ve birikmiş etkisidir. Yeni seviye bir sonraki yarışta uygulanır.',
      ),
    ],
  );
}

/// Ayarlar > Destek.
class SupportPanel extends StatelessWidget {
  const SupportPanel(this.c, {super.key});
  final GameController c;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const PanelText('İlerlemen bu cihaza otomatik kaydedilir. Müzik ve ses düzeylerini Ayarlar bölümünden değiştirebilirsin.'),
      const PanelText('Titreşim, cihaz destekliyorsa çalışır.'),
      ActionButton('Ayarlara dön', full: true, onTap: () => c.open('settings')),
    ],
  );
}

/// Ayarlar > İlerlemeyi sıfırla onayı.
class ResetPanel extends StatelessWidget {
  const ResetPanel(this.c, {super.key});
  final GameController c;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const PanelText('Bu cihazdaki bütün yarışlar, seviyeler ve ödüller silinecek.'),
      ActionButton('Vazgeç', full: true, tone: ButtonTone.cream, onTap: () => c.openPanel('settings')),
      ActionButton('Evet, sıfırla', full: true, onTap: c.confirmReset),
    ],
  );
}
