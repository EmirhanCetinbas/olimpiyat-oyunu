import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// `.race-call`: başlat düğmesi ve (koşu/okçulukta) bilgi etiketi; branşa göre yerleşir.
class RaceCall extends StatelessWidget {
  const RaceCall({super.key, required this.c, required this.layout});
  final GameController c;
  final PercentLayout layout;

  @override
  Widget build(BuildContext context) {
    final branch = c.state.branch;
    final compact = const {'hurdles', 'swim', 'longjump', 'weights'}.contains(branch);
    final button = GameButton(
      onTap: c.beginRace,
      semanticLabel: c.startText,
      label: c.startText,
      skin: compact
          ? ButtonSkin.primary
          : ButtonSkin.primary.copyWith(
              shadows: const [BoxShadow(color: Color(0xFF095E26), offset: Offset(0, 3))],
              insets: const [Inset(Color(0x77FFFFFF), dy: 2)],
            ),
      fontSize: compact ? 13 : 17,
      padding: compact ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4) : const EdgeInsets.symmetric(horizontal: 17, vertical: 7),
    );
    if (compact) {
      final row = Row(mainAxisAlignment: MainAxisAlignment.center, children: [button]);
      Widget band(double top) => Positioned(
        top: layout.y(top),
        left: layout.x(15),
        right: layout.x(15),
        child: ConstrainedBox(constraints: const BoxConstraints(minHeight: 30), child: row),
      );
      return switch (branch) {
        'longjump' => band(36),
        'weights' => band(42),
        _ => Positioned(
          bottom: 0,
          left: layout.x(4),
          right: layout.x(4),
          child: SizedBox(height: 35, child: row),
        ),
      };
    }
    final label = Pill(
      c.raceCallText,
      style: nunito(11),
      color: const Color(0xEEFFFDEE),
      borderColor: GameColors.ink,
      borderWidth: 1.5,
      radius: 9,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    );
    final content = Column(mainAxisSize: MainAxisSize.min, children: [label, const SizedBox(height: 8), button]);
    if (branch == 'archery') {
      return Positioned.fill(
        child: ColoredBox(
          color: const Color(0x18071D27),
          // CSS yüzde padding'i genişliğe göredir.
          child: Padding(
            padding: EdgeInsets.only(top: layout.x(37)),
            child: Align(alignment: Alignment.topCenter, child: content),
          ),
        ),
      );
    }
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(child: blurLayer(.25, const Color(0x24071D27))),
          Center(child: content),
        ],
      ),
    );
  }
}
