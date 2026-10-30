import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/controller.dart';
import '../game/data.dart';
import 'theme.dart';

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
  const Art(this.artKey, {super.key, this.width = 31, this.height = 31, this.emojiSize = 16, this.radius});
  final String artKey;
  final double width;
  final double height;
  final double emojiSize;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    final spec = artSpec(artKey);
    if (spec.emoji != null) {
      return SizedBox(
        width: width,
        height: height,
        child: Center(child: Text(spec.emoji!, style: TextStyle(fontSize: emojiSize, height: 1))),
      );
    }
    return Sprite(spec.sprite!, width: width, height: height, radius: radius);
  }
}

/// Basılınca 1px aşağı inen, devre dışıyken solan düğme.
class Btn extends StatefulWidget {
  const Btn({
    super.key,
    required this.onTap,
    required this.child,
    this.enabled = true,
    this.semanticLabel,
    this.disabledSaturation = .35,
    this.disabledOpacity = .7,
  });

  final VoidCallback? onTap;
  final Widget child;
  final bool enabled;
  final String? semanticLabel;
  final double disabledSaturation;
  final double disabledOpacity;

  @override
  State<Btn> createState() => _BtnState();
}

class _BtnState extends State<Btn> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled && widget.onTap != null;
    Widget child = widget.child;
    if (!enabled) {
      child = disabledLook(child, saturation: widget.disabledSaturation, opacity: widget.disabledOpacity);
    } else if (_down) {
      child = Transform.translate(offset: const Offset(0, 1), child: child);
    }
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTap: enabled
            ? () {
                GameScope.of(context, listen: false).buttonFeedback();
                widget.onTap!();
              }
            : null,
        child: child,
      ),
    );
  }
}

/// Denetleyiciyi ağaca taşır.
class GameScope extends InheritedNotifier<GameController> {
  const GameScope({super.key, required GameController controller, required super.child}) : super(notifier: controller);

  static GameController of(BuildContext context, {bool listen = true}) {
    if (listen) return context.dependOnInheritedWidgetOfExactType<GameScope>()!.notifier!;
    return (context.getElementForInheritedWidgetOfExactType<GameScope>()!.widget as GameScope).notifier!;
  }
}

/// `.row button` / `.modal-action`
class ActionButton extends StatelessWidget {
  const ActionButton(
    this.label, {
    super.key,
    required this.onTap,
    this.enabled = true,
    this.full = false,
    this.fontSize = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    this.borderColor = const Color(0xFF1C7332),
    this.borderWidth = 2,
    this.gradient = const [Color(0xFF52DE35), Color(0xFF18B72B)],
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final bool full;
  final double fontSize;
  final EdgeInsets padding;
  final Color borderColor;
  final double borderWidth;
  final List<Color> gradient;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final box = GBox(
      gradient: vGradient(gradient),
      radius: 8,
      borderColor: borderColor,
      borderWidth: borderWidth,
      padding: padding,
      alignment: full ? Alignment.center : null,
      child: Text(label, textAlign: TextAlign.center, style: nunito(fontSize, color: Colors.white)),
    );
    return Padding(
      padding: EdgeInsets.only(top: full ? 11 : 0),
      child: Btn(
        onTap: onTap,
        enabled: enabled,
        semanticLabel: semanticLabel,
        child: full ? SizedBox(width: double.infinity, child: box) : box,
      ),
    );
  }
}
