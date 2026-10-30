# Pati Şampiyonları proje kuralları

## Tek görsel kontrol / tek etkileşimli kontrol
- Referans görseldeki slider, anahtar, düğme, kilit, tik, sayaç veya ilerleme çubuğunun üzerine ikinci bir görünür kontrol bindirme.
- Dinamik bileşeni HTML ile çizerken görsele gömülü karşılığını tüm sınırları, gölgesi ve hareketli başlığıyla beraber kaldır veya maskele. Maske kontrol durumundan bağımsız olmalı.
- Statik görsel düğmeler için yalnızca şeffaf ve erişilebilir tıklama alanı kullan; ikinci kenarlık, metin veya ikon çizme.
- Değişen değerler ve ilerleme tek gerçek oyun durumundan gelsin. Referanstaki örnek sayıları canlı veri gibi gösterme.
- Her değişiklikte bütün görsel tabanlı panelleri denetle: Ayarlar, Günlük Ödül, Başarımlar ve eklenen paneller.
- Slider uçlarını ve orta konumunu; anahtarların açık/kapalı durumlarını; ödüllerin kilitli/alınabilir/alındı durumlarını kontrol et.
- Mobil ve masaüstü ekran görüntülerinde çift kontrol, eski başlık/ikon kalıntısı, taşma ve örtüşme kontrolü yap. Tarayıcı doğrulaması yapılamadıysa tamamlandı diye belirtme.
- Kontroller klavye ile kullanılabilmeli, erişilebilir isimleri olmalı ve ayarlar kaydedilmeli.

## Ayarlar modalı: kodla oluşturulan arayüz
- Ayarlar modalının tamamını HTML/CSS bileşenleriyle oluştur. Referans görsel yalnızca tasarım rehberidir.
- Tam modal ekran görüntüsü, görsel üzerine koordinatla kontrol yapıştırma veya görsele gömülü kontrolü maskeleyerek çözme yaklaşımını Ayarlar'da kullanma.
- Başlık, panel, satırlar, yazılar, slider, anahtar ve düğmeler bağımsız kod bileşenleri olmalı. Normal grid/flex akışı kullan.
- İkonlar ayrı küçük bileşenler/assetler olabilir; tüm paneli tek görsel olarak yükleme.
- iOS ekran görüntüsünde başlık konturu harfleri bozuyorsa kalın text-stroke ile gölgeyi üst üste kullanma. Anahtar metni ve hareketli düğme ayrı alanlarda olmalı.
- Standart telefon boyutunda alt eylemler ve sürüm satırı görünmeli; düşük yükseklikte erişilebilir kaydırma korunmalı.

## Kampüs
- Harita yalnızca arazi/bina çizimini içerir. Başlık, SP sayacı, bina etiketleri ve yükseltme modalları kod bileşenleridir.
- Bina tıklama bölgeleri ve etiketler haritanın kendi en-boy oranına göre yerleşir; ekran yüksekliğiyle koordinatları kaydırma.
- SP: ilk kurulum/geçişte 8; her 5 tamamlanmış yarışta 1. Yükseltmeler 5 kademe; maliyet başlangıç maliyeti + mevcut kademe.
- Oynanabilir dallar 100 metre ve ortak Stadyum bonuslarıdır. Gelecek branşlarda önizleme açılır, SP harcanamaz.
- Yarış hız bonusunu yarış başında sabitle; aktif yarış sırasında yapılan yükseltmeler sonraki yarışta geçerlidir.

## Uzun atlama
- Tek kulvarlı sahne yalnızca pist, kum havuzu, tribün ve boş bank içerir. Avatar, bayrak ve sayaç görsele gömülmez.
- Sporcular yalnızca yuvarlak yüz avatarlarıdır; aynı anda yalnızca bir sporcu banktan ayrılır.
- Altı sporcu sırayla yaklaşma, sıçrama, iniş ve banka dönüşü tamamlar. Bayrak ancak inişte oluşur ve yeni tur başlayana kadar kalır.
- Mesafe, iniş noktası ve bayrak aynı tur verisinden gelir; sonuçlar en uzun mesafeye göre sıralanır. Mesafe rekoru süre rekorundan ayrı saklanır.
- Çıkış Hızı, Adımlama, Sıçrama Gücü ve İniş Tekniği seviyeleri tur başında sabitlenir; tur içindeki alışveriş sonraki turu etkiler.

## Halter
- Arka plan yalnızca platform, tribün ve boş bank içerir; hareketli halter, yuvarlak avatarlar, kilogram ve başarı durumu ayrı bileşenlerdir.
- Altı sporcu sırayla platforma gelir, kaldırış yapar ve bankına döner. Tek turda yalnızca bir sporcu hareket eder.
- Temel Güç ile Son Hamle hedef kiloyu; Kavrama ve Denge başarı şansını etkiler. Başarı şansı en fazla %98 olur.
- Sonuç ve kilogram aynı tur başı verisinden gelir. Yükseltmeler sonraki turda geçerlidir; halter rekoru yalnızca başarılı kaldırıştan ve diğer branş rekorlarından ayrı kaydedilir.

## Okçuluk
- Sahne sadece altı kulvar, altı hedef, tribün ve boş bank içerir. Yuvarlak yüz avatarları, ok, puan ve kontroller ayrı canlı bileşenlerdir.
- Sporcular sırayla çizgiye gelip üç atış yapar; toplam 30 puan üzerinden sıralanır. Oyuncu nişan zamanlamasıyla küçük avantaj kazanabilir. Yükseltme seviyeleri tur başında sabitlenir; rekor diğer branşlardan ayrı saklanır.

## Yarış kararları ve kupa
- Zamanlama düğmesi canlı kod bileşenidir; kaçırmak yarışı durdurmaz. Koşu ve yüzmede hız, uzun atlamada mesafe, halterde başarı ve okçulukta isabet için sınırlı bir etki verir.
- Halterde güvenli kilo / rekor denemesi seçimi yarış başında sabitlenir. Rekor denemesi daha ağırdır ve başarı şansını azaltır.
- Üç yarışlık kupa seçili branşta iki madalya ister. Ödül, aynı yarış tamamlandığında bir kez verilir; ilerleme yerel kayda dahil edilir.
- Oynanabilen branşların kampüs binaları da geliştirilebilir; bonuslar yarış başında sabitlenir.

## Spor Çantaları
- Her 5 yarışta normal, başarılı üç yarışlık kupada Kupa, belirli başarımda Şampiyon Çantası ver. Açılışta üç kapalı seçenek sun ve yalnızca seçileni ver.
- Sandık tüketimi ve üç hazır seçenek seçim yapılmadan kaydedilir. Modal kapansa veya oyun yeniden açılsa seçim kaybolmaz; ödül bir kez verilir.
- Kupa seçeneklerinin hepsinde ekipman parçası, Şampiyon seçeneklerinin hepsinde varsa yeni kozmetik bulunur. Kozmetiklerin hepsi açıksa parça verir. Tekrar kozmetik de parçaya dönüşür.
- Beş ekipman parçası bir yıldız yükseltmesine harcanır; antrenman kartı yalnızca ilgili branşta yarış başında bir kez tüketilir. Canlı arayüzde ödülleri görsel üzerine yapıştırma.
