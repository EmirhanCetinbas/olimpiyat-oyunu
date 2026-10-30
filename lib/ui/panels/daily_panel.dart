import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/data.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// Günlük ödül: yedi günlük takvim. 1–4 üst sırada, 5–6 ve büyük ödüllü 7. gün alt sırada.
class DailyPanel extends StatelessWidget {
  const DailyPanel(this.c, {super.key});
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final step = c.state.dailyStep % 7;
    final claimed = c.dayClaimed;
    Widget day(int i) => _DayCard(
      day: i,
      prize: dailyPrizes[i],
      taken: i < step,
      ready: i == step && !claimed,
      tomorrow: i == step && claimed,
      onClaim: c.claimDaily,
    );
    const gap = SizedBox(width: 7);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Pill(
            '7 GÜNDE BÜYÜK ÖDÜL',
            style: gameText(13.5, color: GameColors.ink, height: 1.1, letterSpacing: .4),
            color: const Color(0xFFF6E7C4),
            radius: 14,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          ),
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < 4; i++) ...[if (i > 0) gap, Expanded(child: day(i))],
            ],
          ),
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: day(4)),
              gap,
              Expanded(child: day(5)),
              gap,
              Expanded(flex: 2, child: day(6)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        NoteStrip(claimed ? 'Yarın tekrar gel!' : 'Bugünün ödülü hazır!'),
      ],
    );
  }
}

/// Gün kartı: başlık şeridi, ödül görseli, miktar ve durum (alındı / al / yarın / kilitli).
class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.day,
    required this.prize,
    required this.taken,
    required this.ready,
    required this.tomorrow,
    required this.onClaim,
  });
  final int day;
  final Prize prize;
  final bool taken;
  final bool ready;
  final bool tomorrow;
  final VoidCallback onClaim;

  bool get _grand => day == 6;

  String get _icon => prize.money > 0 && prize.gems == 0
      ? 'money'
      : prize.tickets > 0 && prize.money == 0
      ? 'ticket'
      : prize.gems > 0 && prize.money == 0
      ? 'gem'
      : 'gift';

  @override
  Widget build(BuildContext context) {
    final Widget status = taken
        ? const ClaimedCheck(size: 32)
        : ready
        ? RaisedButton('AL', onTap: onClaim, semanticLabel: '${day + 1}. gün: ödülü al', height: 34, minWidth: 0, width: double.infinity)
        : tomorrow
        ? Text('YARIN', style: gameText(14, color: GameColors.slate, height: 1))
        : const LockedMark(size: 26);
    final header = Container(
      margin: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      padding: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: ready ? GameColors.green : (_grand ? const Color(0xFFFFE08A) : const Color(0xFFE6ECEF)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        '${day + 1}. Gün',
        textAlign: TextAlign.center,
        style: gameText(13.5, color: ready ? Colors.white : GameColors.ink, height: 1.1),
      ),
    );
    final card = Container(
      decoration: flatCardDecoration(
        radius: 14,
        color: ready
            ? const Color(0xFFE6FBD9)
            : _grand
            ? const Color(0xFFFFF0B8)
            : GameColors.row,
      ),
      child: Column(
        children: [
          header,
          const SizedBox(height: 6),
          RewardIcon(_icon, size: _grand ? 58 : 40),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(prize.label, maxLines: 1, style: gameText(13.5, color: GameColors.ink, height: 1.1)),
            ),
          ),
          if (_grand) Text('₺50K · 40 elmas · 2 bilet', style: gameText(11, color: GameColors.slate, height: 1.2)),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 6, 5, 7),
            child: SizedBox(height: 34, child: Center(child: status)),
          ),
        ],
      ),
    );
    return Semantics(
      label:
          '${day + 1}. gün: ${taken
              ? 'Alındı'
              : ready
              ? 'Ödülü al'
              : 'Kilitli'}',
      child: card,
    );
  }
}
