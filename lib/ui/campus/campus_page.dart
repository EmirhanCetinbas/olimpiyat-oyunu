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
                level: f.locked ? '🔒 YAKINDA' : 'Sv. ${c.facilityLevel(f.id)}',
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
          minTapSize: minTapTarget,
          child: SizedBox(
            width: side,
            height: side,
            child: RaisedSurface.cream(
              radius: side / 2,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Icon(Icons.arrow_back_rounded, color: GameColors.ink, size: side * .62),
              ),
            ),
          ),
        ),
        gap,
        Expanded(child: ModalBanner('KAMPÜS', height: side + 6)),
        gap,
        Pressable(
          onTap: () => c.toast('Başlangıçta 8 SP; tamamlanan her 5 yarışta +1 SP.'),
          semanticLabel: 'Skill puanı hakkında',
          child: SizedBox(
            height: side,
            child: RaisedSurface(
              color: GameColors.navy,
              shade: GameColors.navyShade,
              radius: side / 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 3),
                child: Center(
                  widthFactor: 1,
                  child: Text.rich(
                    TextSpan(
                      style: gameText(narrow ? 13 : 15, color: Colors.white, height: 1),
                      children: [
                        const TextSpan(
                          text: '★',
                          style: TextStyle(color: GameColors.sparkle),
                        ),
                        TextSpan(text: ' ${c.state.skillPoints} SP'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
