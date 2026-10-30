import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'outlined_text.dart';
import 'pressable.dart';
import 'raised_surface.dart';

/// Pencere düğmesinin rengi: yeşil ana eylem ya da krem ikincil eylem. Kapalıyken gri.
enum ButtonTone { green, cream }

/// Ortak pencere dilinin düğmesi: kabarık yüzey, beyaz konturlu yazı (krem düğmede koyu yazı).
/// Dokunma alanı her zaman en az 44pt.
class RaisedButton extends StatelessWidget {
  const RaisedButton(
    this.label, {
    super.key,
    required this.onTap,
    this.enabled = true,
    this.tone = ButtonTone.green,
    this.height = 40,
    this.fontSize = 16,
    this.minWidth = 56,
    this.width,
    this.semanticLabel,
    this.content,
  });

  final String label;

  /// Yazı yerine özel içerik (ör. "Yükselt" + fiyat); [label] erişilebilirlik adı olarak kalır.
  final Widget? content;
  final VoidCallback? onTap;
  final bool enabled;
  final ButtonTone tone;
  final double height;
  final double fontSize;
  final double minWidth;

  /// Verilirse sabit genişlik (`double.infinity` = tam genişlik).
  final double? width;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final active = enabled && onTap != null;
    final cream = active && tone == ButtonTone.cream;
    final text = cream
        ? Text(
            label,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: gameText(fontSize, color: GameColors.ink, height: 1),
          )
        : OutlinedText(
            label,
            maxLines: 1,
            shadowOffset: const Offset(0, 1.5),
            style: gameText(fontSize, color: Colors.white, height: 1),
          );
    final inner =
        content ??
        Padding(
          // Dudak bandı altta; yazı yüzeyin optik ortasında kalsın.
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 3),
          child: Center(
            widthFactor: 1,
            child: FittedBox(fit: BoxFit.scaleDown, child: text),
          ),
        );
    final radius = height * .42;
    final Widget surface = !active
        ? RaisedSurface.locked(radius: radius, child: inner)
        : cream
        ? RaisedSurface.cream(radius: radius, child: inner)
        : RaisedSurface.green(radius: radius, child: inner);
    return Pressable(
      onTap: onTap,
      enabled: active,
      semanticLabel: semanticLabel ?? label,
      minTapSize: minTapTarget,
      // Kapalı düğme gri yüzeyle anlatılır; ek soldurma yok.
      disabledSaturation: 1,
      disabledOpacity: 1,
      child: SizedBox(
        width: width,
        height: height,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minWidth),
          child: surface,
        ),
      ),
    );
  }
}

/// Pencere içi eylem: satır sonundaki küçük düğme ya da `full` ile tam genişlik ana düğme.
class ActionButton extends StatelessWidget {
  const ActionButton(
    this.label, {
    super.key,
    required this.onTap,
    this.enabled = true,
    this.full = false,
    this.tone = ButtonTone.green,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final bool full;
  final ButtonTone tone;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final button = RaisedButton(
      label,
      onTap: onTap,
      enabled: enabled,
      tone: tone,
      semanticLabel: semanticLabel,
      height: full ? 48 : 40,
      fontSize: full ? 19 : 16,
      width: full ? double.infinity : null,
    );
    return full ? Padding(padding: const EdgeInsets.only(top: 12), child: button) : button;
  }
}
