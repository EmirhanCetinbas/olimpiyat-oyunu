import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../game/controller.dart';
import '../game/data.dart';
import '../game/format.dart';
import 'campus_page.dart';
import 'modal.dart';
import 'stadium.dart';
import 'theme.dart';
import 'widgets.dart';

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
    })
      ..start();
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
  bool _closeTopLayer() {
    if (c.campusOpen && c.campusDialogOpen) {
      c.closeCampusDialog();
    } else if (c.campusOpen) {
      c.closeCampus();
    } else if (c.modal != null) {
      c.closeModal();
    } else if (c.rewardsOpen) {
      c.rewardsMenu(false);
    } else {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return GameScope(
      controller: c,
      child: Builder(builder: (context) {
        final c = GameScope.of(context);
        final anyLayer = c.campusOpen || c.modal != null || c.rewardsOpen;
        return PopScope(
          canPop: !anyLayer,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _closeTopLayer();
          },
          child: Listener(
            onPointerDown: _onPointerDown,
            behavior: HitTestBehavior.translucent,
            child: ColoredBox(
              color: const Color(0xFF173D35),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Stack(
                    children: [
                      Positioned.fill(child: _Game(rewardsTriggerKey: _rewardsTriggerKey)),
                      if (c.rewardsOpen) _RewardsMenu(key: _rewardsMenuKey),
                      if (c.modal != null) const ModalHost(),
                      if (c.campusOpen) const CampusPage(),
                      const _Toast(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _Game extends StatelessWidget {
  const _Game({required this.rewardsTriggerKey});
  final GlobalKey rewardsTriggerKey;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF86D850),
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
              padding: EdgeInsets.fromLTRB(8, 10 + top, 8, 8),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(),
                  SizedBox(height: 7),
                  RepaintBoundary(child: Stadium()),
                  _RaceStrip(),
                  _SkillMove(),
                  _Upgrades(),
                ],
              ),
            ),
          ),
          _BottomNav(rewardsTriggerKey: rewardsTriggerKey),
        ],
      ),
    );
  }
}

// ---------------- Üst bar ----------------

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    return LayoutBuilder(builder: (context, box) {
      final unit = (box.maxWidth - 14) / 3.08;
      final cols = [unit, unit, unit * 1.08];
      Widget cell(int col, double height, Widget child, {Alignment align = Alignment.center}) =>
          SizedBox(width: cols[col], height: height, child: Align(alignment: align, child: child));
      return Column(children: [
        Row(children: [
          cell(0, 47, _Profile(c)),
          const SizedBox(width: 7),
          cell(1, 47, _Income(c), align: Alignment.topCenter),
          const SizedBox(width: 7),
          cell(2, 47, Padding(padding: const EdgeInsets.only(top: 6), child: _Gems(c)), align: Alignment.topCenter),
        ]),
        const SizedBox(height: 5),
        Row(children: [
          cell(0, 44, _Quick(c), align: Alignment.centerLeft),
          const SizedBox(width: 7),
          cell(1, 44, _Boost(c)),
          const SizedBox(width: 7),
          cell(2, 44, _BranchButton(c)),
        ]),
      ]);
    });
  }
}

GBox _cream({required Widget child, double radius = 14, double? width, double? height, EdgeInsets padding = EdgeInsets.zero}) => GBox(
      gradient: creamGradient,
      borderColor: ink,
      borderWidth: outlineWidth,
      radius: radius,
      shadows: creamShadows,
      insets: creamInsets,
      width: width,
      height: height,
      padding: padding,
      child: child,
    );

class _Profile extends StatelessWidget {
  const _Profile(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) => Btn(
        onTap: () => c.open('profile'),
        semanticLabel: 'Profili aç',
        child: _cream(
          radius: 12,
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Row(children: [
            Art('avatar', width: 30, height: 34, radius: BorderRadius.circular(6)),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sv. ${c.level}', style: nunito(12, height: 1.2), maxLines: 1, overflow: TextOverflow.clip),
                  const SizedBox(height: 2),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4DCE3),
                      border: Border.all(color: const Color(0xFF7A9498), width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 500),
                          widthFactor: (c.state.xp % 100) / 100,
                          heightFactor: 1,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF73F344), Color(0xFF12B422)])),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      );
}

class _Income extends StatelessWidget {
  const _Income(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Gelir /sn', style: nunito(12, height: 1.3)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '₺${fmt(c.income())}',
              style: nunito(30, color: const Color(0xFF79F44B), height: 1.05, letterSpacing: -.5, shadows: outlineShadows(ink, 1)),
            ),
          ),
        ],
      );
}

class _Gems extends StatelessWidget {
  const _Gems(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) => Btn(
        onTap: () => c.open('shop'),
        semanticLabel: 'Elmas mağazası',
        child: _cream(
          height: 32,
          child: Stack(children: [
            const Positioned(left: 8, top: 0, bottom: 0, child: Center(child: Art('gem', width: 27, height: 27))),
            Center(child: Text(fmt(c.state.gems), style: nunito(18, height: 1))),
          ]),
        ),
      );
}

class _Quick extends StatelessWidget {
  const _Quick(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) => Row(children: [
        Btn(
          onTap: () => c.open('achievements'),
          semanticLabel: 'Başarımlar',
          child: Stack(clipBehavior: Clip.none, children: [
            _cream(radius: 10, width: 42, height: 42, padding: const EdgeInsets.all(3), child: const Center(child: Art('trophy'))),
            if (c.achievementDot)
              Positioned(
                right: -3,
                top: -4,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5557),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF931C2B), width: 1.5),
                  ),
                ),
              ),
          ]),
        ),
        const SizedBox(width: 6),
        Btn(
          onTap: () => c.open('settings'),
          semanticLabel: 'Ayarlar',
          child: _cream(radius: 10, width: 42, height: 42, padding: const EdgeInsets.all(3), child: const Center(child: Art('gear', width: 30, height: 30))),
        ),
      ]);
}

class _Boost extends StatelessWidget {
  const _Boost(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) => Btn(
        onTap: c.activateBoost,
        enabled: !c.boostDisabled,
        child: GBox(
          gradient: blueGradient,
          borderColor: ink,
          borderWidth: outlineWidth,
          radius: 9,
          shadows: buttonShadows,
          insets: buttonInsets,
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 3),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(c.boostText, style: nunito(13, color: Colors.white, shadows: whiteTextShadow)),
          ),
        ),
      );
}

class _BranchButton extends StatelessWidget {
  const _BranchButton(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final art = c.branchArt;
    return Btn(
      onTap: () => c.open('branches'),
      child: GBox(
        gradient: vGradient(const [Color(0xFF223951), Color(0xFF102134)]),
        borderColor: ink,
        borderWidth: outlineWidth,
        radius: 10,
        shadows: const [BoxShadow(color: Color(0x66466933), offset: Offset(0, 2))],
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Art(art, width: 22, height: 26, emojiSize: art == 'swim-wave' ? 23 : 12),
          const SizedBox(width: 4),
          Flexible(
            child: Text(c.branchName, textAlign: TextAlign.center, style: nunito(12, color: Colors.white, height: 1.1)),
          ),
          const SizedBox(width: 4),
          Text('⌄', style: nunito(13, color: const Color(0xFF8BABBD))),
        ]),
      ),
    );
  }
}

// ---------------- Yarış şeridi ----------------

class _RaceStrip extends StatelessWidget {
  const _RaceStrip();

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final risk = c.state.branch == 'weights';
    return LayoutBuilder(builder: (context, box) {
      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 33),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: box.maxWidth * (risk ? .43 : .63)),
                child: Text(c.raceStatus, style: nunito(10, height: 1.15)),
              ),
              if (risk)
                Btn(
                  onTap: c.toggleRisk,
                  child: GBox(
                    color: const Color(0xFFFFF5D4),
                    borderColor: const Color(0xFF24465A),
                    borderWidth: 2,
                    radius: 8,
                    padding: const EdgeInsets.all(4),
                    child: Text(c.state.weightRisk == 'record' ? 'Rekor denemesi' : 'Güvenli kilo',
                        style: nunito(9, color: const Color(0xFF0E3852))),
                  ),
                ),
              Btn(
                onTap: c.toggleAuto,
                semanticLabel: 'Otomatik ${c.state.auto ? 'açık' : 'kapalı'}',
                child: GBox(
                  color: const Color(0xBBFAFFDF),
                  borderColor: const Color(0xFF477927),
                  borderWidth: 1,
                  radius: 7,
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                  child: Text.rich(TextSpan(style: nunito(9), children: [
                    const TextSpan(text: '↻ Otomatik '),
                    TextSpan(text: c.state.auto ? 'AÇIK' : 'KAPALI', style: nunito(9, color: const Color(0xFF178D2C))),
                  ])),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _SkillMove extends StatelessWidget {
  const _SkillMove();

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    if (c.skillMoveHidden) return const SizedBox.shrink();
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 43),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(3, 4, 3, 7),
        child: Row(children: [
          Expanded(
            child: LayoutBuilder(builder: (context, box) {
              final w = box.maxWidth;
              return Container(
                height: 15,
                decoration: BoxDecoration(
                  border: Border.all(color: ink, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFA9D4C), Color(0xFFF8EF88), Color(0xFF55DC43), Color(0xFF55DC43), Color(0xFFF8EF88), Color(0xFFFA9D4C)],
                    stops: [0, .4, .48, .52, .6, 1],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(clipBehavior: Clip.none, children: [
                    Positioned(
                      left: (w - 4) * .43,
                      width: (w - 4) * .14,
                      top: 0,
                      bottom: 0,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.symmetric(vertical: BorderSide(color: Colors.white, width: 2)),
                        ),
                      ),
                    ),
                    Positioned(
                      left: (w - 4) * c.skillMeter,
                      top: -2,
                      bottom: -2,
                      width: 5,
                      child: Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: ink, width: 1))),
                    ),
                  ]),
                ),
              );
            }),
          ),
          const SizedBox(width: 8),
          Btn(
            onTap: c.tapMove,
            child: GBox(
              gradient: greenGradient,
              borderColor: const Color(0xFF168D25),
              borderWidth: outlineWidth,
              radius: 9,
              shadows: buttonShadows,
              insets: buttonInsets,
              constraints: const BoxConstraints(minWidth: 108, minHeight: 32),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              child: Text(c.skillButtonText, style: nunito(13, color: Colors.white, shadows: whiteTextShadow)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ---------------- Yükseltme kartları ----------------

class _Upgrades extends StatelessWidget {
  const _Upgrades();

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final count = c.activeUpgrades.length;
    return Column(children: [
      for (var row = 0; row < count; row += 2) ...[
        if (row > 0) const SizedBox(height: 6),
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: _UpgradeCard(index: row)),
            const SizedBox(width: 6),
            Expanded(child: row + 1 < count ? _UpgradeCard(index: row + 1) : const SizedBox()),
          ]),
        ),
      ],
    ]);
  }
}

class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final u = c.activeUpgrades[index];
    final level = c.upgradeLevels[index];
    final swim = c.state.branch == 'swim';
    return GBox(
      gradient: vGradient(const [Color(0xFFFFFDEE), Color(0xFFFFFEEF)]),
      borderColor: ink,
      borderWidth: outlineWidth,
      radius: 14,
      shadows: const [BoxShadow(color: Color(0xFF43873B), offset: Offset(0, 2))],
      padding: const EdgeInsets.fromLTRB(6, 7, 6, 6),
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Stack(clipBehavior: Clip.none, children: [
          Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: vGradient(const [Color(0xFFFFF9E4), Color(0xFFFFEDC7)]),
                borderRadius: BorderRadius.circular(9),
                boxShadow: const [BoxShadow(color: Color(0x3017382C), offset: Offset(0, 1), blurRadius: 2)],
              ),
              alignment: Alignment.center,
              child: Art(u.icon, width: 29, height: 29, emojiSize: swim ? 24 : 16, radius: BorderRadius.circular(6)),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(right: 11, bottom: 2),
                  child: Text(u.title, style: nunito(12, height: 1.02, letterSpacing: -.25)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(color: const Color(0xFFE4EBEE), borderRadius: BorderRadius.circular(3)),
                  child: Text('Sv. $level', style: nunito(10, color: const Color(0xFF56728E))),
                ),
              ]),
            ),
          ]),
          Positioned(
            right: -2,
            top: -3,
            child: Btn(
              onTap: () => c.showInfo(index),
              semanticLabel: '${u.title} hakkında',
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(color: Color(0xFF8397B0), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text('i', style: nunito(10, color: Colors.white, height: 1)),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF0ED),
            border: Border.all(color: const Color(0xFFD1D9DB)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(c.statValue(index), style: nunito(13)),
              const SizedBox(width: 6),
              Text('➜', style: nunito(13, color: const Color(0xFF8398AA))),
              const SizedBox(width: 6),
              Text(c.statValue(index, 1), style: nunito(13, color: const Color(0xFF00A328))),
            ]),
          ),
        ),
        const SizedBox(height: 5),
        Btn(
          onTap: () => c.pressUpgrade(index),
          enabled: c.canUpgrade(index),
          child: GBox(
            gradient: greenGradient,
            borderColor: const Color(0xFF168D25),
            borderWidth: 1.5,
            radius: 7,
            shadows: buttonShadows,
            insets: buttonInsets,
            constraints: const BoxConstraints(minHeight: 28),
            child: IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(
                  child: Center(child: Text('Yükselt', style: nunito(13, weight: 1000, color: Colors.white, shadows: whiteTextShadow))),
                ),
                Builder(builder: (context) {
                  final cardWidth = (MediaQuery.sizeOf(context).width.clamp(0.0, 500.0) - 22) / 2;
                  return Container(
                    constraints: BoxConstraints(minWidth: .44 * (cardWidth - 27.8)),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: vGradient(const [Color(0xFF12B927), Color(0xFF078D18)]),
                      borderRadius: BorderRadius.circular(5),
                      border: const Border(left: BorderSide(color: Color(0xFF087F1B))),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Art('bank', width: 18, height: 18),
                      const SizedBox(width: 3),
                      Text(level >= 100 ? 'MAKS.' : '₺${fmt(c.cost(index))}',
                          style: nunito(10, color: Colors.white, shadows: whiteTextShadow)),
                    ]),
                  );
                }),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// ---------------- Alt menü ----------------

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.rewardsTriggerKey});
  final GlobalKey rewardsTriggerKey;

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    const items = [
      ('inventory', 'Envanter'),
      ('race', 'Oyun'),
      ('rewards', 'Ödüller'),
      ('campus', 'Kampüs'),
      ('shop', 'Mağaza'),
    ];
    return GBox(
      gradient: creamGradient,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      border: const Border(
        top: BorderSide(color: ink, width: outlineWidth),
        left: BorderSide(color: ink, width: outlineWidth),
        right: BorderSide(color: ink, width: outlineWidth),
      ),
      insets: creamInsets,
      padding: EdgeInsets.fromLTRB(3, 4, 3, bottom > 5 ? bottom : 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          Expanded(
            child: Btn(
              key: i == 2 ? rewardsTriggerKey : null,
              semanticLabel: items[i].$2,
              onTap: () {
                if (i == 2) {
                  c.selectNav(2);
                  c.rewardsMenu(!c.rewardsOpen);
                } else {
                  c.open(items[i].$1, navIndex: i);
                }
              },
              child: Container(
                constraints: const BoxConstraints(minHeight: 54),
                padding: const EdgeInsets.only(top: 2, bottom: 3),
                decoration: BoxDecoration(
                  color: c.navSelected == i ? const Color(0xFFFFF1BF) : null,
                  borderRadius: BorderRadius.circular(8),
                  border: c.navSelected == i ? Border.all(color: const Color(0xFFE2BD48)) : null,
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Sprite(navIcon(i), width: 38, height: 38),
                  const SizedBox(height: 1),
                  Text(items[i].$2, maxLines: 1, style: nunito(10, weight: 1000, color: const Color(0xFF173548), height: 1.1)),
                ]),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}

class _RewardsMenu extends StatelessWidget {
  const _RewardsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final width = (MediaQuery.sizeOf(context).width - 32).clamp(0.0, 300.0);
    Widget item(String label, String key) => Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Btn(
            onTap: () => c.open(key),
            child: GBox(
              gradient: vGradient(const [Color(0xFFFFFEF8), Color(0xFFE7F1EC)]),
              borderColor: const Color(0xFFABB9BD),
              borderWidth: 2,
              radius: 10,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: SizedBox(width: double.infinity, child: Text(label, style: nunito(15))),
            ),
          ),
        );
    return Positioned(
      left: 0,
      right: 0,
      bottom: 75 + bottom,
      child: Center(
        child: SizedBox(
          width: width,
          child: Stack(clipBehavior: Clip.none, alignment: Alignment.bottomCenter, children: [
            Positioned(
              bottom: -9,
              child: Transform.rotate(
                angle: .785398,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFCED),
                    border: Border(right: BorderSide(color: ink, width: 3), bottom: BorderSide(color: ink, width: 3)),
                  ),
                ),
              ),
            ),
            GBox(
              color: const Color(0xFFFFFCED),
              borderColor: ink,
              borderWidth: 3,
              radius: 17,
              shadows: const [
                BoxShadow(color: Color(0x65183629), offset: Offset(0, 6)),
                BoxShadow(color: Color(0x77062327), offset: Offset(0, 10), blurRadius: 25),
              ],
              padding: const EdgeInsets.fromLTRB(9, 4, 9, 9),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                item('🎁 Günlük ödül', 'daily-rewards'),
                item('🎡 Çarkıfelek', 'wheel'),
                item('🏅 Başarımlar', 'achievements'),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Toast extends StatelessWidget {
  const _Toast();

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final width = MediaQuery.sizeOf(context).width;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 80,
      child: IgnorePointer(
        child: Center(
          child: AnimatedOpacity(
            opacity: c.toastVisible ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedSlide(
              offset: c.toastVisible ? Offset.zero : const Offset(0, .3),
              duration: const Duration(milliseconds: 200),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width * .9),
                child: GBox(
                  color: const Color(0xFFFFFEE9),
                  borderColor: const Color(0xFF193B36),
                  borderWidth: 2,
                  radius: 11,
                  shadows: const [BoxShadow(color: Color(0x33000000), offset: Offset(0, 3), blurRadius: 9)],
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  child: Text(c.toastText, textAlign: TextAlign.center, style: nunito(12, color: const Color(0xFF173627))),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
