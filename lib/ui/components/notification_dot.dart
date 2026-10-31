import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Alınabilecek bir şey var: koyu konturlu küçük kırmızı nokta (menü ve düğme köşeleri).
class NotificationDot extends StatelessWidget {
  const NotificationDot({super.key, this.size = 13});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: GameColors.danger,
      shape: BoxShape.circle,
      border: Border.all(color: GameColors.ink, width: 2),
    ),
  );
}
