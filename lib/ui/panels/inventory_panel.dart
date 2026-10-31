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

  List<Widget> _athletes() {
    return [for (var i = 0; i < animals.length; i++) AthleteCard(c: c, id: i)];
  }

  List<Widget> _equipment() => [
    const PanelText(
      'Her ekipman en fazla $maxStars yıldıza yükselir. Etkileri sonraki yarışta uygulanır.',
      size: 12,
      color: GameColors.slate,
      bottom: 8,
    ),
    for (var i = 0; i < equipmentItems.length; i++) ...[if (i > 0) const SizedBox(height: 7), EquipmentCard(c: c, index: i)],
  ];

  List<Widget> _items() {
    final s = c.state;
    final cards = s.trainingCards.entries
        .where((e) => e.value > 0)
        .map((e) => '${branchLabel(e.key)} ×${e.value}${s.armedCards.contains(e.key) ? ' (hazır)' : ''}')
        .join(', ');
    final branchCards = s.trainingCards[s.branch] ?? 0, armed = s.armedCards.contains(s.branch);
    return [
      ItemCard(
        leading: const RewardKindIcon('parts'),
        title: 'Ekipman parçası ×${s.equipmentParts}',
        small: '$partsPerStar parça ile bir ekipmanı yıldızla geliştir ya da $partsPerChest parçayı Spor Çantasına çevir',
        actions: [_cardAction('Çanta', c.pressTradeParts, enabled: s.equipmentParts >= partsPerChest)],
      ),
      ItemCard(
        leading: const RewardKindIcon('card'),
        title: 'Antrenman kartları',
        small:
            '${cards.isEmpty ? 'Henüz yok' : cards} · Hazırladığın kart, o branşın bir sonraki yarışında kullanılır: '
            'hız/mesafe/kilo +%${trNumber(cardBoost * 100)}, okçulukta her oka +${trNumber(cardArchery, 1)}',
        actions: [_cardAction(armed ? 'Beklet' : 'Hazırla', () => c.toggleTrainingCard(s.branch), enabled: armed || branchCards > 0)],
      ),
      ItemCard(
        leading: const RewardKindIcon('cosmetic'),
        title: 'Avatar çerçeveleri',
        small: '${s.cosmetics.length} / 4 açık · Tekrarı parçaya dönüşür',
        actions: [_cardAction('Seç', () => c.open('cosmetics'))],
      ),
      ItemCard(
        leading: const RewardKindIcon('ticket'),
        title: 'Çark bileti ×${s.spinTickets}',
        small: 'Ödül çarkında bir kez kullanılır',
        actions: [_cardAction('Aç', () => c.open('wheel'))],
      ),
      ItemCard(
        leading: const RewardKindIcon('chest'),
        title: 'Spor Çantaları ×${s.chests + s.cupChests + s.championChests}',
        small: 'Normal ${s.chests} · Kupa ${s.cupChests} · Şampiyon ${s.championChests}',
        actions: [_cardAction('Aç', () => c.open('chests'))],
      ),
      ItemCard(
        leading: const RewardKindIcon('boost'),
        title: '2x gelir kuponu ×${s.boostTokens}',
        small: '3 dakika boyunca geliri ikiye katlar (2x sürüyorsa uzatır)',
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
    final parts = stars < maxStars && c.state.equipmentParts >= partsPerStar;
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
                // Mevcut yıldızlarla gerçek etki; yıldız yoksa bir yıldızın etkisi.
                Text(
                  [for (final (where, perStar) in item.effects) '$where +%${trNumber(perStar * (stars == 0 ? 1 : stars), 1)}'].join(' · ') +
                      (stars == 0 ? ' (1 yıldızda)' : ''),
                  style: gameText(11.5, color: GameColors.slate, height: 1.2),
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
                if (parts) ...[button('$partsPerStar parça', () => c.pressEquipment(index, useParts: true)), const SizedBox(height: 4)],
                button(
                  stars >= maxStars ? 'MAKS.' : '₺${fmt(c.equipmentCost(index))}',
                  () => c.pressEquipment(index),
                  enabled: stars < maxStars && c.state.money >= c.equipmentCost(index),
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
  Widget build(BuildContext context) => Semantics(
    label: '$stars / $maxStars yıldız',
    excludeSemantics: true,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dolu yıldız altın, boş yıldız gri: kaç yıldız olduğu bir bakışta okunur.
        for (var i = 0; i < maxStars; i++)
          Text(
            '★',
            style: TextStyle(
              fontSize: size,
              height: 1.05,
              color: i < stars ? const Color(0xFFFFBF20) : const Color(0xFFCBD3D8),
              shadows: outlineShadows(i < stars ? const Color(0xFF8B5012) : const Color(0xFF8C99A3), .7),
            ),
          ),
      ],
    ),
  );
}

/// Sporcu kartı: yüz, ad, kimlik ve uzmanlık etiketleri; seçili kart yeşil, kilitli kart açılma ilerlemesiyle.
class AthleteCard extends StatelessWidget {
  const AthleteCard({super.key, required this.c, required this.id});
  final GameController c;
  final int id;

  @override
  Widget build(BuildContext context) {
    final a = animals[id];
    final s = c.state;
    final locked = s.races < a.unlock;
    final selected = s.selected == id;
    Widget tag(String text, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(9)),
      child: Text(text, style: gameText(12, color: GameColors.ink, height: 1.2)),
    );
    final card = Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
      decoration: flatCardDecoration(radius: 18, color: selected ? const Color(0xFFF0FBE6) : GameColors.row),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: selected ? GameColors.greenShade : GameColors.ink, width: 2.5),
            ),
            alignment: Alignment.center,
            child: Art(a.art, width: 44, height: 44, radius: BorderRadius.circular(22)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.name, style: gameText(17, color: GameColors.ink, height: 1.1)),
                const SizedBox(height: 4),
                if (locked) ...[
                  Row(
                    children: [
                      Expanded(
                        child: GameProgressBar(value: s.races / a.unlock, label: 'Açılma', height: 11),
                      ),
                      const SizedBox(width: 6),
                      Text('${s.races}/${a.unlock} yarış', style: gameText(12, color: GameColors.slate, height: 1)),
                    ],
                  ),
                ] else
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: [tag(a.role, const Color(0xFFDDEBFA)), for (final t in specialtyTags(id)) tag(t, const Color(0xFFFFEBB8))],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (locked)
            const LockedMark(size: 30)
          else if (selected)
            const SelectedTag()
          else
            RaisedButton('Seç', onTap: () => c.selectAnimal(id), enabled: c.race == null, height: 38, minWidth: 64),
        ],
      ),
    );
    return locked ? Opacity(opacity: .75, child: card) : card;
  }
}
