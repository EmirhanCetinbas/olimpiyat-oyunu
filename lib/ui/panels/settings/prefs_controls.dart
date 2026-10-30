import 'package:flutter/material.dart';

import '../../components/components.dart';
import '../../theme/theme.dart';

/// `.prefs-range`: yeşil dolgulu kaydırıcı.
class PrefsSlider extends StatelessWidget {
  const PrefsSlider({super.key, required this.value, required this.label, required this.onChanged});
  final double value;
  final String label;
  final ValueChanged<double> onChanged;

  static const _thumb = 28.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final w = box.maxWidth;
      final fill = value.clamp(0.0, 1.0);
      void set(double v) => onChanged(v.clamp(0.0, 1.0).toDouble());
      void setAt(double dx) => set((dx - _thumb / 2) / (w - _thumb));
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
            height: 34,
            child: Stack(
              alignment: Alignment.centerLeft,
              clipBehavior: Clip.none,
              children: [
                GBox(
                  width: w,
                  height: 19,
                  borderColor: const Color(0xFF193348),
                  borderWidth: 2,
                  radius: 20,
                  gradient: LinearGradient(
                    colors: const [Color(0xFF35C836), Color(0xFF35C836), Color(0xFFBFC8CF), Color(0xFFBFC8CF)],
                    stops: [0, fill, fill, 1],
                  ),
                  insets: const [Inset(Color(0x90FFFFFF), dy: 3), Inset(Color(0x3023463F), dy: -2)],
                ),
                Positioned(
                  left: (w - _thumb) * fill,
                  child: Container(
                    width: _thumb,
                    height: _thumb,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0A2238), width: 2.5),
                      gradient: angleGradient(125, const [Colors.white, Color(0xFFEDF5FA), Color(0xFFC9D9E2)], const [0, .65, 1]),
                      boxShadow: const [BoxShadow(color: Color(0x40567084), offset: Offset(0, 2))],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// `.prefs-switch`: metin ve hareketli düğme ayrı alanlarda.
class PrefsSwitch extends StatelessWidget {
  const PrefsSwitch({super.key, required this.value, required this.label, required this.onChanged, required this.width});
  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;
  final double width;

  static const _knob = 29.0;
  static const _textShadow = [Shadow(color: Color(0xFF23502D), offset: Offset(0, 1))];

  @override
  Widget build(BuildContext context) => Semantics(
    toggled: value,
    label: label,
    child: Pressable(
      onTap: () => onChanged(!value),
      child: GBox(
        width: width,
        height: 35,
        gradient: vGradient(value ? const [Color(0xFF42DE41), Color(0xFF1ACB28)] : const [Color(0xFFC6D2D9), Color(0xFF9CABB5)]),
        borderColor: const Color(0xFF112C3C),
        borderWidth: 2,
        radius: 30,
        insets: value ? const [Inset(Color(0xFFCAFF9C), dy: 3), Inset(Color(0x30078E24), dy: -3)] : const [Inset(Color(0xFFDCE7ED), dy: 3)],
        child: Stack(
          children: [
            Positioned.fill(
              left: value ? 5 : 31,
              right: value ? 31 : 5,
              child: Center(
                child: Text(
                  value ? 'AÇIK' : 'KAPALI',
                  maxLines: 1,
                  style: nunito(width < 100 ? 11 : 12, color: Colors.white, height: 1, shadows: _textShadow),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 150),
              left: value ? width - 4 - _knob - 1 : 1,
              top: 1,
              child: Container(
                width: _knob,
                height: _knob,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF163344), width: 2),
                  gradient: angleGradient(130, const [Colors.white, Color(0xFFDCEBF0)]),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// `.prefs-status`: kayıt durumu rozeti.
class PrefsStatus extends StatelessWidget {
  const PrefsStatus({super.key, required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        gradient: active ? vGradient(const [Color(0xFFEEF7D6), Color(0xFFDAEDC4)]) : null,
        color: active ? null : const Color(0xFF8C9DAA),
        border: Border.all(color: const Color(0xFFC9DDB4), width: 2),
        borderRadius: BorderRadius.circular(30),
      ),
      alignment: Alignment.center,
      child: Text(active ? 'AKTİF' : 'KAPALI', style: nunito(14, weight: 1000, color: const Color(0xFF308040), height: 1.1)),
    ),
  );
}
