import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

/// Pencere paragrafı (`#modal-content p`); `muted` ise `.muted`.
class PanelText extends StatelessWidget {
  const PanelText(this.text, {super.key, this.align, this.size = TextSizes.body, this.color = GameColors.ink, this.bottom = 11});

  const PanelText.muted(this.text, {super.key, this.align}) : size = 12, color = GameColors.muted, bottom = 11;

  final String text;
  final TextAlign? align;
  final double size;
  final Color color;
  final double bottom;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: bottom),
    child: Text(
      text,
      textAlign: align,
      style: gameText(size, color: color, height: 1.4),
    ),
  );
}
