import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import 'campus_world.dart';

/// Kampüs çizicisi (duck-gacha `ParkGame` düzeni): Flame yalnız oyun döngüsü ve tuvaldir;
/// bileşen yok, harita ve canlı efektler tek `render` içinde çizilir. Etiketler ve
/// pencereler Flutter katmanıdır (`CampusViewport`).
class CampusGame extends Game {
  CampusGame({required this.world});
  final CampusWorld world;

  static const mapArt = 'assets/images/campus-map.png';

  /// Kamera ya da durum değişince artar; üstteki Flutter katmanı bununla yenilenir.
  final revision = ValueNotifier<int>(0);
  bool ready = false, removed = false;
  Object? loadError;
  ui.Image? _map;

  /// Cihaz pikseli / mantıksal piksel; en yakın yakınlaştırmayı belirler.
  double pixelRatio = 3;
  double _accumulator = 0;

  final _mapPaint = Paint()..filterQuality = FilterQuality.high;
  final _glowFill = Paint();
  final _glowOutline = Paint()..style = PaintingStyle.stroke;
  final _glowEdge = Paint()..style = PaintingStyle.stroke;

  @override
  Future<void> onLoad() async {
    try {
      final data = await rootBundle.load(mapArt);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      _map = (await codec.getNextFrame()).image;
      if (removed) return;
      limitZoom();
      ready = true;
      changed();
    } catch (e) {
      if (!removed) {
        loadError = e;
        changed();
      }
    }
  }

  /// En yakın yakınlaştırmada bir harita pikseli en çok ~1,6 cihaz pikseline yayılır;
  /// en uzak görünümün 1,6 katından az olmasın ki harita her zaman biraz yakınlaşsın.
  void limitZoom() {
    final map = _map;
    final texels = map == null ? .5 : map.width / CampusCamera.worldSize.width;
    final camera = world.camera;
    camera.maxZoom = math.max(texels * 1.6 / pixelRatio, camera.minZoom * 1.6);
    camera.constrain();
  }

  void changed() {
    if (removed) return;
    revision.value++;
    if (paused) stepEngine(stepTime: 0);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    world.camera.resize(Size(size.x, size.y));
    if (ready) limitZoom();
  }

  @override
  void onRemove() {
    removed = true;
    revision.dispose();
    _map?.dispose();
    super.onRemove();
  }

  @override
  Color backgroundColor() => const Color(0xFF1F6B2C);

  @override
  void update(double dt) {
    if (!ready || removed) return;
    // Sabit 30 Hz simülasyon; arka plandan dönünce birikmiş adım fırtınası yok.
    _accumulator += dt.clamp(0, .1);
    while (_accumulator >= 1 / 30) {
      world.update(1 / 30);
      _accumulator -= 1 / 30;
    }
  }

  @override
  void render(Canvas canvas) {
    final map = _map;
    if (!ready || removed || map == null) return;
    final camera = world.camera;
    canvas.save();
    canvas.clipRect(Offset.zero & camera.viewport);
    canvas.translate(camera.viewport.width / 2, camera.viewport.height / 2);
    canvas.scale(camera.zoom);
    canvas.translate(-camera.center.dx, -camera.center.dy);
    canvas.drawImageRect(
      map,
      Rect.fromLTWH(0, 0, map.width.toDouble(), map.height.toDouble()),
      Offset.zero & CampusCamera.worldSize,
      _mapPaint,
    );
    _upgradeGlow(canvas);
    canvas.restore();
  }

  /// Geliştirilebilir tesisin çevresinde nabız gibi atan altın çerçeve (sahnede canlanan öğe).
  /// Kalınlık ekran pikseli cinsinden sabit: uzak görünümde de seçilir.
  void _upgradeGlow(Canvas canvas) {
    final pulse = .5 + .5 * math.sin(world.elapsed * 3);
    final px = 1 / world.camera.zoom;
    _glowFill.color = Color.fromRGBO(255, 222, 70, .12 + .12 * pulse);
    _glowOutline
      ..strokeWidth = 7 * px
      ..color = Color.fromRGBO(20, 41, 63, .35 + .2 * pulse);
    _glowEdge
      ..strokeWidth = 3.5 * px
      ..color = Color.fromRGBO(255, 210, 40, .75 + .25 * pulse);
    for (final id in world.upgradable) {
      final spot = campusSpots[id];
      if (spot == null) continue;
      final shape = RRect.fromRectAndRadius(spot.art.inflate((4 + 3 * pulse) * px), Radius.circular(18 * px));
      canvas.drawRRect(shape, _glowFill);
      canvas.drawRRect(shape, _glowOutline);
      canvas.drawRRect(shape, _glowEdge);
    }
  }
}
