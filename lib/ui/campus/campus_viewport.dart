import 'dart:math' as math;

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

class _CampusViewportState extends State<CampusViewport> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final world = CampusWorld();
  late final game = CampusGame(world: world);
  late GameController c;
  bool _background = false, _framed = false;
  int _pointers = 0;
  double _scaleBase = 1;

  /// Düğmeyle kamera geçişi (duck-gacha `_glideCamera`): 320 ms, zoom logaritmik ölçekte.
  /// initState'te kurulur: tembel kurulum dispose'a kalırsa kapanırken ata aranır (hata).
  late final AnimationController _glide;
  Offset _fromCenter = Offset.zero, _toCenter = Offset.zero;
  double _fromZoom = 1, _toZoom = 1;

  @override
  void initState() {
    super.initState();
    _glide = AnimationController(vsync: this, duration: const Duration(milliseconds: 320))
      ..addListener(_glideStep)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _save();
      });
    WidgetsBinding.instance.addObserver(this);
  }

  /// [move] kamerayı hedefe koyar; kamera oraya yumuşakça kayar (azaltılmış harekette anında).
  void _glideCamera(void Function() move) {
    final camera = world.camera;
    _fromCenter = camera.center;
    _fromZoom = camera.zoom;
    move();
    _toCenter = camera.center;
    _toZoom = camera.zoom;
    if (MediaQuery.disableAnimationsOf(context)) {
      game.changed();
      _save();
      return;
    }
    camera
      ..center = _fromCenter
      ..zoom = _fromZoom;
    _glide.forward(from: 0);
  }

  void _glideStep() {
    final t = Curves.easeInOutCubic.transform(_glide.value);
    final camera = world.camera;
    camera.zoom = math.exp(math.log(_fromZoom) + (math.log(_toZoom) - math.log(_fromZoom)) * t);
    camera.center = Offset.lerp(_fromCenter, _toCenter, t)!;
    game.changed();
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
    _glide.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _tap(Offset screen) {
    final id = world.facilityAt(world.camera.toWorld(screen));
    if (id != null) c.showCampusFacility(id);
  }

  /// Tamamı görünüyorsa stadyuma (haritanın ortası) yakınlaşır, değilse tamamına döner.
  void _toggleOverview() {
    final camera = world.camera;
    _glideCamera(() {
      if (camera.zoom <= camera.minZoom * 1.05) {
        camera.focus(campusSpots['stadium']!.art.center, scale: camera.minZoom * 1.8);
      } else {
        camera.overview();
      }
    });
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
        final camera = world.camera..resize(box.biggest);
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
                  _glide.stop();
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
                // Etiketler jest algılayıcının içinde: etiketin üstünden başlayan kaydırma ve
                // kıstırma da haritaya ulaşır; etikete dokunmak yine etiketin işidir.
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ExcludeSemantics(
                        child: RepaintBoundary(child: GameWidget<CampusGame>(game: game)),
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
    // Başlığın ya da alt düğmelerin (şerit ve sağ alttaki görünüm düğmesi) altına giren ve ekran
    // dışındaki etiketler çizilmez: düğmelerle üst üste binmesin.
    if (p.dx < -120 || p.dx > view.width + 120 || p.dy < widget.topInset + 14 || p.dy > view.height - widget.bottomInset - 40) return null;
    return Positioned.fill(
      child: CustomSingleChildLayout(
        delegate: _PinnedLabel(p),
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

/// Etiket tesisin noktasında ortalanır; ekranın kenarına taşacaksa ekranın içinde kalır.
class _PinnedLabel extends SingleChildLayoutDelegate {
  const _PinnedLabel(this.at);
  final Offset at;
  static const _edge = 6.0;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size child) =>
      Offset((at.dx - child.width / 2).clamp(_edge, math.max(_edge, size.width - child.width - _edge)), at.dy - child.height / 2);

  @override
  bool shouldRelayout(_PinnedLabel old) => old.at != at;
}
