import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

/// Karartılmış (isteğe bağlı bulanık) zemin + üstte pencere.
/// Zemine dokunmak `onDismiss` çağırır; pencereye dokunmak geçmez.
class DialogLayer extends StatelessWidget {
  const DialogLayer({
    super.key,
    required this.onDismiss,
    required this.child,
    this.barrierColor = const Color(0xA8081D34),
    this.blur = 0,
    this.alignment = Alignment.center,
    this.padding = EdgeInsets.zero,
  });

  final VoidCallback onDismiss;
  final Widget child;
  final Color barrierColor;
  final double blur;
  final Alignment alignment;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            child: blur > 0 ? blurLayer(blur, barrierColor) : ColoredBox(color: barrierColor),
          ),
        ),
        Padding(
          padding: padding,
          child: Align(
            alignment: alignment,
            child: GestureDetector(onTap: () {}, child: child),
          ),
        ),
      ],
    ),
  );
}
