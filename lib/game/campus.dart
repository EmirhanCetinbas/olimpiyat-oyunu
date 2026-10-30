part of 'controller.dart';

/// campus.js: kalıcı SP geliştirmeleri.
extension CampusLogic on GameController {
  CampusFacility? facility(String id) => campusFacilities.where((f) => f.id == id).firstOrNull;

  /// Tesiste SP'nin yettiği, tavana ulaşmamış bir kademe var mı.
  bool canUpgradeFacility(String id) {
    final f = facility(id);
    return f != null && !f.locked && [0, 1, 2].any((i) => campusRank(id, i) < 5 && state.skillPoints >= campusCost(id, i));
  }

  int campusCost(String id, int i) => facility(id)!.rows[i].base + campusRank(id, i);

  /// Tesis seviyesi: 1 + üç kademenin toplamı.
  int facilityLevel(String id) => 1 + [0, 1, 2].fold(0, (n, i) => n + campusRank(id, i));

  bool buyCampusUpgrade(String id, int i) {
    final f = facility(id);
    if (f == null || f.locked || i < 0 || i >= 3 || campusRank(id, i) >= 5) return false;
    final price = campusCost(id, i);
    if (state.skillPoints < price) return false;
    state.skillPoints -= price;
    state.campusUpgrades.putIfAbsent(id, () => [0, 0, 0]);
    state.campusUpgrades[id]![i]++;
    save();
    update();
    return true;
  }

  void openCampus() {
    modal = null;
    campusOpen = true;
    campusDialogOpen = false;
  }

  void closeCampus() {
    campusOpen = false;
    campusDialogOpen = false;
    navSelected = 1;
    _changed();
  }

  void showCampusFacility(String id) {
    if (facility(id) == null) return;
    campusSelection = id;
    campusDialogOpen = true;
    _changed();
  }

  void closeCampusDialog() {
    campusDialogOpen = false;
    _changed();
  }

  void pressCampusBuy(int i) {
    if (buyCampusUpgrade(campusSelection, i)) {
      beep(880);
      toast('Kalıcı geliştirme alındı!');
    }
  }
}
