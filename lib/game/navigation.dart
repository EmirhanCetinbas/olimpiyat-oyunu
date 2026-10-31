part of 'controller.dart';

enum ModalStyle { normal, reward, settings }

class ModalSpec {
  const ModalSpec(this.key, this.title, {this.style = ModalStyle.normal, this.arg});
  final String key;
  final String title;
  final ModalStyle style;
  final Object? arg;
}

/// Pencere, menü ve sekme gezintisi (openPanel / panel).
extension NavigationLogic on GameController {
  void rewardsMenu(bool open) {
    rewardsOpen = open;
    _changed();
  }

  void selectNav(int index) {
    navSelected = index;
    _changed();
  }

  /// `data-open` düğmeleri.
  void open(String key, {int? navIndex}) {
    if (navIndex != null) selectNav(navIndex);
    beep(620, .04);
    openPanel(key);
  }

  void openPanel(String key) {
    rewardsMenu(false);
    activeModal = key;
    switch (key) {
      case 'race':
        modal = null;
      case 'profile':
        modal = const ModalSpec('profile', 'Profil');
      case 'inventory':
        modal = const ModalSpec('inventory', 'Envanter');
      case 'chests':
        modal = const ModalSpec('chests', 'Spor Çantaları');
      case 'cosmetics':
        modal = const ModalSpec('cosmetics', 'Avatar Çerçeveleri');
      case 'campus':
        openCampus();
      case 'achievements':
        modal = const ModalSpec('achievements', 'Başarımlar', style: ModalStyle.reward);
      case 'daily-rewards':
        modal = const ModalSpec('daily-rewards', 'Günlük Ödül', style: ModalStyle.reward);
      case 'wheel':
        modal = const ModalSpec('wheel', 'Çarkıfelek', style: ModalStyle.reward);
      case 'settings':
        modal = const ModalSpec('settings', 'Ayarlar', style: ModalStyle.settings);
      case 'team':
        // Sporcular tek yerde: Envanter > Sporcular.
        inventoryTab = 'athletes';
        openPanel('inventory');
      case 'tournament':
        modal = const ModalSpec('tournament', 'Üç Yarışlık Kupa');
      case 'equipment':
        inventoryTab = 'equipment';
        openPanel('inventory');
      case 'shop':
        modal = const ModalSpec('shop', 'Mağaza');
      case 'branches':
        modal = const ModalSpec('branches', 'Spor Branşları');
    }
    _changed();
  }

  /// `panel()` ile açılan, activeModal'ı değiştirmeyen pencereler.
  void panel(String key, String title, {Object? arg}) {
    modal = ModalSpec(key, title, arg: arg);
    _changed();
  }

  /// Yarış sonucu: otomatik yarışta kısa bildirim, değilse sonuç penceresi.
  void presentResult(RaceResult r, String summary) {
    lastResult = r;
    if (state.auto) {
      toast(summary);
      return;
    }
    final title = !r.success
        ? 'Başarısız'
        : r.place == 1
        ? 'Zafer!'
        : r.medal
        ? 'Madalya!'
        : 'Yarış bitti';
    panel('result', title, arg: r);
  }

  /// Sonuç penceresinden yeni yarış.
  void raceAgain() {
    closeModal();
    beginRace();
  }

  void closeModal() {
    modal = null;
    _changed();
  }

  /// Yükseltme açıklaması: pencere açmadan kısa bildirim.
  void showInfo(int i) => toast('${upgradeDef(i).title}: ${upgradeDef(i).desc}');

  /// Uzun aradan dönüşte kazancı gösteren pencere; başka pencere açıksa kısa bildirim.
  void showWelcome(int earned, double seconds) {
    if (modal != null) {
      toast('Tekrar hoş geldin! Çevrimdışı gelir: ₺${fmt(earned)}');
      return;
    }
    modal = ModalSpec('welcome', 'Tekrar Hoş Geldin', style: ModalStyle.reward, arg: OfflineEarnings(earned, seconds));
    _changed();
  }

  /// Karşılama penceresini kapatır (kazanç açılışta zaten eklendi).
  void collectWelcome() {
    beep(880, .12);
    closeModal();
  }

  void openSupport() => panel('support', 'Destek');
  void askReset() => panel('reset', 'Sıfırlansın mı?');
}
