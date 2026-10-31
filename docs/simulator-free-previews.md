# Ekran önizleme ve web karşılaştırması

Senaryolar `tool/scenarios.json` içinde; aynı senaryolar hem orijinal web oyununda (headless Chrome) hem Flutter'da çalışır.
İki taraf aynı rastgele sayı üretecini (mulberry32) kullandığından yarışlar birebir aynı ilerler.

```sh
node tool/web_reference.mjs docs/verification            # web referansları (<ekran>-web.png)
flutter test --no-pub tool/preview_game.dart --dart-define=PREVIEW_OUTPUT_ROOT=docs/verification
python3 tool/compare_shots.py                              # <ekran>-compare.png + compare-<tarih>/overview-*.png
# Tek ekran: node tool/web_reference.mjs docs/verification panel-   /   --dart-define=PREVIEW_ONLY=panel-
# Yüksek çözünürlük (ör. 3x): --dart-define=PREVIEW_DPR=3
# Ayarlar ↔ tasarım referansı: python3 tool/settings_vs_reference.py <png> <çıktı>
```

Çıktı `docs/verification/<ekran>-<tarih>/` altına yazılır ve git'e eklenmez. Test ortamında renkli emoji fontu yüklenemez;
emojiler kutu görünür (cihazda normal).

## Kampüs haritası harness'i

Gerçek jestlerle (sürükleme, iki parmakla kıstırma, dokunma) kampüs haritasını üç ekran boyunda (320×568, 390×844, 430×932) kare kare çeker: açılış, kaydırma, yakınlaştırma, en yakın zoom, köşeler, tamamı/odak geçişi, tesis penceresi, tesis listesi, binaya dokunuş.

```sh
flutter test --no-pub tool/preview_campus.dart --dart-define=PREVIEW_OUTPUT_ROOT=docs/verification
# Tek boyut: --dart-define=PREVIEW_ONLY=small|medium|large
```

Çıktı `docs/verification/campus-harness-<tarih>/<boyut>-<adım>.png` ve hepsini yan yana gösteren `<boyut>-sheet.png`. Kıstırmada her parmağa ayrı işaretçi numarası verilir (aynı numara tek parmak sayılır); kamera geçişinde testin animasyon saati dokunuştan sonraki ilk karede başlar.
