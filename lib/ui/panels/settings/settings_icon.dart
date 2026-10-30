import 'package:flutter/widgets.dart';

/// Ayarlar ikonu: tasarım referansından çıkarılmış ayrı görseller (tool/extract_settings_icons.py).
class SettingsIcon extends StatelessWidget {
  const SettingsIcon(this.name, {super.key, this.size = 34});

  /// music, sound, vibration, shoe, pause, save, support, reset
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Image.asset('assets/images/settings/$name.png', fit: BoxFit.contain, filterQuality: FilterQuality.medium),
  );
}
