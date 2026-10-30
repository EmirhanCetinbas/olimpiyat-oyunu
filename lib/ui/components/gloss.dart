import 'package:flutter/widgets.dart';

/// Karikatür "cam" parlaması: kutunun üst kısmında yumuşak beyaz bant.
/// Bir `Stack` içinde, parlatılan yüzeyin üstüne konur.
class Gloss extends StatelessWidget {
  const Gloss({
    super.key,
    this.radius = 12,
    this.opacity = .55,
    this.heightFactor = .45,
    this.inset = const EdgeInsets.fromLTRB(5, 2.5, 5, 0),
  });

  final double radius;
  final double opacity;
  final double heightFactor;
  final EdgeInsets inset;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: IgnorePointer(
      child: Padding(
        padding: inset,
        child: Align(
          alignment: Alignment.topCenter,
          child: FractionallySizedBox(
            heightFactor: heightFactor,
            widthFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color.fromRGBO(255, 255, 255, opacity), Color.fromRGBO(255, 255, 255, opacity * .15)],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
