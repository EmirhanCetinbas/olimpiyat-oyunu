import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/data.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// `#campus-upgrade`: seçili tesisin kalıcı geliştirmeleri.
class CampusDialog extends StatelessWidget {
  const CampusDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final f = c.facility(c.campusSelection)!;
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 600;
    final note = f.locked
        ? 'Skill puanın harcanmaz.'
        : c.race != null && f.id == 'sprint'
        ? 'Yeni bonuslar sonraki yarışta uygulanır.'
        : 'Kalıcı bonuslar otomatik uygulanır.';
    return DialogLayer(
      onDismiss: c.closeCampusDialog,
      barrierColor: const Color(0x25072422),
      child: Container(
        width: (size.width * .92).clamp(0.0, 460.0),
        constraints: BoxConstraints(maxHeight: size.height * .9),
        child: GBox(
          gradient: angleGradient(120, const [Color(0xFFFFFEF3), Color(0xFFFFF0D4)]),
          borderColor: const Color(0xFF0B263A),
          borderWidth: 3,
          radius: 25,
          shadows: const [BoxShadow(color: Color(0x55082437), offset: Offset(0, 8))],
          insets: const [Inset(Color(0xFFFFF8E9), spread: 4)],
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 9),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(facility: f, level: c.facilityLevel(f.id), wide: wide),
                    if (f.locked) const _Note('Bu yarış dalı açıldığında geliştirmeler kullanılabilir.', boxed: true),
                    for (var i = 0; i < f.rows.length; i++) ...[
                      if (i > 0) const SizedBox(height: 9),
                      CampusUpgradeRow(
                        row: f.rows[i],
                        rank: c.campusRank(f.id, i),
                        cost: c.campusCost(f.id, i),
                        locked: f.locked,
                        skillPoints: c.state.skillPoints,
                        onBuy: () => c.pressCampusBuy(i),
                      ),
                    ],
                    _Note(note),
                  ],
                ),
              ),
              Positioned(
                right: 6,
                top: 5,
                child: RoundCloseButton.campus(onTap: c.closeCampusDialog, semanticLabel: 'Yükseltmeleri kapat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.facility, required this.level, required this.wide});
  final CampusFacility facility;
  final int level;
  final bool wide;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 15, right: 18),
    child: Row(
      children: [
        GBox(
          width: wide ? 82 : 65,
          height: wide ? 82 : 68,
          gradient: vGradient(const [Color(0xFFFFFCEF), Color(0xFFEFDBB9)]),
          borderColor: const Color(0xFFD4B28A),
          borderWidth: 2,
          radius: 15,
          alignment: Alignment.center,
          child: Art(facility.icon, width: wide ? 69 : 56, height: wide ? 69 : 56),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                facility.name,
                style: nunito(vwClamp(context, 17, 4.5, 23), weight: 1000, color: GameColors.text, height: 1.1, letterSpacing: -.5),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('Kalıcı geliştirmeler', style: nunito(14, color: const Color(0xFF5C6473))),
              ),
              Pill(
                facility.locked ? 'YAKINDA' : 'Sv. $level',
                style: nunito(15, color: GameColors.text, height: 1.1),
                color: const Color(0xFFEBDDC3),
                radius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 3),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Note extends StatelessWidget {
  const _Note(this.text, {this.boxed = false});
  final String text;
  final bool boxed;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      textAlign: TextAlign.center,
      style: nunito(12, color: const Color(0xFF677077), height: 1.3),
    );
    if (!boxed) return Padding(padding: const EdgeInsets.only(top: 10), child: label);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFFF1E5CB), borderRadius: BorderRadius.circular(9)),
      child: label,
    );
  }
}

/// `.campus-upgrade-row`: kademe, etki, SP bedeli ve ↑ düğmesi.
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
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 600, narrow = width <= 350;
    final enabled = !locked && rank < 5 && skillPoints >= cost;
    final sign = row.amount < 0 ? '−' : '+';
    final gap = SizedBox(
      width: wide
          ? 8
          : narrow
          ? 4
          : 6,
    );
    final iconSize = wide
        ? 46.0
        : narrow
        ? 29.0
        : 35.0;
    return GBox(
      gradient: angleGradient(110, const [Color(0xFFFFFDF3), Color(0xFFFFF5E3)]),
      borderColor: const Color(0xFFDFC19E),
      borderWidth: 2,
      radius: 17,
      insets: const [Inset(Colors.white, dy: 2)],
      padding: EdgeInsets.symmetric(horizontal: wide ? 10 : 6, vertical: wide ? 10 : 8),
      child: Row(
        children: [
          Container(
            width: wide
                ? 52
                : narrow
                ? 32
                : 40,
            height: wide ? 54 : 46,
            decoration: BoxDecoration(
              gradient: vGradient(const [Color(0xFFE7D3B0), Color(0xFFFFF9E9)]),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Art(row.icon, width: iconSize, height: iconSize),
          ),
          gap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    row.name,
                    style: nunito(
                      wide
                          ? 17
                          : narrow
                          ? 12
                          : 14,
                      weight: 1000,
                      color: GameColors.text,
                      height: 1.1,
                    ),
                  ),
                ),
                Text.rich(
                  TextSpan(
                    style: nunito(wide ? 14 : 12, color: const Color(0xFF566171), height: 1.2),
                    children: [
                      TextSpan(text: '${row.effect} '),
                      TextSpan(
                        text: '$sign%${row.amount.abs() * (rank + 1)}',
                        style: nunito(wide ? 14 : 12, weight: 1000, color: const Color(0xFF078420)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    '$rank/5 · Mevcut: $sign%${row.amount.abs() * rank}',
                    style: nunito(10, color: const Color(0xFF767569), height: 1.2),
                  ),
                ),
              ],
            ),
          ),
          gap,
          Text(
            '★ ${rank >= 5 ? 'MAKS.' : '$cost SP'}',
            style: nunito(
              wide
                  ? 14
                  : narrow
                  ? 11
                  : 12,
              weight: 1000,
              color: GameColors.text,
            ),
          ),
          gap,
          GameButton(
            onTap: onBuy,
            enabled: enabled,
            semanticLabel: '${row.name} geliştir, $cost SP',
            skin: ButtonSkin.campus,
            label: locked
                ? '🔒'
                : rank >= 5
                ? '✓'
                : '↑',
            fontSize: enabled ? 29 : 20,
          textHeight: 1,
            padding: EdgeInsets.zero,
            width: wide
                ? 47
                : narrow
                ? 32
                : 38,
            height: wide ? 49 : 41,
            alignment: Alignment.center,
            disabledSaturation: .5,
            disabledOpacity: .65,
          ),
        ],
      ),
    );
  }
}
