import 'package:flutter/material.dart';

import '../../components/components.dart';
import '../../theme/theme.dart';

/// Ayarlar kontrollerinin ortak ölçüleri (tasarım referansı, 352pt panel).
abstract final class PrefsMetrics {
  static const border = 2.5;
  static const controlHeight = 35.0;
  static const trackHeight = 25.0;
  static const knob = 33.0;
  static double switchWidth(bool compact) => compact ? 100 : 114;
  static double statusWidth(bool compact) => compact ? 110 : 124;
}

const _green = [Color(0xFF6BEE4F), Color(0xFF2FCB33), Color(0xFF15A92A)];
const _grey = [Color(0xFFA9B5BD), Color(0xFF8795A0), Color(0xFF6E7C87)];
const _stops = [0.0, .55, 1.0];

/// Beyaz, koyu konturlu yuvarlak topuz.
class _Knob extends StatelessWidget {
  const _Knob({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: GameColors.ink, width: PrefsMetrics.border),
      gradient: const RadialGradient(center: Alignment(-.3, -.4), radius: .9, colors: [Colors.white, Color(0xFFE6EEF2)]),
      boxShadow: const [BoxShadow(color: Color(0x40102633), offset: Offset(0, 2))],
    ),
  );
}

/// Konturlu, parlak hap yüzeyi (kaydırıcı dolgusu, anahtar ve durum zemini).
class _Pill extends StatelessWidget {
  const _Pill({required this.colors, this.child, this.width, this.height = PrefsMetrics.controlHeight});
  final List<Color> colors;
  final Widget? child;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: Stack(
      children: [
        Positioned.fill(
          child: GBox(
            borderColor: GameColors.ink,
            borderWidth: PrefsMetrics.border,
            radius: height / 2,
            gradient: vGradient(colors, _stops),
            insets: const [Inset(Color(0x30000000), dy: -2.5)],
          ),
        ),
        Gloss(radius: height, opacity: .45, heightFactor: .4, inset: EdgeInsets.fromLTRB(height * .45, 3, height * .45, 0)),
        if (child != null) Positioned.fill(child: child!),
      ],
    ),
  );
}

TextStyle _controlText(double size) => nunito(size, weight: 1000, color: Colors.white, height: 1);

/// `.prefs-range`: yeşil dolgulu kalın kaydırıcı; dokunma alanı 44pt.
class PrefsSlider extends StatelessWidget {
  const PrefsSlider({super.key, required this.value, required this.label, required this.onChanged});
  final double value;
  final String label;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final w = box.maxWidth;
      const knob = PrefsMetrics.knob, track = PrefsMetrics.trackHeight;
      final fill = value.clamp(0.0, 1.0);
      void set(double v) => onChanged(v.clamp(0.0, 1.0).toDouble());
      void setAt(double dx) => set((dx - knob / 2) / (w - knob));
      final knobLeft = (w - knob) * fill;
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
            height: minTapTarget,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Boş çubuk
                _Pill(colors: const [Color(0xFFB9C3CA), Color(0xFFA3AFB8), Color(0xFF94A1AB)], width: w, height: track),
                // Yeşil dolgu: topuzun ortasına kadar
                if (fill > 0) _Pill(colors: _green, width: (knobLeft + knob / 2).clamp(track, w), height: track),
                Positioned(
                  left: knobLeft,
                  child: const _Knob(size: knob),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// `.prefs-switch`: AÇIK/KAPALI yazısı ve topuz ayrı alanlarda.
class PrefsSwitch extends StatelessWidget {
  const PrefsSwitch({super.key, required this.value, required this.label, required this.onChanged, required this.width});
  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    const h = PrefsMetrics.controlHeight, knob = h + 1;
    return Semantics(
      toggled: value,
      label: label,
      child: Pressable(
        onTap: () => onChanged(!value),
        minTapSize: minTapTarget,
        child: SizedBox(
          width: width,
          height: knob,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              _Pill(
                colors: value ? _green : _grey,
                width: width,
                child: Padding(
                  padding: EdgeInsets.only(left: value ? 8 : knob - 2, right: value ? knob - 2 : 8),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: OutlinedText(
                        value ? 'AÇIK' : 'KAPALI',
                        strokeWidth: 2.2,
                        shadowOffset: const Offset(0, 1.5),
                        style: _controlText(15.5),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                left: value ? width - knob + .5 : -.5,
                child: const _Knob(size: knob),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `.prefs-status`: kayıt durumu hapı (AKTİF / KAPALI).
class PrefsStatus extends StatelessWidget {
  const PrefsStatus({super.key, required this.active, required this.width});
  final bool active;
  final double width;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: _Pill(
      colors: active ? _green : _grey,
      width: width,
      child: Center(
        child: OutlinedText(active ? 'AKTİF' : 'KAPALI', strokeWidth: 2.4, shadowOffset: const Offset(0, 1.5), style: _controlText(18)),
      ),
    ),
  );
}
