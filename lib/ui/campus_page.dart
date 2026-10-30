import 'package:flutter/material.dart';

import '../game/controller.dart';
import '../game/data.dart';
import 'theme.dart';
import 'widgets.dart';

/// Kampüs: harita yalnızca arazi çizimidir; başlık, SP, etiketler ve pencere koddur.
class CampusPage extends StatelessWidget {
  const CampusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final worldWidth = size.width.clamp(0.0, 660.0);
    final worldHeight = worldWidth * 1536 / 1024;
    final labelSize = vwClamp(context, 10, 2.8, 17);

    final world = SizedBox(
      width: worldWidth,
      height: worldHeight,
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned.fill(child: Image.asset('assets/images/campus-map.png', fit: BoxFit.fill)),
        for (final f in campusFacilities)
          Positioned(
            left: worldWidth * f.area[0] / 100,
            top: worldHeight * f.area[1] / 100,
            width: worldWidth * f.area[2] / 100,
            height: worldHeight * f.area[3] / 100,
            child: Semantics(
              button: true,
              label: f.name,
              child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => c.showCampusFacility(f.id)),
            ),
          ),
        for (final f in campusFacilities)
          Positioned(
            left: worldWidth * f.x / 100,
            top: worldHeight * f.y / 100,
            child: FractionalTranslation(
              translation: const Offset(-.5, -.5),
              child: Btn(
                onTap: () => c.showCampusFacility(f.id),
                semanticLabel: f.name,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 70, maxWidth: worldWidth * .35),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    GBox(
                      gradient: vGradient(const [Color(0xFFFFFEFA), Color(0xFFFFEBC7)]),
                      borderColor: const Color(0xFF14334A),
                      borderWidth: 2,
                      radius: 11,
                      shadows: const [BoxShadow(color: Color(0xFFB9A67C), offset: Offset(0, 2))],
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      child: Text(f.label, maxLines: 1, softWrap: false, style: nunito(labelSize, weight: 1000, color: textInk)),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -1),
                      child: GBox(
                        color: const Color(0xFF0D304D),
                        borderColor: const Color(0xFF132C3F),
                        borderWidth: 2,
                        radius: 12,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Text(f.locked ? '🔒 YAKINDA' : 'Sv. ${c.facilityLevel(f.id)}　⬆',
                            maxLines: 1, softWrap: false, style: nunito(labelSize * .9, weight: 1000, color: Colors.white)),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        Positioned(
          top: worldHeight * .012,
          left: worldWidth * .02,
          right: worldWidth * .02,
          child: _CampusTop(c),
        ),
        Positioned(
          bottom: worldHeight * .09,
          left: worldWidth * .04,
          width: worldWidth * .92,
          child: GBox(
            color: const Color(0xEDFFF9E7),
            borderColor: const Color(0xFF19384B),
            borderWidth: 2,
            radius: 15,
            padding: const EdgeInsets.all(10),
            child: Text('Bir tesise dokun · Her 5 yarışta +1 SP', textAlign: TextAlign.center, style: nunito(13, color: const Color(0xFF0B2139))),
          ),
        ),
      ]),
    );

    return Positioned.fill(
      child: Stack(children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Color(0xFF2B983C),
              image: DecorationImage(image: AssetImage('assets/images/park-background.png'), fit: BoxFit.cover),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: padding.top, bottom: padding.bottom),
              child: Center(child: world),
            ),
          ),
        ),
        if (c.campusDialogOpen) const _CampusDialog(),
      ]),
    );
  }
}

class _CampusTop extends StatelessWidget {
  const _CampusTop(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width <= 350;
    final side = narrow ? 37.0 : 42.0;
    return Row(children: [
      Btn(
        onTap: c.closeCampus,
        semanticLabel: 'Oyuna dön',
        child: GBox(
          width: side,
          height: side,
          gradient: vGradient(const [Color(0xFFFFFEF1), Color(0xFFFFEDCB)]),
          borderColor: const Color(0xFF092337),
          borderWidth: 3,
          radius: 23,
          shadows: const [BoxShadow(color: Color(0x50102438), offset: Offset(0, 3))],
          insets: const [Inset(Colors.white, dy: 2)],
          alignment: Alignment.center,
          child: Text('←', style: nunito(29, color: textInk, height: 1)),
        ),
      ),
      SizedBox(width: narrow ? 4 : 7),
      Expanded(
        child: GBox(
          gradient: vGradient(const [Color(0xFFFF8D7D), Color(0xFFFF554B)]),
          borderColor: const Color(0xFF102437),
          borderWidth: 3,
          radius: 20,
          shadows: const [BoxShadow(color: Color(0x40172C39), offset: Offset(0, 3))],
          insets: const [Inset(Color(0xFFFFBBAC), dy: 4), Inset(Color(0xFFE43C36), dy: -4)],
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 11),
          alignment: Alignment.center,
          child: Text('KAMPÜS',
              style: nunito(vwClamp(context, 19, 5.5, 32), weight: 1000, color: Colors.white, height: 1, shadows: outlineShadows(const Color(0xFF142532), 2))),
        ),
      ),
      SizedBox(width: narrow ? 4 : 7),
      Btn(
        onTap: () => c.toast('Başlangıçta 8 SP; tamamlanan her 5 yarışta +1 SP.'),
        semanticLabel: 'Skill puanı hakkında',
        child: GBox(
          gradient: vGradient(const [Color(0xFF173F5C), Color(0xFF08283E)]),
          borderColor: const Color(0xFF092337),
          borderWidth: 3,
          radius: 23,
          shadows: const [BoxShadow(color: Color(0x50102438), offset: Offset(0, 3))],
          insets: const [Inset(Color(0xFF6A9CAA), dy: 2)],
          padding: const EdgeInsets.all(8),
          child: Text.rich(TextSpan(style: nunito(narrow ? 12 : 14, color: Colors.white), children: [
            const TextSpan(text: '★', style: TextStyle(color: Color(0xFFFFCD36))),
            TextSpan(text: ' ${c.state.skillPoints} SP'),
          ])),
        ),
      ),
    ]);
  }
}

class _CampusDialog extends StatelessWidget {
  const _CampusDialog();

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final f = c.facility(c.campusSelection)!;
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 600, narrow = size.width <= 350;
    final rank = c.facilityLevel(f.id);
    final iconBox = wide ? 82.0 : 65.0;
    return Positioned.fill(
      child: Stack(children: [
        Positioned.fill(child: GestureDetector(onTap: c.closeCampusDialog, child: const ColoredBox(color: Color(0x25072422)))),
        Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: (size.width * .92).clamp(0.0, 460.0),
              constraints: BoxConstraints(maxHeight: size.height * .9),
              child: GBox(
                gradient: angleGradient(120, const [Color(0xFFFFFEF3), Color(0xFFFFF0D4)]),
                borderColor: const Color(0xFF0B263A),
                borderWidth: 3,
                radius: 25,
                shadows: const [BoxShadow(color: Color(0x55082437), offset: Offset(0, 8))],
                insets: const [Inset(Color(0xFFFFF8E9), spread: 4)],
                child: Stack(children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 20, 12, 9),
                    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 15, right: 18),
                        child: Row(children: [
                          GBox(
                            width: iconBox,
                            height: wide ? 82 : 68,
                            gradient: vGradient(const [Color(0xFFFFFCEF), Color(0xFFEFDBB9)]),
                            borderColor: const Color(0xFFD4B28A),
                            borderWidth: 2,
                            radius: 15,
                            alignment: Alignment.center,
                            child: Art(f.icon, width: wide ? 69 : 56, height: wide ? 69 : 56),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(f.name, style: nunito(vwClamp(context, 17, 4.5, 23), weight: 1000, color: textInk, height: 1.1, letterSpacing: -.5)),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text('Kalıcı geliştirmeler', style: nunito(14, color: const Color(0xFF5C6473))),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 3),
                                decoration: BoxDecoration(color: const Color(0xFFEBDDC3), borderRadius: BorderRadius.circular(20)),
                                child: Text(f.locked ? 'YAKINDA' : 'Sv. $rank', style: nunito(15, color: textInk, height: 1.1)),
                              ),
                            ]),
                          ),
                        ]),
                      ),
                      if (f.locked)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFFF1E5CB), borderRadius: BorderRadius.circular(9)),
                          child: Text('Bu yarış dalı açıldığında geliştirmeler kullanılabilir.',
                              textAlign: TextAlign.center, style: nunito(12, color: const Color(0xFF677077), height: 1.3)),
                        ),
                      for (var i = 0; i < f.rows.length; i++) ...[
                        if (i > 0) const SizedBox(height: 9),
                        _UpgradeRow(c: c, f: f, i: i, wide: wide, narrow: narrow),
                      ],
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          f.locked
                              ? 'Skill puanın harcanmaz.'
                              : c.race != null && f.id == 'sprint'
                                  ? 'Yeni bonuslar sonraki yarışta uygulanır.'
                                  : 'Kalıcı bonuslar otomatik uygulanır.',
                          textAlign: TextAlign.center,
                          style: nunito(12, color: const Color(0xFF677077), height: 1.3),
                        ),
                      ),
                    ]),
                  ),
                  Positioned(
                    right: 6,
                    top: 5,
                    child: Btn(
                      onTap: c.closeCampusDialog,
                      semanticLabel: 'Yükseltmeleri kapat',
                      child: GBox(
                        width: 35,
                        height: 35,
                        gradient: vGradient(const [Color(0xFFFF8784), Color(0xFFF42D47)]),
                        borderColor: const Color(0xFF0D2440),
                        borderWidth: 3,
                        radius: 18,
                        insets: const [Inset(Color(0xFFFFBBB1), dy: 2)],
                        alignment: Alignment.center,
                        child: Text('×', style: nunito(31, color: Colors.white, height: .8)),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _UpgradeRow extends StatelessWidget {
  const _UpgradeRow({required this.c, required this.f, required this.i, required this.wide, required this.narrow});
  final GameController c;
  final CampusFacility f;
  final int i;
  final bool wide;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final row = f.rows[i];
    final n = c.campusRank(f.id, i), cost = c.campusCost(f.id, i);
    final enabled = !f.locked && n < 5 && c.state.skillPoints >= cost;
    final sign = row.amount < 0 ? '−' : '+';
    final iconW = wide ? 52.0 : narrow ? 32.0 : 40.0;
    final buttonW = wide ? 47.0 : narrow ? 32.0 : 38.0;
    final buttonLabel = f.locked ? '🔒' : n >= 5 ? '✓' : '↑';
    final button = Container(
      width: buttonW,
      height: wide ? 49 : 41,
      decoration: BoxDecoration(
        gradient: vGradient(const [Color(0xFF73F239), Color(0xFF0FC523)]),
        border: Border.all(color: const Color(0xFF123429), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GBox(
        radius: 10,
        insets: const [Inset(Color(0xFFD0FFAA), dy: 3), Inset(Color(0xFF049628), dy: -3)],
        alignment: Alignment.center,
        child: Text(buttonLabel,
            style: nunito(enabled ? 29 : 20, color: Colors.white, height: 1, shadows: const [Shadow(color: Color(0xFF0F3928), offset: Offset(1, 2))])),
      ),
    );
    return GBox(
      gradient: angleGradient(110, const [Color(0xFFFFFDF3), Color(0xFFFFF5E3)]),
      borderColor: const Color(0xFFDFC19E),
      borderWidth: 2,
      radius: 17,
      insets: const [Inset(Colors.white, dy: 2)],
      padding: EdgeInsets.symmetric(horizontal: wide ? 10 : 6, vertical: wide ? 10 : 8),
      child: Row(children: [
        Container(
          width: iconW,
          height: wide ? 54 : 46,
          decoration: BoxDecoration(
            gradient: vGradient(const [Color(0xFFE7D3B0), Color(0xFFFFF9E9)]),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Art(row.icon, width: wide ? 46 : narrow ? 29 : 35, height: wide ? 46 : narrow ? 29 : 35),
        ),
        SizedBox(width: wide ? 8 : narrow ? 4 : 6),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(row.name, style: nunito(wide ? 17 : narrow ? 12 : 14, weight: 1000, color: textInk, height: 1.1)),
            ),
            Text.rich(
              TextSpan(style: nunito(wide ? 14 : 12, color: const Color(0xFF566171), height: 1.2), children: [
                TextSpan(text: '${row.effect} '),
                TextSpan(text: '$sign%${row.amount.abs() * (n + 1)}', style: nunito(wide ? 14 : 12, weight: 1000, color: const Color(0xFF078420))),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text('$n/5 · Mevcut: $sign%${row.amount.abs() * n}', style: nunito(10, color: const Color(0xFF767569), height: 1.2)),
            ),
          ]),
        ),
        SizedBox(width: wide ? 8 : narrow ? 4 : 6),
        Text('★ ${n >= 5 ? 'MAKS.' : '$cost SP'}', style: nunito(wide ? 14 : narrow ? 11 : 12, weight: 1000, color: textInk)),
        SizedBox(width: wide ? 8 : narrow ? 4 : 6),
        Btn(
          onTap: () => c.pressCampusBuy(i),
          enabled: enabled,
          semanticLabel: '${row.name} geliştir, $cost SP',
          disabledSaturation: .5,
          disabledOpacity: .65,
          child: button,
        ),
      ]),
    );
  }
}
