import 'dart:ui';

import 'package:flutter/material.dart';

import '../game/controller.dart';
import 'exact_panels.dart';
import 'panels.dart';
import 'settings_panel.dart';
import 'theme.dart';
import 'widgets.dart';

/// `<dialog id="modal">`: tek pencere; içerik `ModalSpec.key`e göre değişir.
class ModalHost extends StatelessWidget {
  const ModalHost({super.key});

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final spec = c.modal!;
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final viewport = Size(size.width.clamp(0.0, 500.0), size.height);

    Widget dialog;
    var alignment = Alignment.center;
    switch (spec.style) {
      case ModalStyle.exactAchievements:
        dialog = SizedBox(width: (viewport.width * .844).clamp(0.0, 422.0), child: AchievementsPanel(c));
      case ModalStyle.exactDaily:
        alignment = Alignment.bottomCenter;
        dialog = SizedBox(width: viewport.width, child: DailyPanel(c));
      case ModalStyle.settings:
        dialog = ConstrainedBox(
          constraints: BoxConstraints(maxWidth: (viewport.width * .95).clamp(0.0, 470.0), maxHeight: size.height - 20 - padding.vertical),
          child: SingleChildScrollView(child: SettingsPanel(c)),
        );
      case ModalStyle.reward:
        dialog = _RewardDialog(spec: spec, maxHeight: size.height * .85 - padding.vertical);
      case ModalStyle.normal:
        dialog = _NormalDialog(spec: spec, width: (viewport.width * .93).clamp(0.0, 410.0), maxHeight: size.height * .85 - padding.vertical);
    }

    return Positioned.fill(
      child: Stack(children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: c.closeModal,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                child: const ColoredBox(color: Color(0xA8081D34)),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: padding.top, bottom: spec.style == ModalStyle.exactDaily ? 0 : padding.bottom),
          child: Align(
            alignment: alignment,
            child: GestureDetector(onTap: () {}, child: KeyedSubtree(key: ValueKey(spec.key), child: dialog)),
          ),
        ),
      ]),
    );
  }
}

class _NormalDialog extends StatelessWidget {
  const _NormalDialog({required this.spec, required this.width, required this.maxHeight});
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
        color: const Color(0xFFFFFCED),
        border: Border.all(color: ink, width: 3),
        borderRadius: BorderRadius.circular(19),
        boxShadow: const [BoxShadow(color: Color(0x4D071A38), offset: Offset(0, 9))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF88D54D),
              border: Border(bottom: BorderSide(color: ink, width: 2)),
            ),
            child: Row(children: [
              Expanded(child: Text(spec.title, style: nunito(19, color: ink))),
              Btn(
                onTap: c.closeModal,
                semanticLabel: 'Kapat',
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFCEB),
                    border: Border.all(color: ink, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text('×', style: nunito(22, color: ink, height: 1)),
                ),
              ),
            ]),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: DefaultTextStyle(style: nunito(14, color: ink), child: panelContent(c, spec)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _RewardDialog extends StatelessWidget {
  const _RewardDialog({required this.spec, required this.maxHeight});
  final ModalSpec spec;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final c = GameScope.of(context);
    final width = (MediaQuery.sizeOf(context).width * .96).clamp(0.0, 460.0);
    return Container(
      width: width,
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEF4),
        border: Border.all(color: ink, width: 3),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [BoxShadow(color: Color(0x4D071A38), offset: Offset(0, 9))],
      ),
      child: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
          child: DefaultTextStyle(style: nunito(14, color: ink), child: panelContent(c, spec)),
        ),
        Positioned(
          right: 7,
          top: 4,
          child: Btn(
            onTap: c.closeModal,
            semanticLabel: 'Kapat',
            child: GBox(
              width: 38,
              height: 38,
              gradient: vGradient(const [Color(0xFFFF7C7B), Color(0xFFED314D)]),
              borderColor: ink,
              borderWidth: 2,
              radius: 19,
              shadows: const [BoxShadow(color: Color(0xFF8F142F), offset: Offset(0, 2))],
              alignment: Alignment.center,
              child: Text('×', style: nunito(26, color: Colors.white, height: 1)),
            ),
          ),
        ),
      ]),
    );
  }
}
