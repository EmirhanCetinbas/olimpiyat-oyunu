import 'dart:ui' show Rect;

const branches = ['sprint', 'hurdles', 'swim', 'longjump', 'weights', 'archery'];

/// Yarıştaki sporcu sayısı (100 m pistinde 4 kulvar var).
int fieldSize(String branch) => branch == 'sprint' ? 4 : 6;

/// Madalya alan sıra sayısı: katılımcıların ilk yarısı (4 sporcuda ilk 2, 6 sporcuda ilk 3).
int medalPlaces(int field) => field ~/ 2;

bool isMedal(String branch, int place) => place <= medalPlaces(fieldSize(branch));

String branchLabel(String id) =>
    const {
      'sprint': '100 metre',
      'hurdles': 'Engelli koşu',
      'swim': 'Yüzme',
      'longjump': 'Uzun atlama',
      'weights': 'Halter',
      'archery': 'Okçuluk',
    }[id] ??
    'Yarış';

/// Sporcu: genel bir üstünlüğü yok; gücü [specialties] tablosundaki iki branştan gelir
/// (birinde +%6 uzman, birinde +%3 yardımcı). Her branşın bir uzmanı ve bir yardımcısı var.
class Animal {
  const Animal(this.name, this.art, this.role, this.unlock);
  final String name;
  final String art;

  /// Kartta görünen kısa kimlik (uzman olduğu branş).
  final String role;
  final int unlock;
}

const animals = [
  Animal('Çita', 'cheetah', 'Sprinter', 0),
  Animal('Rakun', 'raccoon', 'Nişancı', 2),
  Animal('Ayı', 'bear', 'Güç ustası', 4),
  Animal('Tavşan', 'rabbit', 'Engel ustası', 7),
  Animal('Kaplumbağa', 'turtle', 'Yüzücü', 10),
  Animal('Tilki', 'fox', 'Atlayıcı', 15),
];

class UpgradeDef {
  const UpgradeDef(this.title, this.icon, this.base, this.desc, {this.income});
  final String title;
  final String icon;
  final int base;
  final String desc;
  final int? income;
}

const sprintUpgrades = [
  UpgradeDef('Başlangıç Hızı', 'shoe', 750, 'İlk 25 metrede hızını artırır. Her seviye çıkış bölümünü %2 hızlandırır.'),
  UpgradeDef('Maksimum Hız', 'speed', 950, 'Yarışın tamamında hızını artırır. Her seviye temel hıza %1 ekler.'),
  UpgradeDef('Dayanıklılık', 'stamina', 700, 'Son 50 metrede temponu korur. Her seviye bu bölümü %1,5 hızlandırır.'),
  UpgradeDef('Finiş Gücü', 'finish', 850, 'Son 20 metrede sprint bonusu sağlar. Her seviye finiş bölümünü %2 hızlandırır.'),
];

/// Branştan bağımsız gelir yükseltmeleri; her branşta görünür. Seviyeler `levels[4]` ve `levels[5]`te saklanır
/// (eski kayıtlarla uyum için), yükseltme dizini de 4 ve 5'tir.
const incomeUpgrades = [
  UpgradeDef('Tribün', 'stadium', 1600, 'Daha fazla seyirci çeker. Her seviye saniyelik geliri ₺12 artırır.', income: 12),
  UpgradeDef('Bilet', 'ticket', 2100, 'Bilet değerini yükseltir. Her seviye saniyelik geliri ₺18 artırır.', income: 18),
];
const hurdleUpgrades = [
  UpgradeDef('Engel Ritmi', 'speed', 900, 'Engelin üstünde korunan hız %55; her seviye +%2,5 (en çok %96).'),
  UpgradeDef('Atlayış Tekniği', 'shoe', 1100, 'Her seviye yarış boyunca hızı %1 artırır.'),
  UpgradeDef('Dayanıklılık', 'stamina', 750, 'Yarışın ikinci yarısında her seviye hızı %1,2 artırır.'),
  UpgradeDef('Finiş Temposu', 'finish', 950, 'Son engelden sonra her seviye hızı %2 artırır.'),
];
const swimUpgrades = [
  UpgradeDef('Çıkış Dalışı', 'swim-dive', 950, 'İlk 25 metrede her seviye hızı %2 artırır.'),
  UpgradeDef('Kulaç Gücü', 'swim-paw', 1100, 'Yarış boyunca her seviye hızı %1,2 artırır.'),
  UpgradeDef('Nefes Kontrolü', 'swim-breath', 900, 'Son 50 metrede her seviye hızı %1,5 artırır.'),
  UpgradeDef('Su Direnci', 'swim-wave', 1000, 'Son 25 metrede her seviye hızı %1,7 artırır.'),
];
const longJumpUpgrades = [
  UpgradeDef('Çıkış Hızı', 'jump-start', 950, 'Hızlı yaklaşma ile mesafeyi artırır; her seviye +%0,7 mesafe bonusu.'),
  UpgradeDef('Adımlama', 'jump-steps', 1100, 'Tahtaya doğru adımlama; her seviye +%0,9 mesafe bonusu.'),
  UpgradeDef('Sıçrama Gücü', 'jump-power', 1200, 'Daha güçlü sıçrama; her seviye +%1,6 mesafe bonusu.'),
  UpgradeDef('İniş Tekniği', 'jump-land', 1000, 'Kuma daha verimli iniş; her seviye +%1,1 mesafe bonusu.'),
];
const weightUpgrades = [
  UpgradeDef('Temel Güç', 'weight-strength', 1000, 'Her seviye hedef kaldırış ağırlığını %2,5 artırır.'),
  UpgradeDef('Kavrama', 'weight-grip', 1100, 'Her seviye başarılı kaldırış şansını 0,8 yüzde puan artırır.'),
  UpgradeDef('Denge', 'weight-balance', 950, 'Her seviye başarılı kaldırış şansını 0,9 yüzde puan artırır.'),
  UpgradeDef(
    'Son Hamle',
    'weight-finish',
    1200,
    'Her seviye ağırlığı %1 ve başarı şansını 0,3 yüzde puan artırır. Başarı şansı en fazla %98 olur.',
  ),
];
const archeryUpgrades = [
  UpgradeDef(
    'Nişan Alma',
    'archery-aim',
    1000,
    'Her seviye isabeti +0,028 artırır. İsabet arttıkça oklar merkeze yaklaşır; 10 puana yaklaştıkça kazanç azalır.',
  ),
  UpgradeDef('Yay Gücü', 'archery-bow', 1100, 'Her seviye isabeti +0,032 artırır; oklar merkeze yaklaşır.'),
  UpgradeDef('Rüzgâr Okuma', 'archery-wind', 950, 'Her seviye isabeti +0,018 artırır; oklar merkeze yaklaşır.'),
  UpgradeDef('Son Atış', 'archery-last', 1200, 'Her seviye isabeti +0,012 artırır; oklar merkeze yaklaşır.'),
];

class EquipmentItem {
  const EquipmentItem(this.name, this.effects, this.base);
  final String name;

  /// Yıldız başına gerçek etki: (nerede, yüzde).
  final List<(String, double)> effects;
  final int base;
}

const equipmentItems = [
  EquipmentItem('Yarış Ayakkabısı', [('100 m hızı', 3), ('Engelli hızı', 2), ('Yüzme hızı', 1.2)], 2000),
  EquipmentItem('Çıkış Bloğu', [('100 m, ilk 25 m hızı', 4)], 1800),
  EquipmentItem('Koşu Forması', [('100 m, son 50 m hızı', 2.5)], 2200),
  EquipmentItem('Sprint Bilekliği', [('100 m, son 20 m hızı', 4)], 2000),
];

class Prize {
  const Prize(this.label, {this.icon = '', this.money = 0, this.gems = 0, this.tickets = 0});
  final String icon;
  final String label;
  final int money;
  final int gems;
  final int tickets;
}

const dailyPrizes = [
  Prize('₺10K', icon: '💵', money: 10000),
  Prize('1 bilet', icon: '🎟️', tickets: 1),
  Prize('10 elmas', icon: '💎', gems: 10),
  Prize('₺25K', icon: '💵', money: 25000),
  Prize('2 bilet', icon: '🎟️', tickets: 2),
  Prize('25 elmas', icon: '💎', gems: 25),
  Prize('Büyük ödül', icon: '🎁', money: 50000, gems: 40, tickets: 2),
];

const wheelPrizes = [
  Prize('₺5K', money: 5000),
  Prize('₺10K', money: 10000),
  Prize('₺20K', money: 20000),
  Prize('5 elmas', gems: 5),
  Prize('10 elmas', gems: 10),
  Prize('1 bilet', tickets: 1),
];

const chestNames = {'normal': 'Spor Çantası', 'cup': 'Kupa Çantası', 'champion': 'Şampiyon Çantası'};
const cosmeticNames = ['Altın Çerçeve', 'Mavi Şimşek Çerçeve', 'Yıldız Çerçeve', 'Pati Çerçeve'];

/// Branş → sporcu sırasına göre çarpan (Çita, Rakun, Ayı, Tavşan, Kaplumbağa, Tilki).
const specialties = {
  'sprint': [1.06, 1.0, 1.0, 1.03, 1.0, 1.0],
  'hurdles': [1.0, 1.03, 1.0, 1.06, 1.0, 1.0],
  'swim': [1.0, 1.0, 1.0, 1.0, 1.06, 1.03],
  'longjump': [1.03, 1.0, 1.0, 1.0, 1.0, 1.06],
  'weights': [1.0, 1.0, 1.06, 1.0, 1.03, 1.0],
  'archery': [1.0, 1.06, 1.03, 1.0, 1.0, 1.0],
};

double specialty(String branch, int id) {
  final values = specialties[branch];
  if (values == null || id < 0 || id >= values.length) return 1;
  return values[id];
}

/// Uzmanlık ve gerçek etkisi: hızda/mesafede/kiloda çarpan; okçulukta her oka eklenen isabet.
String specialtyLabel(int id) {
  final labels = specialtyTags(id);
  return labels.isEmpty ? 'Çok yönlü' : labels.join(', ');
}

/// Uzmanlıklar ayrı etiketler olarak (kartlarda çip).
List<String> specialtyTags(int id) {
  return [
    for (final entry in specialties.entries)
      if (entry.value[id] > 1)
        entry.key == 'archery'
            ? '${branchLabel(entry.key)} +${_tr2((entry.value[id] - 1) * 12)} isabet'
            : '${branchLabel(entry.key)} +%${_tr1((entry.value[id] - 1) * 100)}',
  ];
}

String _tr1(double v) => _trim(v.toStringAsFixed(1));
String _tr2(double v) => _trim(v.toStringAsFixed(2));
String _trim(String v) => v.replaceAll(RegExp(r'\.?0+$'), '').replaceAll('.', ',');

class CampusRow {
  const CampusRow(this.name, this.effect, this.amount, this.base, this.icon, {this.unit = '%'});
  final String name;
  final String effect;

  /// Kademe başına gerçek etki ([unit] cinsinden).
  final double amount;
  final int base;
  final String icon;

  /// '%' (yüzde) ya da 'isabet' (okçulukta oka eklenen isabet).
  final String unit;

  /// Verilen kademe sayısındaki toplam etki, ör. "+%2,5" ya da "+0,64 isabet".
  String format(int ranks) => unit == '%' ? '+%${_tr1(amount * ranks)}' : '+${_tr2(amount * ranks)} $unit';
}

class CampusFacility {
  const CampusFacility(this.id, this.name, this.label, this.icon, this.x, this.y, this.area, this.rows);
  final String id;
  final String name;
  final String label;
  final String icon;
  final double x;
  final double y;

  /// [left, top, width, height] yüzde olarak, haritanın kendi oranına göre.
  final List<double> area;
  final List<CampusRow> rows;
  bool get locked => false;
}

const campusFacilities = [
  CampusFacility(
    'sprint',
    '100 METRE TESİSİ',
    '100 METRE',
    'shoe',
    25,
    25,
    [6, 11, 36, 14],
    [
      CampusRow('Çıkış Hızı', 'İlk 25 m hızı', 1, 2, 'shoe'),
      CampusRow('Sprint Gücü', 'Genel hız', 1, 3, 'speed'),
      CampusRow('Finiş Gücü', 'Son 20 m hızı', 1, 3, 'finish'),
    ],
  ),
  CampusFacility(
    'hurdles',
    'ENGELLİ KOŞU TESİSİ',
    'ENGELLİ KOŞU',
    'speed',
    79,
    26,
    [63, 11, 29, 12],
    [
      CampusRow('Engel Ritmi', 'Engel üstünde hız', 2.5, 2, 'speed'),
      CampusRow('Atlayış Tekniği', 'Genel hız', 1, 3, 'shoe'),
      CampusRow('Finiş Temposu', 'Son engelden sonra hız', 1, 3, 'finish'),
    ],
  ),
  CampusFacility(
    'swim',
    'YÜZME TESİSİ',
    'YÜZME',
    'stamina',
    16,
    47,
    [2, 29, 27, 16],
    [
      CampusRow('Çıkış Tepkisi', 'İlk 25 m hızı', 1, 2, 'shoe'),
      CampusRow('Kulaç Gücü', 'Genel hız', 1, 3, 'speed'),
      CampusRow('Nefes Kontrolü', 'Son 50 m hızı', 1, 3, 'stamina'),
    ],
  ),
  CampusFacility(
    'stadium',
    'STADYUM',
    'STADYUM',
    'stadium',
    56,
    50,
    [34, 28, 40, 21],
    [
      CampusRow('Tribün Kapasitesi', 'Tribün geliri', 5, 2, 'team'),
      CampusRow('Bilet Geliri', 'Bilet geliri', 5, 3, 'ticket'),
      CampusRow('Sponsorluk', 'Yarış ödülü', 3, 3, 'trophy'),
    ],
  ),
  CampusFacility(
    'jump',
    'UZUN ATLAMA TESİSİ',
    'UZUN ATLAMA',
    'shoe',
    20,
    66,
    [4, 54, 30, 12],
    [
      CampusRow('Koşu Hızı', 'Atlama mesafesi', 1, 2, 'shoe'),
      CampusRow('Sıçrama Gücü', 'Atlama mesafesi', 1, 3, 'speed'),
      CampusRow('İniş Tekniği', 'Atlama mesafesi', 1, 3, 'finish'),
    ],
  ),
  CampusFacility(
    'weights',
    'HALTER TESİSİ',
    'HALTER',
    'stamina',
    53,
    70,
    [39, 55, 25, 14],
    [
      CampusRow('Temel Güç', 'Kaldırılan kilo', 1, 2, 'stamina'),
      CampusRow('Denge', 'Başarı şansı', .9, 3, 'medal'),
      CampusRow('Son Hamle', 'Kaldırılan kilo', .6, 3, 'finish'),
    ],
  ),
  CampusFacility(
    'archery',
    'OKÇULUK TESİSİ',
    'OKÇULUK',
    'medal',
    86,
    66,
    [76, 52, 18, 14],
    [
      CampusRow('Nişan Tekniği', 'Her oka', .32, 2, 'medal', unit: 'isabet'),
      CampusRow('Yay Gücü', 'Her oka', .3, 3, 'stamina', unit: 'isabet'),
      CampusRow('Odaklanma', '3. oka', .42, 3, 'finish', unit: 'isabet'),
    ],
  ),
];

// ---- Görsel parçaları (paintArt karşılığı) ----

class SpriteRef {
  const SpriteRef(this.image, this.src);
  final String image;
  final Rect src;
}

/// Bir `data-art` anahtarı ya sprite kırpıntısı ya da emoji olarak çizilir.
class ArtSpec {
  const ArtSpec.sprite(SpriteRef this.sprite) : emoji = null;
  const ArtSpec.emoji(String this.emoji) : sprite = null;
  final SpriteRef? sprite;
  final String? emoji;
}

const imgReference = 'assets/images/reference.png';
const imgUiIcons = 'assets/images/ui-icons.png';
const imgNavIcons = 'assets/images/nav-icons.png';
const imgEquipment = 'assets/images/equipment-icons.png';
const imgJumpIcons = 'assets/images/jump-icons-source.png';
const imgWeightIcons = 'assets/images/weights-icons-source.png';

const spriteImages = [imgReference, imgUiIcons, imgNavIcons, imgEquipment, imgJumpIcons, imgWeightIcons];

Rect _r(List<num> r) => Rect.fromLTWH(r[0].toDouble(), r[1].toDouble(), r[2].toDouble(), r[3].toDouble());

const _referenceArt = {
  'avatar': [69.0, 58, 73, 75],
  'trophy': [67.0, 163, 77, 74],
  'shoe': [64.0, 1009, 75, 72],
  'speed': [515.0, 1009, 76, 71],
  'stamina': [66.0, 1273, 80, 64],
  'finish': [514.0, 1267, 77, 69],
  'clipboard': [35.0, 1524, 96, 97],
  'bag': [174.0, 1528, 79, 93],
  'cards': [301.0, 1530, 75, 91],
  'camp': [553.0, 1530, 85, 92],
  'medal': [685.0, 1529, 74, 93],
  'shop': [805.0, 1527, 101, 93],
  'cheetah': [705.0, 524, 38, 38],
  'raccoon': [623.0, 576, 36, 35],
  'bear': [493.0, 609, 36, 35],
  'rabbit': [374.0, 650, 36, 35],
  'turtle': [404.0, 710, 33, 31],
  'fox': [521.0, 758, 36, 35],
};

const _iconGrid = {
  'avatar': [0, 0],
  'trophy': [1, 0],
  'gear': [2, 0],
  'gem': [3, 0],
  'shoe': [4, 0],
  'bank': [5, 0],
  'team': [0, 1],
  'speed': [1, 1],
  'stamina': [2, 1],
  'finish': [3, 1],
  'stadium': [4, 1],
  'ticket': [5, 1],
  'clipboard': [0, 2],
  'bag': [1, 2],
  'cards': [2, 2],
  'medal': [3, 2],
  'camp': [4, 2],
  'shop': [5, 2],
};

const _jumpIcons = {
  'jump-start': [46.0, 999, 107, 88],
  'jump-steps': [500.0, 998, 110, 92],
  'jump-power': [43.0, 1252, 111, 92],
  'jump-land': [498.0, 1252, 111, 92],
};

const _weightIcons = {
  'weight-strength': [48.0, 1000, 105, 90],
  'weight-grip': [500.0, 1000, 110, 92],
  'weight-balance': [48.0, 1252, 106, 94],
  'weight-finish': [500.0, 1252, 110, 94],
};

const _archeryEmoji = {'archery-aim': '🎯', 'archery-bow': '🏹', 'archery-wind': '🍃', 'archery-last': '➶'};
const _swimEmoji = {'swim-dive': '🏊', 'swim-paw': '🐾', 'swim-breath': '🤿', 'swim-wave': '🌊'};

ArtSpec artSpec(String key) {
  final weight = _weightIcons[key];
  if (weight != null) return ArtSpec.sprite(SpriteRef(imgWeightIcons, _r(weight)));
  final archery = _archeryEmoji[key];
  if (archery != null) return ArtSpec.emoji(archery);
  final jump = _jumpIcons[key];
  if (jump != null) return ArtSpec.sprite(SpriteRef(imgJumpIcons, _r(jump)));
  final swim = _swimEmoji[key];
  if (swim != null) return ArtSpec.emoji(swim);
  final grid = _iconGrid[key];
  if (grid != null) {
    return ArtSpec.sprite(SpriteRef(imgUiIcons, Rect.fromLTWH(grid[0] * 256.0, grid[1] * 256.0, 256, 256)));
  }
  return ArtSpec.sprite(SpriteRef(imgReference, _r(_referenceArt[key] ?? _referenceArt['avatar']!)));
}

SpriteRef navIcon(int column) => SpriteRef(imgNavIcons, Rect.fromLTWH(column * 256.0, 0, 256, 256));
SpriteRef equipmentIcon(int i) => SpriteRef(imgEquipment, Rect.fromLTWH(i * 256.0, 0, 256, 256));
