import 'package:flutter/material.dart';

import '../../components/components.dart';
import '../../theme/theme.dart';

/// Ayarlar kontrollerinin ölçüleri.
abstract final class PrefsMetrics {
  static const controlHeight = 40.0;
  static double sliderWidth(bool compact) => compact ? 118 : 136;
  static double switchWidth(bool compact) => compact ? 96 : 106;
  static double statusWidth(bool compact) => compact ? 104 : 116;
}

const _knobSize = 32.0;

/// Beyaz, koyu konturlu yuvarlak topuz.
class _Knob extends StatelessWidget {
  const _Knob();

  @override
  Widget build(BuildContext context) => Container(
    width: _knobSize,
    height: _knobSize,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      border: Border.all(color: GameColors.ink, width: 2.6),
      boxShadow: const [BoxShadow(color: GameColors.cardShadow, offset: Offset(0, 2), blurRadius: 2)],
    ),
  );
}

/// Kaydırıcı çubuğu: gri iz, yeşil dolgu, ince kenar ışığı, koyu kontur.
class _BarPainter extends CustomPainter {
  const _BarPainter(this.fill);
  final double fill;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1);
    final shape = RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2));
    canvas.drawRRect(shape, Paint()..color = GameColors.track);
    canvas.save();
    canvas.clipRRect(shape);
    canvas.drawRect(Rect.fromLTRB(rect.left, rect.top, rect.left + rect.width * fill, rect.bottom), Paint()..color = GameColors.green);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(2), Radius.circular(rect.height / 2 - 2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0x99FFFFFF),
            const Color(0x48FFFFFF),
            GameColors.greenShade.withValues(alpha: .16),
            GameColors.greenShade.withValues(alpha: .48),
          ],
          stops: const [0, .35, .58, 1],
        ).createShader(rect),
    );
    canvas.restore();
    canvas.drawRRect(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = GameColors.ink,
    );
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.fill != fill;
}

/// Ses kaydırıcısı; dokunma alanı 44pt.
class PrefsSlider extends StatelessWidget {
  const PrefsSlider({super.key, required this.value, required this.label, required this.onChanged, required this.width});
  final double value;
  final String label;
  final ValueChanged<double> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    final fill = value.clamp(0.0, 1.0);
    void set(double v) => onChanged(v.clamp(0.0, 1.0).toDouble());
    void setAt(double dx) => set((dx - _knobSize / 2) / (width - _knobSize));
    final knobLeft = (width - _knobSize) * fill;
    return Semantics(
      slider: true,
      label: label,
      value: '${(fill * 100).round()}',
      increasedValue: '${((fill + .1).clamp(0, 1) * 100).round()}',
      decreasedValue: '${((fill - .1).clamp(0, 1) * 100).round()}',
      onIncrease: () => set(fill + .1),
      onDecrease: () => set(fill - .1),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) => setAt(d.localPosition.dx),
        onHorizontalDragUpdate: (d) => setAt(d.localPosition.dx),
        child: SizedBox(
          width: width,
          height: minTapTarget,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Dolgu topuzun ortasına kadar gelir.
              SizedBox(
                width: width,
                height: 20,
                child: CustomPaint(painter: _BarPainter(width > 0 ? (knobLeft + _knobSize / 2) / width : 0)),
              ),
              Positioned(left: knobLeft, child: const _Knob()),
            ],
          ),
        ),
      ),
    );
  }
}

TextStyle _controlText(double size) => gameText(size, color: Colors.white, height: 1, letterSpacing: .4);

/// Açık/kapalı anahtarı: yazı ve topuz ayrı alanlarda.
class PrefsSwitch extends StatelessWidget {
  const PrefsSwitch({super.key, required this.value, required this.label, required this.onChanged, required this.width});
  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    // Topuz yüzeyin tam ortasında: dikey ve yatay boşluk eşit.
    const h = PrefsMetrics.controlHeight, inset = (h - _knobSize) / 2;
    final text = OutlinedText(value ? 'AÇIK' : 'KAPALI', shadowOffset: const Offset(0, 1.5), style: _controlText(value ? 15.5 : 14));
    return Semantics(
      toggled: value,
      label: label,
      child: Pressable(
        onTap: () => onChanged(!value),
        minTapSize: minTapTarget,
        child: SizedBox(
          width: width,
          height: h,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned.fill(
                child: value ? const RaisedSurface.green(radius: h / 2) : const RaisedSurface.locked(radius: h / 2),
              ),
              Positioned.fill(
                left: value ? 10 : _knobSize + inset,
                right: value ? _knobSize + inset : 10,
                bottom: 3,
                child: Center(
                  child: FittedBox(fit: BoxFit.scaleDown, child: text),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                top: inset,
                left: value ? width - _knobSize - inset : inset,
                child: const _Knob(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kayıt durumu hapı (AKTİF / KAPALI).
class PrefsStatus extends StatelessWidget {
  const PrefsStatus({super.key, required this.active, required this.width});
  final bool active;
  final double width;

  @override
  Widget build(BuildContext context) {
    const h = PrefsMetrics.controlHeight;
    final text = Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Center(
        child: OutlinedText(active ? 'AKTİF' : 'KAPALI', shadowOffset: const Offset(0, 1.5), style: _controlText(17)),
      ),
    );
    return Semantics(
      liveRegion: true,
      child: SizedBox(
        width: width,
        height: h,
        child: active ? RaisedSurface.green(radius: h / 2, child: text) : RaisedSurface.locked(radius: h / 2, child: text),
      ),
    );
  }
}
