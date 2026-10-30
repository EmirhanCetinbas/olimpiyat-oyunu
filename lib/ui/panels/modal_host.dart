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
      // Ödül ve standart pencereler aynı çerçeveyi kullanır (Ayarlar ile aynı genişlik).
      ModalStyle.reward ||
      ModalStyle.normal => _FramedPanel(spec: spec, width: m.dialogWidth((w * .95).clamp(0.0, 470.0)), maxHeight: m.dialogMaxHeight(.9)),
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

/// Standart pencere: ortak pencere dili (başlık plakası, pati izleri, kapat düğmesi) içinde kayan içerik.
class _FramedPanel extends StatelessWidget {
  const _FramedPanel({required this.spec, required this.width, required this.maxHeight});
  final ModalSpec spec;
  final double width;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    return SizedBox(
      width: width,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: GameModal(
          title: trUpper(spec.title),
          onClose: c.closeModal,
          child: SingleChildScrollView(
            child: DefaultTextStyle(
              style: gameText(TextSizes.body, color: GameColors.ink),
              child: panelContent(c, spec),
            ),
          ),
        ),
      ),
    );
  }
}
