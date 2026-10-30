import 'package:flutter/material.dart';

import '../../game/controller.dart';
import '../../game/data.dart';
import '../../game/format.dart';
import '../components/components.dart';
import '../theme/theme.dart';

/// Envanter: Sporcular / Ekipman / Eşyalar sekmeleri.
class InventoryPanel extends StatelessWidget {
  const InventoryPanel(this.c, {super.key});
  final GameController c;

  static const _tabs = [('athletes', 'Sporcular'), ('equipment', 'Ekipman'), ('items', 'Eşyalar')];

  @override
  Widget build(BuildContext context) {
    final body = switch (c.inventoryTab) {
      'athletes' => _athletes(),
      'equipment' => _equipment(),
      _ => _items(),
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_tabBar(), ...body]);
  }

  Widget _tabBar() => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: Row(
      children: [
        for (var i = 0; i < _tabs.length; i++) ...[
          if (i > 0) const SizedBox(width: 7),
          Expanded(
            // Seçili sekme yeşil, diğerleri krem.
            child: RaisedButton(
              _tabs[i].$2,
              onTap: () => c.setInventoryTab(_tabs[i].$1),
              tone: c.inventoryTab == _tabs[i].$1 ? ButtonTone.green : ButtonTone.cream,
              width: double.infinity,
              fontSize: 15,
            ),
          ),
        ],
      ],
    ),
  );

  Widget _cardAction(String label, VoidCallback onTap, {bool enabled = true}) => ActionButton(label, onTap: onTap, enabled: enabled);

  Widget _emoji(String e) => SizedBox(width: 42, child: EmojiArt(e, size: 29));

  List<Widget> _athletes() {
    final s = c.state;
    return [
      for (var i = 0; i < animals.length; i++)
        ItemCard(
          locked: s.races < animals[i].unlock,
          leading: Art(animals[i].art, width: 42, height: 42),
          title: animals[i].name,
          small: '${animals[i].trait} · Uzmanlık: ${specialtyLabel(i)}',
          actions: [
            _cardAction(
              s.races < animals[i].unlock
                  ? '${animals[i].unlock} yarış'
                  : s.selected == i
                  ? 'Seçili'
                  : 'Seç',
              () => c.selectAnimal(i),
              enabled: s.races >= animals[i].unlock && c.race == null,
            ),
          ],
        ),
    ];
  }

  List<Widget> _equipment() => [
    const PanelText(
      'Her ekipman en fazla 3 yıldıza yükselir. Etkileri sonraki yarışta uygulanır.',
      size: 12,
      color: GameColors.slate,
      bottom: 8,
    ),
    for (var i = 0; i < equipmentItems.length; i++) ...[if (i > 0) const SizedBox(height: 7), EquipmentCard(c: c, index: i)],
  ];

  List<Widget> _items() {
    final s = c.state;
    final cards = s.trainingCards.entries.where((e) => e.value > 0).map((e) => '${branchLabel(e.key)} ×${e.value}').join(', ');
    return [
      ItemCard(leading: _emoji('⚙️'), title: 'Ekipman parçası ×${s.equipmentParts}', small: '5 parça ile bir ekipmanı yıldızla geliştir'),
      ItemCard(
        leading: _emoji('🎫'),
        title: 'Antrenman kartları',
        small: '${cards.isEmpty ? 'Henüz yok' : cards} · Sonraki ilgili yarışta otomatik kullanılır',
      ),
      ItemCard(
        leading: _emoji('✨'),
        title: 'Avatar çerçeveleri',
        small: '${s.cosmetics.length} / 4 açık · Tekrarı parçaya dönüşür',
        actions: [_cardAction('Seç', () => c.open('cosmetics'))],
      ),
      ItemCard(
        leading: const Art('ticket', width: 42, height: 42),
        title: 'Çark bileti ×${s.spinTickets}',
        small: 'Ödül çarkında bir kez kullanılır',
        actions: [_cardAction('Aç', () => c.open('wheel'))],
      ),
      ItemCard(
        leading: _emoji('🎁'),
        title: 'Spor Çantaları ×${s.chests + s.cupChests + s.championChests}',
        small: 'Normal ${s.chests} · Kupa ${s.cupChests} · Şampiyon ${s.championChests}',
        actions: [_cardAction('Aç', () => c.open('chests'))],
      ),
      ItemCard(
        leading: _emoji('⚡'),
        title: '2x gelir kuponu ×${s.boostTokens}',
        small: '30 saniye boyunca geliri ikiye katlar',
        actions: [_cardAction('Kullan', c.useBoostToken, enabled: s.boostTokens >= 1)],
      ),
    ];
  }
}

/// `.equipment-card`: ikon, yıldızlar ve para/parça ile yükseltme.
class EquipmentCard extends StatelessWidget {
  const EquipmentCard({super.key, required this.c, required this.index});
  final GameController c;
  final int index;

  @override
  Widget build(BuildContext context) {
    final item = equipmentItems[index];
    final stars = c.state.equipmentStars[index];
    final parts = stars < 3 && c.state.equipmentParts >= 5;
    final compact = ScreenMetrics.of(context).compact;
    final gap = SizedBox(width: compact ? 4 : 7);
    Widget button(String label, VoidCallback onTap, {bool enabled = true}) =>
        RaisedButton(label, onTap: onTap, enabled: enabled, width: double.infinity, height: 36, fontSize: 14);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: flatCardDecoration(),
      child: Row(
        children: [
          Sprite(equipmentIcon(index), width: compact ? 42 : 52, height: compact ? 42 : 52),
          gap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: gameText(compact ? 12 : 13, color: GameColors.ink, height: 1.15)),
                _Stars(stars, size: compact ? 17 : 19),
                Text(
                  '${item.effect}: +%${trNumber(stars * item.bonus, 3)}',
                  style: gameText(11, color: const Color(0xFF58738A), height: 1.2),
                ),
              ],
            ),
          ),
          gap,
          SizedBox(
            width: compact ? 64 : 74,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (parts) ...[button('5 parça', () => c.pressEquipment(index, useParts: true)), const SizedBox(height: 4)],
                button(
                  stars >= 3 ? 'MAKS.' : '₺${fmt(c.equipmentCost(index))}',
                  () => c.pressEquipment(index),
                  enabled: stars < 3 && c.state.money >= c.equipmentCost(index),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars(this.stars, {required this.size});
  final int stars;
  final double size;

  @override
  Widget build(BuildContext context) => Text(
    '${'★' * stars}${'☆' * (3 - stars)}',
    semanticsLabel: '$stars / 3 yıldız',
    style: TextStyle(
      fontSize: size,
      height: 1.05,
      letterSpacing: 1,
      color: const Color(0xFFFFBF20),
      shadows: [
        ...outlineShadows(const Color(0xFF8B5012), .7),
        const Shadow(color: Color(0xFF6D4A08), offset: Offset(0, 1)),
      ],
    ),
  );
}
