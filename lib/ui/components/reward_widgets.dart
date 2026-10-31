import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'raised_surface.dart';
import 'sprite.dart';

/// Ödül / pencere ikonu: `assets/images/rewards/<name>.png` (tool/extract_panel_icons.py).
class RewardIcon extends StatelessWidget {
  const RewardIcon(this.name, {super.key, required this.size, this.radius});
  final String name;
  final double size;

  /// Resimli kare ikonlar (başarım kartları) için köşe yuvarlatma.
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/rewards/$name.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
    if (radius == null) return image;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius!),
        border: Border.all(color: GameColors.ink, width: 2),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(radius! - 2), child: image),
    );
  }
}

/// Ödül miktarı: ikon + değer, açık yeşil hap içinde (₺10K, 10 elmas…).
class RewardPill extends StatelessWidget {
  const RewardPill({super.key, required this.icon, required this.label});
  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(6, 3, 9, 3),
    decoration: BoxDecoration(
      color: const Color(0xFFE3F6DC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFB9DFAE), width: 2),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RewardIcon(icon, size: 24),
        const SizedBox(width: 4),
        Text(label, style: gameText(15, color: GameColors.ink, height: 1.1)),
      ],
    ),
  );
}

/// Alındı işareti: koyu konturlu yeşil disk içinde beyaz tik.
class ClaimedCheck extends StatelessWidget {
  const ClaimedCheck({super.key, this.size = 36});
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Alındı',
    child: SizedBox(
      width: size,
      height: size,
      child: RaisedSurface.green(
        radius: size / 2,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: size * .66,
            shadows: const [Shadow(color: GameColors.ink, blurRadius: 1)],
          ),
        ),
      ),
    ),
  );
}

/// Kilitli durum: gri kilit ikonu.
class LockedMark extends StatelessWidget {
  const LockedMark({super.key, this.size = 30});
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Kilitli',
    child: RewardIcon('lock', size: size),
  );
}

/// Pencere altındaki bilgi şeridi: saat ikonu ve kısa metin.
class NoteStrip extends StatelessWidget {
  const NoteStrip(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 4),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: const Color(0xFFE6ECEF), borderRadius: BorderRadius.circular(16)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const RewardIcon('clock', size: 24),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: gameText(14.5, color: GameColors.ink, height: 1.2),
          ),
        ),
      ],
    ),
  );
}

/// Ödül türünün görseli (çanta ödülleri, envanter eşyaları): gerçek oyun ikonları, emoji yok.
class RewardKindIcon extends StatelessWidget {
  const RewardKindIcon(this.kind, {super.key, this.size = 40});

  /// money, gems, parts, card, boost, cosmetic, bundle, chest, ticket
  final String kind;
  final double size;

  @override
  Widget build(BuildContext context) => switch (kind) {
    'money' => RewardIcon('money', size: size),
    'boost' => RewardIcon('boost', size: size),
    'gems' => RewardIcon('gem', size: size),
    'ticket' => RewardIcon('ticket', size: size),
    'bundle' || 'chest' => RewardIcon('gift', size: size),
    'parts' => Art('gear', width: size, height: size),
    'card' => Art('cards', width: size, height: size),
    'cosmetic' => Art('avatar', width: size, height: size, radius: BorderRadius.circular(size * .2)),
    _ => RewardIcon('gift', size: size),
  };
}

/// Seçili durum etiketi (düğme yerine; dokunulacak bir şey yok).
class SelectedTag extends StatelessWidget {
  const SelectedTag({super.key, this.label = 'Seçili'});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
    decoration: BoxDecoration(
      color: const Color(0xFFDDF5CF),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: GameColors.greenShade, width: 2),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_rounded, size: 16, color: GameColors.greenShade),
        const SizedBox(width: 2),
        Text(label, style: gameText(13.5, color: GameColors.greenShade, height: 1.1)),
      ],
    ),
  );
}
