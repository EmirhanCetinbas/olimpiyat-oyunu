import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

/// Sarı, koyu konturlu pati izi: başlık plakasının iki yanında (Pati Şampiyonları imzası).
/// [mirrored] sol taraftaki patiyi aynalar; ikisi de plakadan dışa doğru yatar.
class PawMark extends StatelessWidget {
  const PawMark({super.key, this.mirrored = false, this.size = defaultSize});
  static const defaultSize = 28.0;
  final bool mirrored;
  final double size;

  @override
  Widget build(BuildContext context) => Transform.flip(
    flipX: mirrored,
    child: Transform.rotate(
      angle: .38,
      child: SizedBox(
        width: size,
        height: size,
        child: const CustomPaint(painter: _PawPainter()),
      ),
    ),
  );
}

class _PawPainter extends CustomPainter {
  const _PawPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final fill = Paint()..color = GameColors.sparkle;
    final stroke = Paint()
      ..color = GameColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * .075
      ..strokeJoin = StrokeJoin.round;
    final shapes = <Rect>[
      // Avuç
      Rect.fromCenter(center: Offset(s * .5, s * .7), width: s * .52, height: s * .42),
      // Dört parmak, avucun üstünde yay şeklinde
      Rect.fromCenter(center: Offset(s * .17, s * .44), width: s * .2, height: s * .25),
      Rect.fromCenter(center: Offset(s * .37, s * .2), width: s * .2, height: s * .26),
      Rect.fromCenter(center: Offset(s * .63, s * .2), width: s * .2, height: s * .26),
      Rect.fromCenter(center: Offset(s * .83, s * .44), width: s * .2, height: s * .25),
    ];
    for (final r in shapes) {
      canvas.drawOval(r, stroke);
      canvas.drawOval(r, fill);
    }
    // Avuca ve parmaklara küçük parlama
    final shine = Paint()..color = const Color(0xB3FFFFFF);
    canvas.drawOval(Rect.fromCenter(center: Offset(s * .4, s * .62), width: s * .14, height: s * .07), shine);
  }

  @override
  bool shouldRepaint(_PawPainter oldDelegate) => false;
}
