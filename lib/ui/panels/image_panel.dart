import 'package:flutter/widgets.dart';

import '../components/components.dart';
import '../theme/theme.dart';

/// Sağlanan panel görseli + gömülü kontrolleri örten yamalar + kapat alanı.
/// Canlı kontroller `overlays` ile görselin kendi oranına göre yerleşir.
class ImagePanel extends StatelessWidget {
  const ImagePanel({
    super.key,
    required this.image,
    required this.aspectRatio,
    required this.masks,
    required this.onClose,
    required this.overlays,
  });

  final String image;
  final double aspectRatio;

  /// `[left, top, width, height]` yüzde.
  final List<List<double>> masks;
  final VoidCallback onClose;
  final List<Widget> Function(BuildContext context, PercentLayout layout) overlays;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: aspectRatio,
    child: LayoutBuilder(
      builder: (context, box) {
        final layout = PercentLayout(box.maxWidth, box.maxHeight);
        return Stack(
          children: [
            Positioned.fill(child: Image.asset(image, fit: BoxFit.fill)),
            for (final m in masks) layout.area(m, const ColoredBox(color: GameColors.mask)),
            Positioned(
              right: layout.x(4),
              top: layout.y(2.7),
              width: layout.x(12),
              height: layout.y(9),
              child: HotSpot(onTap: onClose, label: 'Kapat'),
            ),
            ...overlays(context, layout),
          ],
        );
      },
    ),
  );
}
