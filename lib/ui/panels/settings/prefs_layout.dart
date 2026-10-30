import 'package:flutter/material.dart';

import '../../components/components.dart';
import '../../theme/theme.dart';
import 'settings_icon.dart';

TextStyle _label(double size) => display(size, color: GameColors.ink, height: 1.05, letterSpacing: .3);

/// SES / OYUN / KAYIT başlığı ve satırları.
class PrefsSection extends StatelessWidget {
  const PrefsSection({super.key, required this.title, required this.rows});
  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final short = ScreenMetrics.of(context).short;
    return Padding(
      padding: EdgeInsets.only(bottom: short ? 4 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8, bottom: short ? 4 : 6),
            child: Text(title, style: display(short ? 21 : 23, color: GameColors.ink, height: 1, letterSpacing: .6)),
          ),
          ...rows,
        ],
      ),
    );
  }
}

/// Ayar satırı: düz kart, ikon, etiket ve sağda kontrol.
class PrefsRow extends StatelessWidget {
  const PrefsRow({super.key, required this.icon, required this.label, required this.control});
  final String icon;
  final String label;
  final Widget control;

  @override
  Widget build(BuildContext context) {
    final m = ScreenMetrics.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: m.short ? 6 : 9),
      child: Container(
        constraints: BoxConstraints(minHeight: m.short ? 50 : 56),
        padding: EdgeInsets.symmetric(horizontal: m.compact ? 9 : 11),
        decoration: flatCardDecoration(),
        child: Row(
          children: [
            SettingsIcon(icon, size: m.compact ? 32 : 38),
            SizedBox(width: m.compact ? 8 : 11),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(label, maxLines: 1, style: _label(m.compact ? 16 : 18)),
              ),
            ),
            const SizedBox(width: 8),
            control,
          ],
        ),
      ),
    );
  }
}

/// Alt eylem kutucuğu (Destek / İlerlemeyi sıfırla): düz kart, ikon ve etiket.
class PrefsActionTile extends StatelessWidget {
  const PrefsActionTile({super.key, required this.icon, required this.label, required this.onTap});
  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final m = ScreenMetrics.of(context);
    final twoLines = label.contains('\n');
    return Pressable(
      onTap: onTap,
      semanticLabel: label.replaceAll('\n', ' '),
      child: Container(
        constraints: BoxConstraints(minHeight: m.short ? 50 : 56),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: flatCardDecoration(),
        child: Row(
          children: [
            SettingsIcon(icon, size: m.compact ? 32 : 36),
            const SizedBox(width: 6),
            Expanded(
              child: Text(label, textAlign: TextAlign.center, style: _label(twoLines ? (m.compact ? 13.5 : 15) : (m.compact ? 16 : 18))),
            ),
          ],
        ),
      ),
    );
  }
}
