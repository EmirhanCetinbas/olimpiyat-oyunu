// check-game.cjs senaryolarının Dart karşılığı.
import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pati_sampiyonlari/game/controller.dart';
import 'package:pati_sampiyonlari/game/race.dart';

void main() {
  late MemoryStorage storage;
  late GameController game;
  var clock = 1000000;

  Map<String, dynamic> saved() => jsonDecode(storage.value!) as Map<String, dynamic>;

  void ticks(int count, {double dt = 1 / 60, bool Function()? until}) {
    for (var i = 0; i < count; i++) {
      if (until != null && !until()) return;
      clock += (dt * 1000).round();
      game.tick(dt);
    }
  }

  setUp(() {
    storage = MemoryStorage();
    clock = 1000000;
    game = GameController(storage: storage, random: Random(7), clock: () => clock);
  });

  tearDown(() => game.dispose());

  test('race, save, equipment, chest rewards', () {
    expect(game.state.money, 3500);
    expect(game.state.races, 0);
    expect(game.state.levels.length, 6);
    expect(game.income(), 45);
    var before = game.state.money, beforeIncome = game.income();
    expect(game.upgrade(0).ok, true);
    expect(game.state.money, before - 750);
    expect(game.state.levels[0], 2);
    expect(game.income(), beforeIncome);
    game.state.money = 0;
    expect(game.upgrade(1).ok, false);
    expect(game.state.levels[1], 1);
    expect(() => game.upgrade(7), throwsArgumentError);
    game.state.money = 10000;
    beforeIncome = game.income();
    expect(game.upgrade(4).ok, true);
    expect(game.income(), beforeIncome + 12);
    beforeIncome = game.income();
    expect(game.upgrade(5).ok, true);
    expect(game.income(), beforeIncome + 18);

    game.state.auto = false;
    game.state.money = 3500;
    game.beginRace();
    expect(game.race, isNotNull);
    expect(game.race!.progress.length, 4);
    expect(game.runnerPos.length, 4);
    expect(game.beginRace().ok, false);
    ticks(1800, until: () => game.race != null);
    expect(game.state.races, 1);
    expect(game.race, isNull);
    expect(game.state.money, greaterThan(3500));
    expect(game.state.best, greaterThan(0));
    expect(game.state.xp, greaterThanOrEqualTo(15));

    game.save();
    expect(saved()['races'], 1);
    game.state.money = 1000000;
    for (var i = 0; i < 4; i++) {
      for (var star = 0; star < 3; star++) {
        expect(game.buyEquipment(i), true);
      }
      expect(game.buyEquipment(i), false);
    }
    expect(game.state.equipmentStars.join(','), '3,3,3,3');
    game.beginRace();
    expect(game.race!.equipmentStars.join(','), '3,3,3,3');
    game.state.races = 4;
    game.race!.elapsed = 10;
    game.race!.times = [9, 10, 11, 12];
    game.finishRace();
    expect(game.state.chests, 1);
  });

  test('daily reward states', () {
    for (var day = 0; day < 7; day++) {
      game.state.dailyStep = day;
      game.state.daily = 0;
      expect(game.dayClaimed, false);
    }
    game.state.daily = clock;
    expect(game.dayClaimed, true);
  });

  test('campus SP spending, cap, income effect and race snapshot', () {
    game.state.skillPoints = 8;
    game.state.campusUpgrades = {};
    expect(game.buyCampusUpgrade('sprint', 0), true);
    expect(game.state.skillPoints, 6);
    expect(game.campusRank('sprint', 0), 1);
    expect(game.buyCampusUpgrade('weights', 0), true);
    expect(game.state.skillPoints, 4);
    expect(game.buyCampusUpgrade('sprint', 9), false);
    final campusIncome = game.passiveIncome();
    expect(game.buyCampusUpgrade('stadium', 0), true);
    expect(game.passiveIncome(), greaterThan(campusIncome));
    game.beginRace();
    expect(game.race!.campus[0], 1);
    game.state.skillPoints = 100;
    game.buyCampusUpgrade('sprint', 0);
    expect(game.race!.campus[0], 1);
    game.race = null;
    game.save();
    expect((saved()['campusUpgrades'] as Map)['sprint'][0], 2);
    game.state.skillPoints = 0;
    expect(game.buyCampusUpgrade('sprint', 1), false);
    game.state.skillPoints = 100;
    for (var i = 0; i < 7; i++) {
      game.buyCampusUpgrade('sprint', 1);
    }
    expect(game.campusRank('sprint', 1), 5);
    expect(game.buyCampusUpgrade('sprint', 1), false);
  });

  test('hurdles and swimming', () {
    game.state.money = 10000;
    game.state.auto = false;
    game.selectBranch('hurdles');
    expect(game.state.branch, 'hurdles');
    expect(game.runnerPos.length, 6);
    expect(game.timerText, '◴ 00:00');
    expect(game.upgrade(0).ok, true);
    expect(game.state.hurdleLevels[0], 2);
    expect(game.beginRace().ok, true);
    expect(game.race!.progress.length, 6);
    ticks(1800, until: () => game.race != null);
    expect(game.race, isNull);
    expect(game.timerText, matches(RegExp(r'◴ \d\d:\d\d')));

    game.state.money = 10000;
    game.selectBranch('swim');
    expect(game.arenaImage, contains('swim-arena'));
    expect(game.activeUpgrades.map((u) => u.title), contains('Kulaç Gücü'));
    expect(game.upgrade(1).ok, true);
    expect(game.beginRace().ok, true);
    expect(game.race!.swimLevels[1], 2);
    game.state.swimLevels[1] = 3;
    expect(game.race!.swimLevels[1], 2);
    ticks(1800, until: () => game.race != null);
    expect(game.race, isNull);
    expect(saved()['swimLevels'][1], 3);
  });

  test('sequential long jump with bench positions and flags', () {
    game.state.money = 10000;
    game.state.auto = false;
    game.selectBranch('longjump');
    expect(game.runnerPos.length, 6);
    expect(game.timerText, 'DENEME');
    expect(game.activeUpgrades.map((u) => u.title).join(','), 'Çıkış Hızı,Adımlama,Sıçrama Gücü,İniş Tekniği');
    expect(game.upgrade(2).ok, true);
    expect(game.beginRace().ok, true);
    expect(game.beginRace().ok, false);
    expect(game.race!.jump!.levels[2], 2);
    game.state.longJumpLevels[2] = 20;
    expect(game.race!.jump!.levels[2], 2);
    final racesBefore = game.state.races;
    game.race!.jump!.distances = [7, 6, 5, 4, 3, 2];
    final seen = <String>{};
    for (var i = 0; i < 600 && game.race != null; i++) {
      game.tick(.1);
      if (game.race != null) {
        seen.add(game.race!.jump!.phase);
        for (var lane = 0; lane < 6; lane++) {
          if (lane != game.race!.jump!.turn) expect(game.runnerPos[lane].y, 85.5);
        }
      }
    }
    expect(game.race, isNull);
    expect(game.jumpCompleted.length, 6);
    expect(game.state.races, racesBefore + 1);
    expect(game.state.bestJump, 7);
    expect(game.roundText, '6 / 6');
    expect(seen, containsAll(['ready', 'runup', 'flight', 'landed', 'return']));
    for (var i = 0; i < 4; i++) {
      expect(game.longJumpDistance(0, [for (var j = 0; j < 4; j++) j == i ? 2 : 1], .5),
          greaterThan(game.longJumpDistance(0, [1, 1, 1, 1], .5)));
    }
    expect(game.raceStatus, contains('1. sıra'));
    expect(game.beginRace().ok, true);
    expect(game.jumpCompleted, isEmpty);
    game.paused = true;
    final t = game.race!.jump!.time;
    game.tick(.1);
    expect(game.race!.jump!.time, t);
  });

  test('weightlifting order, barbell, success and failure', () {
    game.state.auto = false;
    game.state.money = 10000;
    game.selectBranch('weights');
    expect(game.timerText, 'DENEME');
    expect(game.upgrade(0).ok, true);
    expect(game.beginRace().ok, true);
    game.selectBranch('sprint');
    expect(game.state.branch, 'weights');
    game.race!.weights!.attempts = [
      for (var i = 0; i < 6; i++) WeightAttempt(kg: 100 - i * 5, chance: 1, success: true),
    ];
    final phases = <String>{}, bars = <double>{};
    for (var i = 0; i < 500 && game.race != null; i++) {
      game.tick(.1);
      bars.add(game.weightBarTop);
      if (game.race != null) {
        phases.add(game.race!.weights!.phase);
        for (var lane = 0; lane < 6; lane++) {
          if (lane != game.race!.weights!.turn) expect(game.runnerPos[lane].y, 81.5);
        }
      }
    }
    expect(game.race, isNull);
    expect(game.state.bestWeight, 100);
    expect(game.raceStatus, contains('1. sıra · 100 KG'));
    expect(bars.length, greaterThan(5));
    expect(phases, containsAll(['walk', 'ready', 'pull', 'push', 'hold', 'lower', 'return']));
    final base = game.weightAttempt(0, [1, 1, 1, 1], .5, .5);
    expect(game.weightAttempt(0, [11, 1, 1, 1], .5, .5).kg, greaterThan(base.kg));
    expect(game.weightAttempt(0, [1, 11, 1, 1], .5, .5).chance, greaterThan(base.chance));
    expect(game.weightAttempt(0, [1, 1, 1, 11], .5, .5).kg, greaterThan(base.kg));
    expect(game.weightAttempt(0, [100, 100, 100, 100], .5, .99).success, false);
    final wins = game.state.wins;
    game.beginRace();
    game.race!.weights!.attempts = [for (var i = 0; i < 6; i++) WeightAttempt(kg: 200, chance: 0, success: false)];
    for (var i = 0; i < 500 && game.race != null; i++) {
      game.tick(.1);
    }
    expect(game.state.bestWeight, 100);
    expect(game.state.wins, wins);
    expect(game.raceStatus, contains('başarısız'));
  });

  test('archery sequential shots and scoring', () {
    game.state.money = 10000;
    game.state.auto = false;
    game.selectBranch('archery');
    expect(game.activeUpgrades.map((u) => u.title).join(','), 'Nişan Alma,Yay Gücü,Rüzgâr Okuma,Son Atış');
    expect(game.upgrade(0).ok, true);
    expect(game.beginRace().ok, true);
    game.race!.archery!.shots = [
      for (var i = 0; i < 6; i++) [10 - i, 10 - i, 10 - i],
    ];
    final phases = <String>{}, arrows = <double>{};
    for (var i = 0; i < 700 && game.race != null; i++) {
      game.tick(.1);
      arrows.add(game.archeryArrowLeft);
      if (game.race != null) {
        phases.add(game.race!.archery!.phase);
        for (var lane = 0; lane < 6; lane++) {
          if (lane != game.race!.archery!.turn) expect(game.runnerPos[lane].y, 87);
        }
      }
    }
    expect(game.race, isNull);
    expect(game.state.bestArchery, 30);
    expect(game.raceStatus, contains('1. sıra · 30 puan'));
    expect(arrows.length, greaterThan(4));
    expect(phases, containsAll(['walk', 'aim', 'flight', 'hit', 'return']));
  });

  test('timing input, tournament, specialties and weight risk', () {
    game.offerMove('archery', 2, 'Nişanı bırak!');
    game.tickMove(1);
    expect(game.tapMove(), true);
    expect(game.moveQuality(), 1);
    expect(game.tapMove(), false);
    game.clearMove();
    expect(game.skillMoveHidden, true);
    game.state.tournament = null;
    game.state.skillPoints = 0;
    expect(game.startTournament(), true);
    expect(game.startTournament(), false);
    game.state.tournament!.branch = 'archery';
    game.recordTournament('archery', 1);
    game.recordTournament('archery', 2);
    game.recordTournament('archery', 6);
    expect(game.state.tournamentCups, 1);
    expect(game.state.skillPoints, 1);
    expect(game.state.cupChests, 1);
    game.recordTournament('archery', 1);
    expect(game.state.tournamentCups, 1);
    game.state.weightRisk = 'record';
    game.selectBranch('weights');
    game.beginRace();
    expect(game.race!.weights!.attempts[0].chance, lessThan(.7));
  });

  test('persistent three-choice chests and one-use training card', () {
    game.state
      ..cupChests = 1
      ..championChests = 1
      ..chests = 1
      ..pendingChest = null
      ..equipmentParts = 0
      ..cosmetics = [];
    expect(game.openChest('cup'), true);
    expect(game.state.cupChests, 0);
    expect(game.state.pendingChest!.offers.every((o) => o.kind == 'bundle'), true);
    expect(game.openChest('normal'), true);
    expect(game.state.chests, 1);
    expect(saved()['pendingChest'], isNotNull);
    expect(game.chooseChest(0), isNotNull);
    expect(game.state.pendingChest, isNull);
    expect(game.state.equipmentParts, greaterThanOrEqualTo(2));
    expect(game.chooseChest(0), isNull);
    expect(game.openChest('champion'), true);
    expect(game.state.pendingChest!.offers.every((o) => o.kind == 'cosmetic'), true);
    expect(game.chooseChest(1), isNotNull);
    expect(game.state.cosmetics.length, 1);
    game.state
      ..equipmentParts = 5
      ..money = 0;
    game.state.equipmentStars[1] = 0;
    expect(game.buyEquipment(1, useParts: true), true);
    expect(game.state.equipmentStars[1], 1);
    game.state.trainingCards['archery'] = 1;
    game.selectBranch('archery');
    game.beginRace();
    expect(game.state.trainingCards['archery'], 0);
    expect(game.beginRace().ok, false);
  });

  test('save and reload keeps progress', () {
    game.upgrade(0);
    game.save();
    final reloaded = GameController(storage: storage, clock: () => clock);
    expect(reloaded.state.levels[0], 2);
    reloaded.dispose();
  });
}
