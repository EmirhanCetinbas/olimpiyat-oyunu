import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../game/campus_game.dart';
import '../../game/campus_world.dart';
import '../../game/controller.dart';
import '../../game/data.dart';
import '../components/components.dart';
import '../theme/theme.dart';
import 'facility_marker.dart';

/// Kaydırılıp yakınlaştırılan kampüs haritası (duck-gacha `ParkViewport` düzeni): Flame tuvali
/// bir `GestureDetector` altında; etiketler ve düğmeler üstte Flutter katmanı. Pencere
/// açıkken, uygulama arka plandayken ya da sayfa görünmezken oyun döngüsü durur.
class CampusViewport extends StatefulWidget {
  const CampusViewport({super.key, required this.topInset, required this.bottomInset, required this.suspended});

  /// Haritanın üstünü örten başlık ve altını örten düğme şeridi.
  final double topInset, bottomInset;

  /// Tesis penceresi ya da liste açık: harita durur.
  final bool suspended;

  @override
  State<CampusViewport> createState() => _CampusViewportState();
}

class _CampusViewportState extends State<CampusViewport> with WidgetsBindingObserver {
  final world = CampusWorld();
  late final game = CampusGame(world: world);
  late GameController c;
  bool _background = false, _framed = false;
  int _pointers = 0;
  double _scaleBase = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    c = GameScope.of(context);
    _syncEngine();
  }

  @override
  void didUpdateWidget(CampusViewport old) {
    super.didUpdateWidget(old);
    _syncEngine();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _background = state != AppLifecycleState.resumed;
    if (_background) _save();
    _syncEngine();
  }

  void _syncEngine() {
    final run = !_background && !widget.suspended && TickerMode.valuesOf(context).enabled && !MediaQuery.disableAnimationsOf(context);
    run ? game.resumeEngine() : game.pauseEngine();
    game.changed();
  }

  void _save() => c.campusView = world.camera.snapshot();

  @override
  void dispose() {
    _save();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _tap(Offset screen) {
    final id = world.facilityAt(world.camera.toWorld(screen));
    if (id != null) c.showCampusFacility(id);
  }

  void _toggleOverview() {
    final camera = world.camera;
    if (camera.zoom <= camera.minZoom * 1.05) {
      world.openingView();
    } else {
      camera.overview();
    }
    game.changed();
    _save();
  }

  @override
  Widget build(BuildContext context) {
    // Durum → dünya: hangi tesis parlar, hangi seviyede.
    world.upgradable = {
      for (final f in campusFacilities)
        if (c.canUpgradeFacility(f.id)) f.id,
    };
    world.levels = {for (final f in campusFacilities) f.id: c.facilityLevel(f.id)};
    return LayoutBuilder(
      builder: (context, box) {
        final camera = world.camera
          ..insetTop = widget.topInset
          ..insetBottom = widget.bottomInset
          ..resize(box.biggest);
        final ratio = MediaQuery.devicePixelRatioOf(context);
        if (game.pixelRatio != ratio) {
          game.pixelRatio = ratio;
          if (game.ready) game.limitZoom();
        }
        if (!_framed && !box.biggest.isEmpty) {
          _framed = true;
          final saved = c.campusView;
          saved == null ? world.openingView() : camera.restore(saved);
        }
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: (d) {
                  _pointers = d.pointerCount;
                  _scaleBase = 1;
                  camera.begin(d.localFocalPoint);
                },
                onScaleUpdate: (d) {
                  // Parmak sayısı değişince sıçramasın: hareketi yeniden başlat.
                  if (_pointers != d.pointerCount) {
                    _pointers = d.pointerCount;
                    _scaleBase = d.scale;
                    camera.begin(d.localFocalPoint);
                    return;
                  }
                  camera.gesture(d.localFocalPoint, d.scale / _scaleBase);
                  game.changed();
                },
                onScaleEnd: (_) => _save(),
                onTapUp: (d) => _tap(d.localPosition),
                child: ExcludeSemantics(
                  child: RepaintBoundary(child: GameWidget<CampusGame>(game: game)),
                ),
              ),
            ),
            // Tesis etiketleri ekran uzayında: yakınlaştırmayla boyları değişmez.
            Positioned.fill(
              child: ValueListenableBuilder<int>(
                valueListenable: game.revision,
                builder: (context, _, _) => Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    for (final f in campusFacilities)
                      if (_marker(f, camera, box.biggest) case final Widget marker) marker,
                  ],
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: widget.bottomInset + 12,
              child: Pressable(
                onTap: _toggleOverview,
                semanticLabel: 'Haritanın tamamı',
                minTapSize: minTapTarget,
                child: SizedBox.square(
                  dimension: 46,
                  child: RaisedSurface.cream(
                    radius: 23,
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 3),
                      child: Icon(Icons.zoom_out_map_rounded, color: GameColors.ink, size: 26),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget? _marker(CampusFacility f, CampusCamera camera, Size view) {
    final p = camera.toScreen(campusSpots[f.id]!.label);
    // Ekranın dışındaki etiketler çizilmez.
    if (p.dx < -120 || p.dx > view.width + 120 || p.dy < widget.topInset - 40 || p.dy > view.height + 60) return null;
    return Positioned(
      left: p.dx,
      top: p.dy,
      child: FractionalTranslation(
        translation: const Offset(-.5, -.5),
        child: FacilityMarker(
          label: f.label,
          level: 'Sv. ${world.levels[f.id] ?? 1}',
          upgradable: world.upgradable.contains(f.id),
          maxWidth: 150,
          semanticLabel: f.name,
          onTap: () => c.showCampusFacility(f.id),
        ),
      ),
    );
  }
}
