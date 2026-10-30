# Ekran önizleme ve web karşılaştırması

Senaryolar `tool/scenarios.json` içinde; aynı senaryolar hem orijinal web oyununda (headless Chrome) hem Flutter'da çalışır.
İki taraf aynı rastgele sayı üretecini (mulberry32) kullandığından yarışlar birebir aynı ilerler.

```sh
node tool/web_reference.mjs docs/verification            # web referansları (<ekran>-web.png)
flutter test --no-pub tool/preview_game.dart --dart-define=PREVIEW_OUTPUT_ROOT=docs/verification
python3 tool/compare_shots.py                              # <ekran>-compare.png + compare-<tarih>/overview-*.png
# Tek ekran: node tool/web_reference.mjs docs/verification panel-   /   --dart-define=PREVIEW_ONLY=panel-
```

Çıktı `docs/verification/<ekran>-<tarih>/` altına yazılır ve git'e eklenmez. Test ortamında renkli emoji fontu yüklenemez;
emojiler kutu görünür (cihazda normal).
