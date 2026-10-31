# Görsel istemleri

ChatGPT'ye verilen görsel görevleri. Kaynak görseller `design/art/` altına yazılır; uygulamaya
`tool/` altındaki içe alma aracıyla alınır (`assets/`e elle konmaz).

## 1. Sporcu portreleri ve yükseltme ikonları (2026-10-31)

Neden: sporcu yüzleri tasarım referansı ekran görüntüsünden 33–38 px kırpılmış (bulanık, köşelerinde
pist/zemin rengi). Uzun atlama ve halter ikonları ekran görüntüsünden kırpıldığı için beyaz kutulu ve
kenarları kesik. Okçuluk ve yüzme ikonları emoji. Kilit ve saat 45–57 px.

```text
Görev: Pawlympics adlı mobil spor oyunu için 24 görsel üret ve repoda aşağıdaki yollara kaydet.
Oyunda hayvan sporcular 6 branşta yarışıyor. Bu görseller sporcu kartlarında, pistteki yuvarlak
sporcu rozetlerinde, yükseltme satırlarındaki 48 pt'lik ikon kutularında ve başarım/günlük ödül
pencerelerinde görünecek. Telefonda 3x yoğunlukta net görünmeleri gerekiyor.

Önce bak (üslup referansı, aynısını tuttur):
- assets/images/ui-icons.png  → 256 px'lik ikon seti; özellikle sol üstteki çita portresi
  (sporcu portrelerinin üslubu bu olacak), dambıl, bayrak, ayakkabı.
- assets/images/nav-icons.png ve assets/images/equipment-icons.png → aynı ailenin diğer ikonları.
Yalnız içerik için bak (üslubunu ve kalitesini ALMA, bunlar bulanık ekran görüntüsü kırpıntısı):
- assets/images/reference.png içindeki pistte koşan 6 küçük hayvan yüzü → hayvanların renk kimliği.
- assets/images/jump-icons-source.png ve assets/images/weights-icons-source.png → alttaki 4'er
  ikonun neyi anlattığı.

Üslup kuralları:
- Oyunun mevcut ikon setiyle aynı: kalın koyu lacivert kontur (#14293F civarı), parlak doygun
  renkler, yumuşak iç gölge ve üstte küçük parlama, sevimli ve sade "mobil oyun ikonu" çizgisi.
- Zemin tamamen saydam (alfa kanalı). Arkada kutu, kart, daire, gölge ya da zemin rengi olmasın.
- Nesne kareyi ortalı doldursun (kenarlara ~6 % boşluk); hiçbir parça kesilmesin.
- Yazı, harf, rakam, logo, marka ve gerçek ürün benzerliği yok.
- Sporcu portreleri: önden bakan baş ve omuzların üstü, gülümseyen sevimli ifade, ui-icons'taki
  çita gibi mavi atlet (#2F7DE0 civarı) askıları görünsün. Baş genişliğin ~80 %'ini doldursun;
  pistte 30 pt'lik daire içinde de tanınmalı. Altısı aynı açı, aynı ışık, aynı ölçekte.

Liste (hedef yol → ne çizilecek):
Sporcu portreleri
- design/art/athletes/cheetah.png → Çita: turuncu-sarı, siyah benekli, beyaz ağız çevresi.
- design/art/athletes/raccoon.png → Rakun: gri, gözlerde siyah maske, beyaz yüz bölgeleri.
- design/art/athletes/bear.png → Ayı: kahverengi, açık kahve burun bölgesi, yuvarlak kulaklar.
- design/art/athletes/rabbit.png → Tavşan: açık pembe, uzun dik kulaklar (kulaklar kareye sığsın).
- design/art/athletes/turtle.png → Kaplumbağa: yeşil baş, arkada omuz hizasında kabuk kenarı.
- design/art/athletes/fox.png → Tilki: canlı turuncu, beyaz yanaklar ve çene, sivri kulaklar.
Uzun atlama yükseltmeleri
- design/art/upgrades/jump-start.png → hız çizgili kırmızı koşu ayakkabısı (Çıkış Hızı).
- design/art/upgrades/jump-steps.png → kırmızı pist parçası üstünde sıralı pati izleri (Adımlama).
- design/art/upgrades/jump-power.png → atlama tahtasından güçle sıçrayan benekli pati/bacak (Sıçrama Gücü).
- design/art/upgrades/jump-land.png → kumun sıçradığı iniş anı, kum fışkırması (İniş Tekniği).
Halter yükseltmeleri
- design/art/upgrades/weight-strength.png → mavi plakalı dambıl (Temel Güç).
- design/art/upgrades/weight-grip.png → halter barını kavrayan pati (Kavrama).
- design/art/upgrades/weight-balance.png → altın terazi (Denge).
- design/art/upgrades/weight-finish.png → patlama efektli kırmızı halter eldiveni (Son Hamle).
Okçuluk yükseltmeleri
- design/art/upgrades/archery-aim.png → tam ortasında ok saplı hedef tahtası (Nişan Alma).
- design/art/upgrades/archery-bow.png → gerilmiş, oku takılı ahşap yay (Yay Gücü).
- design/art/upgrades/archery-wind.png → kıvrımlı rüzgâr çizgileri ve savrulan yaprak (Rüzgâr Okuma).
- design/art/upgrades/archery-last.png → altın parıltılı tek ok, uçuşta (Son Atış).
Yüzme yükseltmeleri
- design/art/upgrades/swim-dive.png → su sıçratan çıkış bloğu (Çıkış Dalışı).
- design/art/upgrades/swim-paw.png → suyu yaran pati ve su sıçraması (Kulaç Gücü).
- design/art/upgrades/swim-breath.png → yüzücü gözlüğü ve yükselen hava kabarcıkları (Nefes Kontrolü).
- design/art/upgrades/swim-wave.png → kıvrılan mavi dalga (Su Direnci).
Arayüz
- design/art/ui/lock.png → gri-gümüş asma kilit (kilitli öğeler).
- design/art/ui/clock.png → sarı çalar saat (bilgi şeridi).

Teknik: PNG, RGBA (saydam zemin), 512×512. Daha büyük üretirsen sorun değil, ben küçültürüm.

Sınırlar: yalnız yukarıdaki 24 dosyayı yaz. Kod, assets/, pubspec.yaml, dokümanlar ve başka
dosyalara dokunma; commit ya da push yapma.

Tutarlılık: hepsi aynı kontur kalınlığı, ışık yönü (sol üstten), doygunluk ve çizgide olsun.
Bitince 24'ünü yan yana kontrol et; seriden kopan, kesik kadrajlı ya da arkasında zemin kalan
varsa yeniden üret.

Bitince: kaydettiğin dosyaların listesini ve yeniden üretilmesi gerektiğini düşündüklerini yaz.
```

İnceleme: (görseller gelince doldurulacak)
