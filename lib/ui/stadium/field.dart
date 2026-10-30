import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/race.dart';
import '../components/components.dart';
import '../theme/theme.dart';
import 'field_huds.dart';
import 'race_call.dart';
import 'runner_avatar.dart';

/// `.field`: arena görseli üzerinde canlı sporcular, engeller ve göstergeler.
/// Katman sırası style.css z-index değerlerini izler.
class RaceField extends StatelessWidget {
  const RaceField({super.key});

  static const _hurdleX = [24.0, 44.0, 64.0, 83.0];

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final branch = c.state.branch;
    final screenW = MediaQuery.sizeOf(context).width;
    final runnerSize = switch (branch) {
      'hurdles' || 'swim' => 19.0,
      'longjump' => (screenW * .046).clamp(17.0, 23.0),
      'weights' => (screenW * .054).clamp(19.0, 27.0),
      'archery' => 23.0,
      _ => 24.0,
    };
    return AspectRatio(
      aspectRatio: branch == 'sprint' ? 1.72 : 1.5,
      child: LayoutBuilder(
        builder: (context, box) {
          final layout = PercentLayout(box.maxWidth, box.maxHeight);
          List<Widget> runners(bool Function(RunnerPos p) include) => [
            for (var i = 0; i < c.runnerIds.length && i < c.runnerPos.length; i++)
              if (include(c.runnerPos[i])) _runner(c, layout, i, runnerSize),
          ];
          final blur = c.stadiumIdle && (branch == 'sprint' || branch == 'archery');
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              if (branch != 'sprint') Positioned.fill(child: Image.asset(c.arenaImage, fit: BoxFit.fill)),
              if (branch == 'hurdles')
                for (var lane = 0; lane < 6; lane++)
                  for (final x in _hurdleX)
                    layout.point(
                      x,
                      35.5 + lane * 9.2,
                      SizedBox(
                        width: 22,
                        height: layout.y(7.8),
                        child: Image.asset('assets/images/hurdle-sprite.png', fit: BoxFit.contain),
                      ),
                    ),
              if (branch == 'sprint') ...runners((_) => true),
              if (blur) Positioned.fill(child: blurLayer(1.1, const Color(0x22112233))),
              if (branch == 'archery') ...[ArcheryHud(c: c, layout: layout), ...runners((_) => true)],
              if (branch == 'hurdles' || branch == 'swim') ...[...runners((p) => !p.jump), ...runners((p) => p.jump)],
              if (branch == 'longjump') ...[
                ...runners((p) => !p.airborne),
                for (var i = 0; i < c.jumpCompleted.length; i++) JumpFlag(c: c, index: i, layout: layout),
                ...runners((p) => p.airborne),
              ],
              if (branch == 'weights') ...[...runners((_) => true), WeightHud(c: c, layout: layout)],
              if (!c.raceCallHidden) RaceCall(c: c, layout: layout),
              if (!c.liveTagHidden)
                Positioned(
                  left: 7,
                  top: switch (branch) {
                    'longjump' => layout.y(37),
                    'weights' => layout.y(36),
                    _ => 6,
                  },
                  child: Pill(
                    '● CANLI',
                    style: nunito(9, color: const Color(0xFF198039)),
                    color: const Color(0xE8FFFEF1),
                    borderColor: const Color(0xFF183324),
                    borderWidth: 1.5,
                    radius: 9,
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _runner(GameController c, PercentLayout layout, int i, double size) {
    final pos = c.runnerPos[i];
    final id = c.runnerIds[i];
    final branch = c.state.branch;
    final jumpLook = branch == 'hurdles' && pos.jump;
    return layout.point(
      pos.x,
      pos.y,
      Transform.scale(
        scale: jumpLook ? 1.15 : 1.0,
        child: RunnerAvatar(
          animalId: id,
          player: id == c.state.selected,
          size: size,
          branch: branch,
          airborne: pos.airborne,
          jumping: jumpLook,
          cosmetic: c.state.selectedCosmetic,
        ),
      ),
      anchor: Offset(.5, jumpLook ? .75 : .5),
    );
  }
}
