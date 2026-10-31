import 'package:flutter/widgets.dart';

import '../../game/controller.dart';
import '../../game/race.dart';
import '../../game/state.dart';
import 'achievements_panel.dart';
import 'branches_panel.dart';
import 'chest_panels.dart';
import 'daily_panel.dart';
import 'inventory_panel.dart';
import 'profile_panel.dart';
import 'result_panel.dart';
import 'progress_panels.dart';
import 'shop_panel.dart';
import 'system_panels.dart';
import 'welcome_panel.dart';
import 'wheel_panel.dart';

/// `openPanel` anahtarından pencere içeriğine.
Widget panelContent(GameController c, ModalSpec spec) => switch (spec.key) {
  'achievements' => AchievementsPanel(c),
  'daily-rewards' => DailyPanel(c),
  'result' => ResultPanel(c, spec.arg as RaceResult),
  'profile' => ProfilePanel(c),
  'inventory' => InventoryPanel(c),
  'chests' => ChestsPanel(c),
  'chests-result' => ChestResultPanel(c, spec.arg as ChestItem),
  'cosmetics' => CosmeticsPanel(c),
  'wheel' => WheelPanel(c),
  'tournament' => TournamentPanel(c),
  'shop' => ShopPanel(c),
  'branches' => BranchesPanel(c),
  'support' => SupportPanel(c),
  'reset' => ResetPanel(c),
  'welcome' => WelcomePanel(c, spec.arg as OfflineEarnings),
  _ => const SizedBox.shrink(),
};
