part of 'controller.dart';

/// Ekipman: en çok yıldız, yıldız başına parça ve çantaya dönen parça sayısı.
const maxStars = 5, partsPerStar = 5, partsPerChest = 10;

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
    final stars = state.equipmentStars[i].clamp(0, maxStars - 1);
    return (equipmentItems[i].base * const [1, 2.5, 6, 14, 30][stars]).round();
  }

  bool buyEquipment(int i, {bool useParts = false}) {
    if (i < 0 || i >= equipmentItems.length) return false;
    if (state.equipmentStars[i] >= maxStars) return false;
    final price = equipmentCost(i);
    if (useParts) {
      if (state.equipmentParts < partsPerStar) return false;
      state.equipmentParts -= partsPerStar;
    } else {
      if (state.money < price) return false;
      state.money -= price;
    }
    state.equipmentStars[i]++;
    gainXp(5);
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
      state.boostUntil = max(now, state.boostUntil) + boostMs;
      save();
      update();
      openPanel('inventory');
      toast('2x gelir 3 dakika uzatıldı!');
    }
  }

  /// Ekipmanı en üst yıldıza çıkmış ya da parçası birikmiş oyuncu için: parçalar çantaya döner.
  bool tradePartsForChest() {
    if (state.equipmentParts < partsPerChest) return false;
    state.equipmentParts -= partsPerChest;
    state.chests++;
    save();
    update();
    toast('$partsPerChest parça → 1 Spor Çantası');
    return true;
  }

  void pressTradeParts() {
    if (tradePartsForChest()) openPanel('inventory');
  }

  /// Antrenman kartını o branşın bir sonraki yarışı için hazırlar ya da hazırlığı geri alır.
  void toggleTrainingCard(String branch) {
    if (state.armedCards.remove(branch)) {
      toast('${branchLabel(branch)} kartı bekletiliyor.');
    } else if ((state.trainingCards[branch] ?? 0) > 0) {
      state.armedCards.add(branch);
      toast('🎫 ${branchLabel(branch)} kartı sonraki yarışta kullanılacak.');
    } else {
      return;
    }
    save();
    _changed();
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
