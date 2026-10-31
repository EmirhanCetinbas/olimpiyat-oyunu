# Görsel istemleri

ChatGPT'ye verilen görsel görevleri. Kaynak görseller `design/art/` altına yazılır; uygulamaya
`tool/` altındaki içe alma aracıyla alınır (`assets/`e elle konmaz).

## 1. Görsel yenileme: denetim ve tek görev (2026-10-31)

Denetim (ekran önizlemeleri ve `assets/` tek tek incelendi):

| Grup | Sorun | Nerede görünüyor |
|---|---|---|
| Sporcu portreleri (6) | Tasarım referansı ekran görüntüsünden 33–38 px kırpıntı: bulanık, köşelerde pist rengi | Pistteki rozetler, Sporcular, başlık avatarı |
| Uzun atlama + halter ikonları (8) | Ekran görüntüsü kırpıntısı: beyaz kutulu, kenarları kesik | Yükseltme kartları, branş etiketi |
| Okçuluk + yüzme ikonları (8) | Emoji (testte kutu, cihazda sistem emojisi; üsluba uymuyor) | Yükseltme kartları, branş etiketi ve listesi |
| Branş ikonları (6) | Ayrı çizim yok, yükseltme ikonu ödünç: engelli koşuda hız göstergesi, yüzme/okçulukta emoji | Stadyum başlığı, yarış şeridi, Spor Branşları |
| Çanta türleri (3) | Üç çantada aynı hediye kutusu; Şampiyon çantası aynı kutunun soluk hali | Spor Çantaları, Mağaza, ödüller |
| Avatar çerçeveleri (4) | Kodla çizilmiş düz renkli halka | Avatar Çerçeveleri, pistteki oyuncu rozeti |
| Başarım ikonları (16) | 4 görsel 16 başarıya paylaştırılmış (Keskin Nişancı'da bilet gişesi); 107 px, kare zeminli sahne kırpıntısı | Başarımlar |
| Küçük arayüz ikonları (3) | Kilit 47 px, saat 45 px, takvim 144 px (3x'te bulanık) | Kilitli satırlar, bilgi şeridi, Günlük ödül |
| Saha parçaları (2) | Okçulukta uçan ok `➶` yazı karakteri, uzun atlamada mesafe bayrağı `⚑` karakteri | Okçuluk ve uzun atlama sahası |
| 2x gelir kuponu (1) | Ayrı ikon yok, para ikonu kullanılıyor | Eşyalar, çanta ödülü |
| 100 m stadyumu (1) | Diğer arenalardan farklı üslup: hayvan seyirci yerine renkli noktalar, çerçeve yok, uzak ve düz | 100 m sahası (oyunun ilk ekranı) |

İyi durumda (dokunulmayacak): `ui-icons.png`, `nav-icons.png`, `equipment-icons.png`, `weights-barbell.png`,
`hurdle-sprite.png`, ayar ikonları, para/elmas/bilet/hediye/madalya ödül ikonları, engelli/yüzme/uzun atlama/halter/
okçuluk arenaları. Kampüs haritası ayrı iş (görev K2: boş zemin + ayrı bina çizimleri). Çarkıfelek kodla çiziliyor,
yazılı dilimleri olduğu için kodda kalıyor.

Kaynaklar `design/art/` altına yazılır; uygulamaya `tool/import_art.py` ile alınır (görseller gelince yazılacak).
Seri uzun: ChatGPT gruplar halinde üretip her grubu yan yana kontrol etsin.

```text
Görev: Pawlympics adlı mobil spor oyununun bozuk, bulanık ya da eksik görsellerini yeniden üret ve
repoda aşağıdaki yollara kaydet. Oyunda hayvan sporcular 6 branşta (100 metre, engelli koşu, yüzme,
uzun atlama, halter, okçuluk) yarışıyor. Toplam 58 görsel: 57 saydam ikon/parça ve 1 arena. Telefonda
3x yoğunlukta net görünmeleri gerekiyor. Gruplar halinde çalış (A'dan I'ya); her grubu bitirince
yan yana kontrol et, sonra sonrakine geç.

Önce bak (üslup referansı, aynısını tuttur):
- assets/images/ui-icons.png → 256 px'lik ana ikon seti. Sol üstteki çita portresi sporcu portrelerinin,
  diğerleri (kupa, dambıl, bayrak, ayakkabı, bilet, madalya) ikonların üslubu.
- assets/images/nav-icons.png, assets/images/equipment-icons.png → aynı ailenin diğer ikonları.
- assets/images/rewards/gift.png, gem.png, medal.png, ticket.png, money.png → ödül ikonlarının üslubu.
- assets/images/hurdle-arena.png ve assets/images/swim-arena.png → arena üslubu (I grubu için).
Yalnız içerik için bak (üslubunu ve kalitesini ALMA, bunlar bulanık ekran görüntüsü kırpıntısı):
- assets/images/reference.png içindeki pistte koşan 6 küçük hayvan yüzü → hayvanların renk kimliği.
- assets/images/jump-icons-source.png ve assets/images/weights-icons-source.png → alttaki 4'er ikonun
  neyi anlattığı.
- assets/images/stadium.png → 100 m pistinin yerleşimi (I grubu).
- assets/images/rewards/ach-*.png → eski başarım görselleri (bunların yerine geçecekler).

Üslup kuralları (A–H):
- Mevcut ikon setiyle aynı: kalın koyu lacivert kontur (#14293F civarı), parlak doygun renkler, yumuşak
  iç gölge, üstte küçük parlama, sol üstten ışık; sevimli ve sade "mobil oyun ikonu" çizgisi.
- Zemin GERÇEKTEN saydam (alfa kanalı). Arkada kutu, kart, daire, gölge, zemin rengi ya da saydamlığı
  taklit eden gri-beyaz dama deseni olmasın. Kaydetmeden önce köşe piksellerinin saydam olduğunu kontrol et.
- Nesne kareyi ortalı doldursun (kenarlarda ~6 % boşluk); hiçbir parça kesilmesin.
- Yazı, harf, rakam, logo, marka ve gerçek ürün benzerliği yok ("2x", "100" gibi sayılar da yok).

A. Sporcu portreleri: önden bakan baş ve omuzların üstü, gülümseyen sevimli ifade, ui-icons'taki çita
   gibi mavi atlet (#2F7DE0 civarı) askıları görünsün. Baş genişliğin ~80 %'ini doldursun; pistte 30 pt'lik
   daire içinde de tanınmalı. Altısı aynı açı, ışık ve ölçekte.
- design/art/athletes/cheetah.png → Çita: turuncu-sarı, siyah benekli, beyaz ağız çevresi.
- design/art/athletes/raccoon.png → Rakun: gri, gözlerde siyah maske, beyaz yüz bölgeleri.
- design/art/athletes/bear.png → Ayı: kahverengi, açık kahve burun bölgesi, yuvarlak kulaklar.
- design/art/athletes/rabbit.png → Tavşan: açık pembe, uzun dik kulaklar (kulaklar kareye sığsın).
- design/art/athletes/turtle.png → Kaplumbağa: yeşil baş, arkada omuz hizasında kabuk kenarı.
- design/art/athletes/fox.png → Tilki: canlı turuncu, beyaz yanaklar ve çene, sivri kulaklar.

B. Yükseltme ikonları (kartlarda 52 pt kutuda; tek nesne, sade):
- design/art/upgrades/jump-start.png → hız çizgili kırmızı koşu ayakkabısı (Çıkış Hızı).
- design/art/upgrades/jump-steps.png → kırmızı pist parçası üstünde sıralı pati izleri (Adımlama).
- design/art/upgrades/jump-power.png → atlama tahtasından güçle sıçrayan benekli pati (Sıçrama Gücü).
- design/art/upgrades/jump-land.png → kuma iniş anı, kum fışkırması (İniş Tekniği).
- design/art/upgrades/weight-strength.png → mavi plakalı dambıl (Temel Güç).
- design/art/upgrades/weight-grip.png → halter barını kavrayan pati (Kavrama).
- design/art/upgrades/weight-balance.png → altın terazi (Denge).
- design/art/upgrades/weight-finish.png → patlama efektli kırmızı halter eldiveni (Son Hamle).
- design/art/upgrades/archery-aim.png → tam ortasında ok saplı hedef tahtası (Nişan Alma).
- design/art/upgrades/archery-bow.png → gerilmiş, oku takılı ahşap yay (Yay Gücü).
- design/art/upgrades/archery-wind.png → kıvrımlı rüzgâr çizgileri ve savrulan yaprak (Rüzgâr Okuma).
- design/art/upgrades/archery-last.png → altın parıltılı tek ok, uçuşta (Son Atış).
- design/art/upgrades/swim-dive.png → su sıçratan çıkış bloğu (Çıkış Dalışı).
- design/art/upgrades/swim-paw.png → suyu yaran pati ve su sıçraması (Kulaç Gücü).
- design/art/upgrades/swim-breath.png → yüzücü gözlüğü ve yükselen hava kabarcıkları (Nefes Kontrolü).
- design/art/upgrades/swim-wave.png → kıvrılan mavi dalga (Su Direnci).

C. Branş ikonları: yükseltme ikonlarından ayrılsın diye her biri kendi renginde yuvarlak bir rozetin
   (koyu lacivert kontur, üstte parlama) içinde spor sembolü. 24 pt'de de okunacak kadar sade.
- design/art/branches/sprint.png → kırmızı rozet, pist üstünde çıkış takozu ve hız çizgileri.
- design/art/branches/hurdles.png → turuncu rozet, mavi-beyaz çizgili tek engel (hurdle-sprite.png gibi).
- design/art/branches/swim.png → mavi rozet, kulvar ipi ve su sıçraması.
- design/art/branches/longjump.png → kum rengi rozet, kum havuzu ve havada pati izi yayı.
- design/art/branches/weights.png → mor rozet, mavi plakalı halter barı (weights-barbell.png gibi).
- design/art/branches/archery.png → yeşil rozet, ok saplanmış hedef.

D. Çanta türleri (çantayı açma penceresinde 62 pt; üçü aynı açı ve boyutta, açıkça kademeli):
- design/art/chests/normal.png → Spor Çantası: yeşil-turuncu spor çantası (duffel), önünde yıldız arması.
- design/art/chests/cup.png → Kupa Çantası: kırmızı, altın şeritli çanta, önünde küçük kupa arması.
- design/art/chests/champion.png → Şampiyon Çantası: mor-altın gösterişli çanta, üstünde taç, etrafında parıltı.
  (Alt menüdeki mavi sırt çantasına, assets/images/nav-icons.png'nin ilk ikonuna benzemesin.)

E. Avatar çerçeveleri: yuvarlak sporcu yüzünün etrafına oturan süslü halka. Ortası tamamen saydam
   bir daire (çapı genişliğin ~68 %'i); süs yalnız halkanın üstünde, iç daireye taşmasın.
- design/art/frames/gold.png → Altın Çerçeve: parlak altın halka, küçük perçinler.
- design/art/frames/lightning.png → Mavi Şimşek Çerçeve: mavi halka, iki yanda sarı şimşekler.
- design/art/frames/star.png → Yıldız Çerçeve: mor halka, üstünde ve yanlarda altın yıldızlar.
- design/art/frames/paw.png → Pati Çerçeve: pembe halka, üstüne dizili beyaz pati izleri.

F. Başarım ikonları (başarım satırında 56 pt; madalyon/rozet hissi, her biri farklı ve anlamlı):
- design/art/achievements/first.png → İlk Yarış: damalı bayrak ve tek yıldız.
- design/art/achievements/fast-paws.png → Hızlı Patiler: hız çizgili koşan pati.
- design/art/achievements/full-stand.png → Dolu Tribün: hayvan seyircilerle dolu küçük tribün.
- design/art/achievements/ticket-office.png → Bilet Gişesi: çizgili tenteli bilet gişesi.
- design/art/achievements/first-cup.png → İlk Kupa: küçük altın kupa, tek yıldız.
- design/art/achievements/races-25.png → Antrenman Temposu: kronometre ve koşu ayakkabısı.
- design/art/achievements/full-team.png → Tam Kadro: yan yana altı küçük hayvan başı (çita, rakun, ayı,
  tavşan, kaplumbağa, tilki).
- design/art/achievements/medals-25.png → Madalya Koleksiyonu: üst üste altın, gümüş, bronz madalyalar.
- design/art/achievements/campus-10.png → Kampüs Yatırımcısı: küçük stadyum binası ve yükselen ok.
- design/art/achievements/level-10.png → Deneyimli Takım: yıldızlı rütbe nişanı (şeritli).
- design/art/achievements/wins-50.png → Zafer Serisi: defne yapraklı altın kupa.
- design/art/achievements/cups-5.png → Kupa Avcısı: yan yana üç kupa.
- design/art/achievements/full-gear.png → Tam Teçhizat: atlet forması, ayakkabı ve bileklik yığını,
  üstünde yıldızlar.
- design/art/achievements/archer.png → Keskin Nişancı: tam ortadan vurulmuş hedef, parıltı.
- design/art/achievements/races-250.png → Maraton Ruhu: kanatlı koşu ayakkabısı.
- design/art/achievements/wins-250.png → Efsane Patiler: taçlı, defne yapraklı büyük altın kupa ve pati arması.

G. Küçük arayüz ikonları ve eşya:
- design/art/ui/lock.png → gri-gümüş asma kilit (kilitli öğeler).
- design/art/ui/clock.png → sarı çalar saat (bilgi şeridi).
- design/art/ui/calendar.png → kırmızı halkalı masa takvimi, önünde küçük hediye (Günlük ödül).
- design/art/ui/boost.png → 2x gelir kuponu: sarı-mavi kupon bilet, üstünde şimşek (rakam yok).

H. Saha parçaları (sahada küçük çizilir; sade ve net kontur):
- design/art/field/arrow.png → altın uçlu, kırmızı tüylü ahşap ok; YATAY, sivri ucu sağa bakıyor,
  kareyi enine dolduruyor.
- design/art/field/flag.png → mesafe bayrağı: ince direk ve BEYAZ bez (kod rengini verir), bez sağa dalgalı.

I. 100 m stadyumu (oyunun ilk ekranı; diğer arenalarla aynı aileden görünmeli):
- design/art/arenas/stadium.png → 1536×1024, saydamlık YOK. assets/images/hurdle-arena.png'deki
  tribün üslubunu kullan: üstte hayvan seyircili, bayraklı tribün, ortada merdiven; aynı koyu yuvarlak
  çerçeve. Altında assets/images/stadium.png'deki gibi kuşbakışı oval pist: 4 kırmızı kulvar, beyaz
  kulvar çizgileri, sağ üst virajda kademeli başlangıç çizgileri (dış kulvar önde), alt düzlüğün
  ortasında damalı bitiş çizgisi; pistin ortası çim. Pist resmin alt ~75 %'ini kaplasın, köşelerde çadır,
  ışık direği, bank gibi küçük süsler. Kulvarlar düzgün ve simetrik olsun (sporcu konumları bunlardan
  ölçülecek). Yazı, logo ve rakam yok.

Teknik: PNG. A–H: RGBA (saydam zemin), 512×512 (büyük üretirsen sorun değil, ben küçültürüm).
I: RGB, 1536×1024.

Sınırlar: yalnız yukarıdaki 58 dosyayı yaz. Kod, assets/, pubspec.yaml, dokümanlar ve başka dosyalara
dokunma; mevcut dosyaların üzerine yazma; commit ya da push yapma.

Tutarlılık: hepsi aynı kontur kalınlığı, ışık yönü (sol üstten), doygunluk ve çizgide olsun. Her grubu
bitirince yan yana kontrol et; seriden kopan, kesik kadrajlı, arkasında zemin ya da dama deseni kalan
varsa yeniden üret.

Bitince: kaydettiğin dosyaların listesini ve yeniden üretilmesi gerektiğini düşündüklerini yaz.
```

İnceleme (ilk teslim, 2026-10-31): ChatGPT görselleri büyük tabakalar halinde üretip 512 px'lik karelere kesti.
- Alındı: branş ikonları (6), sporcu portreleri (6), yükseltme ikonları (16), takvim, kupon, 100 m stadyumu.
  Sporcu ve yükseltme dosyaları istem sırasıyla üretilip alfabetik adlarla kaydedilmişti; `tool/import_art.py`
  içindeki `KAYNAK_ADI` tablosu dosyayı içeriğine eşler ve kenara değen komşu parçalarını siler.
  Stadyum aynı yerleşimde (kademeli başlangıç sağ virajda, bitiş alt düzlükte); pist ölçüleri yeniden alındı.
  Üslubu diğer arenalardan daha resimsi ama tribün ve seyirciler ailede.
- Kullanılamadı (kesik, komşu görselle karışık): çantalar (3), avatar çerçeveleri (4), başarım ikonları (16),
  ok ve bayrak, kilit ve saat (altı kesik). Yeniden istendi: §2.

## 2. Yeniden üretim: kesik gelen 27 görsel (2026-10-31)

```text
Görev: Pawlympics görsel teslimindeki 27 dosya kullanılamadı: görseller büyük bir tabakada üretilip
512 px'lik karelere kesildiği için nesneler kesik, karelerde komşu görselin parçaları var ve bazı
dosyaların içeriği adıyla uyuşmuyor. Aşağıdaki 27 dosyayı yeniden üret ve aynı yollara kaydet
(bu 27 dosyanın üzerine yazabilirsin).

En önemli kural: HER GÖRSELİ AYRI ÜRET. Tabaka, ızgara ya da kolaj üretip kesme. Her dosya kendi
tuvalinde tek bir nesne; nesnenin tamamı tuvalin içinde, dört kenarda da en az %6 boş saydam pay.
Kaydetmeden önce her dosyayı aç ve kontrol et: içerik dosya adıyla aynı mı, nesne kesik mi, kenarda
başka bir şeyin parçası var mı.

Önce bak:
- design/art/branches/*.png ve design/art/upgrades/*.png → ilk teslimden kabul edilen ikonlar; üslup,
  kontur ve ışık bunlarla aynı olsun.
- assets/images/ui-icons.png, assets/images/rewards/gift.png, medal.png → oyunun ikon ailesi.
- docs/art-prompts.md §1 → üslup kuralları ve aşağıdaki görsellerin ayrıntılı tarifleri (D, E, F, G, H).

Üslup: kalın koyu lacivert kontur (#14293F civarı), parlak doygun renkler, yumuşak iç gölge, üstte küçük
parlama, sol üstten ışık. Zemin gerçekten saydam (alfa); kutu, daire, gölge ya da dama deseni yok.
Yazı, harf, rakam, logo, marka yok.

Liste:
Çantalar (üçü aynı açı ve boyutta, açıkça kademeli; alt menüdeki mavi sırt çantasına benzemesin)
- design/art/chests/normal.png → Spor Çantası: yeşil-turuncu spor çantası, önünde yıldız arması.
- design/art/chests/cup.png → Kupa Çantası: kırmızı, altın şeritli çanta, önünde küçük kupa arması.
- design/art/chests/champion.png → Şampiyon Çantası: mor-altın gösterişli çanta, üstünde taç, parıltı.
Avatar çerçeveleri (yuvarlak yüzün etrafına oturan halka; ortası tamamen saydam daire, çapı genişliğin
~68 %'i; süs iç daireye taşmasın; halka tuvalin ortasında ve tamamı görünür)
- design/art/frames/gold.png → parlak altın halka, küçük perçinler.
- design/art/frames/lightning.png → mavi halka, iki yanda sarı şimşekler.
- design/art/frames/star.png → mor halka, üstünde ve yanlarda altın yıldızlar.
- design/art/frames/paw.png → pembe halka, üstüne dizili beyaz pati izleri.
Başarım ikonları (madalyon/rozet hissi, her biri farklı)
- design/art/achievements/first.png → damalı bayrak ve tek yıldız.
- design/art/achievements/fast-paws.png → hız çizgili koşan pati.
- design/art/achievements/full-stand.png → hayvan seyircilerle dolu küçük tribün.
- design/art/achievements/ticket-office.png → çizgili tenteli bilet gişesi.
- design/art/achievements/first-cup.png → küçük altın kupa, tek yıldız.
- design/art/achievements/races-25.png → kronometre ve koşu ayakkabısı.
- design/art/achievements/full-team.png → yan yana altı küçük hayvan başı (çita, rakun, ayı, tavşan,
  kaplumbağa, tilki); design/art/athletes/ altındaki portrelerle aynı hayvanlar.
- design/art/achievements/medals-25.png → üst üste altın, gümüş, bronz madalyalar.
- design/art/achievements/campus-10.png → küçük stadyum binası ve yükselen ok.
- design/art/achievements/level-10.png → yıldızlı rütbe nişanı (şeritli).
- design/art/achievements/wins-50.png → defne yapraklı altın kupa.
- design/art/achievements/cups-5.png → yan yana üç kupa.
- design/art/achievements/full-gear.png → atlet forması, ayakkabı ve bileklik yığını, üstünde yıldızlar.
- design/art/achievements/archer.png → tam ortadan vurulmuş hedef, parıltı.
- design/art/achievements/races-250.png → kanatlı koşu ayakkabısı.
- design/art/achievements/wins-250.png → taçlı, defne yapraklı büyük altın kupa ve pati arması.
Arayüz
- design/art/ui/lock.png → gri-gümüş asma kilit (tamamı görünür, altı kesik olmasın).
- design/art/ui/clock.png → sarı çalar saat (ayakları dahil tamamı görünür).
Saha parçaları
- design/art/field/arrow.png → altın uçlu, kırmızı tüylü ahşap ok; YATAY, ucu sağa; ok tek parça ve
  tamamı bu dosyada (uç da tüyler de).
- design/art/field/flag.png → mesafe bayrağı: ince direk ve BEYAZ bez, bez sağa dalgalı; yalnız bayrak.

Teknik: PNG, RGBA (saydam zemin), 512×512.

Sınırlar: yalnız bu 27 dosyayı yaz. design/art altındaki diğer dosyalara, koda, assets/, pubspec.yaml ve
dokümanlara dokunma; commit ya da push yapma.

Bitince: kaydettiğin dosyaların listesini, her birini açıp kontrol ettiğini ve yeniden üretilmesi gerektiğini
düşündüklerini yaz.
```

İnceleme (2026-11-01): 27 dosyanın hepsi ayrı üretilmiş; kesik ya da komşu parçası yok, adlar içerikle uyuşuyor.
Alındı: çantalar (`rewards/chest-<tür>.png`), başarım ikonları (`rewards/ach-<id>.png`, her başarının kendi ikonu),
kilit ve saat, avatar çerçeveleri (`art/frames/`, deliğe ortalanır; `AvatarFrame`), ok ve mesafe bayrağı (`art/field/`).
