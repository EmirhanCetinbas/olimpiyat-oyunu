import 'package:flutter/widgets.dart';

/// Avatar çerçevesi görselleri (`cosmeticNames` sırasıyla; `tool/import_art.py`).
const avatarFrameArt = ['gold', 'lightning', 'star', 'paw'];

/// Yuvarlak avatarın çevresine kozmetik çerçeveyi oturtur. Görselde delik çapı kenarın %54'ü
/// (`FRAME_HOLE`); delik avatarın kenarını hafifçe örter. Çerçeve avatarın dışına taşar, yer kaplamaz.
class AvatarFrame extends StatelessWidget {
  const AvatarFrame({super.key, required this.cosmetic, required this.size, required this.child});

  /// `cosmeticNames` sırası; geçersizse çerçevesiz.
  final int cosmetic;

  /// Avatarın çapı.
  final double size;
  final Widget child;

  static const _hole = .54, _cover = .9;

  @override
  Widget build(BuildContext context) {
    if (cosmetic < 0 || cosmetic >= avatarFrameArt.length) return child;
    final side = size * _cover / _hole;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          child,
          IgnorePointer(
            child: OverflowBox(
              maxWidth: side,
              maxHeight: side,
              child: Image.asset(
                'assets/images/art/frames/${avatarFrameArt[cosmetic]}.png',
                width: side,
                height: side,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
