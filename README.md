# Pawlympics — Pati Şampiyonları

`pati-sampiyonlari/` klasöründeki web oyununun bire bir Flutter sürümü (iOS ve Android, `com.olympos.pawlympics`).

- `lib/game/`: oyun mantığı (game.js, longjump.js, weights.js, archery.js, chests.js, moves.js, campus.js karşılıkları)
- `lib/ui/`: ana ekran, stadyum, paneller, ayarlar, kampüs
- `test/game_logic_test.dart`: `check-game.cjs` senaryolarının Dart karşılığı (`flutter test`)
- `tool/preview_game.dart`: simülatörsüz ekran önizlemesi, bkz. `docs/simulator-free-previews.md`
