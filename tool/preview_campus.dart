// Kampüs haritası harness'i: gerçek jestlerle (sürükleme, kıstırma, dokunma) kareler.
// flutter test --no-pub tool/preview_campus.dart --dart-define=PREVIEW_OUTPUT_ROOT=docs/verification
// Çıktı: <kök>/campus-harness-<tarih>/<boyut>-<adım>.png ve <boyut>-sheet.png (şerit).
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pati_sampiyonlari/game/campus_world.dart';
import 'package:pati_sampiyonlari/game/controller.dart';
import 'package:pati_sampiyonlari/game/state.dart';
import 'package:pati_sampiyonlari/main.dart';
import 'package:pati_sampiyonlari/ui/components/sprite.dart';

import 'mulberry32.dart';
import 'preview_game.dart' show loadPreviewFonts;

final _date = DateTime.now().toIso8601String().substring(0, 10);
const _root = String.fromEnvironment('PREVIEW_OUTPUT_ROOT', defaultValue: 'docs/verification');
const _only = String.fromEnvironment('PREVIEW_ONLY');

/// Ekran boyutları: küçük (SE), orta (iPhone 16), büyük (Pro Max).
const _sizes = {'small': Size(320, 568), 'medium': Size(390, 844), 'large': Size(430, 932)};

void main() {
  testWidgets('campus harness', (tester) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    await tester.runAsync(loadPreviewFonts);
    await tester.runAsync(SpriteCache.preload);

    for (final MapEntry(key: sizeName, value: size) in _sizes.entries) {
      if (_only.isNotEmpty && sizeName != _only) continue;
      tester.view.physicalSize = size;
      final now = DateTime.now().millisecondsSinceEpoch;
      // 12 SP: bazı tesisler geliştirilebilir (altın çerçeve), bazı kademeler alınmış.
      final preset = {
        ...GameState.initial(now).toJson(),
        'skillPoints': 3,
        'races': 40,
        'campusUpgrades': {
          'stadium': [2, 1, 0],
          'sprint': [1, 0, 0],
        },
        'last': now,
      };
      final c = GameController(storage: MemoryStorage(jsonEncode(preset)), random: Mulberry32(7));
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: PatiApp(controller: c, fontFallback: const ['Arial Unicode', 'Apple Symbols']),
        ),
      );
      await tester.pump();

      Future<void> settle([int rounds = 2]) async {
        for (var i = 0; i < rounds; i++) {
          await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 250)));
          await tester.pump(const Duration(milliseconds: 50));
        }
      }

      final shots = <String>[];
      Future<void> shot(String step) async {
        await tester.pump(const Duration(milliseconds: 16));
        await tester.runAsync(() async {
          final image = await (boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary).toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final path = '$_root/campus-harness-$_date/$sizeName-$step.png';
          File(path)
            ..createSync(recursive: true)
            ..writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
          shots.add(path);
        });
      }

      // Kampüse alt menüden gir.
      await tester.tap(find.text('Kampüs').last);
      await settle(3);
      await shot('01-open');

      final center = Offset(size.width / 2, size.height / 2);
      // Tek parmakla sola ve yukarı sürükle (haritanın sağ altına bak).
      await tester.timedDragFrom(center, const Offset(-160, -260), const Duration(milliseconds: 400));
      await settle();
      await shot('02-pan');

      // İki parmakla yakınlaştır (parmaklar birbirinden uzaklaşır).
      // Her parmağa ayrı işaretçi: aynı numara tek parmak sayılır.
      var pointer = 100;
      Future<void> pinch(double from, double to) async {
        final a = await tester.startGesture(center.translate(-from, 0), pointer: pointer++);
        final b = await tester.startGesture(center.translate(from, 0), pointer: pointer++);
        for (var i = 1; i <= 8; i++) {
          final d = from + (to - from) * i / 8;
          await a.moveTo(center.translate(-d, 0));
          await b.moveTo(center.translate(d, 0));
          await tester.pump(const Duration(milliseconds: 16));
        }
        await a.up();
        await b.up();
        await settle(1);
      }

      await pinch(40, 160);
      await shot('03-zoom-in');
      await pinch(40, 400);
      await shot('04-zoom-max');

      // Köşeler: sol üst ve sağ alt sınır.
      for (var i = 0; i < 3; i++) {
        await tester.timedDragFrom(center, Offset(size.width, size.height), const Duration(milliseconds: 300));
      }
      await settle();
      await shot('05-corner-top-left');
      for (var i = 0; i < 4; i++) {
        await tester.timedDragFrom(center, Offset(-size.width, -size.height), const Duration(milliseconds: 300));
      }
      await settle();
      await shot('06-corner-bottom-right');

      // En uzak görünüm (düğme) ve geri.
      // Kamera 320 ms kayar; testte animasyon saati dokunuştan sonraki ilk karede başlar.
      Future<void> toggle() async {
        await tester.tap(find.bySemanticsLabel('Haritanın tamamı'));
        await tester.pump();
      }

      await toggle();
      await tester.pump(const Duration(milliseconds: 400));
      await settle();
      await shot('07-overview');
      await toggle();
      await tester.pump(const Duration(milliseconds: 160));
      await shot('07b-glide-half');
      await tester.pump(const Duration(milliseconds: 300));
      await settle();
      await shot('07c-focus-stadium');
      await toggle();
      await tester.pump(const Duration(milliseconds: 400));
      await settle();

      // Etikete dokun → tesis penceresi.
      await tester.tap(find.text('STADYUM').first);
      await settle();
      await shot('08-dialog');
      c.closeCampusDialog();
      await settle();

      // Haritada boş bir yere ve bir tesise dokunuş.
      final world = c.campusView; // görünüm kaydı çalışıyor mu (null olmamalı)
      // ignore: avoid_print
      print('$sizeName campusView saved: ${world != null}');
      await tester.tap(find.text('TESİSLER').first);
      await settle();
      await shot('09-list');
      await tester.tap(find.bySemanticsLabel('Kapat').last);
      await settle();

      // Haritada tesisin kendisine (etiket değil) dokun: okçuluk alanının ortası.
      final camera = CampusCamera()
        ..resize(size)
        ..restore(c.campusView);
      await tester.tapAt(camera.toScreen(campusSpots['archery']!.art.center));
      await settle();
      await shot('10-tap-building');
      c.closeCampusDialog();
      await settle();

      // Şerit: hepsi tek görüntüde.
      await tester.runAsync(() async {
        final images = <ui.Image>[];
        for (final p in shots) {
          final codec = await ui.instantiateImageCodec(File(p).readAsBytesSync());
          images.add((await codec.getNextFrame()).image);
        }
        const cols = 5;
        final w = size.width, h = size.height, rows = (images.length / cols).ceil();
        final rec = ui.PictureRecorder();
        final canvas = Canvas(rec)..drawColor(const Color(0xFFFFFFFF), BlendMode.src);
        for (var i = 0; i < images.length; i++) {
          canvas.drawImage(images[i], Offset((i % cols) * (w + 8), (i ~/ cols) * (h + 8)), Paint());
        }
        final sheet = await rec.endRecording().toImage((cols * (w + 8)).toInt(), (rows * (h + 8)).toInt());
        final bytes = await sheet.toByteData(format: ui.ImageByteFormat.png);
        File('$_root/campus-harness-$_date/$sizeName-sheet.png').writeAsBytesSync(bytes!.buffer.asUint8List());
      });

      await tester.pumpWidget(const SizedBox());
      c.dispose();
    }
  });
}
