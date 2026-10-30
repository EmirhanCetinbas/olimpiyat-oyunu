import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/format.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// Üst HUD: tek satır. Profil/seviye, para (büyük; altında gelir/sn ve 2x), elmas ve ayarlar.
/// Para oyunun asıl birimi olduğu için ortada ve en büyük öğedir.
class Hud extends StatelessWidget {
  const Hud({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final compact = ScreenMetrics.of(context).compact;
    final gap = SizedBox(width: compact ? 5 : 7);
    return SizedBox(
      height: 58,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileChip(c),
          gap,
          Expanded(child: _MoneyCard(c, compact: compact)),
          gap,
          _GemsChip(c),
          gap,
          _IconButton(onTap: () => c.open('settings'), label: 'Ayarlar', child: const Art('gear', width: 28, height: 28)),
        ],
      ),
    );
  }
}

/// Düz kart zemini.
class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.symmetric(horizontal: 7)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) =>
      Container(padding: padding, decoration: flatCardDecoration(radius: 16, borderWidth: 2.5), child: child);
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: () => c.open('profile'),
    semanticLabel: 'Profil, seviye ${c.level}',
    child: _Card(
      padding: const EdgeInsets.fromLTRB(5, 5, 7, 5),
      child: Row(
        children: [
          Art('avatar', width: 34, height: 38, radius: BorderRadius.circular(8)),
          const SizedBox(width: 5),
          SizedBox(
            width: 38,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sv.${c.level}', maxLines: 1, style: gameText(14, color: GameColors.ink, height: 1.1)),
                const SizedBox(height: 4),
                GameProgressBar.xp(value: (c.state.xp % 100) / 100),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _MoneyCard extends StatelessWidget {
  const _MoneyCard(this.c, {required this.compact});
  final GameController c;
  final bool compact;

  @override
  Widget build(BuildContext context) => _Card(
    padding: const EdgeInsets.fromLTRB(7, 4, 5, 4),
    child: Row(
      children: [
        Art('bank', width: compact ? 24 : 28, height: compact ? 24 : 28),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                // Para sıçramaları (ödül, harcama) sayarak geçer.
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: c.state.money),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) =>
                      Text(fmt(v), maxLines: 1, style: gameText(compact ? 20 : 22, color: GameColors.ink, height: 1.05)),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '+₺${fmt(c.income())}/sn',
                  maxLines: 1,
                  style: gameText(12.5, color: c.boostActive ? GameColors.blue : GameColors.greenShade, height: 1.1),
                ),
              ),
            ],
          ),
        ),
        _BoostButton(c),
      ],
    ),
  );
}

/// 2x gelir: hazırken mavi "2x", etkinken ve beklemede kalan saniye.
class _BoostButton extends StatelessWidget {
  const _BoostButton(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final ready = !c.boostDisabled;
    final label = c.boostActive
        ? '${((c.state.boostUntil - c.now) / 1000).ceil()}s'
        : ready
        ? '2x'
        : '${((c.state.boostReady - c.now) / 1000).ceil()}s';
    final text = Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Center(
        child: OutlinedText(
          label,
          shadowOffset: const Offset(0, 1.5),
          style: gameText(15, color: Colors.white, height: 1),
        ),
      ),
    );
    return Pressable(
      onTap: c.activateBoost,
      enabled: ready,
      disabledSaturation: 1,
      disabledOpacity: 1,
      minTapSize: minTapTarget,
      semanticLabel: c.boostText,
      child: SizedBox(
        width: 42,
        height: 38,
        child: ready || c.boostActive
            ? RaisedSurface(color: GameColors.blue, shade: GameColors.blueShade, radius: 13, child: text)
            : RaisedSurface.locked(radius: 13, child: text),
      ),
    );
  }
}

class _GemsChip extends StatelessWidget {
  const _GemsChip(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: () => c.open('shop'),
    semanticLabel: '${c.state.gems} elmas, mağaza',
    child: _Card(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
      child: Row(
        children: [
          const Art('gem', width: 24, height: 24),
          const SizedBox(width: 4),
          Text(fmt(c.state.gems), style: gameText(17, color: GameColors.ink, height: 1)),
        ],
      ),
    ),
  );
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.onTap, required this.label, required this.child});
  final VoidCallback onTap;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    semanticLabel: label,
    child: SizedBox(
      width: 46,
      child: RaisedSurface.cream(
        radius: 16,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Center(child: child),
        ),
      ),
    ),
  );
}
