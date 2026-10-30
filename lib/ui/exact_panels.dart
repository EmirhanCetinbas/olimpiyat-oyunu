import 'package:flutter/material.dart';

import '../game/controller.dart';
import 'theme.dart';
import 'widgets.dart';

const _maskColor = Color(0xFFFFF9E9);

/// Görsele gömülü kontrolleri örten yamalar ([left, top, width, height] %).
Widget _masks(List<List<double>> rects, double w, double h) => Stack(children: [
      for (final r in rects)
        Positioned(left: w * r[0] / 100, top: h * r[1] / 100, width: w * r[2] / 100, height: h * r[3] / 100, child: const ColoredBox(color: _maskColor)),
    ]);

Widget _closeHotspot(GameController c, double w, double h) => Positioned(
      right: w * .04,
      top: h * .027,
      width: w * .12,
      height: h * .09,
      child: Semantics(
        button: true,
        label: 'Kapat',
        child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: c.closeModal),
      ),
    );

/// Başarımlar: sağlanan görsel, üzerinde tek canlı kontrol katmanı.
class AchievementsPanel extends StatelessWidget {
  const AchievementsPanel(this.c, {super.key});
  final GameController c;

  static const _tops = [30.7, 47.0, 63.2, 79.4];

  @override
  Widget build(BuildContext context) {
    final s = c.state;
    final values = [s.races, s.wins, s.levels[4], s.levels[5]];
    const goals = [1, 3, 5, 3];
    return AspectRatio(
      aspectRatio: 729 / 861,
      child: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth, h = box.maxHeight;
        Positioned rect(double l, double t, double rw, double rh, Widget child) =>
            Positioned(left: w * l / 100, top: h * t / 100, width: w * rw / 100, height: h * rh / 100, child: child);
        return Stack(children: [
          Positioned.fill(child: Image.asset('assets/images/achievements-panel-exact.png', fit: BoxFit.fill)),
          Positioned.fill(
            child: _masks(const [
              [7, 16, 87, 5.5],
              [86, 26, 10.5, 10],
              [86, 42, 10.5, 10],
              [86, 58.2, 10.5, 10],
              [86, 74.4, 10.5, 10],
              [22.5, 33, 40.5, 4.2],
              [22.5, 49.3, 40.5, 4.2],
              [22.5, 65.5, 40.5, 4.2],
              [22.5, 81.7, 40.5, 4.2],
            ], w, h),
          ),
          _closeHotspot(c, w, h),
          rect(8, 16.6, 72, 4, _Progress(value: s.claims.length / achievements.length, label: 'Alınan başarımlar')),
          rect(
            82,
            17,
            13,
            5,
            Center(
              child: Text('${s.claims.length} / ${achievements.length}',
                  style: nunito(vwClamp(context, 12, 3, 18), weight: 1000, color: const Color(0xFF07192E), height: 1)),
            ),
          ),
          for (var i = 0; i < achievements.length; i++) ...[
            rect(
              23.2,
              _tops[i] + 2,
              39,
              4,
              LayoutBuilder(builder: (context, row) {
                final done = values[i] < goals[i] ? values[i] : goals[i];
                return Row(children: [
                  SizedBox(
                    width: row.maxWidth * .8,
                    height: row.maxHeight * .72,
                    child: _Progress(value: done / goals[i], label: achievements[i].title),
                  ),
                  SizedBox(width: row.maxWidth * .04),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('$done / ${goals[i]}', style: nunito(vwClamp(context, 10, 2.5, 15), color: ink)),
                    ),
                  ),
                ]);
              }),
            ),
            Positioned(
              left: w * .86,
              top: h * _tops[i] / 100 - h * .04,
              width: w * .10,
              height: h * .08,
              child: _AchievementAction(c, i),
            ),
          ],
        ]);
      }),
    );
  }
}

class _AchievementAction extends StatelessWidget {
  const _AchievementAction(this.c, this.i);
  final GameController c;
  final int i;

  @override
  Widget build(BuildContext context) {
    final a = achievements[i];
    final taken = c.state.claims.contains(a.id), ready = a.done(c.state) && !taken;
    final label = taken ? 'Alındı' : ready ? 'Ödülü al' : 'Kilitli';
    if (!taken && !ready) {
      return Btn(
        onTap: null,
        enabled: false,
        semanticLabel: '${a.title}: $label',
        child: Center(child: Text('🔒', style: TextStyle(fontSize: vwClamp(context, 17, 4, 24), color: const Color(0xFF123450)))),
      );
    }
    final circle = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: taken
            ? vGradient(const [Color(0xFF45E654), Color(0xFF00AD24)])
            : vGradient(const [Color(0xFF70EF49), Color(0xFF08BC27)]),
        border: Border.all(color: taken ? const Color(0xFF126332) : const Color(0xFF0C5820), width: 2),
      ),
      alignment: Alignment.center,
      child: Text(taken ? '✓' : 'AL',
          style: nunito(vwClamp(context, 10, 2.4, 15), color: Colors.white, height: 1, shadows: const [Shadow(color: Color(0xFF143C1D), offset: Offset(0, 1))])),
    );
    return Btn(
      onTap: ready ? () => c.claimAchievement(a.id) : null,
      enabled: ready,
      semanticLabel: '${a.title}: $label',
      child: circle,
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.value, required this.label});
  final double value;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
        label: label,
        value: '${(value * 100).round()}%',
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFDCE2EB),
            border: Border.all(color: const Color(0xFF9CAAC0)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value.clamp(0, 1),
                heightFactor: 1,
                child: GBox(
                  gradient: vGradient(const [Color(0xFF69FC6D), Color(0xFF06C622)]),
                  radius: 20,
                  insets: const [Inset(Color(0xFFC8FFB8), dy: 2)],
                ),
              ),
            ),
          ),
        ),
      );
}

/// Günlük ödül: yedi günlük takvim görseli ve canlı gün düğmeleri.
class DailyPanel extends StatelessWidget {
  const DailyPanel(this.c, {super.key});
  final GameController c;

  static const _spots = [
    [4.5, 45.4, 21, 7],
    [29.5, 45.4, 20, 7],
    [52.4, 45.4, 20, 7],
    [76.0, 45.4, 20, 7],
    [5.0, 77.5, 20, 7],
    [30.0, 77.5, 20, 7],
    [58.0, 77.0, 36, 7],
  ];

  @override
  Widget build(BuildContext context) {
    final step = c.state.dailyStep % 7;
    final claimed = c.dayClaimed;
    return AspectRatio(
      aspectRatio: 864 / 910,
      child: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth, h = box.maxHeight;
        final fontSize = vwClamp(context, 13, 4, 25);
        return Stack(children: [
          Positioned.fill(child: Image.asset('assets/images/daily-panel-exact.png', fit: BoxFit.fill)),
          Positioned.fill(
            child: _masks(const [
              [4.5, 45.3, 21.5, 7.2],
              [34.5, 44.8, 9, 7],
              [58, 44.8, 9, 7],
              [81.5, 44.8, 9, 7],
              [11.5, 76, 8.5, 8],
              [37, 76, 8.5, 8],
              [57.5, 76, 37, 8],
            ], w, h),
          ),
          _closeHotspot(c, w, h),
          for (var i = 0; i < _spots.length; i++)
            Positioned(
              left: w * _spots[i][0] / 100,
              top: h * _spots[i][1] / 100,
              width: w * _spots[i][2] / 100,
              height: h * _spots[i][3] / 100,
              child: () {
                final taken = i < step, ready = i == step && !claimed;
                final label = '${i + 1}. gün: ${taken ? 'Alındı' : ready ? 'Ödülü al' : 'Kilitli'}';
                final text = taken ? '✓' : ready ? 'AL' : i == step ? 'YARIN' : '🔒';
                final green = ready || taken;
                final face = Container(
                  decoration: green
                      ? BoxDecoration(
                          gradient: vGradient(const [Color(0xFF68F33C), Color(0xFF04B921)]),
                          border: Border.all(color: const Color(0xFF104B19), width: 2),
                          borderRadius: BorderRadius.circular(30),
                        )
                      : null,
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(text,
                        style: nunito(fontSize,
                            color: green ? Colors.white : const Color(0xFF16334A),
                            height: 1,
                            shadows: green ? const [Shadow(color: Color(0xFF16571C), offset: Offset(0, 2))] : null)),
                  ),
                );
                return Btn(
                  onTap: ready ? c.claimDaily : null,
                  enabled: ready,
                  disabledOpacity: 1,
                  semanticLabel: label,
                  child: face,
                );
              }(),
            ),
        ]);
      }),
    );
  }
}
