import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

/// `.cream`: krem degradeli, mürekkep konturlu kutu.
class CreamBox extends StatelessWidget {
  const CreamBox({super.key, required this.child, this.radius = 14, this.width, this.height, this.padding = EdgeInsets.zero});
  final Widget child;
  final double radius;
  final double? width;
  final double? height;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => GBox(
    gradient: creamGradient,
    borderColor: GameColors.ink,
    borderWidth: outlineWidth,
    radius: radius,
    shadows: creamShadows,
    insets: creamInsets,
    width: width,
    height: height,
    padding: padding,
    child: child,
  );
}
