import 'package:flutter/widgets.dart';

import '../../game/controller.dart';
import '../../game/state.dart';
import 'branches_panel.dart';
import 'chest_panels.dart';
import 'inventory_panel.dart';
import 'profile_panel.dart';
import 'progress_panels.dart';
import 'shop_panel.dart';
import 'system_panels.dart';
import 'team_panel.dart';
import 'wheel_panel.dart';

/// `openPanel` anahtarından pencere içeriğine.
Widget panelContent(GameController c, ModalSpec spec) => switch (spec.key) {
  'profile' => ProfilePanel(c),
  'inventory' => InventoryPanel(c),
  'chests' => ChestsPanel(c),
  'chests-result' => ChestResultPanel(c, spec.arg as ChestItem),
  'cosmetics' => CosmeticsPanel(c),
  'wheel' => WheelPanel(c),
  'team' => TeamPanel(c),
  'league' => LeaguePanel(c),
  'tournament' => TournamentPanel(c),
  'camp' => CampPanel(c),
  'shop' => ShopPanel(c),
  'branches' => BranchesPanel(c),
  'info' => InfoPanel(c, spec.arg as int),
  'support' => SupportPanel(c),
  'reset' => ResetPanel(c),
  _ => const SizedBox.shrink(),
};
