import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../components/components.dart';
import '../theme/theme.dart';
import 'achievements_panel.dart';
import 'daily_panel.dart';
import 'panel_router.dart';
import 'settings/settings_panel.dart';

/// `<dialog id="modal">`: tek pencere; görünümü `ModalSpec.style`, içeriği `key` belirler.
class ModalHost extends StatelessWidget {
  const ModalHost({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final spec = c.modal!;
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final viewportWidth = size.width.clamp(0.0, 500.0);
    final maxHeight = size.height * .85 - padding.vertical;
    final daily = spec.style == ModalStyle.exactDaily;

    final Widget dialog = switch (spec.style) {
      ModalStyle.exactAchievements => SizedBox(width: (viewportWidth * .844).clamp(0.0, 422.0), child: AchievementsPanel(c)),
      ModalStyle.exactDaily => SizedBox(width: viewportWidth, child: DailyPanel(c)),
      ModalStyle.settings => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: (viewportWidth * .95).clamp(0.0, 470.0), maxHeight: size.height - 20 - padding.vertical),
        child: SingleChildScrollView(child: SettingsPanel(c)),
      ),
      ModalStyle.reward => _RewardFrame(spec: spec, maxHeight: maxHeight),
      ModalStyle.normal => _StandardFrame(spec: spec, width: (viewportWidth * .93).clamp(0.0, 410.0), maxHeight: maxHeight),
    };

    return DialogLayer(
      onDismiss: c.closeModal,
      blur: 1.5,
      alignment: daily ? Alignment.bottomCenter : Alignment.center,
      padding: EdgeInsets.only(top: padding.top, bottom: daily ? 0 : padding.bottom),
      child: KeyedSubtree(key: ValueKey(spec.key), child: dialog),
    );
  }
}

/// Yeşil başlıklı standart pencere.
class _StandardFrame extends StatelessWidget {
  const _StandardFrame({required this.spec, required this.width, required this.maxHeight});
  final ModalSpec spec;
  final double width;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    return Container(
      width: width,
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: GameColors.cream,
        border: Border.all(color: GameColors.ink, width: 3),
        borderRadius: BorderRadius.circular(19),
        boxShadow: const [BoxShadow(color: Color(0x4D071A38), offset: Offset(0, 9))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF88D54D),
                border: Border(bottom: BorderSide(color: GameColors.ink, width: 2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(spec.title, style: nunito(19, color: GameColors.ink)),
                  ),
                  SquareCloseButton(onTap: c.closeModal),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: DefaultTextStyle(
                  style: nunito(14, color: GameColors.ink),
                  child: panelContent(c, spec),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `.reward-dialog`: başlıksız, köşede kırmızı kapat düğmeli pencere.
class _RewardFrame extends StatelessWidget {
  const _RewardFrame({required this.spec, required this.maxHeight});
  final ModalSpec spec;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    return Container(
      width: (MediaQuery.sizeOf(context).width * .96).clamp(0.0, 460.0),
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEF4),
        border: Border.all(color: GameColors.ink, width: 3),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [BoxShadow(color: Color(0x4D071A38), offset: Offset(0, 9))],
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
            child: DefaultTextStyle(
              style: nunito(14, color: GameColors.ink),
              child: panelContent(c, spec),
            ),
          ),
          Positioned(
            right: 7,
            top: 4,
            child: RoundCloseButton(
              onTap: c.closeModal,
              shadows: const [BoxShadow(color: Color(0xFF8F142F), offset: Offset(0, 2))],
            ),
          ),
        ],
      ),
    );
  }
}
