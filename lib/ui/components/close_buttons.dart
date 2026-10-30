import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'pressable.dart';

enum CloseGlyph { times, bars }

/// Yuvarlak kapat düğmesi (ödül penceresi, kampüs, ayarlar).
class RoundCloseButton extends StatelessWidget {
  const RoundCloseButton({
    super.key,
    required this.onTap,
    this.size = 38,
    this.colors = const [Color(0xFFFF7C7B), Color(0xFFED314D)],
    this.angle,
    this.stops,
    this.borderColor = GameColors.ink,
    this.borderWidth = 2,
    this.shadows = const [],
    this.insets = const [],
    this.glyph = CloseGlyph.times,
    this.fontSize = 26,
    this.glyphHeight = 1,
    this.semanticLabel = 'Kapat',
  });

  /// Kampüs penceresi: kırmızı, iç parlamalı.
  const RoundCloseButton.campus({super.key, required this.onTap, this.semanticLabel = 'Kapat'})
    : size = 35,
      colors = const [Color(0xFFFF8784), Color(0xFFF42D47)],
      angle = null,
      stops = null,
      borderColor = const Color(0xFF0D2440),
      borderWidth = 3,
      shadows = const [],
      insets = const [Inset(Color(0xFFFFBBB1), dy: 2)],
      glyph = CloseGlyph.times,
      fontSize = 31,
      glyphHeight = .8;

  /// Ayarlar: yeşil, çapraz çubuklu.
  const RoundCloseButton.settings({super.key, required this.onTap, this.semanticLabel = 'Kapat'})
    : size = 42,
      colors = const [Color(0xFF86FB69), Color(0xFF16C535)],
      angle = 135,
      stops = const [0, .65],
      borderColor = GameColors.panelInk,
      borderWidth = 3,
      shadows = const [],
      insets = const [Inset(Color(0xFFB6FF99), dy: 3), Inset(Color(0xFF009D24), dy: -3)],
      glyph = CloseGlyph.bars,
      fontSize = 0,
      glyphHeight = 1;

  final VoidCallback onTap;
  final double size;
  final List<Color> colors;
  final double? angle;
  final List<double>? stops;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow> shadows;
  final List<Inset> insets;
  final CloseGlyph glyph;
  final double fontSize;
  final double glyphHeight;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final mark = glyph == CloseGlyph.times
        ? Text(
            '×',
            style: nunito(fontSize, color: Colors.white, height: glyphHeight),
          )
        : Stack(
            alignment: Alignment.center,
            children: [
              for (final a in const [.785398, -.785398])
                Transform.rotate(
                  angle: a,
                  child: Container(
                    width: 25,
                    height: 7,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: const [BoxShadow(color: Color(0xFF203744), offset: Offset(0, 1))],
                    ),
                  ),
                ),
            ],
          );
    return Pressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      minTapSize: minTapTarget,
      child: GBox(
        width: size,
        height: size,
        gradient: angle == null ? vGradient(colors, stops) : angleGradient(angle!, colors, stops),
        borderColor: borderColor,
        borderWidth: borderWidth,
        radius: size / 2,
        shadows: shadows,
        insets: insets,
        alignment: Alignment.center,
        child: mark,
      ),
    );
  }
}

/// Standart pencere başlığındaki kare kapat düğmesi.
class SquareCloseButton extends StatelessWidget {
  const SquareCloseButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    semanticLabel: 'Kapat',
    minTapSize: minTapTarget,
    child: GBox(
      width: 28,
      height: 28,
      color: const Color(0xFFFFFCEB),
      borderColor: GameColors.ink,
      borderWidth: 2,
      radius: 8,
      alignment: Alignment.center,
      child: Text('×', style: nunito(22, color: GameColors.ink, height: 1)),
    ),
  );
}
