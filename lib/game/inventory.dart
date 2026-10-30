part of 'controller.dart';

/// Sporcu seçimi, ekipman, kamp, kupon ve kozmetikler.
extension InventoryLogic on GameController {
  void selectAnimal(int i) {
    if (race == null && i >= 0 && i < animals.length && state.races >= animals[i].unlock) {
      state.selected = i;
      runners();
      save();
      openPanel('inventory');
      toast('${animals[i].name} takım liderin oldu.');
    }
  }

  void setInventoryTab(String tab) {
    inventoryTab = tab;
    openPanel('inventory');
  }

  int equipmentCost(int i) {
    final stars = state.equipmentStars[i];
    return (equipmentItems[i].base * const [1, 2.5, 6, 6][stars]).round();
  }

  bool buyEquipment(int i, {bool useParts = false}) {
    if (i < 0 || i >= equipmentItems.length) return false;
    if (state.equipmentStars[i] >= 3) return false;
    final price = equipmentCost(i);
    if (useParts) {
      if (state.equipmentParts < 5) return false;
      state.equipmentParts -= 5;
    } else {
      if (state.money < price) return false;
      state.money -= price;
    }
    state.equipmentStars[i]++;
    state.xp += 5;
    save();
    update();
    toast('${equipmentItems[i].name} → ${state.equipmentStars[i]} yıldız');
    return true;
  }

  void pressEquipment(int i, {bool useParts = false}) {
    if (buyEquipment(i, useParts: useParts)) openPanel('inventory');
  }

  void useBoostToken() {
    if (state.boostTokens > 0) {
      state.boostTokens--;
      state.boostUntil = max(now, state.boostUntil) + 30000;
      save();
      update();
      openPanel('inventory');
      toast('2x gelir 30 saniye uzatıldı!');
    }
  }

  void selectCosmetic(int i) {
    if (state.cosmetics.contains(i)) {
      state.selectedCosmetic = i;
      save();
      runners();
      openPanel('cosmetics');
    }
  }
}
