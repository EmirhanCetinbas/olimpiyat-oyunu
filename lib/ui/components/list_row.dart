import 'package:flutter/widgets.dart';

import '../theme/theme.dart';
import 'raised_surface.dart';

/// Pencere içi satır kartı (Ayarlar satırlarıyla aynı düz kart): soldan sağa çocuklar, aralarında boşluk.
class ListRow extends StatelessWidget {
  const ListRow({super.key, required this.children, this.locked = false});
  final List<Widget> children;

  /// Kilitli satır soluk görünür (henüz açılmamış sporcu).
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Container(
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: flatCardDecoration(),
        child: Row(
          children: [
            for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(width: 10), children[i]],
          ],
        ),
      ),
    );
    return locked ? Opacity(opacity: .6, child: row) : row;
  }
}

/// Satır başlığı ve isteğe bağlı açıklama; kalan genişliği kaplar.
class RowTitle extends StatelessWidget {
  const RowTitle(this.title, {super.key, this.small});
  final String title;
  final String? small;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: gameText(16.5, color: GameColors.ink, height: 1.15)),
        if (small != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(small!, style: gameText(12.5, color: GameColors.slate, height: 1.25)),
          ),
      ],
    ),
  );
}

/// İkonlu kart: ikon, başlık, açıklama ve sağda eylemler.
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
  Widget build(BuildContext context) => ListRow(
    locked: locked,
    children: [
      leading,
      RowTitle(title, small: small),
      ...actions,
    ],
  );
}
