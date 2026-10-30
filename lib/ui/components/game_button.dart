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

  /// `.row button` / `.modal-action`: pencere içi eylemler.
  static const action = ButtonSkin(colors: [Color(0xFF52DE35), Color(0xFF18B72B)], borderColor: GameColors.actionBorder);

  /// `.inventory-card>button`: envanter kartı eylemleri.
  static const leaf = ButtonSkin(colors: [Color(0xFF5FE347), Color(0xFF17B72D)], borderColor: Color(0xFF17752D));

  /// `.equipment-card button`.
  static const equipment = ButtonSkin(colors: [Color(0xFF66E843), Color(0xFF12B82B)], borderColor: Color(0xFF117427), borderWidth: 1.5);

  /// Etkin sekme (`.inventory-tabs button.active`).
  static const tabActive = ButtonSkin(
    colors: [Color(0xFF75EB44), Color(0xFF16BC2A)],
    borderColor: Color(0xFF15852B),
    radius: 10,
    insets: [Inset(Color(0x7AFFFFFF), dy: 2)],
  );

  /// Pasif sekme.
  static const tabIdle = ButtonSkin(
    colors: [Color(0xFFF8FBF6), Color(0xFFE5EDF1)],
    borderColor: Color(0xFF17344C),
    radius: 10,
    textColor: GameColors.ink,
  );

  /// Kampüs yükseltme düğmesi (↑).
  static const campus = ButtonSkin(
    colors: [Color(0xFF73F239), Color(0xFF0FC523)],
    borderColor: Color(0xFF123429),
    radius: 12,
    insets: [Inset(Color(0xFFD0FFAA), dy: 3), Inset(Color(0xFF049628), dy: -3)],
    textShadows: [Shadow(color: Color(0xFF0F3928), offset: Offset(1, 2))],
  );
}

/// Degradeli, konturlu oyun düğmesi. `label` ya da `child` verilir.
class GameButton extends StatelessWidget {
  const GameButton({
    super.key,
    this.label,
    this.child,
    required this.onTap,
    this.skin = ButtonSkin.action,
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

/// `.modal-action` (gerekirse `.full`: tam genişlik, üstte 11px boşluk).
class ActionButton extends StatelessWidget {
  const ActionButton(
    this.label, {
    super.key,
    required this.onTap,
    this.enabled = true,
    this.full = false,
    this.fontSize = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    this.skin = ButtonSkin.action,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final bool full;
  final double fontSize;
  final EdgeInsets padding;
  final ButtonSkin skin;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final button = GameButton(
      label: label,
      onTap: onTap,
      enabled: enabled,
      skin: skin,
      fontSize: fontSize,
      padding: padding,
      semanticLabel: semanticLabel,
      width: full ? double.infinity : null,
      alignment: full ? Alignment.center : null,
    );
    return full ? Padding(padding: const EdgeInsets.only(top: 11), child: button) : button;
  }
}
