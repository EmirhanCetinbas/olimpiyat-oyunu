import 'data.dart';
import 'state.dart';

class Achievement {
  const Achievement(
    this.id,
    this.title,
    this.detail,
    this.reward,
    this.goal,
    this.progress, {
    required this.art,
    this.gems = 0,
    this.chest = false,
  });
  final String id;
  final String title;
  final String detail;
  final int reward;

  /// Ek ödüller: elmas ve Şampiyon Çantası.
  final int gems;
  final bool chest;

  /// Hedef ve mevcut ilerleme (aynı ölçüde; ör. yarış sayısı).
  final int goal;
  final int Function(GameState s) progress;

  /// Kart görseli (`assets/images/rewards/<art>.png`).
  final String art;

  bool done(GameState s) => progress(s) >= goal;
}

int _campusRanks(GameState s) => s.campusUpgrades.values.fold(0, (n, l) => n + l.fold(0, (m, r) => m + r.clamp(0, 5)));

/// Kısa, orta ve uzun vadeli hedefler; ödüller ilerlemeyle büyür.
final achievements = [
  Achievement('first', 'İlk Yarış', '1 yarış yap', 10000, 1, (s) => s.races, art: 'ach-first'),
  Achievement('fast-paws', 'Hızlı Patiler', '3 yarış kazan', 25000, 3, (s) => s.wins, art: 'ach-fast', chest: true),
  Achievement('full-stand', 'Dolu Tribün', 'Tribünü 5. seviyeye yükselt', 40000, 5, (s) => s.levels[4], art: 'ach-stand', chest: true),
  Achievement('ticket-office', 'Bilet Gişesi', 'Bileti 3. seviyeye yükselt', 35000, 3, (s) => s.levels[5], art: 'ach-ticket'),
  Achievement('first-cup', 'İlk Kupa', 'Bir üç yarışlık kupa kazan', 50000, 1, (s) => s.tournamentCups, art: 'medal', gems: 5),
  Achievement('races-25', 'Antrenman Temposu', '25 yarış yap', 60000, 25, (s) => s.races, art: 'clock', gems: 5),
  Achievement(
    'full-team',
    'Tam Kadro',
    'Altı sporcunun hepsini aç',
    80000,
    animals.length,
    (s) => animals.where((a) => s.races >= a.unlock).length,
    art: 'ach-first',
    gems: 10,
  ),
  Achievement('medals-25', 'Madalya Koleksiyonu', '25 madalya kazan', 100000, 25, (s) => s.medals, art: 'medal', gems: 10),
  Achievement('campus-10', 'Kampüs Yatırımcısı', '10 kampüs kademesi al', 120000, 10, _campusRanks, art: 'ach-stand', gems: 10),
  Achievement('level-10', 'Deneyimli Takım', '10. seviyeye ulaş', 150000, 10, (s) => levelProgress(s.xp).level, art: 'gem', gems: 15),
  Achievement('wins-50', 'Zafer Serisi', '50 yarış kazan', 250000, 50, (s) => s.wins, art: 'ach-fast', gems: 15, chest: true),
  Achievement('cups-5', 'Kupa Avcısı', '5 kupa kazan', 300000, 5, (s) => s.tournamentCups, art: 'medal', gems: 20, chest: true),
  Achievement(
    'full-gear',
    'Tam Teçhizat',
    'Ekipmanlarda toplam 20 yıldız topla',
    400000,
    20,
    (s) => s.equipmentStars.fold(0, (n, v) => n + v),
    art: 'gift',
    gems: 20,
  ),
  Achievement('archer', 'Keskin Nişancı', 'Okçulukta 28 puan yap', 300000, 28, (s) => s.bestArchery, art: 'ach-ticket', gems: 15),
  Achievement('races-250', 'Maraton Ruhu', '250 yarış yap', 750000, 250, (s) => s.races, art: 'clock', gems: 30, chest: true),
  Achievement('wins-250', 'Efsane Patiler', '250 yarış kazan', 2000000, 250, (s) => s.wins, art: 'ach-fast', gems: 50, chest: true),
];
