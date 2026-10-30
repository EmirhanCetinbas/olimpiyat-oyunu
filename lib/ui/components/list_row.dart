import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

/// `.row`: iki uca yaslanmış, alt çizgili satır.
class ListRow extends StatelessWidget {
  const ListRow({super.key, required this.children, this.last = false, this.locked = false});
  final List<Widget> children;
  final bool last;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final row = Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: Color(0xFFDCE1C7))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(width: 8), children[i]],
        ],
      ),
    );
    return locked ? Opacity(opacity: .6, child: row) : row;
  }
}

/// Satır başlığı ve isteğe bağlı açıklama (`.row small`).
class RowTitle extends StatelessWidget {
  const RowTitle(this.title, {super.key, this.small});
  final String title;
  final String? small;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: gameText(14, color: GameColors.ink)),
        if (small != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(small!, style: gameText(11.7, color: const Color(0xFF68826C))),
          ),
      ],
    ),
  );
}

/// `.inventory-card`: ikon, başlık, açıklama ve eylemler.
class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.leading,
    required this.title,
    required this.small,
    this.actions = const [],
    this.locked = false,
  });
  final Widget leading;
  final String title;
  final String small;
  final List<Widget> actions;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFD5E0D6))),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: gameText(14, color: GameColors.ink)),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(small, style: gameText(12, color: GameColors.slate, height: 1.3)),
                ),
              ],
            ),
          ),
          for (final a in actions) ...[const SizedBox(width: 10), a],
        ],
      ),
    );
    return locked ? Opacity(opacity: .6, child: card) : card;
  }
}
