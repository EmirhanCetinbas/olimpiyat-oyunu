import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'pressable.dart';

/// Düğme görünümü: degrade, kontur, köşe, gölgeler.
class ButtonSkin {
  const ButtonSkin({
    required this.colors,
    required this.borderColor,
    this.borderWidth = 2,
    this.radius = 8,
    this.shadows = const [],
    this.insets = const [],
    this.textColor = Colors.white,
    this.textShadows,
  });

  final List<Color> colors;
  final Color borderColor;
  final double borderWidth;
  final double radius;
  final List<BoxShadow> shadows;
  final List<Inset> insets;
  final Color textColor;
  final List<Shadow>? textShadows;

  ButtonSkin copyWith({double? borderWidth, double? radius, List<BoxShadow>? shadows, List<Inset>? insets}) => ButtonSkin(
    colors: colors,
    borderColor: borderColor,
    borderWidth: borderWidth ?? this.borderWidth,
    radius: radius ?? this.radius,
    shadows: shadows ?? this.shadows,
    insets: insets ?? this.insets,
    textColor: textColor,
    textShadows: textShadows,
  );

  /// `.green`: ana eylem (yükselt, yarışa başla, hamle).
  static const primary = ButtonSkin(
    colors: [Color(0xFF51EF2F), Color(0xFF08B50D)],
    borderColor: GameColors.greenBorder,
    borderWidth: outlineWidth,
    radius: 9,
    shadows: buttonShadows,
    insets: buttonInsets,
    textShadows: whiteTextShadow,
  );

  /// `.blue`: 2x gelir.
  static const blue = ButtonSkin(
    colors: [Color(0xFF3597FF), Color(0xFF1460EB)],
    borderColor: GameColors.ink,
    borderWidth: outlineWidth,
    radius: 9,
    shadows: buttonShadows,
    insets: buttonInsets,
    textShadows: whiteTextShadow,
  );
}

/// Degradeli, konturlu oyun düğmesi. `label` ya da `child` verilir.
class GameButton extends StatelessWidget {
  const GameButton({
    super.key,
    this.label,
    this.child,
    required this.onTap,
    this.skin = ButtonSkin.primary,
    this.enabled = true,
    this.fontSize = 14,
    this.textHeight,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    this.width,
    this.height,
    this.constraints,
    this.alignment,
    this.semanticLabel,
    this.disabledSaturation = .35,
    this.disabledOpacity = .7,
  }) : assert(label != null || child != null);

  final String? label;
  final Widget? child;
  final VoidCallback? onTap;
  final ButtonSkin skin;
  final bool enabled;
  final double fontSize;
  final double? textHeight;
  final EdgeInsets padding;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final String? semanticLabel;
  final double disabledSaturation;
  final double disabledOpacity;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    enabled: enabled,
    semanticLabel: semanticLabel,
    disabledSaturation: disabledSaturation,
    disabledOpacity: disabledOpacity,
    child: GBox(
      gradient: vGradient(skin.colors),
      borderColor: skin.borderColor,
      borderWidth: skin.borderWidth,
      radius: skin.radius,
      shadows: skin.shadows,
      insets: skin.insets,
      padding: padding,
      width: width,
      height: height,
      constraints: constraints,
      alignment: alignment,
      child:
          child ??
          Text(
            label!,
            textAlign: TextAlign.center,
            style: gameText(fontSize, color: skin.textColor, height: textHeight, shadows: skin.textShadows),
          ),
    ),
  );
}
