# Simülatörsüz önizleme

```sh
flutter test --no-pub tool/preview_game.dart --dart-define=PREVIEW_OUTPUT_ROOT=docs/verification
# Tek ekran: --dart-define=PREVIEW_ONLY=panel-settings
```

Çıktı: `docs/verification/<ekran>-<tarih>/<ekran>.png`. Test ortamında emoji ve ▶ ➜ ⌄ gibi semboller kutu görünür (sistem yedek fontu yok); cihazda normaldir.
