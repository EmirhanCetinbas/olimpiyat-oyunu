import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/data.dart';
import '../components/components.dart';
import '../theme/theme.dart';
import 'campus_dialog.dart';
import 'facility_marker.dart';

/// Kampüs: harita yalnızca arazi çizimidir; başlık, SP, etiketler ve pencere koddur.
/// Tüm koordinatlar haritanın kendi en-boy oranına göredir.
class CampusPage extends StatelessWidget {
  const CampusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final worldWidth = size.width.clamp(0.0, 660.0);
    final layout = PercentLayout(worldWidth, worldWidth * 1536 / 1024);

    final world = SizedBox(
      width: layout.width,
      height: layout.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: Image.asset('assets/images/campus-map.png', fit: BoxFit.fill)),
          for (final f in campusFacilities) layout.area(f.area, HotSpot(onTap: () => c.showCampusFacility(f.id), label: f.name)),
          for (final f in campusFacilities)
            layout.point(
              f.x,
              f.y,
              FacilityMarker(
                label: f.label,
                level: f.locked ? '🔒 YAKINDA' : 'Sv. ${c.facilityLevel(f.id)}　⬆',
                maxWidth: layout.x(35),
                semanticLabel: f.name,
                onTap: () => c.showCampusFacility(f.id),
              ),
            ),
          Positioned(top: layout.y(1.2), left: layout.x(2), right: layout.x(2), child: _CampusTop(c)),
          Positioned(
            bottom: layout.y(9),
            left: layout.x(4),
            width: layout.x(92),
            child: Pill(
              'Bir tesise dokun · Her 5 yarışta +1 SP',
              style: gameText(13, color: const Color(0xFF0B2139)),
              textAlign: TextAlign.center,
              color: const Color(0xEDFFF9E7),
              borderColor: const Color(0xFF19384B),
              borderWidth: 2,
              radius: 15,
              padding: const EdgeInsets.all(10),
            ),
          ),
        ],
      ),
    );

    return Positioned.fill(
      child: Stack(
        children: [
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
          if (c.campusDialogOpen) const CampusDialog(),
        ],
      ),
    );
  }
}

/// Geri düğmesi, KAMPÜS başlığı ve SP sayacı.
class _CampusTop extends StatelessWidget {
  const _CampusTop(this.c);
  final GameController c;

  static const _shadow = [BoxShadow(color: Color(0x50102438), offset: Offset(0, 3))];

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width <= 350;
    final side = narrow ? 37.0 : 42.0;
    final gap = SizedBox(width: narrow ? 4 : 7);
    return Row(
      children: [
        Pressable(
          onTap: c.closeCampus,
          semanticLabel: 'Oyuna dön',
          child: GBox(
            width: side,
            height: side,
            gradient: vGradient(const [Color(0xFFFFFEF1), Color(0xFFFFEDCB)]),
            borderColor: const Color(0xFF092337),
            borderWidth: 3,
            radius: 23,
            shadows: _shadow,
            insets: const [Inset(Colors.white, dy: 2)],
            alignment: Alignment.center,
            child: Text('←', style: gameText(29, color: GameColors.text, height: 1)),
          ),
        ),
        gap,
        Expanded(child: BannerTitle('KAMPÜS', fontSize: vwClamp(context, 19, 5.5, 32))),
        gap,
        Pressable(
          onTap: () => c.toast('Başlangıçta 8 SP; tamamlanan her 5 yarışta +1 SP.'),
          semanticLabel: 'Skill puanı hakkında',
          child: GBox(
            gradient: vGradient(const [Color(0xFF173F5C), Color(0xFF08283E)]),
            borderColor: const Color(0xFF092337),
            borderWidth: 3,
            radius: 23,
            shadows: _shadow,
            insets: const [Inset(Color(0xFF6A9CAA), dy: 2)],
            padding: const EdgeInsets.all(8),
            child: Text.rich(
              TextSpan(
                style: gameText(narrow ? 12 : 14, color: Colors.white),
                children: [
                  const TextSpan(
                    text: '★',
                    style: TextStyle(color: Color(0xFFFFCD36)),
                  ),
                  TextSpan(text: ' ${c.state.skillPoints} SP'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
