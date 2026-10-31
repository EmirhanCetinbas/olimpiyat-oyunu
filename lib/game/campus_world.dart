import 'dart:math' as math;
import 'dart:ui';

import 'data.dart';

/// Kampüs haritasının saf Dart katmanı (duck-gacha `ParkWorld` / `ParkCamera` düzeni):
/// sabit dünya koordinatları, kamera, tesis yerleri ve dokunma testi. Flutter bileşeni yok;
/// çizim `CampusGame`, arayüz `CampusViewport` işidir.
class CampusCamera {
  /// Dünya birimi harita görselinden bağımsızdır (campus-map.png 1024×1536 → ×2).
  static const worldSize = Size(2048, 3072);

  /// Haritanın kenarından bu kadar öteye bakılabilir; köşeler ekranın ortasına getirilebilir.
  static const margin = 160.0;

  /// Çizici, harita görselinin taşıdığı ayrıntıya göre ayarlar (bulanık büyütme olmasın).
  double maxZoom = .5;
  Size viewport = Size.zero;
  Offset center = worldSize.center(Offset.zero);
  double zoom = .2;
  Offset _anchor = Offset.zero;
  double _gestureZoom = .2;

  /// Ekranın üstünü ve altını örten arayüz şeritleri: harita o kadar ötesine çekilebilir.
  double insetTop = 0, insetBottom = 0;

  /// En uzakta harita ve kenar payı ekranı doldurur.
  double get minZoom =>
      viewport.isEmpty ? .1 : math.max(viewport.width / (worldSize.width + 2 * margin), viewport.height / (worldSize.height + 2 * margin));

  Rect get visible => Rect.fromCenter(center: center, width: viewport.width / zoom, height: viewport.height / zoom);
  Offset toWorld(Offset screen) => center + (screen - viewport.center(Offset.zero)) / zoom;
  Offset toScreen(Offset world) => (world - center) * zoom + viewport.center(Offset.zero);

  void resize(Size size) {
    if (size.isEmpty || size == viewport) return;
    viewport = size;
    constrain();
  }

  void constrain() {
    zoom = zoom.clamp(minZoom, math.max(minZoom, maxZoom));
    double axis(double value, double world, double view, double lo, double hi) {
      final min = view / 2 - lo, max = world - view / 2 + hi;
      return min >= max ? (min + max) / 2 : value.clamp(min, max);
    }

    center = Offset(
      axis(center.dx, worldSize.width, viewport.width / zoom, margin, margin),
      axis(center.dy, worldSize.height, viewport.height / zoom, margin + insetTop / zoom, margin + insetBottom / zoom),
    );
  }

  /// Kıstırma parmakların altındaki dünya noktasını orada tutar.
  void begin(Offset focal) {
    _anchor = toWorld(focal);
    _gestureZoom = zoom;
  }

  void gesture(Offset focal, double scale) {
    if (!scale.isFinite || scale <= 0) return;
    zoom = (_gestureZoom * scale).clamp(minZoom, math.max(minZoom, maxZoom));
    center = _anchor - (focal - viewport.center(Offset.zero)) / zoom;
    constrain();
  }

  void overview() {
    zoom = minZoom;
    center = worldSize.center(Offset.zero);
    constrain();
  }

  void focus(Offset point, {required double scale}) {
    center = point;
    zoom = scale;
    constrain();
  }

  List<double> snapshot() => [center.dx, center.dy, zoom];

  void restore(List<double>? value) {
    if (value == null || value.length != 3 || value.any((n) => !n.isFinite)) return;
    center = Offset(value[0], value[1]);
    zoom = value[2];
    constrain();
  }
}

/// Bir tesisin haritadaki yeri: dokunma dikdörtgeni ([art]), tabanının ortası ([at];
/// derinlik sırası için) ve etiketinin yeri ([label]).
class CampusSpot {
  const CampusSpot({required this.id, required this.art, required this.label});
  final String id;
  final Rect art;
  final Offset label;
  Offset get at => art.bottomCenter;
}

/// Tesis yerleri harita görselinden ölçüldü ([CampusFacility.area], [CampusFacility.x]/[y]:
/// haritanın yüzdesi). Binalar ayrı çizimler olarak gelince yerleri aynı kalır.
final campusSpots = {
  for (final f in campusFacilities)
    f.id: CampusSpot(
      id: f.id,
      art: Rect.fromLTWH(
        f.area[0] / 100 * CampusCamera.worldSize.width,
        f.area[1] / 100 * CampusCamera.worldSize.height,
        f.area[2] / 100 * CampusCamera.worldSize.width,
        f.area[3] / 100 * CampusCamera.worldSize.height,
      ),
      label: Offset(f.x / 100 * CampusCamera.worldSize.width, f.y / 100 * CampusCamera.worldSize.height),
    ),
};

/// Kampüs dünyası: kamera, tesislerin durumu ve geçen süre (canlı efektler bununla zamanlanır).
class CampusWorld {
  final camera = CampusCamera();

  /// Geliştirilebilir tesisler (SP yetiyor): haritada parlar.
  Set<String> upgradable = {};

  /// Tesis seviyeleri (etiketler ve ileride seviyeye göre bina çizimi).
  Map<String, int> levels = {};

  double elapsed = 0;

  void update(double dt) => elapsed += dt;

  /// Dünya noktasındaki tesis; üst üste binerse önde (tabanı aşağıda) olan kazanır.
  String? facilityAt(Offset world) {
    String? best;
    var front = double.negativeInfinity;
    for (final s in campusSpots.values) {
      if (s.art.contains(world) && s.at.dy > front) {
        best = s.id;
        front = s.at.dy;
      }
    }
    return best;
  }

  /// Kamera açılışta stadyuma (haritanın ortası) bakar, harita genişliği ekranı doldurur.
  void openingView() {
    final stadium = campusSpots['stadium']!;
    camera.focus(stadium.art.center, scale: camera.viewport.width / CampusCamera.worldSize.width);
  }
}
