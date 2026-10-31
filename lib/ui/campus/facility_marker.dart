import 'package:flutter/material.dart';

import '../components/components.dart';
import '../theme/theme.dart';

/// `.campus-marker`: tesis adı ve seviye etiketi.
class FacilityMarker extends StatelessWidget {
  const FacilityMarker({
    super.key,
    required this.label,
    required this.level,
    required this.maxWidth,
    required this.semanticLabel,
    required this.onTap,
    this.upgradable = false,
  });

  /// SP yetiyor: etiketin köşesinde yeşil yukarı ok rozeti.
  final bool upgradable;

  final String label;
  final String level;
  final double maxWidth;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = vwClamp(context, 10, 2.8, 17);
    return Pressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 70, maxWidth: maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Pill(
              label,
              style: gameText(size, color: GameColors.ink),
              maxLines: 1,
              color: GameColors.row,
              borderColor: GameColors.ink,
              borderWidth: 2.5,
              radius: 12,
              shadows: const [BoxShadow(color: GameColors.cardShadow, offset: Offset(0, 2.5), blurRadius: 3)],
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            ),
            _Pulse(
              on: upgradable,
              child: Transform.translate(
                offset: const Offset(0, -1),
                child: Pill(
                  upgradable ? '$level ↑' : level,
                  style: gameText(size * .9, color: Colors.white),
                  maxLines: 1,
                  color: upgradable ? GameColors.greenShade : GameColors.navy,
                  borderColor: GameColors.ink,
                  borderWidth: 2.5,
                  radius: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Geliştirilebilir tesisin seviye rozeti hafifçe büyüyüp küçülür (azaltılmış harekette durur).
class _Pulse extends StatefulWidget {
  const _Pulse({required this.on, required this.child});
  final bool on;
  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  void _sync() {
    final run = widget.on && !MediaQuery.disableAnimationsOf(context);
    if (run && !_anim.isAnimating) {
      _anim.repeat(reverse: true);
    } else if (!run && _anim.isAnimating) {
      _anim
        ..stop()
        ..value = 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_Pulse old) {
    super.didUpdateWidget(old);
    _sync();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: Tween(begin: 1.0, end: 1.12).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut)),
    child: widget.child,
  );
}
