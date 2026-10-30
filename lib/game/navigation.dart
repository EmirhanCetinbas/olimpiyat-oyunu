part of 'controller.dart';

enum ModalStyle { normal, reward, exactAchievements, exactDaily, settings }

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
        modal = const ModalSpec('achievements', 'Başarımlar', style: ModalStyle.exactAchievements);
      case 'daily-rewards':
        modal = const ModalSpec('daily-rewards', 'Günlük Ödül', style: ModalStyle.exactDaily);
      case 'wheel':
        modal = const ModalSpec('wheel', 'Çarkıfelek', style: ModalStyle.reward);
      case 'settings':
        modal = const ModalSpec('settings', 'Ayarlar', style: ModalStyle.settings);
      case 'team':
        modal = const ModalSpec('team', 'Hayvan Takımın');
      case 'league':
        modal = const ModalSpec('league', 'Çaylaklar Ligi');
      case 'tournament':
        modal = const ModalSpec('tournament', 'Üç Yarışlık Kupa');
      case 'equipment':
        inventoryTab = 'equipment';
        openPanel('inventory');
      case 'camp':
        modal = const ModalSpec('camp', 'Antrenman Kampı');
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

  void closeModal() {
    modal = null;
    _changed();
  }

  void showInfo(int i) => panel('info', activeUpgrades[i].title, arg: i);

  void openSupport() => panel('support', 'Destek');
  void askReset() => panel('reset', 'İlerleme sıfırlansın mı?');
}
