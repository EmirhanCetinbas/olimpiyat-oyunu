import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'outlined_text.dart';
import 'paw_mark.dart';
import 'pressable.dart';
import 'raised_surface.dart';

/// Oyunun ortak pencere dili: kalın konturlu kâğıt panel, üst kenara oturan kırmızı başlık plakası
/// (iki yanda sarı pati izleri) ve köşeden taşan yeşil kapat düğmesi.
class GameModal extends StatelessWidget {
  const GameModal({
    super.key,
    required this.title,
    required this.onClose,
    required this.child,
    this.closeLabel = 'Kapat',
    this.padding = const EdgeInsets.fromLTRB(12, 34, 12, 10),
  });

  final String title;
  final VoidCallback onClose;
  final String closeLabel;
  final Widget child;

  /// Panel içi boşluk (kontur dahil değil).
  final EdgeInsets padding;

  /// Başlık plakasının panel üst kenarından taşan kısmı.
  static const bannerOverhang = 26.0;
  static const borderWidth = 3.5;
  static const radius = 26.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final width = box.maxWidth;
      // Plaka yazıyı sarar; uzun başlıkta yazı küçülür.
      final textWidth = (TextPainter(
        text: TextSpan(text: title, style: ModalBanner.textStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout()).width;
      // Sağdaki pati, köşedeki kapat düğmesine değmeden sığmalı: plaka en çok width − 2 × (pati + düğme payı).
      final maxBanner = width - 2 * (PawMark.defaultSize + 40);
      final bannerWidth = (textWidth + 2 * ModalBanner.horizontalPadding + 8).clamp(width * .52, maxBanner);
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(top: bannerOverhang),
            padding: padding,
            decoration: BoxDecoration(
              color: GameColors.paper,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: GameColors.ink, width: borderWidth),
              boxShadow: const [BoxShadow(color: GameColors.panelShadow, offset: Offset(0, 5), blurRadius: 8)],
            ),
            child: child,
          ),
          Positioned(top: 0, left: (width - bannerWidth) / 2, width: bannerWidth, child: ModalBanner(title)),
          // Pati izleri plakanın iki yanının ortasında.
          Positioned(top: 12, right: (width + bannerWidth) / 2 - 2, child: const PawMark(mirrored: true)),
          Positioned(top: 12, left: (width + bannerWidth) / 2 - 2, child: const PawMark()),
          // 48pt düğme panelin sağ üst köşesinden taşar.
          Positioned(
            top: 8,
            right: -6,
            child: ModalCloseButton(onTap: onClose, semanticLabel: closeLabel),
          ),
        ],
      );
    },
  );
}

/// Kırmızı, kabarık başlık plakası.
class ModalBanner extends StatelessWidget {
  const ModalBanner(this.title, {super.key, this.height = 56});
  final String title;
  final double height;

  static final textStyle = gameText(TextSizes.title, color: Colors.white, height: 1, letterSpacing: 1);
  static const horizontalPadding = 14.0;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: RaisedSurface(
      color: GameColors.coral,
      shade: GameColors.coralShade,
      radius: 20,
      lip: 5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 4),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: OutlinedText(title, maxLines: 1, shadowOffset: const Offset(0, 2.5), style: textStyle),
          ),
        ),
      ),
    ),
  );
}

/// Yeşil, kabarık yuvarlak kapat düğmesi (48pt).
class ModalCloseButton extends StatelessWidget {
  const ModalCloseButton({super.key, required this.onTap, this.size = 48, this.semanticLabel = 'Kapat'});
  final VoidCallback onTap;
  final double size;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    // Çarpı: önce iki koyu çubuk (kontur), sonra üstlerine iki beyaz çubuk; kesişimde kontur görünmez.
    Widget bar(double angle, {required bool outline}) => Transform.rotate(
      angle: angle,
      child: Container(
        width: size * .46 + (outline ? 4 : 0),
        height: size * .15 + (outline ? 4 : 0),
        decoration: BoxDecoration(color: outline ? GameColors.ink : Colors.white, borderRadius: BorderRadius.circular(size * .1)),
      ),
    );
    return Pressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      minTapSize: minTapTarget,
      child: SizedBox(
        width: size,
        height: size,
        child: RaisedSurface.green(
          radius: size / 2,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (final outline in const [true, false]) ...[bar(.785398, outline: outline), bar(-.785398, outline: outline)],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
