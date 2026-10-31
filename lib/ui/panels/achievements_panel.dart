import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/format.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// Başarımlar: toplam ilerleme, başarım kartları (görsel, hedef, ödül, durum) ve alt bilgi.
class AchievementsPanel extends StatelessWidget {
  const AchievementsPanel(this.c, {super.key});
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final claimed = c.state.claims.length, total = achievements.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          child: Row(
            children: [
              Expanded(
                child: GameProgressBar(value: claimed / total, label: 'Alınan başarımlar', height: 18),
              ),
              const SizedBox(width: 10),
              Text('$claimed / $total', style: gameText(17, color: GameColors.ink, height: 1)),
            ],
          ),
        ),
        for (final a in achievements) _AchievementCard(c: c, achievement: a),
        NoteStrip(claimed == total ? 'Tüm başarımları topladın!' : 'Yeni hedefler seni bekliyor!'),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.c, required this.achievement});
  final GameController c;
  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final a = achievement;
    final compact = ScreenMetrics.of(context).compact;
    final value = a.progress(c.state).clamp(0, a.goal);
    final taken = c.state.claims.contains(a.id), ready = a.done(c.state) && !taken;
    final Widget action = taken
        ? const ClaimedCheck()
        : ready
        ? RaisedButton('AL', onTap: () => c.claimAchievement(a.id), semanticLabel: '${a.title}: ödülü al', height: 36, minWidth: 64)
        : const LockedMark();
    return ListRow(
      children: [
        RewardIcon(a.art, size: compact ? 50 : 58, radius: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(a.title, style: gameText(16.5, color: GameColors.ink, height: 1.15)),
              Text(a.detail, style: gameText(12.5, color: GameColors.slate, height: 1.2)),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: GameProgressBar(value: value / a.goal, label: a.title, height: 12),
                  ),
                  const SizedBox(width: 6),
                  Text('$value / ${a.goal}', style: gameText(12.5, color: GameColors.ink, height: 1)),
                ],
              ),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RewardPill(icon: 'money', label: '₺${fmt(a.reward)}'),
            if (a.gems > 0 || a.chest) ...[
              const SizedBox(height: 4),
              // Ek ödül: elmas ve/veya Şampiyon Çantası.
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (a.gems > 0) RewardPill(icon: 'gem', label: '${a.gems}'),
                  if (a.chest) ...[const SizedBox(width: 3), const RewardIcon('gift', size: 28)],
                ],
              ),
            ],
            const SizedBox(height: 6),
            SizedBox(height: 38, child: Center(child: action)),
          ],
        ),
      ],
    );
  }
}
