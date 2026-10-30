part of 'controller.dart';

/// chests.js: üç seçenekli spor çantaları ve antrenman kartları.
extension ChestLogic on GameController {
  ChestItem chestReward(String type) {
    final normal = type == 'normal';
    final pool = [
      ChestItem(kind: 'money', amount: normal ? 3500 : 6500, label: '₺${normal ? '3.500' : '6.500'}', icon: '💵'),
      ChestItem(kind: 'parts', amount: normal ? 2 : 4, label: '${normal ? 2 : 4} ekipman parçası', icon: '⚙️'),
      ChestItem(kind: 'card', amount: 1, branch: state.branch, label: '${branchLabel(state.branch)} antrenman kartı', icon: '🎫'),
      ChestItem(kind: 'boost', amount: 1, label: '2x gelir kuponu', icon: '⚡'),
      ChestItem(kind: 'gems', amount: normal ? 2 : 4, label: '${normal ? 2 : 4} elmas', icon: '💎'),
    ];
    if (!normal) pool.add(ChestItem(kind: 'cosmetic', index: _random.nextInt(cosmeticNames.length), icon: '✨'));
    final reward = pool[_random.nextInt(pool.length)];
    if (reward.kind == 'cosmetic') reward.label = cosmeticNames[reward.index!];
    return reward;
  }

  bool openChest([String type = 'normal']) {
    if (state.pendingChest != null) return true;
    final count = switch (type) {
      'normal' => state.chests,
      'cup' => state.cupChests,
      'champion' => state.championChests,
      _ => -1,
    };
    if (count < 1) return false;
    switch (type) {
      case 'normal':
        state.chests--;
      case 'cup':
        state.cupChests--;
      case 'champion':
        state.championChests--;
    }
    var offers = [chestReward(type), chestReward(type), chestReward(type)];
    if (type == 'cup') {
      offers = [
        for (var i = 0; i < 3; i++)
          () {
            final extra = chestReward('normal');
            return ChestItem(kind: 'bundle', amount: 2, extra: extra, label: '2 ekipman parçası + ${extra.label}', icon: '🏆');
          }(),
      ];
    }
    if (type == 'champion') {
      final missing = [
        for (var i = 0; i < cosmeticNames.length; i++)
          if (!state.cosmetics.contains(i)) i,
      ];
      offers = [
        for (var i = 0; i < 3; i++)
          missing.isNotEmpty
              ? ChestItem(
                  kind: 'cosmetic',
                  index: missing[i % missing.length],
                  label: cosmeticNames[missing[i % missing.length]],
                  icon: '✨',
                )
              : ChestItem(kind: 'parts', amount: 6, label: '6 ekipman parçası', icon: '⚙️'),
      ];
    }
    state.pendingChest = PendingChest(type, offers);
    save();
    return true;
  }

  void grantChestReward(ChestItem item) {
    if (item.kind == 'bundle') {
      state.equipmentParts += item.amount;
      grantChestReward(item.extra!);
      return;
    }
    switch (item.kind) {
      case 'money':
        state.money += item.amount;
      case 'gems':
        state.gems += item.amount;
      case 'parts':
        state.equipmentParts += item.amount;
      case 'boost':
        state.boostTokens += item.amount;
      case 'card':
        state.trainingCards[item.branch!] = (state.trainingCards[item.branch!] ?? 0) + item.amount;
      case 'cosmetic':
        if (state.cosmetics.contains(item.index)) {
          state.equipmentParts += 4;
          item.label = 'Tekrar: +4 ekipman parçası';
        } else {
          state.cosmetics.add(item.index!);
          state.selectedCosmetic = item.index!;
        }
    }
  }

  ChestItem? chooseChest(int index) {
    final pending = state.pendingChest;
    if (pending == null || index < 0 || index > 2) return null;
    final item = pending.offers[index];
    grantChestReward(item);
    state.pendingChest = null;
    save();
    update();
    toast('${item.icon} ${item.label} kazandın!');
    return item;
  }

  bool consumeTrainingCard(String branch) {
    if ((state.trainingCards[branch] ?? 0) <= 0) return false;
    state.trainingCards[branch] = state.trainingCards[branch]! - 1;
    save();
    toast('🎫 ${branchLabel(branch)} antrenman kartı kullanıldı!');
    return true;
  }

  void pressOpenChest(String type) {
    if (openChest(type)) openPanel('chests');
  }

  void pressChooseChest(int i) {
    final prize = chooseChest(i);
    if (prize != null) {
      activeModal = 'chests-result';
      panel('chests-result', 'Çanta Açıldı', arg: prize);
    }
  }
}
