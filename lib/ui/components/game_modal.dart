import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'gloss.dart';
import 'outlined_text.dart';
import 'pressable.dart';

/// Oyunun ortak pencere dili (Ayarlar tasarım referansı):
/// kalın konturlu krem panel, üst kenara oturan kırmızı başlık şeridi ve köşeden taşan yeşil kapat düğmesi.
class GameModal extends StatelessWidget {
  const GameModal({
    super.key,
    required this.title,
    required this.onClose,
    required this.child,
    this.closeLabel = 'Kapat',
    this.padding = const EdgeInsets.fromLTRB(9, 28, 9, 6),
  });

  final String title;
  final VoidCallback onClose;
  final String closeLabel;
  final Widget child;

  /// Panel içi boşluk (kontur dahil değil).
  final EdgeInsets padding;

  /// Başlık şeridinin panel üst kenarından taşan kısmı.
  static const bannerOverhang = 24.0;
  static const borderWidth = 4.0;
  static const radius = 24.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final width = box.maxWidth;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: bannerOverhang),
            child: GBox(
              borderColor: GameColors.ink,
              borderWidth: borderWidth,
              radius: radius,
              gradient: vGradient(const [Color(0xFFFFF8E9), Color(0xFFFCEFD4)]),
              shadows: const [BoxShadow(color: Color(0x40061D25), offset: Offset(0, 6))],
              insets: const [Inset(Color(0xFFFFFCF3), spread: 2.5)],
              padding: padding,
              child: child,
            ),
          ),
          Positioned(top: 0, left: (width - width * .62) / 2, width: width * .62, child: ModalBanner(title)),
          // 48pt düğme panelin sağ üst köşesinden taşar (referans: üstte ~14pt, sağda ~5pt).
          Positioned(
            top: 8,
            right: -5,
            child: ModalCloseButton(onTap: onClose, semanticLabel: closeLabel),
          ),
        ],
      );
    },
  );
}

/// Kırmızı, parlak başlık şeridi.
class ModalBanner extends StatelessWidget {
  const ModalBanner(this.title, {super.key, this.height = 52});
  final String title;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Stack(
      children: [
        Positioned.fill(
          child: GBox(
            borderColor: GameColors.ink,
            borderWidth: 3,
            radius: 18,
            gradient: vGradient(const [Color(0xFFFF7A68), Color(0xFFFF5546), Color(0xFFE8372D)], const [0, .55, 1]),
            shadows: const [BoxShadow(color: Color(0x55102633), offset: Offset(0, 3))],
            insets: const [Inset(Color(0x55B81E18), dy: -4)],
          ),
        ),
        const Gloss(radius: 12, opacity: .5, heightFactor: .42, inset: EdgeInsets.fromLTRB(9, 5, 9, 0)),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: OutlinedText(
                title,
                maxLines: 1,
                strokeWidth: 3.2,
                shadowOffset: const Offset(0, 2.5),
                style: nunito(33, weight: 1000, color: Colors.white, height: 1.05, letterSpacing: .2),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// Yeşil, kalın konturlu yuvarlak kapat düğmesi (44pt).
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
        width: size * .5 + (outline ? 3.2 : 0),
        height: size * .15 + (outline ? 3.2 : 0),
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: GBox(
                borderColor: GameColors.ink,
                borderWidth: 3,
                radius: size / 2,
                gradient: vGradient(const [Color(0xFF7DF35A), Color(0xFF33D23A), Color(0xFF14AE2C)], const [0, .5, 1]),
                shadows: const [BoxShadow(color: Color(0x55102633), offset: Offset(0, 2.5))],
                insets: const [Inset(Color(0x55077A1E), dy: -3)],
              ),
            ),
            Gloss(radius: size, opacity: .5, heightFactor: .4, inset: EdgeInsets.fromLTRB(size * .2, 4, size * .2, 0)),
            for (final outline in const [true, false]) ...[bar(.785398, outline: outline), bar(-.785398, outline: outline)],
          ],
        ),
      ),
    );
  }
}
