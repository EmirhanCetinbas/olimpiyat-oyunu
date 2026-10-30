import 'package:flutter/material.dart';

import '../game/controller.dart';
import '../game/data.dart';
import '../game/format.dart';
import '../game/race.dart';
import 'theme.dart';
import 'widgets.dart';

/// `<section class="stadium">`: yarış başlığı ve canlı saha.
class Stadium extends StatelessWidget {
  const Stadium({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final branch = c.state.branch;
    final stadiumBackground = branch == 'sprint' || branch == 'archery';
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF174838),
        border: Border.all(color: ink, width: 3),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Color(0x66347A32), offset: Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (stadiumBackground)
              Positioned.fill(child: Image.asset('assets/images/stadium.png', fit: BoxFit.fill)),
            Column(children: [_RaceHead(c), _Field(c)]),
          ],
        ),
      ),
    );
  }
}

class _RaceHead extends StatelessWidget {
  const _RaceHead(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) {
    const darkShadow = [Shadow(color: Color(0xBB000000), offset: Offset(0, 1), blurRadius: 2)];
    final hurdle = c.state.branch == 'hurdles';
    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            flex: 100,
            child: SizedBox(
              height: 29,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Art('bank', width: 25, height: 25),
                  Text(fmt(c.state.money),
                      style: nunito(15, shadows: const [Shadow(color: Colors.white, offset: Offset(0, 1), blurRadius: 2)])),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 115,
            child: Padding(
              padding: const EdgeInsets.all(3.5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.roundText,
                      style: nunito(hurdle ? 18 : 19, color: const Color(0xFF92D7FF), height: 1, shadows: darkShadow)),
                  Text(c.timerText,
                      style: nunito(hurdle ? 11 : 10, color: Colors.white, height: 1, letterSpacing: .3, shadows: darkShadow)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 100,
            child: Btn(
              onTap: () => c.open('team'),
              semanticLabel: 'Takımın',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('TAKIMIN', style: nunito(10, color: const Color(0xFF91D6FF), shadows: darkShadow)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Art('team', width: 22, height: 22),
                      const SizedBox(width: 3),
                      Text('${c.power}', style: nunito(15, color: Colors.white, shadows: darkShadow)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final branch = c.state.branch;
    final screenW = MediaQuery.sizeOf(context).width;
    return AspectRatio(
      aspectRatio: branch == 'sprint' ? 1.72 : 1.5,
      child: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth, h = box.maxHeight;
        Widget at(double xPct, double yPct, Widget child, {Offset anchor = const Offset(.5, .5)}) => Positioned(
              left: w * xPct / 100,
              top: h * yPct / 100,
              child: FractionalTranslation(translation: Offset(-anchor.dx, -anchor.dy), child: child),
            );

        final runnerSize = switch (branch) {
          'hurdles' || 'swim' => 19.0,
          'longjump' => (screenW * .046).clamp(17.0, 23.0),
          'weights' => (screenW * .054).clamp(19.0, 27.0),
          'archery' => 23.0,
          _ => 24.0,
        };
        List<Widget> runners(bool Function(RunnerPos p) include) => [
              for (var i = 0; i < c.runnerIds.length && i < c.runnerPos.length; i++)
                if (include(c.runnerPos[i]))
                  _positionedRunner(c, i, w, h, runnerSize),
            ];

        final blur = c.stadiumIdle && (branch == 'sprint' || branch == 'archery');
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            if (branch != 'sprint') Positioned.fill(child: Image.asset(c.arenaImage, fit: BoxFit.fill)),
            if (branch == 'hurdles')
              for (var lane = 0; lane < 6; lane++)
                for (final x in const [24.0, 44.0, 64.0, 83.0])
                  at(
                    x,
                    35.5 + lane * 9.2,
                    SizedBox(
                      width: 22,
                      height: h * .078,
                      child: Image.asset('assets/images/hurdle-sprite.png', fit: BoxFit.contain),
                    ),
                  ),
            if (branch == 'sprint') ...runners((_) => true),
            if (blur) Positioned.fill(child: blurLayer(1.1, const Color(0x22112233))),
            if (branch == 'archery') ...[
              _archeryHud(c, w, h, at),
              ...runners((_) => true),
            ],
            if (branch == 'hurdles' || branch == 'swim') ...[
              ...runners((p) => !p.jump),
              ...runners((p) => p.jump),
            ],
            if (branch == 'longjump') ...[
              ...runners((p) => !p.airborne),
              for (var i = 0; i < c.jumpCompleted.length; i++) _flag(c, i, w, h),
              ...runners((p) => p.airborne),
            ],
            if (branch == 'weights') ...[
              ...runners((_) => true),
              _weightHud(c, w, h, at),
            ],
            if (!c.raceCallHidden) _raceCall(c, w, h, branch),
            if (!c.liveTagHidden)
              Positioned(
                left: 7,
                top: branch == 'longjump'
                    ? h * .37
                    : branch == 'weights'
                        ? h * .36
                        : 6,
                child: GBox(
                  color: const Color(0xE8FFFEF1),
                  borderColor: const Color(0xFF183324),
                  borderWidth: 1.5,
                  radius: 9,
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  child: Text('● CANLI', style: nunito(9, color: const Color(0xFF198039))),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _positionedRunner(GameController c, int i, double w, double h, double size) {
    final pos = c.runnerPos[i];
    final id = c.runnerIds[i];
    final branch = c.state.branch;
    final player = id == c.state.selected;
    final jumpLook = branch == 'hurdles' && pos.jump;
    final scale = jumpLook ? 1.15 : 1.0;
    final dy = jumpLook ? -.75 : -.5;
    return Positioned(
      left: w * pos.x / 100,
      top: h * pos.y / 100,
      child: FractionalTranslation(
        translation: Offset(-.5, dy),
        child: Transform.scale(scale: scale, child: _Runner(id: id, player: player, size: size, branch: branch, pos: pos, cosmetic: c.state.selectedCosmetic)),
      ),
    );
  }

  Widget _flag(GameController c, int i, double w, double h) {
    final r = c.jumpCompleted[i];
    final p = jumpLanding(r.metres, i);
    final color = Color(jumpColors[i]);
    return Positioned(
      left: w * p.x / 100 - 3,
      top: h * p.y / 100 - 21,
      child: Btn(
        onTap: () => c.showJumpResult(i),
        semanticLabel: '${animals[r.id].name}: ${jumpMetres(r.metres)}',
        child: SizedBox(
          width: 18,
          height: 21,
          child: Stack(clipBehavior: Clip.none, children: [
            Text('⚑', style: TextStyle(fontSize: 24, height: 21 / 24, color: color, shadows: outlineShadows(ink, 1))),
            Positioned(left: 8, top: 3, child: Text('${i + 1}', style: nunito(8, color: ink, height: 1))),
          ]),
        ),
      ),
    );
  }

  Widget _weightHud(GameController c, double w, double h, Widget Function(double, double, Widget, {Offset anchor}) at) {
    final result = c.weightResultText;
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(clipBehavior: Clip.none, children: [
          at(
            50,
            34,
            GBox(
              gradient: vGradient(const [Color(0xFF536074), Color(0xFF253243)]),
              borderColor: ink,
              borderWidth: 2,
              radius: 6,
              insets: const [Inset(Color(0xFFB2BFCA), dy: 1)],
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
              child: Text(c.weightKgText, style: nunito(13, color: Colors.white, height: 1)),
            ),
          ),
          at(
            50,
            c.weightBarTop,
            Transform.rotate(
              angle: c.weightBarTilt * 3.14159265 / 180,
              child: Container(
                decoration: const BoxDecoration(boxShadow: []),
                child: Image.asset('assets/images/weights-barbell.png', width: w * .4),
              ),
            ),
          ),
          if (result.isNotEmpty)
            at(
              50,
              75,
              GBox(
                color: c.weightResultFailed ? const Color(0xEDB52D36) : const Color(0xE8168825),
                radius: 7,
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                child: Text(result,
                    style: nunito(11, color: Colors.white, shadows: const [Shadow(color: ink, offset: Offset(0, 1))])),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _archeryHud(GameController c, double w, double h, Widget Function(double, double, Widget, {Offset anchor}) at) {
    final score = c.archeryScoreText;
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(clipBehavior: Clip.none, children: [
          if (!c.archeryArrowHidden)
            at(
              c.archeryArrowLeft,
              c.archeryArrowTop,
              Text('➶',
                  style: TextStyle(
                    fontSize: 28,
                    height: 1,
                    color: const Color(0xFFFFCF2C),
                    shadows: [
                      ...outlineShadows(const Color(0xFF14293F), 1.5),
                      const Shadow(color: Color(0xFF102539), offset: Offset(0, 1), blurRadius: 3),
                    ],
                  )),
            ),
          if (score.isNotEmpty)
            Positioned(
              top: h * .24,
              left: 0,
              right: 0,
              child: Center(
                child: GBox(
                  color: const Color(0xE8142D42),
                  borderColor: const Color(0xFFFFF9D6),
                  borderWidth: 2,
                  radius: 8,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text(score, style: nunito(13, color: Colors.white)),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _raceCall(GameController c, double w, double h, String branch) {
    final compact = branch == 'hurdles' || branch == 'swim' || branch == 'longjump' || branch == 'weights';
    final button = Btn(
      onTap: c.beginRace,
      semanticLabel: c.startText,
      child: GBox(
        gradient: greenGradient,
        borderColor: const Color(0xFF168D25),
        borderWidth: outlineWidth,
        radius: 9,
        shadows: compact
            ? buttonShadows
            : const [BoxShadow(color: Color(0xFF095E26), offset: Offset(0, 3))],
        insets: compact ? buttonInsets : const [Inset(Color(0x77FFFFFF), dy: 2)],
        padding: compact ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4) : const EdgeInsets.symmetric(horizontal: 17, vertical: 7),
        child: Text(c.startText, style: nunito(compact ? 13 : 17, color: Colors.white, shadows: whiteTextShadow)),
      ),
    );
    if (compact) {
      final row = Row(mainAxisAlignment: MainAxisAlignment.center, children: [button]);
      return switch (branch) {
        'longjump' => Positioned(top: h * .36, left: w * .15, right: w * .15, child: ConstrainedBox(constraints: const BoxConstraints(minHeight: 30), child: row)),
        'weights' => Positioned(top: h * .42, left: w * .15, right: w * .15, child: ConstrainedBox(constraints: const BoxConstraints(minHeight: 30), child: row)),
        _ => Positioned(bottom: 0, left: w * .04, right: w * .04, child: SizedBox(height: 35, child: row)),
      };
    }
    final label = GBox(
      color: const Color(0xEEFFFDEE),
      borderColor: ink,
      borderWidth: 1.5,
      radius: 9,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      child: Text(c.raceCallText, style: nunito(11)),
    );
    if (branch == 'archery') {
      return Positioned.fill(
        child: ColoredBox(
          color: const Color(0x18071D27),
          child: Padding(
            padding: EdgeInsets.only(top: w * .37),
            child: Column(children: [label, const SizedBox(height: 8), button]),
          ),
        ),
      );
    }
    return Positioned.fill(
      child: Stack(children: [
        Positioned.fill(child: blurLayer(.25, const Color(0x24071D27))),
        Center(child: Column(mainAxisSize: MainAxisSize.min, children: [label, const SizedBox(height: 8), button])),
      ]),
    );
  }
}

/// Yuvarlak yüz avatarı (`.runner`).
class _Runner extends StatelessWidget {
  const _Runner({required this.id, required this.player, required this.size, required this.branch, required this.pos, required this.cosmetic});
  final int id;
  final bool player;
  final double size;
  final String branch;
  final RunnerPos pos;
  final int cosmetic;

  static const _cosmetics = [
    [Color(0xFFFFCF19), Color(0xFFFFCD23)],
    [Color(0xFF24A9FF), Color(0xFF48D8FF)],
    [Color(0xFFDE70FD), Color(0xFFEEB3FF)],
    [Color(0xFFFF7B87), Color(0xFFFFABB4)],
  ];

  @override
  Widget build(BuildContext context) {
    final round = branch == 'longjump' || branch == 'weights';
    Color border;
    double borderWidth;
    Color background;
    List<BoxShadow> shadows;
    if (round) {
      border = player ? const Color(0xFFFFC226) : const Color(0xFF0763AB);
      borderWidth = 2;
      background = const Color(0xFFEFFAFF);
      shadows = player
          ? const [BoxShadow(color: Colors.white, spreadRadius: 1), BoxShadow(color: Color(0xFFFFDD45), blurRadius: 5)]
          : const [BoxShadow(color: Colors.white, spreadRadius: 1), BoxShadow(color: Color(0x5510283B), offset: Offset(0, 2), blurRadius: 2)];
      if (pos.airborne) {
        shadows = const [BoxShadow(color: Color(0xFF9DE9FF), spreadRadius: 2), BoxShadow(color: Color(0x6610283B), offset: Offset(0, 4), blurRadius: 6)];
      }
    } else {
      border = player ? const Color(0xFFFFB900) : const Color(0xFF172637);
      borderWidth = 1.5;
      background = const Color(0xFFF4F9EC);
      shadows = player
          ? const [BoxShadow(color: Colors.white, spreadRadius: 1.5), BoxShadow(color: Color(0xFFFFE94E), blurRadius: 8)]
          : const [BoxShadow(color: Color(0x44000000), offset: Offset(0, 1))];
    }
    if (player && cosmetic >= 0 && cosmetic < _cosmetics.length) {
      shadows = [
        BoxShadow(color: _cosmetics[cosmetic][0], spreadRadius: 3),
        BoxShadow(color: _cosmetics[cosmetic][1], blurRadius: 8),
      ];
    }
    final hurdleJump = branch == 'hurdles' && pos.jump;
    if (hurdleJump) shadows = [...shadows, const BoxShadow(color: Colors.white, blurRadius: 5)];
    final face = Art(animals[id].art, width: size - borderWidth * 2 - 2, height: size - borderWidth * 2 - 2, radius: BorderRadius.circular(size));
    final showMarker = player && !round;
    final small = branch == 'hurdles' || branch == 'swim';
    return SizedBox(
      width: size,
      height: size,
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: background,
            border: Border.all(color: border, width: borderWidth),
            boxShadow: shadows,
          ),
          child: Center(child: face),
        ),
        if (showMarker)
          Positioned(
            left: small ? 4 : 6,
            top: small ? -12 : -14,
            child: Text('▼',
                style: TextStyle(
                  fontSize: small ? 9 : 11,
                  height: 1,
                  color: const Color(0xFFFFE44A),
                  shadows: const [Shadow(color: Color(0xFF15273C), offset: Offset(0, 1))],
                )),
          ),
      ]),
    );
  }
}
