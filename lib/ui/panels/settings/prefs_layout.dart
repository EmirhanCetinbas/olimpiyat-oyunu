import 'package:flutter/material.dart';

import '../../components/components.dart';
import '../../theme/theme.dart';
import 'settings_icon.dart';

const _rowShadow = [BoxShadow(color: Color(0xFFE3D0A6), offset: Offset(0, 2.5))];
const _rowGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFFFFCF2), Color(0xFFFDF3DE)],
);

TextStyle _label(double size) => nunito(size, weight: 1000, color: GameColors.panelInk, height: 1.1, letterSpacing: -.2);

/// `.prefs-section`: SES / OYUN / KAYIT başlığı ve satırları.
class PrefsSection extends StatelessWidget {
  const PrefsSection({super.key, required this.title, required this.rows});
  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: ScreenMetrics.of(context).short ? 4 : 7),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 4),
          child: Text(title, style: nunito(19, weight: 1000, color: GameColors.panelInk, height: 1.1, letterSpacing: -.2)),
        ),
        ...rows,
      ],
    ),
  );
}

/// `.prefs-row`: ikon, etiket ve kontrol. `wide` satırlarda kontrol kalan alanı kullanır (kaydırıcılar).
class PrefsRow extends StatelessWidget {
  const PrefsRow({super.key, required this.icon, required this.label, required this.control, this.wide = false});
  final String icon;
  final String label;
  final Widget control;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final m = ScreenMetrics.of(context);
    final text = Text(label, maxLines: 1, softWrap: false, style: _label(m.compact ? 14 : 15));
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: GBox(
        gradient: _rowGradient,
        borderColor: GameColors.ink,
        borderWidth: 2.5,
        radius: 15,
        shadows: _rowShadow,
        constraints: BoxConstraints(minHeight: m.short ? 46 : 50),
        padding: EdgeInsets.only(left: m.compact ? 8 : 11, right: m.compact ? 7 : 9),
        child: Row(
          children: [
            SettingsIcon(icon, size: m.compact ? 30 : 34),
            SizedBox(width: m.compact ? 10 : 14),
            if (wide)
              SizedBox(width: m.compact ? 62 : 70, child: text)
            else
              Expanded(
                child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: text),
              ),
            const SizedBox(width: 8),
            if (wide) Expanded(child: control) else control,
          ],
        ),
      ),
    );
  }
}

/// `.prefs-actions button`: Destek / İlerlemeyi sıfırla kutucukları.
class PrefsActionTile extends StatelessWidget {
  const PrefsActionTile({super.key, required this.icon, required this.label, required this.onTap});
  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final m = ScreenMetrics.of(context);
    return Pressable(
      onTap: onTap,
      semanticLabel: label.replaceAll('\n', ' '),
      child: GBox(
        gradient: _rowGradient,
        borderColor: GameColors.ink,
        borderWidth: 2.5,
        radius: 15,
        shadows: _rowShadow,
        constraints: BoxConstraints(minHeight: m.short ? 44 : 50),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          children: [
            SettingsIcon(icon, size: m.compact ? 32 : 38),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: _label(label.contains('\n') ? (m.compact ? 12.5 : 13.5) : (m.compact ? 14 : 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
