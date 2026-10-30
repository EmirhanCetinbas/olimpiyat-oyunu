part of 'controller.dart';

/// Başarımlar, günlük ödül, çark ve mağaza.
extension RewardsLogic on GameController {
  void claimAchievement(String id) {
    final a = achievements.where((x) => x.id == id).firstOrNull;
    if (a != null && a.done(state) && !state.claims.contains(a.id)) {
      state.claims.add(a.id);
      state.money += a.reward;
      if (['fast-paws', 'full-stand'].contains(a.id)) state.championChests++;
      save();
      update();
      openPanel('achievements');
      toast('Başarım ödülü alındı!');
    }
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

  void buyCoins() {
    if (state.gems >= 5) {
      state.gems -= 5;
      state.money += 10000;
      save();
      update();
      openPanel('shop');
      toast('+₺10.000 sponsor geliri!');
    }
  }
}
