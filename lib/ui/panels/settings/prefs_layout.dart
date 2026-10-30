import 'package:flutter/material.dart';

import '../../components/components.dart';
import '../../theme/theme.dart';
import 'settings_icon.dart';

bool _narrow(BuildContext context) => MediaQuery.sizeOf(context).width <= 360;

/// `.prefs-section`: başlık ve satırlar.
class PrefsSection extends StatelessWidget {
  const PrefsSection({super.key, required this.title, required this.rows});
  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 7, bottom: 5),
          child: Text(
            title,
            style: nunito(17, weight: 1000, color: GameColors.panelInk, height: 20 / 17, letterSpacing: -.3),
          ),
        ),
        ...rows,
      ],
    ),
  );
}

/// `.prefs-row`: ikon, etiket ve kontrol. `wide` satırlarda kontrol kalan alanı kullanır
/// (ses satırları: `grid-template-columns: 35px 76px 1fr`).
class PrefsRow extends StatelessWidget {
  const PrefsRow({super.key, required this.icon, required this.label, required this.control, this.wide = false});
  final String icon;
  final String label;
  final Widget control;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final narrow = _narrow(context);
    final text = Text(label, style: nunito(narrow ? 12 : 13, weight: 850, color: GameColors.panelInk, height: 1.1, letterSpacing: -.3));
    final gap = SizedBox(width: narrow ? 5 : 8);
    final aligned = Align(alignment: Alignment.centerRight, child: control);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GBox(
        gradient: angleGradient(110, const [Color(0xFFFFFCF1), Color(0xFFFFF9E9)]),
        borderColor: const Color(0xFF142A3B),
        borderWidth: 2,
        radius: 15,
        shadows: const [BoxShadow(color: Color(0x75D8CAA5), offset: Offset(0, 3))],
        insets: const [Inset(Colors.white, dy: 2)],
        padding: EdgeInsets.symmetric(horizontal: narrow ? 6 : 9, vertical: 6),
        constraints: const BoxConstraints(minHeight: 54),
        child: Row(
          children: [
            SizedBox(
              width: narrow ? 30 : 35,
              child: Center(child: SettingsIcon(icon, size: narrow ? 30 : 34)),
            ),
            gap,
            if (wide) SizedBox(width: narrow ? 66 : 76, child: text) else Expanded(child: text),
            gap,
            if (wide) Expanded(child: aligned) else SizedBox(width: narrow ? 96 : 108, child: aligned),
          ],
        ),
      ),
    );
  }
}

/// `.prefs-actions button`: Destek / Sıfırla kutucukları.
class PrefsActionTile extends StatelessWidget {
  const PrefsActionTile({super.key, required this.icon, required this.label, required this.onTap});
  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    child: GBox(
      constraints: const BoxConstraints(minHeight: 50),
      gradient: vGradient(const [Color(0xFFFFFDF3), Color(0xFFFFF7E5)]),
      borderColor: const Color(0xFF102B40),
      borderWidth: 2,
      radius: 15,
      shadows: const [BoxShadow(color: Color(0x75D8CAA5), offset: Offset(0, 3))],
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SettingsIcon(icon, size: 31),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label, style: nunito(_narrow(context) ? 11 : 12, color: GameColors.panelInk, height: 1.1)),
          ),
        ],
      ),
    ),
  );
}
