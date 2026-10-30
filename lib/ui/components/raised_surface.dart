import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

/// Kabarık yüzey: düz dolgu, altında kendi renginin koyusu bir dudak bandı ve yumuşak temas gölgesi,
/// içte üstten aydınlık / alttan gölgeli ince kenar ışığı, sol üstte parıltı ve koyu kontur.
/// Düğmeler, anahtarlar, başlık plakası ve kapat düğmesi bununla çizilir (gradyan yok).
class RaisedSurface extends StatelessWidget {
  const RaisedSurface({super.key, required this.color, required this.shade, this.radius = 18, this.lip, this.glossy = true, this.child});

  /// Yeşil kontrol (açık anahtar, onay).
  const RaisedSurface.green({super.key, this.radius = 18, this.lip, this.child})
    : color = GameColors.green,
      shade = GameColors.greenShade,
      glossy = true;

  /// Gri kontrol (kapalı / kilitli).
  const RaisedSurface.locked({super.key, this.radius = 18, this.lip, this.child})
    : color = GameColors.locked,
      shade = GameColors.lockedShade,
      glossy = false;

  /// Krem ikincil düğme.
  const RaisedSurface.cream({super.key, this.radius = 18, this.lip, this.child})
    : color = GameColors.paper,
      shade = GameColors.creamShade,
      glossy = false;

  final Color color;

  /// Kenar ışığının alt tonu ve dudak bandının rengi buradan türetilir.
  final Color shade;
  final double radius;

  /// Alt dudak kalınlığı; verilmezse yüksekliğe göre 2–3 pt.
  final double? lip;
  final bool glossy;
  final Widget? child;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _RaisedPainter(color: color, shade: shade, radius: radius, lip: lip, glossy: glossy),
    child: child,
  );
}

class _RaisedPainter extends CustomPainter {
  const _RaisedPainter({required this.color, required this.shade, required this.radius, required this.lip, required this.glossy});
  final Color color;
  final Color shade;
  final double radius;
  final double? lip;
  final bool glossy;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1.5);
    final r = Radius.circular(radius.clamp(0, rect.shortestSide / 2));
    final shape = Path()..addRRect(RRect.fromRectAndRadius(rect, r));
    final lipHeight = lip ?? (rect.height * .045).clamp(2.0, 3.0);

    // Temas gölgesi ve dudak bandı.
    canvas.drawPath(
      shape.shift(Offset(0, lipHeight + 1.5)),
      Paint()
        ..color = GameColors.ink.withValues(alpha: .14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawPath(shape.shift(Offset(0, lipHeight)), Paint()..color = Color.lerp(color, GameColors.ink, .32)!);
    canvas.drawPath(shape, Paint()..color = color);

    // İç kenar ışığı: üstte beyaz, altta gölge tonu.
    canvas.save();
    canvas.clipPath(shape);
    final bevel = RRect.fromRectAndRadius(rect.deflate(3), Radius.circular((r.x - 3).clamp(0, 999)));
    canvas.drawRRect(
      bevel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = glossy ? 4 : 2.5
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0x99FFFFFF), const Color(0x48FFFFFF), shade.withValues(alpha: .16), shade.withValues(alpha: .48)],
          stops: const [0, .35, .58, 1],
        ).createShader(rect),
    );
    if (glossy) {
      // Parıltı sol üst kıvrımda; yeri ve boyu yüksekliğe göre.
      final h = rect.height;
      final scale = (h / 60).clamp(.55, 1.0);
      final wide = rect.width > h * 2;
      canvas.translate(
        rect.left + (wide ? (h * .38).clamp(7.0, 19.0) : (h * .3).clamp(6.0, 13.0)),
        rect.top + (h * .24).clamp(5.0, wide ? 15.0 : 10.0),
      );
      canvas.rotate(-.65);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 11 * scale, height: 4.5 * scale),
        Paint()..color = const Color(0xCFFFFFFF),
      );
    }
    canvas.restore();

    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (rect.height * .073).clamp(2.2, 3.2)
        ..color = GameColors.ink,
    );
  }

  @override
  bool shouldRepaint(_RaisedPainter old) =>
      old.color != color || old.shade != shade || old.radius != radius || old.lip != lip || old.glossy != glossy;
}

/// Düz kart: dolgu + koyu kontur + yumuşak temas gölgesi (satırlar, liste kartları).
BoxDecoration flatCardDecoration({Color color = GameColors.row, double radius = 18, double borderWidth = 2.7}) => BoxDecoration(
  color: color,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: GameColors.ink, width: borderWidth),
  boxShadow: const [BoxShadow(color: GameColors.cardShadow, offset: Offset(0, 2.5), blurRadius: 3)],
);
