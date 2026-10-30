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
    final worldWidth = (size.width - 16).clamp(0.0, 640.0);
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
                level: f.locked ? 'YAKINDA' : 'Sv. ${c.facilityLevel(f.id)}',
                upgradable: c.canUpgradeFacility(f.id),
                maxWidth: layout.x(35),
                semanticLabel: f.name,
                onTap: () => c.showCampusFacility(f.id),
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
              child: Column(
                children: [
                  // Başlık haritanın üstünde sabit; harita ve tesis listesi kayar.
                  Padding(padding: EdgeInsets.fromLTRB(8, padding.top + 6, 8, 6), child: _CampusTop(c)),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: padding.bottom + 12),
                      child: Center(
                        child: SizedBox(
                          width: layout.width,
                          child: Column(
                            children: [
                              ClipRRect(borderRadius: BorderRadius.circular(18), child: world),
                              const SizedBox(height: 10),
                              _FacilityList(c),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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

/// Haritanın altında tesis listesi: seviye ve geliştirilebilirlik bir bakışta.
class _FacilityList extends StatelessWidget {
  const _FacilityList(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(10, 10, 10, 2),
    decoration: BoxDecoration(
      color: GameColors.paper,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: GameColors.ink, width: 3),
      boxShadow: const [BoxShadow(color: GameColors.panelShadow, offset: Offset(0, 5), blurRadius: 8)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('TESİSLER', style: gameText(TextSizes.section, color: GameColors.ink, height: 1)),
        ),
        for (final f in campusFacilities)
          ListRow(
            children: [
              Art(f.icon, width: 38, height: 38),
              RowTitle(f.name, small: 'Sv. ${c.facilityLevel(f.id)} · ${[for (final r in f.rows) r.name].join(', ')}'),
              if (c.canUpgradeFacility(f.id))
                ActionButton('Geliştir', onTap: () => c.showCampusFacility(f.id))
              else
                RaisedButton('Gör', tone: ButtonTone.cream, onTap: () => c.showCampusFacility(f.id), height: 40),
            ],
          ),
        const PanelText.muted('Başlangıçta 8 SP; tamamlanan her 5 yarışta +1 SP.', align: TextAlign.center),
      ],
    ),
  );
}
