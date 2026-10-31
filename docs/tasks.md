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
- [ ] **16. Görsel yenileme (58 görsel).** Denetim tablosu ve ChatGPT görevi: `docs/art-prompts.md` §1. Sporcu portreleri, 16 yükseltme ikonu, 6 branş ikonu, 3 çanta, 4 avatar çerçevesi, 16 başarım ikonu, kilit/saat/takvim/kupon, ok ve mesafe bayrağı, 100 m stadyumu. Görseller `design/art/` altına gelince `tool/import_art.py` yazılacak; yeni stadyumda 100 m pist geometrisi (`track.dart`) yeniden ölçülecek.

## Oynanış ve arayüz (cihaz testi, 2026-10-31)

- [x] **17. Zamanlama hamlesi.** İmleç çubukta durmadan sağa sola gidip geliyor (bir geçiş 0,7 sn), kusursuz bölge her hamlede çubuğun ortasına yakın başka bir yere düşüyor. Hamle açıkken stadyumun ve yarış şeridinin herhangi bir yerine dokunmak hamle sayılıyor (`PlayArea`). Halterde oyuncunun kaldırış penceresi 1,6 sn.
- [x] **18. Başlangıç ve bitiş çizgileri.** Konumlar arena görsellerinden ölçüldü (`lib/game/track.dart`). Engelli koşu %7,2 → %94, yüzme %7 → %93,8, engeller aynı eşlemeyle çiziliyor. 100 m: sporcular sağ üstteki kademeli başlangıç çizgilerinden çıkıp saat yönünün tersine koşuyor ve alt düzlükteki damalı çizgide bitiriyor (eskiden sağ virajda başlayıp tam tur atıyorlardı).
- [x] **19. Branş değiştirme tek elle.** Yarış şeridinde solda otomatik anahtarı, en sağda büyük branş düğmesi (44 pt). Başlıktaki branş etiketi yalnız gösterge.

Not alınan benzer iyileştirmeler:
- [ ] **20. Hamle paneli alt kulvarları örtüyor.** Engelli koşu ve yüzmede 5–6. kulvardaki sporcular panelin altında kalıyor; panel inceltilebilir ya da sahanın dışına (yarış şeridinin yerine) alınabilir.
- [ ] **21. 100 m pisti dar.** 4 kulvar 24 pt'lik avatarlara dar; başlangıçta sporcular üst üste biniyor. Avatar küçültülebilir ya da daha geniş kulvarlı pist görseli çizilebilir.
- [x] **22. Hamle açılınca haber ver.** Hamle yalnız görsel olarak açılıyor; otomatik yarışta göz başka yerdeyken kaçıyor. Açılışta kısa titreşim ve ses.
  - Çözüm: `offerMove` açılışta kısa ses ve titreşim veriyor; kusursuz dokunuşta daha güçlü titreşim.
- [ ] **23. Basılı tutunca art arda yükseltme.** İdle oyunlarda beklenen davranış; şu an her seviye için ayrı dokunuş gerekiyor.
- [ ] **24. Branşa göre uzman önerisi.** Tek takım lideri tüm branşlarda koşuyor; branş penceresinde her branşın uzmanını göster, branşa geçerken uzmana geçmeyi öner.
- [x] **25. Çevrimdışı gelir karşılaması.** Uzun aradan sonra kazanç yalnız bildirim olarak geçiyor; ayrı bir karşılama penceresi daha görünür olur.
  - Çözüm: "Tekrar Hoş Geldin" penceresi (süre, sayarak artan kazanç, 8 saat sınırı notu, Topla). Başka pencere açıksa bildirim olarak geçer.

## Kampüs haritası (duck-gacha Duck Park düzeni)

Mimari Duck Park'tan alındı: saf Dart dünya + kamera (`lib/game/campus_world.dart`), bileşensiz tek tuvale çizen Flame sahnesi (`lib/game/campus_game.dart`, sabit 30 Hz simülasyon), üstte Flutter katmanı (`lib/ui/campus/campus_viewport.dart`: jestler, ekran uzayında etiketler, düğmeler). Pencere açıkken, uygulama arka plandayken ya da sayfa görünmezken döngü durur.

- [x] **K1. Harita temeli.** Tam ekran harita; kaydırma, parmak altında sabit kalan kıstırarak yakınlaştırma, sınırlar ve kenar payı, tamamını göster düğmesi, son görünüm oturum boyunca saklı. Tesise ya da etiketine dokununca tesis penceresi. Geliştirilebilir tesislerin çevresinde nabız gibi atan altın çerçeve. Tesis listesi alttan açılan pencerede.
  - Harness incelemesi (2026-10-31, `tool/preview_campus.dart`): kenar boşlukları (harita kenarda aynalanıyor; paylar orman şeridi derinliğinde, nehir/tesis kopyası görünmüyor), açılışta ve düğmeyle haritanın tamamı, etiketler ekran kenarında sabitleniyor ve başlık/düğmelerin altına girince gizleniyor, etiketin üstünden başlayan kaydırma/kıstırma haritaya ulaşıyor, düğmeyle 320 ms kamera kayması (tamamı ↔ stadyum), geliştirilebilir tesiste seviye rozeti nabız atıyor (haritaya bindirilen ışık çizimi soldurduğu için kaldırıldı). Ortak `GameModal`'da 320 pt ekranda çökme düzeltildi (tüm pencereler).
  - Kalan: harita görseli 1024 px; telefonda genel görünümde bile hafif büyütülüyor, yakınlaştırınca yumuşuyor (K2'deki yüksek çözünürlüklü harita çözer).
- [ ] **K2. Duck Park sanat düzeni.** Binalar haritaya gömülü değil, ayrı çizimler olarak boş arsalara oturur; seviyeye göre görünüm değişebilir. Yakınlaştırınca net görünmesi için yüksek çözünürlüklü harita (ve gerekirse karolar). Gereken görseller: binasız kampüs zemini (aynı yol ve nehir düzeni, en az 2048×3072), 7 tesis için saydam bina çizimleri (seviye kademeleriyle). Yürünebilir alan maskesi yol renklerinden kodla çıkarılabilir.
- [ ] **K3. Yürüyen seyirciler.** Duck Park `ParkWalker` modeli: yol maskesi üzerinde hedef seçip yürüme, çarpışmadan kaçınma, binalarla derinlik sırası, dokununca tepki.
- [ ] **K4. Bina efektleri.** Binalarda canlı efektler (bayrak, havuzda su, ok atışı, tribün coşkusu) ve geliştirme kutlaması (bina sıçraması + toz, kamera tesise kayar; Duck Park `celebrateBuild`).
- [ ] **K5. Ortam.** Kenar bulutları, ortam parçacıkları, sesler, küçük ödüller.
