# Oyun tasarımı görevleri

Oyun tasarımı incelemesinden (2026-10-31) çıkan sorunlar. Sırayla ele alınır; biten görev `[x]` olur.

> **Bekleyen karar:** Rakip gücü modeli (branş ligi / yarış sayısı / oyuncu gücü). Şimdilik "oyuncu gücüne göre" uygulandı (`lib/game/rivals.dart`); lig ya da olimpiyat hedefi (4. görevin kalan kısmı) bu karara bağlı, kullanıcıya sorulacak. Ödül formülü (5) şimdilik bu modele göre: güçlü takım güçlü rakibi yener, daha çok kazanır.

## Kritik: zorluk ve hedef

- [x] **1. Koşu branşlarında rakipler ölçeklensin.** 100 m'de Çita yükseltmesiz bile en hızlı rakipten hızlı (1.10 vs 1.08); rakip artışı 40 zaferde (+%12) duruyor. (`lib/game/running.dart` `beginRace`)
- [x] **2. Saha branşlarında rakipler ölçeklensin.** Uzun atlama, halter ve okçulukta rakipler hep 1. seviye değerlerle yarışıyor. (`longjump.dart`, `weights.dart`, `archery.dart`)
  - Çözüm (1–2): rakipler oyuncunun yükseltme/kampüs/ekipman düzeyini kullanıyor, koşu branşlarında herkese ±%6 form. Simülasyonda kazanma oranı 1. ve 30. seviyede aynı kalıyor (uzun atlama hariç, bkz. 3).
- [x] **3. Kayıt tavanları yükseltmeleri boşa çıkarmasın.** Uzun atlama 9,65/9,95 m'de, okçuluk 30 puanda tıkanıyor; sonrasında alınan yükseltme hiçbir şey değiştirmiyor.
  - Rakipler artık aynı seviyede olduğu için yüksek seviyede herkes 9,95 m'ye dayanıyor; eşitlikte ilk atlayan (oyuncu) kazanıyor → uzun atlama %100 zafer.
  - Çözüm: uzun atlamada tavan yok (30. sv ort. 12,5 m); kum havuzu turun en uzun atlayışına göre ölçekleniyor (`jumpSpan`). Okçulukta yükseltmeler "isabet" veriyor ve sapmayı daraltıyor: oklar 10'a giderek yaklaşıyor ama hiçbir seviyede garanti olmuyor (30. sv ort. 24, 100. sv 27,3 / 30). Eşitlikte X (tam merkez) sayısı, sonra merkeze toplam yakınlık belirliyor; eskiden eşitlik oyuncuyu öne alıyordu.
  - Not: uzun atlama ve koşu süreleri gerçekçi sınırları aşabilir (30. sv 12–14 m); idle "sayı büyüsün" hissi için bilinçli bırakıldı.
- [ ] **4. Uzun vadeli hedef.** İlerlemenin bir varış noktası yok (lig / olimpiyat hedefi); oyuncu seviyesi (Sv.) yalnızca görüntü.
  - Kısmen: oyuncu seviyesi artık ödül veriyor (her seviye +3 elmas, her 5. seviye Spor Çantası); seviye eğrisi artan (100 XP, sonra her seviye +25). Varış noktası (lig / olimpiyat) rakip modeli kararını bekliyor.

## Denge ve ekonomi

- [x] **5. Branş ödülleri eşit olsun.** Koşu, engelli ve yüzme ödülü yarış sayısıyla sınırsız artıyor (10 yarışta bir +%10); uzun atlama, halter ve okçulukta bu artış yok.
  - Çözüm: tek formül `raceReward`: sıra ödülü × branş gücü / 100 × kampüs sponsorluğu; yarış sayısı çarpanı kalktı.
- [x] **6. 100 m kolaylığı.** 4 sporcu var, 4 kişiden 3'ü madalya alıyor; kupa ("3 yarışta 2 madalya") neredeyse bedava.
  - Çözüm: madalya katılımcıların ilk yarısına veriliyor (`medalPlaces`: 4 sporcuda ilk 2, 6 sporcuda ilk 3); başarım, kupa, sonuç penceresi ve madalya rozeti aynı kuralı kullanıyor. Rakipler her yarışta rastgele seçiliyor; eskiden Çita hep en zayıf üçlüyle (Rakun, Ayı, Tavşan) koşuyordu, Tilki ve Kaplumbağa hiç gelmiyordu. Pist görselinde 4 kulvar olduğu için 6 sporcuya çıkılmadı.
  - Simülasyon (Çita, dokunuşsuz): madalya %100 → %90, kupa %96. Kusursuz çıkışla hâlâ %97 zafer: kalan kolaylığın kaynağı çıkış hamlesinin yarış boyu +%6'sı (8. görev) ve Çita'nın 100 m uzmanlığı (11. görev).
- [x] **7. Gelir yükseltmeleri görünür olsun.** Tribün ve Bilet yalnızca 100 m sekmesinde; başka branşta oynayan oyuncu görmüyor.
  - Çözüm: Tribün ve Bilet `incomeUpgrades` listesine taşındı; her branşın "GELİR" bölümünde 4 ve 5. dizinde görünüyor (seviyeler eski kayıtlarla uyumlu olarak `levels[4..5]`te).
- [x] **8. Zamanlama hamlesi branşlar arasında dengeli olsun.** Halter: garanti başarı; okçuluk: ok başına +2 puan; koşu: yarışın kalanında +%6 hız; uzun atlama: +%3,5 mesafe. Halterde iyi dokunan için "Rekor" modu risksiz, her zaman doğru seçim.
  - Simülasyon (Çita, kusursuz dokunuş): 100 m %95 zafer, halter %8–19, engelli/yüzme %20–28. Halterde Ayı'nın kilo çarpanı (×1,13) Çita'dan (×0,98) çok yüksek.
  - Çözüm: katsayılar `moveEffect` tablosunda. 100 m çıkışı yalnız ilk 25 m'yi hızlandırıyor (+%12), yüzme +%4, engelli +%6, uzun atlama +%3, okçuluk ok başına +0,7, halter başarı şansına +20 puan (garanti değil). Rekor modu ×1,10 kilo / −25 puan şans. Koşu formu ±%9. Simülasyonda kusursuz dokunuş her branşta zafere +8–15 puan ekliyor; Rekor modu daha çok zafer, daha az madalya veriyor.
- [x] **9. Ölü para birimleri.**
  - Elmas: tek harcama yeri "5 elmas → ₺10K", kısa sürede önemsizleşiyor.
  - Ekipman parçası: 12 yıldız dolunca işe yaramıyor; ekipman yalnızca koşu branşlarını etkiliyor.
  - 2x kuponu: 2x gelir her 90 saniyede bir zaten bedava, kuponun değeri yok; bedava 2x oyuncuyu sürekli dokunmaya zorluyor.
  - Çözüm: elmas: mağazada sponsor paketi (10 dk gelir, en az ₺10K), Spor Çantası (15) ve antrenman kartı (6). Ekipman en çok 5 yıldız, 10 parça → Spor Çantası. Bedava 2x: 3 dakika, 15 dakikada bir; kupon 3 dakika ekliyor.
- [x] **10. Antrenman kartı.** Otomatik harcanıyor, oyuncu ne zaman kullanacağını seçemiyor; etkisi yalnızca +%3.
  - Çözüm: kart oyuncu hazırlayınca harcanıyor (yarış şeridindeki KART düğmesi ya da Envanter > Eşyalar); etkisi +%5 (okçulukta oka +1,5).
- [x] **11. Hayvan seçimi.** Hayvanlar yalnızca bir yüzdeyle ayrılıyor; Ayı (+%1,5) her açıdan en kötüsü. Koşu branşlarındaki rakipler hayvan özelliklerini kullanmıyor, rastgele hız alıyor.
  - Rakiplerin hayvan özelliklerini kullanması 1. görevle çözüldü; geriye hayvan çeşitliliği kaldı.
  - Çözüm: genel hız üstünlüğü kalktı; her sporcu bir branşta uzman (+%6), birinde yardımcı (+%3), her branşın bir uzmanı ve bir yardımcısı var. Simülasyonda uzman dokunuşsuz %40–57, uzman olmayan %10–20 kazanıyor.
- [x] **12. İçerik.** Yalnızca 4 başarım var.
  - Çözüm: 16 başarım (kısa, orta, uzun vade); ödüller para + elmas + Şampiyon Çantası.

## Küçük şeyler

- [x] **13. Arka plandan dönüşte çevrimdışı gelir gösterilsin.** "Tekrar hoş geldin" bildirimi yalnızca soğuk açılışta çıkıyor (`controller.dart` `appVisible`).
  - Çözüm: `appVisible` 60 saniyeden uzun aradan sonra kazancı bildiriyor.
- [x] **14. Halterde başarısızlar sıralaması.** Başarısız olan herkes 6. sayılıyor, herkes başarısız olsa bile.
  - Çözüm: başarısız kaldırış başarılıların ardından sayılıyor (herkes başarısızsa ortak 1.); zafer, madalya, kupa ve sıra ödülü başarı istiyor.

## Görseller

- [x] **15. Ödül ikonları net olsun.** Elmas, bilet, madalya, para ve hediye panel ekran görüntülerinden kırpılmıştı (70–110 px, kenarları kesik). Oyunun 256 px'lik ikon setinden yeniden üretildi (`tool/hires_reward_icons.py`).
- [ ] **16. Sporcu portreleri ve yükseltme ikonları.** Sporcu yüzleri tasarım referansından 33–38 px kırpılmış (bulanık, köşelerde pist rengi); uzun atlama/halter ikonları beyaz kutulu ve kesik; okçuluk/yüzme ikonları emoji; kilit ve saat 45–57 px. ChatGPT görevi: `docs/art-prompts.md` §1. Görseller `design/art/` altına gelince içe alma aracı yazılacak.
