part of 'controller.dart';

/// Mağaza fiyatları (elmas).
const shopPrices = {'coins': 5, 'chest': 15, 'card': 6};

/// Seviye atlama ödülü (elmas).
const levelGems = 3;

/// Başarımlar, günlük ödül, çark ve mağaza.
extension RewardsLogic on GameController {
  void claimAchievement(String id) {
    final a = achievements.where((x) => x.id == id).firstOrNull;
    if (a != null && a.done(state) && !state.claims.contains(a.id)) {
      state.claims.add(a.id);
      state.money += a.reward;
      state.gems += a.gems;
      if (a.chest) state.championChests++;
      save();
      update();
      openPanel('achievements');
      toast('Başarım ödülü alındı!');
    }
  }

  /// Deneyim ekler. Her yeni seviye [levelGems] elmas, her 5. seviye ayrıca bir Spor Çantası verir.
  /// Bildirim, yarış sonucu bildirimini ezmesin diye biraz sonra gösterilir.
  void gainXp(int amount) {
    final before = level;
    state.xp += amount;
    if (level == before) return;
    var chests = 0;
    for (var l = before + 1; l <= level; l++) {
      state.gems += levelGems;
      if (l % 5 == 0) chests++;
    }
    state.chests += chests;
    final text = '⭐ Seviye $level! +${levelGems * (level - before)} elmas${chests > 0 ? ' · +$chests Spor Çantası' : ''}';
    _levelTimer?.cancel();
    _levelTimer = Timer(const Duration(milliseconds: 1600), () => toast(text));
  }

  void grant(Prize prize) {
    state.money += prize.money;
    state.gems += prize.gems;
    state.spinTickets += prize.tickets;
    save();
    update();
  }

  void claimDaily() {
    if (!dayClaimed) {
      final prize = dailyPrizes[state.dailyStep % 7];
      state.daily = now;
      state.dailyStep++;
      grant(prize);
      openPanel('daily-rewards');
      toast('${prize.label} kazandın!');
    }
  }

  void spinWheel() {
    if (state.spinDate != todayKey || state.spinTickets > 0) {
      if (state.spinDate == todayKey) {
        state.spinTickets--;
      } else {
        state.spinDate = todayKey;
      }
      final prize = wheelPrizes[_random.nextInt(wheelPrizes.length)];
      grant(prize);
      openPanel('wheel');
      toast('Çark ödülün: ${prize.label}');
    }
  }

  /// Sponsor paketi: 10 dakikalık pasif gelir (en az ₺10.000); ilerledikçe değeri korunur.
  int get sponsorAmount => max(10000, (passiveIncome() * 600).round());

  bool _spendGems(int price) {
    if (state.gems < price) return false;
    state.gems -= price;
    return true;
  }

  void _bought(String text) {
    save();
    update();
    openPanel('shop');
    toast(text);
  }

  void buyCoins() {
    final amount = sponsorAmount;
    if (_spendGems(shopPrices['coins']!)) {
      state.money += amount;
      _bought('+₺${fmt(amount)} sponsor geliri!');
    }
  }

  void buyChest() {
    if (_spendGems(shopPrices['chest']!)) {
      state.chests++;
      _bought('+1 Spor Çantası!');
    }
  }

  void buyTrainingCard() {
    if (_spendGems(shopPrices['card']!)) {
      state.trainingCards[state.branch] = (state.trainingCards[state.branch] ?? 0) + 1;
      _bought('🎫 ${branchLabel(state.branch)} antrenman kartı alındı!');
    }
  }
}
