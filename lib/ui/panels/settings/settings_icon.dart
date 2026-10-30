import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../components/components.dart';

/// settings.js `settingsIcon`: aynı SVG yolları, `drop-shadow(0 2px #c6b792)` ile.
class SettingsIcon extends StatelessWidget {
  const SettingsIcon(this.name, {super.key, this.size = 34});
  final String name;
  final double size;

  static const _paths = {
    'music': '<path fill="url(#prefs-gold)" d="M23 34V12l25-5v23l-8 2V17l-9 2v19c0 12-19 15-19 4 0-6 6-9 11-8Z"/>',
    'sound':
        '<path fill="url(#prefs-blue)" d="M9 25h10L34 12v40L19 39H9Z"/><path d="M42 23q10 9 0 18m7-26q17 17 0 34" fill="none" stroke="#ffc72a"/>',
    'vibration':
        '<rect x="20" y="8" width="26" height="48" rx="5" fill="url(#prefs-blue)"/><path d="M27 14h12M30 49h6M11 19l-5 7 5 7-5 7m48-21 5 7-5 7 5 7" fill="none"/>',
    'pause': '<circle cx="32" cy="32" r="26" fill="#1aabf1"/><path d="M23 20h6v24h-6zm12 0h6v24h-6z" fill="white"/>',
    'save':
        '<path d="M15 49C-1 45 3 26 17 25 17 8 40 7 45 23c20-1 22 26 5 26Z" fill="#a9e7ff"/><path d="m23 34 7 7 15-16" fill="none" stroke="#1acb24" stroke-width="7"/>',
    'support': '<rect x="7" y="13" width="50" height="39" rx="6" fill="#eaf6ff"/><path d="m9 17 23 18 23-18" fill="#ff6256"/>',
    'reset': '<path d="M48 17A23 23 0 1 0 52 44l-10-5A12 12 0 1 1 40 25l-9 2 25 7V9Z" fill="#63df24"/>',
  };

  String get _svg =>
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none" stroke="#0c2034" stroke-width="3" '
      'stroke-linecap="round" stroke-linejoin="round"><defs>'
      '<linearGradient id="prefs-gold" x1="0" y1="0" x2=".3" y2="1"><stop offset="0" stop-color="#fff381"/><stop offset=".5" stop-color="#ffcf27"/><stop offset="1" stop-color="#f2a509"/></linearGradient>'
      '<linearGradient id="prefs-blue" x1="0" y1="0" x2=".8" y2="1"><stop offset="0" stop-color="#bdeaff"/><stop offset=".55" stop-color="#70b6df"/><stop offset="1" stop-color="#3981b2"/></linearGradient>'
      '</defs>${_paths[name]}</svg>';

  @override
  Widget build(BuildContext context) {
    if (name == 'shoe') return Art('shoe', width: size, height: size);
    final svg = _svg;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            top: 2,
            left: 0,
            child: SvgPicture.string(
              svg,
              width: size,
              height: size,
              colorFilter: const ColorFilter.mode(Color(0xFFC6B792), BlendMode.srcIn),
            ),
          ),
          SvgPicture.string(svg, width: size, height: size),
        ],
      ),
    );
  }
}
