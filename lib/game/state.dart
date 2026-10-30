import 'data.dart';

const storageKey = 'pati-champions-v1';

class ChestItem {
  ChestItem({required this.kind, this.amount = 0, this.branch, this.label = '', this.icon = '', this.index, this.extra});

  String kind;
  int amount;
  String? branch;
  String label;
  String icon;
  int? index;
  ChestItem? extra;

  Map<String, dynamic> toJson() => {
    'kind': kind,
    'amount': amount,
    if (branch != null) 'branch': branch,
    'label': label,
    'icon': icon,
    if (index != null) 'index': index,
    if (extra != null) 'extra': extra!.toJson(),
  };

  static ChestItem? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    return ChestItem(
      kind: '${raw['kind'] ?? ''}',
      amount: _int(raw['amount']),
      branch: raw['branch'] is String ? raw['branch'] as String : null,
      label: '${raw['label'] ?? ''}',
      icon: '${raw['icon'] ?? ''}',
      index: raw['index'] is num ? (raw['index'] as num).toInt() : null,
      extra: ChestItem.fromJson(raw['extra']),
    );
  }
}

class PendingChest {
  PendingChest(this.type, this.offers);
  final String type;
  final List<ChestItem> offers;

  Map<String, dynamic> toJson() => {
    'type': type,
    'offers': [for (final o in offers) o.toJson()],
  };
}

class Tournament {
  Tournament(this.branch, this.attempts, this.podiums, [List<int>? places]) : places = places ?? [];
  String branch;
  int attempts;
  int podiums;

  /// Kupa yarışlarındaki sıralar (sırasıyla); eski kayıtlarda boş olabilir.
  final List<int> places;

  Map<String, dynamic> toJson() => {'branch': branch, 'attempts': attempts, 'podiums': podiums, 'places': places};
}

int _int(dynamic v, [int fallback = 0]) {
  if (v is num && v.isFinite) return v.floor();
  if (v is String) return num.tryParse(v)?.floor() ?? fallback;
  return fallback;
}

double _num(dynamic v, [double fallback = 0]) {
  if (v is num && v.isFinite) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

List<int> _levels(dynamic raw, int count) {
  final source = raw is List ? raw : const [];
  return List.generate(count, (i) => i < source.length ? _int(source[i], 1).clamp(1, 100) : 1);
}

class GameState {
  GameState.initial(int now) : last = now, version = 1;

  int version;
  int skillPoints = 8;
  Map<String, List<int>> campusUpgrades = {};
  double money = 3500;
  int gems = 8;
  int xp = 0;
  List<int> levels = [1, 1, 1, 1, 1, 1];
  List<int> hurdleLevels = [1, 1, 1, 1];
  List<int> swimLevels = [1, 1, 1, 1];
  List<int> longJumpLevels = [1, 1, 1, 1];
  double bestJump = 0;
  List<int> weightLevels = [1, 1, 1, 1];
  int bestWeight = 0;
  List<int> archeryLevels = [1, 1, 1, 1];
  int bestArchery = 0;
  Tournament? tournament;
  int tournamentCups = 0;
  String weightRisk = 'safe';
  String branch = 'sprint';
  int races = 0;
  int wins = 0;
  int medals = 0;
  double? best;
  int selected = 0;
  String name = 'Pati Takımı';
  bool auto = true;
  bool sound = true;
  double musicVolume = 0.6;
  double soundVolume = 0.4;
  bool vibration = true;
  List<String> claims = [];
  int camp = 1;
  int equipment = 0;
  List<int> equipmentStars = [0, 0, 0, 0];
  int equipmentLegacy = 0;
  int chests = 0;
  int cupChests = 0;
  int championChests = 0;
  int equipmentParts = 0;
  Map<String, int> trainingCards = {};
  List<int> cosmetics = [];
  int selectedCosmetic = -1;
  PendingChest? pendingChest;
  int boostTokens = 0;
  int boostUntil = 0;
  int boostReady = 0;
  int last;
  int daily = 0;
  int dailyStep = 0;
  String spinDate = '';
  int spinTickets = 0;

  /// game.js başındaki yükleme ve temizleme mantığının karşılığı.
  static GameState load(Map raw, int now) {
    final s = GameState.initial(now);
    if (raw['version'] != 1) return s;
    s.skillPoints = raw.containsKey('skillPoints') ? _int(raw['skillPoints']).clamp(0, 1 << 31) : 8;
    final campus = raw['campusUpgrades'];
    if (campus is Map) {
      campus.forEach((key, value) {
        if (value is List) s.campusUpgrades['$key'] = [for (var i = 0; i < 3; i++) i < value.length ? _int(value[i]) : 0];
      });
    }
    s.money = _num(raw['money']).clamp(0, double.maxFinite);
    s.gems = _int(raw['gems']).clamp(0, 1 << 31);
    s.xp = _int(raw['xp'], 0);
    s.levels = _levels(raw['levels'], 6);
    s.hurdleLevels = _levels(raw['hurdleLevels'], 4);
    s.swimLevels = _levels(raw['swimLevels'], 4);
    s.longJumpLevels = _levels(raw['longJumpLevels'], 4);
    s.weightLevels = _levels(raw['weightLevels'], 4);
    s.archeryLevels = _levels(raw['archeryLevels'], 4);
    s.bestJump = _num(raw['bestJump']).clamp(0, double.maxFinite);
    s.bestWeight = _int(raw['bestWeight']).clamp(0, 1 << 31);
    s.bestArchery = _int(raw['bestArchery']).clamp(0, 1 << 31);
    final t = raw['tournament'];
    if (t is Map && branches.contains(t['branch'])) {
      s.tournament = Tournament(
        t['branch'] as String,
        _int(t['attempts']).clamp(0, 3),
        _int(t['podiums']).clamp(0, 3),
        t['places'] is List ? [for (final p in (t['places'] as List).take(3)) _int(p, 6)] : [],
      );
    }
    s.tournamentCups = _int(raw['tournamentCups']).clamp(0, 1 << 31);
    s.weightRisk = raw['weightRisk'] == 'record' ? 'record' : 'safe';
    s.branch = branches.contains(raw['branch']) ? raw['branch'] as String : 'sprint';
    s.races = _int(raw['races']);
    s.wins = _int(raw['wins']);
    s.medals = _int(raw['medals']);
    s.best = raw['best'] is num ? (raw['best'] as num).toDouble() : null;
    s.selected = _int(raw['selected']).clamp(0, 5);
    if (raw['name'] is String) s.name = raw['name'] as String;
    if (raw['auto'] is bool) s.auto = raw['auto'] as bool;
    if (raw['sound'] is bool) s.sound = raw['sound'] as bool;
    if (raw['musicVolume'] is num) s.musicVolume = _num(raw['musicVolume']).clamp(0, 1);
    if (raw['soundVolume'] is num) s.soundVolume = _num(raw['soundVolume']).clamp(0, 1);
    if (raw['vibration'] is bool) s.vibration = raw['vibration'] as bool;
    s.claims = raw['claims'] is List ? [for (final c in raw['claims'] as List) '$c'] : [];
    s.camp = raw.containsKey('camp') ? _int(raw['camp'], 1).clamp(1, 1 << 31) : 1;
    final oldEquipment = _int(raw['equipment']).clamp(0, 1 << 31);
    s.equipment = oldEquipment;
    if (raw['equipmentStars'] is List) {
      final stars = raw['equipmentStars'] as List;
      s.equipmentStars = [for (var i = 0; i < 4; i++) i < stars.length ? _int(stars[i]).clamp(0, 3) : 0];
      s.equipmentLegacy = _int(raw['equipmentLegacy']).clamp(0, 1 << 31);
    } else {
      s.equipmentStars = [oldEquipment.clamp(0, 3), 0, 0, 0];
      s.equipmentLegacy = (oldEquipment - 3).clamp(0, 1 << 31);
    }
    s.chests = _int(raw['chests']).clamp(0, 1 << 31);
    s.cupChests = _int(raw['cupChests']).clamp(0, 1 << 31);
    s.championChests = _int(raw['championChests']).clamp(0, 1 << 31);
    s.equipmentParts = _int(raw['equipmentParts']).clamp(0, 1 << 31);
    final cards = raw['trainingCards'];
    if (cards is Map) cards.forEach((k, v) => s.trainingCards['$k'] = _int(v));
    if (raw['cosmetics'] is List) {
      s.cosmetics = {
        for (final c in raw['cosmetics'] as List)
          if (c is num && c == c.floor() && c >= 0 && c < 4) c.toInt(),
      }.toList();
    }
    final selectedCosmetic = _int(raw['selectedCosmetic'], -1);
    s.selectedCosmetic = s.cosmetics.contains(selectedCosmetic) ? selectedCosmetic : -1;
    final pending = raw['pendingChest'];
    if (pending is Map &&
        ['normal', 'cup', 'champion'].contains(pending['type']) &&
        pending['offers'] is List &&
        (pending['offers'] as List).length == 3) {
      final offers = [for (final o in pending['offers'] as List) ChestItem.fromJson(o)];
      if (!offers.contains(null)) s.pendingChest = PendingChest(pending['type'] as String, offers.cast<ChestItem>());
    }
    s.boostTokens = _int(raw['boostTokens']).clamp(0, 1 << 31);
    s.boostUntil = _int(raw['boostUntil']);
    s.boostReady = _int(raw['boostReady']);
    s.last = _int(raw['last'], now);
    s.daily = _int(raw['daily']);
    s.dailyStep = _int(raw['dailyStep']);
    s.spinDate = raw['spinDate'] is String ? raw['spinDate'] as String : '';
    s.spinTickets = _int(raw['spinTickets']);
    return s;
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'skillPoints': skillPoints,
    'campusUpgrades': campusUpgrades,
    'money': money,
    'gems': gems,
    'xp': xp,
    'levels': levels,
    'hurdleLevels': hurdleLevels,
    'swimLevels': swimLevels,
    'longJumpLevels': longJumpLevels,
    'bestJump': bestJump,
    'weightLevels': weightLevels,
    'bestWeight': bestWeight,
    'archeryLevels': archeryLevels,
    'bestArchery': bestArchery,
    'tournament': tournament?.toJson(),
    'tournamentCups': tournamentCups,
    'weightRisk': weightRisk,
    'branch': branch,
    'races': races,
    'wins': wins,
    'medals': medals,
    'best': best,
    'selected': selected,
    'name': name,
    'auto': auto,
    'sound': sound,
    'musicVolume': musicVolume,
    'soundVolume': soundVolume,
    'vibration': vibration,
    'claims': claims,
    'camp': camp,
    'equipment': equipment,
    'equipmentStars': equipmentStars,
    'equipmentLegacy': equipmentLegacy,
    'chests': chests,
    'cupChests': cupChests,
    'championChests': championChests,
    'equipmentParts': equipmentParts,
    'trainingCards': trainingCards,
    'cosmetics': cosmetics,
    'selectedCosmetic': selectedCosmetic,
    'pendingChest': pendingChest?.toJson(),
    'boostTokens': boostTokens,
    'boostUntil': boostUntil,
    'boostReady': boostReady,
    'last': last,
    'daily': daily,
    'dailyStep': dailyStep,
    'spinDate': spinDate,
    'spinTickets': spinTickets,
  };
}
