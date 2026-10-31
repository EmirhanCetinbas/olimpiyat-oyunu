import 'data.dart';

/// Aktif yarış / deneme verisi (game.js `race` nesnesi).
class Race {
  Race({
    required this.branch,
    required this.phase,
    required this.ids,
    required this.playerLane,
    this.countdown = 0,
    this.elapsed = 0,
    List<double>? progress,
    List<double?>? times,
    this.speeds = const [],
    this.levels = const [],
    this.hurdleLevels = const [],
    this.swimLevels = const [],
    this.equipmentStars = const [0, 0, 0, 0],
    this.equipmentLegacy = 0,
    this.campus = const [0, 0, 0],
    this.trainingCard = false,
    this.jump,
    this.weights,
    this.archery,
  }) : progress = progress ?? [],
       times = times ?? [];

  final String branch;
  String phase;
  double countdown;
  double elapsed;
  List<double> progress;
  List<double?> times;
  final List<int> ids;
  final int playerLane;
  int place = 1;
  final List<double> speeds;
  final List<int> levels;
  final List<int> hurdleLevels;
  final List<int> swimLevels;
  final List<int> equipmentStars;
  final int equipmentLegacy;
  final List<int> campus;
  final bool trainingCard;
  double manualBonus = 0;
  bool moveOffered = false;
  final JumpRound? jump;
  final WeightsRound? weights;
  final ArcheryRound? archery;
}

class JumpResult {
  JumpResult(this.id, this.metres);
  final int id;
  final double metres;
}

class JumpRound {
  JumpRound({required this.levels, required this.campus, required this.distances});
  int turn = 0;
  String phase = 'ready';
  double time = 0;
  double duration = .7;
  final List<int> levels;
  final List<int> campus;
  final List<JumpResult> results = [];
  List<double> distances;
}

class WeightAttempt {
  WeightAttempt({required this.kg, required this.chance, this.roll = 0, required this.success});
  int kg;
  double chance;
  double roll;
  bool success;
}

class WeightResult {
  WeightResult(this.id, this.kg, this.success);
  final int id;
  final int kg;
  final bool success;
}

class WeightsRound {
  WeightsRound({required this.levels, required this.campus, required this.attempts});
  int turn = 0;
  String phase = 'walk';
  double time = 0;
  double duration = .8;
  final List<int> levels;
  final List<int> campus;
  final List<WeightResult> results = [];
  List<WeightAttempt> attempts;
}

class ArcheryResult {
  ArcheryResult(this.id, this.points, [this.x = 0, this.rings = 0]);
  final int id;
  final int points;

  /// Tam merkez (X) sayısı; eşit puanda sıralamayı belirler.
  final int x;

  /// Okların halka değerleri toplamı (merkeze yakınlık); X de eşitse sıralamayı belirler.
  final double rings;

  /// Sıralamada bu sonuç [other]'ın önünde mi: puan, sonra X, sonra merkeze yakınlık.
  bool beats(ArcheryResult other) => points != other.points ? points > other.points : (x != other.x ? x > other.x : rings > other.rings);
}

class ArcheryRound {
  ArcheryRound({required this.levels, required this.campus, required this.shots, required this.scores});
  int turn = 0;
  int arrow = 0;
  String phase = 'walk';
  double time = 0;
  double duration = .8;
  final List<int> levels;
  final List<int> campus;
  final List<ArcheryResult> results = [];

  /// Okların halkadaki değerleri (1–10,99); puan [archeryPoints] ile çıkar.
  List<List<double>> shots;
  final List<List<int>> scores;
}

/// Zamanlama düğmesi (moves.js `activeMove`).
class ActiveMove {
  ActiveMove(this.kind, this.duration, {this.target = .5});
  final String kind;

  /// Hamlenin açık kaldığı süre; bitince dokunulmamışsa kaçar.
  final double duration;

  /// İmlecin çubuğun bir ucundan öbürüne gidiş süresi (sn).
  static const sweep = .7;

  /// Kusursuz bölgenin çubuktaki yeri (0–1).
  final double target;
  double elapsed = 0;
  bool tapped = false;
  double quality = 0;

  /// İmleç çubukta durmadan sağa sola gidip gelir (0–1).
  double get cursor {
    final t = elapsed / sweep % 2;
    return t < 1 ? t : 2 - t;
  }
}

/// Bir sporcunun sahnedeki yüzde konumu.
class RunnerPos {
  RunnerPos(this.x, this.y, {this.jump = false, this.airborne = false});
  double x;
  double y;
  bool jump;
  bool airborne;
}

/// Biten yarışın oyuncuya gösterilen sonucu (sonuç penceresi).
class RaceResult {
  const RaceResult({
    required this.branch,
    required this.place,
    required this.total,
    required this.value,
    required this.reward,
    required this.xp,
    this.record = false,
    this.success = true,
  });
  final String branch;
  final int place;
  final int total;

  /// Ölçüm: süre, mesafe, kilo ya da puan (biçimlenmiş).
  final String value;
  final int reward;
  final int xp;

  /// Kişisel rekor kırıldı mı.
  final bool record;

  /// Halterde kaldırış başarılı mı.
  final bool success;

  /// Madalya mı: katılımcıların ilk yarısı (bkz. [medalPlaces]).
  bool get medal => success && place <= medalPlaces(total);
}
