import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Çizilmiş ödül çarkı: renkli dilimler, dilim etiketleri, merkez göbek ve üstte işaretçi.
/// [labels] boşsa küçük ikon olarak çizilir (menüde).
class PrizeWheel extends StatelessWidget {
  const PrizeWheel({super.key, required this.size, this.labels = const []});
  final double size;
  final List<String> labels;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(painter: _WheelPainter(labels, slices: labels.isEmpty ? 6 : labels.length)),
  );
}

class _WheelPainter extends CustomPainter {
  _WheelPainter(this.labels, {required this.slices});
  final List<String> labels;
  final int slices;

  static const _colors = [Color(0xFFFF6B5B), Color(0xFFFFD45C), Color(0xFF43D82E), Color(0xFF2F8BFF), Color(0xFFB66BF2), Color(0xFFFF9F2E)];

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = s < 60 ? 2.0 : 4.0;
    final center = Offset(s / 2, s / 2 + s * .03);
    final r = s * .44;
    final sweep = 2 * math.pi / slices;
    final ink = Paint()
      ..color = GameColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeJoin = StrokeJoin.round;
    // Gölge
    canvas.drawCircle(center.translate(0, stroke), r, Paint()..color = GameColors.ink.withValues(alpha: .25));
    for (var i = 0; i < slices; i++) {
      final start = -math.pi / 2 - sweep / 2 + i * sweep;
      final rect = Rect.fromCircle(center: center, radius: r);
      canvas.drawArc(rect, start, sweep, true, Paint()..color = _colors[i % _colors.length]);
      canvas.drawArc(rect, start, sweep, true, ink);
      if (i < labels.length) {
        final mid = start + sweep / 2;
        canvas.save();
        // Etiketler dik durur (alttaki dilimlerde ters okunmasın).
        canvas.translate(center.dx + math.cos(mid) * r * .6, center.dy + math.sin(mid) * r * .6);
        final tp = TextPainter(
          text: TextSpan(
            text: labels[i],
            style: gameText(s * .062, color: Colors.white, height: 1, shadows: outlineShadows(GameColors.ink, 1.6)),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          maxLines: 2,
        )..layout(maxWidth: r * .7);
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        canvas.restore();
      }
    }
    canvas.drawCircle(center, r, ink..strokeWidth = stroke * 1.3);
    // Göbek
    canvas.drawCircle(center, r * .16, Paint()..color = Colors.white);
    canvas.drawCircle(center, r * .16, ink..strokeWidth = stroke);
    // İşaretçi (üstte, aşağı bakan)
    final pointer = Path()
      ..moveTo(s / 2 - s * .07, center.dy - r - s * .05)
      ..lineTo(s / 2 + s * .07, center.dy - r - s * .05)
      ..lineTo(s / 2, center.dy - r + s * .07)
      ..close();
    canvas.drawPath(pointer, Paint()..color = GameColors.sparkle);
    canvas.drawPath(pointer, ink);
  }

  @override
  bool shouldRepaint(_WheelPainter old) => old.labels != labels;
}
