import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pati_sampiyonlari/game/campus_world.dart';

void main() {
  test('camera: fits the map, keeps the pinched point under the fingers, stays inside', () {
    final camera = CampusCamera()..resize(const Size(390, 844));
    expect(camera.minZoom, closeTo(844 / (3072 + 2 * CampusCamera.margin), 1e-9));
    camera.maxZoom = 1;
    camera.focus(const Offset(1024, 1536), scale: .5);
    const focal = Offset(120, 300);
    final under = camera.toWorld(focal);
    camera.begin(focal);
    camera.gesture(focal, 1.4);
    expect(camera.zoom, closeTo(.7, 1e-9));
    expect((camera.toWorld(focal) - under).distance, lessThan(1e-6));
    expect((camera.toScreen(camera.toWorld(focal)) - focal).distance, lessThan(1e-6));
    // Haritanın çok dışına çekilemez.
    camera.focus(const Offset(-5000, -5000), scale: .5);
    expect(camera.visible.left, greaterThanOrEqualTo(-CampusCamera.margin - 1e-6));
    expect(camera.visible.top, greaterThanOrEqualTo(-CampusCamera.margin - 1e-6));
    camera.gesture(focal, 100);
    expect(camera.zoom, 1);
    final saved = camera.snapshot();
    camera.overview();
    camera.restore(saved);
    expect(camera.snapshot(), saved);
  });

  test('world: taps hit the facility drawn there', () {
    final world = CampusWorld();
    expect(world.facilityAt(campusSpots['stadium']!.art.center), 'stadium');
    expect(world.facilityAt(campusSpots['archery']!.art.center), 'archery');
    expect(world.facilityAt(const Offset(1024, 2800)), isNull, reason: 'nehir');
    world.camera.resize(const Size(390, 844));
    world.openingView();
    expect(world.camera.visible.contains(campusSpots['stadium']!.art.center), true);
  });
}
