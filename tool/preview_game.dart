// Simülatörsüz ekran önizlemesi: flutter test --no-pub tool/preview_game.dart --dart-define=PREVIEW_OUTPUT_ROOT=docs/verification
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pati_sampiyonlari/game/controller.dart';
import 'package:pati_sampiyonlari/main.dart';
import 'package:pati_sampiyonlari/ui/components/sprite.dart';

final _date = DateTime.now().toIso8601String().substring(0, 10);
const _root = String.fromEnvironment('PREVIEW_OUTPUT_ROOT', defaultValue: 'docs/verification');
const _only = String.fromEnvironment('PREVIEW_ONLY');

Future<void> loadPreviewFonts() async {
  final manifest = jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final family in manifest) {
    final loader = FontLoader(family['family'] as String);
    for (final font in family['fonts'] as List) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

void main() {
  testWidgets('pati screens', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(loadPreviewFonts);
    await tester.runAsync(SpriteCache.preload);

    final c = GameController(storage: MemoryStorage());
    c.state.races = 6;
    c.state.wins = 3;
    c.state.money = 117000;
    c.state.auto = false;
    final boundary = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(key: boundary, child: PatiApp(controller: c)));

    Future<void> settle([int ms = 300]) async {
      await tester.runAsync(() => Future.delayed(Duration(milliseconds: ms)));
      await tester.pump(const Duration(milliseconds: 16));
    }

    Future<void> shot(String name) async {
      if (_only.isNotEmpty && !name.startsWith(_only)) return;
      await settle(400);
      await tester.runAsync(() async {
        final image = await (boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary).toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$_root/$name-$_date/$name.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    Future<void> run(double seconds) async {
      for (var i = 0; i < seconds * 30; i++) {
        await tester.pump(const Duration(milliseconds: 33));
      }
    }

    await settle(800);
    await shot('sprint-idle');
    c.beginRace();
    await run(4.5);
    await shot('sprint-race');

    for (final branch in ['hurdles', 'swim', 'longjump', 'weights', 'archery']) {
      c.race = null;
      c.selectBranch(branch);
      await settle(600);
      await shot('$branch-idle');
      c.beginRace();
      await run(branch == 'hurdles' || branch == 'swim' ? 6 : 3);
      await shot('$branch-race');
    }
    c.race = null;
    c.clearMove();
    c.selectBranch('sprint');

    for (final panel in ['settings', 'achievements', 'daily-rewards', 'inventory', 'shop', 'branches', 'wheel']) {
      c.openPanel(panel);
      await settle(600);
      await shot('panel-$panel');
    }
    c.inventoryTab = 'equipment';
    c.openPanel('inventory');
    await shot('panel-equipment');
    c.closeModal();
    c.rewardsMenu(true);
    await shot('rewards-menu');
    c.rewardsMenu(false);
    c.openPanel('campus');
    await settle(800);
    await shot('campus');
    c.showCampusFacility('stadium');
    await shot('campus-dialog');
    c.closeCampus();
    await tester.pump();
    c.dispose();
  });
}
