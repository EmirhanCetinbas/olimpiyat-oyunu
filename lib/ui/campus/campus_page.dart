import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/data.dart';
import '../components/components.dart';
import '../theme/theme.dart';
import 'campus_dialog.dart';
import 'campus_viewport.dart';

/// Kampüs: tam ekran, kaydırılıp yakınlaştırılan harita (bkz. [CampusViewport]); üstte sabit
/// başlık, altta tesis listesi düğmesi. Tesise ya da etiketine dokunmak tesis penceresini açar.
class CampusPage extends StatefulWidget {
  const CampusPage({super.key});

  @override
  State<CampusPage> createState() => _CampusPageState();
}

class _CampusPageState extends State<CampusPage> {
  bool _listOpen = false;

  void _setList(bool open) => setState(() => _listOpen = open);

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final padding = MediaQuery.paddingOf(context);
    final narrow = MediaQuery.sizeOf(context).width <= 350;
    final topInset = padding.top + 12 + (narrow ? 37 : 42);
    final bottomInset = padding.bottom + 66;
    final anyUpgrade = campusFacilities.any((f) => c.canUpgradeFacility(f.id));
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: CampusViewport(topInset: topInset, bottomInset: bottomInset, suspended: c.campusDialogOpen || _listOpen),
          ),
          // Başlık haritanın üstünde sabit; arkasındaki koyu geçiş okunurluk için.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: IgnorePointer(
              child: Container(
                height: topInset + 24,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x88123018), Color(0x00123018)],
                  ),
                ),
              ),
            ),
          ),
          Positioned(left: 8, right: 8, top: padding.top + 6, child: _CampusTop(c)),
          Positioned(
            left: 12,
            bottom: padding.bottom + 12,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                RaisedButton('TESİSLER', onTap: () => _setList(true), height: 46, minWidth: 128, fontSize: 17),
                if (anyUpgrade) const Positioned(right: -4, top: -4, child: NotificationDot()),
              ],
            ),
          ),
          if (_listOpen) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: () => _setList(false),
                child: const ColoredBox(color: Color(0x66000000)),
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: padding.bottom + 8,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .62),
                child: SingleChildScrollView(
                  child: _FacilityList(
                    c,
                    onOpen: (id) {
                      _setList(false);
                      c.showCampusFacility(id);
                    },
                    onClose: () => _setList(false),
                  ),
                ),
              ),
            ),
          ],
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

/// Tesis listesi (alttan açılır): seviye ve geliştirilebilirlik bir bakışta.
class _FacilityList extends StatelessWidget {
  const _FacilityList(this.c, {required this.onOpen, required this.onClose});
  final GameController c;
  final ValueChanged<String> onOpen;
  final VoidCallback onClose;

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
          child: Row(
            children: [
              Expanded(
                child: Text('TESİSLER', style: gameText(TextSizes.section, color: GameColors.ink, height: 1)),
              ),
              ModalCloseButton(onTap: onClose),
            ],
          ),
        ),
        for (final f in campusFacilities)
          ListRow(
            children: [
              Art(f.icon, width: 38, height: 38),
              RowTitle(f.name, small: 'Sv. ${c.facilityLevel(f.id)} · ${[for (final r in f.rows) r.name].join(', ')}'),
              if (c.canUpgradeFacility(f.id))
                ActionButton('Geliştir', onTap: () => onOpen(f.id))
              else
                RaisedButton('Gör', tone: ButtonTone.cream, onTap: () => onOpen(f.id), height: 40),
            ],
          ),
        const PanelText.muted('Başlangıçta 8 SP; tamamlanan her 5 yarışta +1 SP.', align: TextAlign.center),
      ],
    ),
  );
}
