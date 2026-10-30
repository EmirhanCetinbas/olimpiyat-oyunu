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
    final m = ScreenMetrics.of(context);
    final w = m.gameWidth;
    final daily = spec.style == ModalStyle.exactDaily;

    final Widget dialog = switch (spec.style) {
      ModalStyle.exactAchievements => SizedBox(width: m.dialogWidth((w * .844).clamp(0.0, 422.0)), child: AchievementsPanel(c)),
      ModalStyle.exactDaily => SizedBox(width: m.dialogWidth(w), child: DailyPanel(c)),
      ModalStyle.settings => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: m.dialogWidth((w * .95).clamp(0.0, 470.0)), maxHeight: m.dialogMaxHeight()),
        child: SingleChildScrollView(child: SettingsPanel(c)),
      ),
      ModalStyle.reward => _RewardFrame(spec: spec, width: m.dialogWidth((w * .96).clamp(0.0, 460.0)), maxHeight: m.dialogMaxHeight(.85)),
      ModalStyle.normal => _StandardFrame(spec: spec, width: m.dialogWidth((w * .93).clamp(0.0, 410.0)), maxHeight: m.dialogMaxHeight(.85)),
    };

    // Günlük ödül alttan açılan sayfa gibi durur; ev çubuğunun ve klavyenin üstünde kalır.
    return DialogLayer(
      onDismiss: c.closeModal,
      blur: 3,
      alignment: daily ? Alignment.bottomCenter : Alignment.center,
      padding: EdgeInsets.only(top: m.padding.top, bottom: m.padding.bottom + m.viewInsets.bottom),
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
              // Kapat düğmesinin 44pt dokunma alanı başlık yüksekliğini korur (28 + 2×10).
              padding: const EdgeInsets.fromLTRB(14, 2, 6, 2),
              decoration: const BoxDecoration(
                color: Color(0xFF88D54D),
                border: Border(bottom: BorderSide(color: GameColors.ink, width: 2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(spec.title, style: gameText(19, color: GameColors.ink)),
                  ),
                  SquareCloseButton(onTap: c.closeModal),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: DefaultTextStyle(
                  style: gameText(14, color: GameColors.ink),
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
  const _RewardFrame({required this.spec, required this.width, required this.maxHeight});
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
              style: gameText(14, color: GameColors.ink),
              child: panelContent(c, spec),
            ),
          ),
          // 38pt görsel, 44pt dokunma alanının ortasında: konum 3pt içeri kayar.
          Positioned(
            right: 4,
            top: 1,
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
