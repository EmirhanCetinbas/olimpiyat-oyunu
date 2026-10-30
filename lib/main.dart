import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game/audio.dart';
import 'game/controller.dart';
import 'game/state.dart';
import 'ui/home/game_screen.dart';
import 'ui/components/sprite.dart';
import 'ui/theme/typography.dart';

/// localStorage karşılığı: SharedPreferences'ta aynı anahtar ve JSON biçimi.
class PrefsStorage implements GameStorage {
  PrefsStorage(this.prefs);
  final SharedPreferences prefs;

  @override
  String? read() => prefs.getString(storageKey);

  @override
  bool write(String value) {
    prefs.setString(storageKey, value);
    return true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final results = await Future.wait([SharedPreferences.getInstance(), SpriteCache.preload()]);
  final controller = GameController(storage: PrefsStorage(results[0] as SharedPreferences), audio: SoloudAudio());
  runApp(PatiApp(controller: controller));
}

class PatiApp extends StatelessWidget {
  const PatiApp({super.key, required this.controller, this.fontFallback});
  final GameController controller;

  /// Yalnızca simülatörsüz önizlemede: sistem yedek fontu olmayan test ortamı için.
  final List<String>? fontFallback;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pati Şampiyonları',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: gameFontFamily,
        fontFamilyFallback: [...?fontFallback, ...gameFontFallback],
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: TextSizes.body, fontWeight: FontWeight.w800),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF76C94D)),
        textSelectionTheme: const TextSelectionThemeData(cursorColor: Color(0xFF10283B)),
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFF173D35),
        resizeToAvoidBottomInset: false,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          // Oyun yerleşimi sabit ölçülü; sistem yazı büyütmesi düzeni bozmasın diye sınırlı tutulur.
          child: MediaQuery.withClampedTextScaling(maxScaleFactor: 1.15, child: GameScreen(controller: controller)),
        ),
      ),
    );
  }
}
