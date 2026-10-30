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
      bottom: 80,
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
                  style: nunito(12, color: const Color(0xFF173627)),
                  textAlign: TextAlign.center,
                  color: const Color(0xFFFFFEE9),
                  borderColor: const Color(0xFF193B36),
                  borderWidth: 2,
                  radius: 11,
                  shadows: const [BoxShadow(color: Color(0x33000000), offset: Offset(0, 3), blurRadius: 9)],
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
