import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import 'campus_world.dart';

/// Kampüs çizicisi (duck-gacha `ParkGame` düzeni): Flame yalnız oyun döngüsü ve tuvaldir;
/// bileşen yok, harita ve canlı öğeler tek `render` içinde çizilir. Etiketler ve
/// pencereler Flutter katmanıdır (`CampusViewport`). Binalar zemine çizili olduğu sürece
/// üstlerine efekt bindirilmez (çizimi soldurur); bina efektleri ayrı bina çizimleriyle gelir.
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

  final _mapPaint = Paint();

  @override
  Future<void> onLoad() async {
    try {
      final data = await rootBundle.load(mapArt);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final image = _map = (await codec.getNextFrame()).image;
      if (removed) return;
      _mapPaint.shader = ImageShader(
        image,
        TileMode.mirror,
        TileMode.mirror,
        Float64List.fromList([
          CampusCamera.worldSize.width / image.width, 0, 0, 0, //
          0, CampusCamera.worldSize.height / image.height, 0, 0,
          0, 0, 1, 0,
          0, 0, 0, 1,
        ]),
        filterQuality: FilterQuality.medium,
      );
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

  /// En yakın yakınlaştırmada bir harita pikseli ~1,6 cihaz pikseline yayılır; harita görseli
  /// bundan düşük çözünürlüklüyse yine de en uzak görünümün 2,5 katına kadar yakınlaşılır
  /// (yüksek çözünürlüklü harita gelince sınır kendiliğinden genişler).
  void limitZoom() {
    final map = _map;
    final texels = map == null ? .5 : map.width / CampusCamera.worldSize.width;
    final camera = world.camera;
    camera.maxZoom = math.max(texels * 1.6 / pixelRatio, camera.minZoom * 2.5);
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
    // Harita kenarın ötesinde aynalanarak sürer: boş kenar yok (Duck Park da kenar ağaçlarını aynalar).
    canvas.drawRect(camera.visible.inflate(8), _mapPaint);
    canvas.restore();
  }
}
