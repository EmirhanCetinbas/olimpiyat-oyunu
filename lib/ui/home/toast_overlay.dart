import 'package:flutter/material.dart';

import '../components/components.dart';
import '../theme/theme.dart';

/// `.toast`: alttan kayarak gelen bildirim.
class ToastOverlay extends StatelessWidget {
  const ToastOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final width = MediaQuery.sizeOf(context).width;
    const duration = Duration(milliseconds: 200);
    return Positioned(
      left: 0,
      right: 0,
      // Alt menünün üstünde kalır (web'de sabit 80px, ev çubuğuyla menüyle çakışıyordu).
      bottom: ScreenMetrics.of(context).bottomNavHeight + 14,
      child: IgnorePointer(
        child: Center(
          child: AnimatedOpacity(
            opacity: c.toastVisible ? 1 : 0,
            duration: duration,
            child: AnimatedSlide(
              offset: c.toastVisible ? Offset.zero : const Offset(0, .3),
              duration: duration,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width * .9),
                child: Pill(
                  c.toastText,
                  style: gameText(14, color: GameColors.ink, height: 1.2),
                  textAlign: TextAlign.center,
                  color: GameColors.paper,
                  borderColor: GameColors.ink,
                  borderWidth: 2.5,
                  radius: 16,
                  shadows: const [BoxShadow(color: Color(0x44062327), offset: Offset(0, 4), blurRadius: 10)],
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
