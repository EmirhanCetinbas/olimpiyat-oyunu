import 'state.dart';

class Achievement {
  const Achievement(this.id, this.title, this.detail, this.reward, this.done);
  final String id;
  final String title;
  final String detail;
  final int reward;
  final bool Function(GameState s) done;
}

final achievements = [
  Achievement('first', 'İlk Yarış', '1 yarış yap', 10000, (s) => s.races >= 1),
  Achievement('fast-paws', 'Hızlı Patiler', '3 yarış kazan', 25000, (s) => s.wins >= 3),
  Achievement('full-stand', 'Dolu Tribün', 'Tribünü 5. seviyeye yükselt', 40000, (s) => s.levels[4] >= 5),
  Achievement('ticket-office', 'Bilet Gişesi', 'Bileti 3. seviyeye yükselt', 35000, (s) => s.levels[5] >= 3),
];
