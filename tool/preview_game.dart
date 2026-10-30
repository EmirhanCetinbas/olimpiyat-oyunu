// Simülatörsüz ekran önizlemesi; senaryolar tool/scenarios.json'dan gelir.
// flutter test --no-pub tool/preview_game.dart --dart-define=PREVIEW_OUTPUT_ROOT=docs/verification [--dart-define=PREVIEW_ONLY=panel-]
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pati_sampiyonlari/game/controller.dart';
import 'package:pati_sampiyonlari/game/state.dart';
import 'package:pati_sampiyonlari/main.dart';
import 'package:pati_sampiyonlari/ui/components/sprite.dart';

import 'mulberry32.dart';

final _date = DateTime.now().toIso8601String().substring(0, 10);
const _root = String.fromEnvironment('PREVIEW_OUTPUT_ROOT', defaultValue: 'docs/verification');
const _only = String.fromEnvironment('PREVIEW_ONLY');
final _dpr = double.parse(const String.fromEnvironment('PREVIEW_DPR', defaultValue: '1'));

Future<void> loadPreviewFonts() async {
  final manifest = jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final family in manifest) {
    final loader = FontLoader(family['family'] as String);
    for (final font in family['fonts'] as List) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
  // Test ortamında sistem yedek fontu yok: sembol ve emoji için macOS fontlarını ekle.
  for (final (family, path) in const [
    ('Arial Unicode', '/System/Library/Fonts/Supplemental/Arial Unicode.ttf'),
    // Oyun fontunun yedeği 'Arial' (cihazda sistemde var); testte Arial Unicode ile karşılanır.
    ('Arial', '/System/Library/Fonts/Supplemental/Arial Unicode.ttf'),
    ('Apple Symbols', '/System/Library/Fonts/Apple Symbols.ttf'),
  ]) {
    final file = File(path);
    if (!file.existsSync()) continue;
    final loader = FontLoader(family)..addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
    await loader.load();
  }
}

/// scenarios.json eylemlerinin Flutter karşılığı (web_reference.mjs ile aynı adlar).
void runStep(GameController c, String action, Object? arg) {
  switch (action) {
    case 'begin':
      c.beginRace();
    case 'advance':
      for (var i = 0; i < ((arg as num) * 60).round(); i++) {
        c.tick(1 / 60);
      }
    case 'open':
      c.openPanel(arg as String);
    case 'inventoryTab':
      c.setInventoryTab(arg as String);
    case 'info':
      c.showInfo(arg as int);
    case 'support':
      c.openSupport();
    case 'reset':
      c.askReset();
    case 'rewardsMenu':
      c.selectNav(2);
      c.rewardsMenu(true);
    case 'upgrade':
      c.pressUpgrade(arg as int);
    case 'openChest':
      c.pressOpenChest(arg as String);
    case 'chooseChest':
      c.pressChooseChest(arg as int);
    case 'campusFacility':
      c.showCampusFacility(arg as String);
    case 'spinUsed':
      c.state.spinDate = c.todayKey;
    case 'dailyClaimed':
      c.state.daily = c.now;
    case 'keepToast':
      break;
    default:
      throw ArgumentError('Bilinmeyen eylem: $action');
  }
}

void main() {
  final spec = jsonDecode(File('tool/scenarios.json').readAsStringSync()) as Map<String, dynamic>;
  final base = spec['base'] as Map<String, dynamic>;

  testWidgets('pati screens', (tester) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = _dpr;
    await tester.runAsync(loadPreviewFonts);
    await tester.runAsync(SpriteCache.preload);

    Future<void> settle() async {
      for (var i = 0; i < 2; i++) {
        await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
        await tester.pump();
      }
    }

    for (final s in (spec['scenarios'] as List).cast<Map<String, dynamic>>()) {
      final name = s['name'] as String;
      if (_only.isNotEmpty && !name.startsWith(_only)) continue;
      final size = (s['size'] as List?)?.cast<num>() ?? [390, 844];
      tester.view.physicalSize = Size(size[0] * _dpr, size[1] * _dpr);

      final now = DateTime.now().millisecondsSinceEpoch;
      final preset = {...GameState.initial(now).toJson(), ...base, ...?s['state'] as Map<String, dynamic>?, 'last': now};
      final c = GameController(storage: MemoryStorage(jsonEncode(preset)), random: Mulberry32(12345));
      final boundary = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(key: boundary, child: PatiApp(controller: c, fontFallback: const ['Arial Unicode', 'Apple Symbols'])));
      await settle();

      final steps = (s['steps'] as List?)?.cast<List>() ?? const [];
      for (final step in steps) {
        runStep(c, step[0] as String, step.length > 1 ? step[1] : null);
      }
      if (!steps.any((step) => step[0] == 'keepToast')) c.toastVisible = false;
      // Arayüz animasyonları (toast, çanta açılışı) bitsin; oyun simülasyonu bu sırada dondurulur.
      // Yarış yoksa dondurmaya gerek yok (Ayarlar'daki duraklat anahtarı etkilenmesin).
      final wasPaused = c.paused;
      if (c.race != null || c.resultDelay > 0) c.paused = true;
      await tester.pump(); // değişiklikler kurulsun, animasyonlar bu karede başlasın
      await tester.pump(const Duration(milliseconds: 400));
      c.paused = wasPaused;
      await tester.pump();
      await settle();

      await tester.runAsync(() async {
        final image = await (boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary).toImage(pixelRatio: _dpr);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$_root/$name-$_date/$name.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
      await tester.pumpWidget(const SizedBox());
      c.dispose();
    }
  });
}
