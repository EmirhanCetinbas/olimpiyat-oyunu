import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/data.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// Seçili tesisin kalıcı geliştirmeleri; ortak pencere dilinde.
class CampusDialog extends StatelessWidget {
  const CampusDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final f = c.facility(c.campusSelection)!;
    final m = ScreenMetrics.of(context);
    final note = f.locked
        ? 'Skill puanın harcanmaz.'
        : c.race != null && f.id == 'sprint'
        ? 'Yeni bonuslar sonraki yarışta uygulanır.'
        : 'Kalıcı bonuslar otomatik uygulanır.';
    return DialogLayer(
      onDismiss: c.closeCampusDialog,
      barrierColor: const Color(0x55072422),
      padding: EdgeInsets.only(top: m.padding.top, bottom: m.padding.bottom),
      child: SizedBox(
        width: m.dialogWidth((m.gameWidth * .95).clamp(0.0, 470.0)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: m.dialogMaxHeight(.9)),
          child: GameModal(
            title: trUpper(f.label),
            onClose: c.closeCampusDialog,
            closeLabel: 'Yükseltmeleri kapat',
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(facility: f, level: c.facilityLevel(f.id)),
                  if (f.locked) const PanelText('Bu yarış dalı açıldığında geliştirmeler kullanılabilir.', align: TextAlign.center),
                  for (var i = 0; i < f.rows.length; i++)
                    CampusUpgradeRow(
                      row: f.rows[i],
                      rank: c.campusRank(f.id, i),
                      cost: c.campusCost(f.id, i),
                      locked: f.locked,
                      skillPoints: c.state.skillPoints,
                      onBuy: () => c.pressCampusBuy(i),
                    ),
                  PanelText.muted(note, align: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tesis ikonu, açıklama ve seviye rozeti.
class _Header extends StatelessWidget {
  const _Header({required this.facility, required this.level});
  final CampusFacility facility;
  final int level;

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    // Tek satır: tesis seviyesi ve harcanabilir SP.
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Art(facility.icon, width: 40, height: 40),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Tesis seviyesi $level', style: gameText(TextSizes.cardTitle, color: GameColors.ink, height: 1.1)),
          ),
          Pill(
            '★ ${c.state.skillPoints} SP',
            style: gameText(15, color: Colors.white, height: 1.1),
            color: GameColors.navy,
            borderColor: GameColors.ink,
            borderWidth: 2,
            radius: 12,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          ),
        ],
      ),
    );
  }
}

/// Tek geliştirme kademesi: ikon, etki, kademe ve SP bedelli düğme.
class CampusUpgradeRow extends StatelessWidget {
  const CampusUpgradeRow({
    super.key,
    required this.row,
    required this.rank,
    required this.cost,
    required this.locked,
    required this.skillPoints,
    required this.onBuy,
  });

  final CampusRow row;
  final int rank;
  final int cost;
  final bool locked;
  final int skillPoints;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final compact = ScreenMetrics.of(context).compact;
    final maxed = rank >= 5;
    return ListRow(
      children: [
        Art(row.icon, width: compact ? 32 : 38, height: compact ? 32 : 38),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(row.name, style: gameText(16.5, color: GameColors.ink, height: 1.15)),
              Text.rich(
                TextSpan(
                  style: gameText(13, color: GameColors.slate, height: 1.25),
                  children: [
                    TextSpan(text: '${row.effect} '),
                    TextSpan(
                      text: maxed ? row.format(rank) : row.format(rank + 1),
                      style: gameText(13, color: GameColors.greenShade),
                    ),
                  ],
                ),
              ),
              Text('$rank/5 · Mevcut: ${rank == 0 ? 'yok' : row.format(rank)}', style: gameText(11, color: GameColors.slate, height: 1.2)),
            ],
          ),
        ),
        RaisedButton(
          locked ? 'YAKINDA' : (maxed ? 'MAKS.' : '★ $cost SP'),
          onTap: onBuy,
          enabled: !locked && !maxed && skillPoints >= cost,
          semanticLabel: '${row.name} geliştir, $cost SP',
          width: compact ? 72 : 82,
          fontSize: 15,
        ),
      ],
    );
  }
}
