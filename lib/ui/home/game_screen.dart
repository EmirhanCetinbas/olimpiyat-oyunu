import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../game/controller.dart';
import '../campus/campus_page.dart';
import '../components/components.dart';
import '../panels/modal_host.dart';
import '../stadium/stadium.dart';
import '../theme/theme.dart';
import 'bottom_nav.dart';
import 'race_strip.dart';
import 'rewards_menu.dart';
import 'toast_overlay.dart';
import 'top_bar.dart';
import 'upgrade_grid.dart';

/// Oyun kabuğu: oyun döngüsü (Ticker), yaşam döngüsü ve katmanlar.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.controller});
  final GameController controller;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  bool _musicStarted = false;
  final _rewardsMenuKey = GlobalKey();
  final _rewardsTriggerKey = GlobalKey();

  GameController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    c.vibrate = (ms) => ms >= 40 ? HapticFeedback.mediumImpact() : HapticFeedback.lightImpact();
    _ticker = createTicker((elapsed) {
      final dt = (elapsed - _last).inMicroseconds / 1e6;
      _last = elapsed;
      c.tick(dt);
    })..start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.paused || lifecycle == AppLifecycleState.hidden) {
      if (!c.hidden) c.appHidden();
    } else if (lifecycle == AppLifecycleState.resumed && c.hidden) {
      c.appVisible();
    }
  }

  bool _inside(GlobalKey key, Offset position) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return false;
    return (box.localToGlobal(Offset.zero) & box.size).contains(position);
  }

  /// İlk dokunuşta müzik başlar; menü dışına dokunuş ödül menüsünü kapatır.
  void _onPointerDown(PointerDownEvent e) {
    if (!_musicStarted) {
      _musicStarted = true;
      c.startMusic();
    }
    if (c.rewardsOpen && !_inside(_rewardsMenuKey, e.position) && !_inside(_rewardsTriggerKey, e.position)) {
      c.rewardsMenu(false);
    }
  }

  /// Android geri tuşu: en üstteki katmanı kapatır (Escape karşılığı).
  void _closeTopLayer() {
    if (c.campusOpen && c.campusDialogOpen) {
      c.closeCampusDialog();
    } else if (c.campusOpen) {
      c.closeCampus();
    } else if (c.modal != null) {
      c.closeModal();
    } else if (c.rewardsOpen) {
      c.rewardsMenu(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameScope(
      controller: c,
      child: Builder(
        builder: (context) {
          final c = GameScope.of(context);
          return PopScope(
            canPop: !(c.campusOpen || c.modal != null || c.rewardsOpen),
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _closeTopLayer();
            },
            child: Listener(
              onPointerDown: _onPointerDown,
              behavior: HitTestBehavior.translucent,
              child: ColoredBox(
                color: GameColors.page,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Stack(
                      children: [
                        Positioned.fill(child: _GameBody(rewardsTriggerKey: _rewardsTriggerKey)),
                        if (c.rewardsOpen) RewardsMenu(key: _rewardsMenuKey),
                        if (c.modal != null) const ModalHost(),
                        if (c.campusOpen) const CampusPage(),
                        const ToastOverlay(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// `<main class="game">`: kaydırılabilir içerik ve alt menü.
class _GameBody extends StatelessWidget {
  const _GameBody({required this.rewardsTriggerKey});
  final GlobalKey rewardsTriggerKey;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final side = ScreenMetrics.of(context).compact ? 6.0 : 8.0;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: GameColors.grass,
        image: DecorationImage(
          image: AssetImage('assets/images/park-background.png'),
          alignment: Alignment.topCenter,
          fit: BoxFit.fitWidth,
          repeat: ImageRepeat.repeatY,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(side, 10 + top, side, 8),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TopBar(),
                  SizedBox(height: 7),
                  RepaintBoundary(child: Stadium()),
                  RaceStrip(),
                  UpgradeGrid(),
                ],
              ),
            ),
          ),
          BottomNav(rewardsTriggerKey: rewardsTriggerKey),
        ],
      ),
    );
  }
}
