import 'package:flutter/widgets.dart';

import '../../game/controller.dart';

/// Denetleyiciyi ağaca taşır; `of(context)` dinleyerek yeniden çizer.
class GameScope extends InheritedNotifier<GameController> {
  const GameScope({super.key, required GameController controller, required super.child}) : super(notifier: controller);

  static GameController of(BuildContext context, {bool listen = true}) {
    if (listen) return context.dependOnInheritedWidgetOfExactType<GameScope>()!.notifier!;
    return (context.getElementForInheritedWidgetOfExactType<GameScope>()!.widget as GameScope).notifier!;
  }
}
