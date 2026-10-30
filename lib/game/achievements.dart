import 'state.dart';

class Achievement {
  const Achievement(this.id, this.title, this.detail, this.reward, this.goal, this.progress, {required this.art});
  final String id;
  final String title;
  final String detail;
  final int reward;

  /// Hedef ve mevcut ilerleme (aynı ölçüde; ör. yarış sayısı).
  final int goal;
  final int Function(GameState s) progress;

  /// Kart görseli (`assets/images/rewards/<art>.png`).
  final String art;

  bool done(GameState s) => progress(s) >= goal;
}

final achievements = [
  Achievement('first', 'İlk Yarış', '1 yarış yap', 10000, 1, (s) => s.races, art: 'ach-first'),
  Achievement('fast-paws', 'Hızlı Patiler', '3 yarış kazan', 25000, 3, (s) => s.wins, art: 'ach-fast'),
  Achievement('full-stand', 'Dolu Tribün', 'Tribünü 5. seviyeye yükselt', 40000, 5, (s) => s.levels[4], art: 'ach-stand'),
  Achievement('ticket-office', 'Bilet Gişesi', 'Bileti 3. seviyeye yükselt', 35000, 3, (s) => s.levels[5], art: 'ach-ticket'),
];
