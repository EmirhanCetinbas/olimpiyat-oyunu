import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../game/data.dart';

/// Sprite kaynak görsellerinin çözülmüş halleri (CSS background-position kırpmaları için).
class SpriteCache {
  static final Map<String, ui.Image> _images = {};

  static Future<void> preload() async {
    await Future.wait([
      for (final path in spriteImages)
        () async {
          final data = await rootBundle.load(path);
          final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
          _images[path] = (await codec.getNextFrame()).image;
        }(),
    ]);
  }

  static ui.Image? get(String path) => _images[path];
}

class _SpritePainter extends CustomPainter {
  _SpritePainter(this.sprite, this.radius);
  final SpriteRef sprite;
  final BorderRadius? radius;

  @override
  void paint(Canvas canvas, Size size) {
    final image = SpriteCache.get(sprite.image);
    if (image == null) return;
    final dst = Offset.zero & size;
    if (radius != null) canvas.clipRRect(radius!.toRRect(dst));
    canvas.drawImageRect(
      image,
      sprite.src,
      dst,
      Paint()
        ..filterQuality = FilterQuality.medium
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_SpritePainter old) => old.sprite.image != sprite.image || old.sprite.src != sprite.src || old.radius != radius;
}

/// Bir sprite kırpıntısını verilen kutuya esneterek çizer.
class Sprite extends StatelessWidget {
  const Sprite(this.sprite, {super.key, required this.width, required this.height, this.radius});
  final SpriteRef sprite;
  final double width;
  final double height;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: CustomPaint(painter: _SpritePainter(sprite, radius)),
  );
}

/// `<span class="art" data-art="...">` karşılığı.
class Art extends StatelessWidget {
  const Art(this.artKey, {super.key, this.width = 31, this.height = 31, this.radius});
  final String artKey;
  final double width;
  final double height;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) => Sprite(artSprite(artKey), width: width, height: height, radius: radius);
}
