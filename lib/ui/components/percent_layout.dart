import 'package:flutter/widgets.dart';

/// Bir görselin kendi en-boy oranına göre yüzde koordinatlı yerleşim
/// (CSS `left:x%; top:y%; transform:translate(-50%,-50%)`).
class PercentLayout {
  const PercentLayout(this.width, this.height);
  final double width;
  final double height;

  double x(double pct) => width * pct / 100;
  double y(double pct) => height * pct / 100;

  /// Bir noktaya, `anchor` oranında kaydırarak yerleştirir (varsayılan: ortala).
  Widget point(double xPct, double yPct, Widget child, {Offset anchor = const Offset(.5, .5)}) => Positioned(
    left: x(xPct),
    top: y(yPct),
    child: FractionalTranslation(translation: Offset(-anchor.dx, -anchor.dy), child: child),
  );

  /// Yüzde dikdörtgen.
  Widget rect(double left, double top, double w, double h, Widget child) =>
      Positioned(left: x(left), top: y(top), width: x(w), height: y(h), child: child);

  /// Yüzde dikdörtgen; `[left, top, width, height]` listesiyle.
  Widget area(List<double> r, Widget child) => rect(r[0], r[1], r[2], r[3], child);
}

/// Görünmez, erişilebilir dokunma alanı.
class HotSpot extends StatelessWidget {
  const HotSpot({super.key, required this.onTap, required this.label});
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap),
  );
}
