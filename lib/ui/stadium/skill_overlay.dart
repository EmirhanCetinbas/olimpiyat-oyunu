import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// Zamanlama hamlesi sahanın içinde: sahanın her yerine dokunmak hamleyi yapar,
/// altta hedef bölgeli çubuk ve büyük düğme durur, sonuç ortada kısa süre görünür.
class SkillOverlay extends StatelessWidget {
  const SkillOverlay({super.key, required this.c});
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final move = c.activeMove;
    final active = !c.skillMoveHidden && move != null && !move.tapped;
    return Positioned.fill(
      child: Stack(
        children: [
          if (active)
            Positioned.fill(
              child: Semantics(
                button: true,
                label: c.skillButtonText,
                child: GestureDetector(behavior: HitTestBehavior.opaque, onTapDown: (_) => c.tapMove()),
              ),
            ),
          if (active)
            Positioned(
              left: 10,
              right: 10,
              bottom: 8,
              child: _MovePanel(label: c.skillButtonText, meter: c.skillMeter, target: move.target, onTap: c.tapMove),
            ),
          if (c.moveFeedbackTime > 0)
            Center(
              child: IgnorePointer(
                child: Opacity(
                  opacity: (c.moveFeedbackTime / .3).clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 1 + (c.moveFeedbackTime - .6).clamp(0.0, .3),
                    child: OutlinedText(
                      c.moveFeedback,
                      shadowOffset: const Offset(0, 3),
                      style: gameText(34, color: c.moveFeedbackPerfect ? const Color(0xFFFFE04A) : Colors.white, height: 1),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Kâğıt şerit: zamanlama çubuğu + hamle düğmesi.
class _MovePanel extends StatelessWidget {
  const _MovePanel({required this.label, required this.meter, required this.target, required this.onTap});
  final String label;
  final double meter;
  final double target;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
    decoration: BoxDecoration(
      color: GameColors.paper.withValues(alpha: .96),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: GameColors.ink, width: 2.5),
      boxShadow: const [BoxShadow(color: GameColors.panelShadow, offset: Offset(0, 3), blurRadius: 6)],
    ),
    child: Row(
      children: [
        Expanded(
          child: TimingTrack(meter: meter, target: target),
        ),
        const SizedBox(width: 8),
        RaisedButton(label, onTap: onTap, height: 40, minWidth: 104, fontSize: 15.5),
      ],
    ),
  );
}

/// Zamanlama çubuğu: yeşil kusursuz bölge hedefin çevresinde, sarı iyi bölge, beyaz imleç.
class TimingTrack extends StatelessWidget {
  const TimingTrack({super.key, required this.meter, required this.target});
  final double meter;
  final double target;

  @override
  Widget build(BuildContext context) => SizedBox(height: 24, child: CustomPaint(painter: _TrackPainter(meter, target)));
}

class _TrackPainter extends CustomPainter {
  _TrackPainter(this.meter, this.target);
  final double meter;
  final double target;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 3, size.width, size.height - 6);
    final shape = RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2));
    canvas.drawRRect(shape, Paint()..color = GameColors.track);
    canvas.save();
    canvas.clipRRect(shape);
    double x(double f) => rect.left + rect.width * f.clamp(0.0, 1.0);
    // İyi bölge (kalite > .35) ve kusursuz bölge (kalite > .7).
    canvas.drawRect(Rect.fromLTRB(x(target - .325), rect.top, x(target + .325), rect.bottom), Paint()..color = const Color(0xFFFFD84A));
    canvas.drawRect(
      Rect.fromLTRB(x(target - MovesLogic.perfectWindow), rect.top, x(target + MovesLogic.perfectWindow), rect.bottom),
      Paint()..color = GameColors.green,
    );
    canvas.restore();
    canvas.drawRRect(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = GameColors.ink,
    );
    // İmleç
    final cursor = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x(meter), size.height / 2), width: 7, height: size.height),
      const Radius.circular(3),
    );
    canvas.drawRRect(cursor, Paint()..color = Colors.white);
    canvas.drawRRect(
      cursor,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = GameColors.ink,
    );
  }

  @override
  bool shouldRepaint(_TrackPainter old) => old.meter != meter || old.target != target;
}
