import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Kırmızı, konturlu yazılı başlık şeridi (AYARLAR, KAMPÜS).
class BannerTitle extends StatelessWidget {
  const BannerTitle(
    this.text, {
    super.key,
    required this.fontSize,
    this.gradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFF8D7D), Color(0xFFFF554B)],
    ),
    this.borderColor = const Color(0xFF102437),
    this.radius = 20,
    this.padding = const EdgeInsets.symmetric(horizontal: 3, vertical: 11),
    this.shadows = const [BoxShadow(color: Color(0x40172C39), offset: Offset(0, 3))],
    this.insets = const [Inset(Color(0xFFFFBBAC), dy: 4), Inset(Color(0xFFE43C36), dy: -4)],
    this.textShadows,
    this.weight = 1000,
    this.height = 1,
    this.semanticsLabel,
  });

  final String text;
  final double fontSize;
  final Gradient gradient;
  final Color borderColor;
  final double radius;
  final EdgeInsets padding;
  final List<BoxShadow> shadows;
  final List<Inset> insets;
  final List<Shadow>? textShadows;
  final int weight;
  final double height;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) => GBox(
    gradient: gradient,
    borderColor: borderColor,
    borderWidth: 3,
    radius: radius,
    shadows: shadows,
    insets: insets,
    padding: padding,
    alignment: Alignment.center,
    child: Text(
      text,
      semanticsLabel: semanticsLabel,
      style: nunito(
        fontSize,
        weight: weight,
        color: Colors.white,
        height: height,
        shadows: textShadows ?? outlineShadows(const Color(0xFF142532), 2),
      ),
    ),
  );
}
