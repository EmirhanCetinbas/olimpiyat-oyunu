import 'package:flutter/widgets.dart';

import '../theme/theme.dart';
import 'game_scope.dart';

/// Tüm dokunulabilir öğelerin temeli: basılınca 1px iner, devre dışıyken solar,
/// dokunuşta titreşim geri bildirimi verir.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.onTap,
    required this.child,
    this.enabled = true,
    this.semanticLabel,
    this.disabledSaturation = .35,
    this.disabledOpacity = .7,
  });

  final VoidCallback? onTap;
  final Widget child;
  final bool enabled;
  final String? semanticLabel;
  final double disabledSaturation;
  final double disabledOpacity;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _setDown(bool value) => setState(() => _down = value);

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled && widget.onTap != null;
    Widget child = widget.child;
    if (!enabled) {
      child = saturated(child, saturation: widget.disabledSaturation, opacity: widget.disabledOpacity);
    } else if (_down) {
      child = Transform.translate(offset: const Offset(0, 1), child: child);
    }
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setDown(true) : null,
        onTapCancel: enabled ? () => _setDown(false) : null,
        onTapUp: enabled ? (_) => _setDown(false) : null,
        onTap: enabled
            ? () {
                GameScope.of(context, listen: false).buttonFeedback();
                widget.onTap!();
              }
            : null,
        child: child,
      ),
    );
  }
}
