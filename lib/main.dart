import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game/audio.dart';
import 'game/controller.dart';
import 'game/state.dart';
import 'ui/game_screen.dart';
import 'ui/widgets.dart';

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
  const PatiApp({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pati Şampiyonları',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Nunito',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF76C94D)),
        textSelectionTheme: const TextSelectionThemeData(cursorColor: Color(0xFF10283B)),
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFF173D35),
        resizeToAvoidBottomInset: false,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: GameScreen(controller: controller),
        ),
      ),
    );
  }
}
