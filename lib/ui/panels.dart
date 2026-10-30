import 'package:flutter/material.dart';

import '../game/controller.dart';
import '../game/data.dart';
import '../game/format.dart';
import '../game/state.dart';
import 'theme.dart';
import 'widgets.dart';

const _muted = Color(0xFF66806D);

Widget _p(String text, {TextAlign? align, double size = 14, Color color = ink, double bottom = 11}) => Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Text(text, textAlign: align, style: nunito(size, weight: 700, color: color, height: 1.4)),
    );

Widget _mutedText(String text) => _p(text, size: 12, color: _muted);

/// `.row`
Widget _row(List<Widget> children, {bool last = false, bool locked = false}) {
  final row = Container(
    padding: const EdgeInsets.symmetric(vertical: 9),
    decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: Color(0xFFDCE1C7)))),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(width: 8), children[i]],
    ]),
  );
  return locked ? Opacity(opacity: .6, child: row) : row;
}

Widget _rowTitle(String title, [String? small]) => Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: nunito(14, color: ink)),
        if (small != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(small, style: nunito(11.7, weight: 700, color: const Color(0xFF68826C))),
          ),
      ]),
    );

/// `.modal-stat`
Widget _stats(List<(String, String)> items) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: GBox(
              color: const Color(0xFFE7F4D4),
              borderColor: const Color(0xFFBFD3A7),
              borderWidth: 2,
              radius: 10,
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 9),
              child: Column(children: [
                Text(items[i].$1, style: nunito(20, color: ink)),
                Text(items[i].$2, textAlign: TextAlign.center, style: nunito(11, color: ink)),
              ]),
            ),
          ),
        ],
      ]),
    );

Widget panelContent(GameController c, ModalSpec spec) => switch (spec.key) {
      'profile' => _ProfilePanel(c),
      'inventory' => _inventory(c),
      'chests' => _chests(c),
      'chests-result' => _chestResult(c, spec.arg as ChestItem),
      'cosmetics' => _cosmetics(c),
      'wheel' => _wheel(c),
      'team' => _team(c),
      'league' => _league(c),
      'tournament' => _tournament(c),
      'camp' => _camp(c),
      'shop' => _shop(c),
      'branches' => _branches(c),
      'info' => _info(c, spec.arg as int),
      'support' => _support(c),
      'reset' => _reset(c),
      _ => const SizedBox.shrink(),
    };

class _ProfilePanel extends StatefulWidget {
  const _ProfilePanel(this.c);
  final GameController c;

  @override
  State<_ProfilePanel> createState() => _ProfilePanelState();
}

class _ProfilePanelState extends State<_ProfilePanel> {
  late final _name = TextEditingController(text: widget.c.state.name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _p('Takımının adı'),
      Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 10),
        child: TextField(
          controller: _name,
          maxLength: 24,
          style: nunito(14, color: ink),
          decoration: InputDecoration(
            counterText: '',
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(8),
            semanticCounterText: 'Takım adı',
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF89A79A), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFFCA39), width: 2),
            ),
          ),
        ),
      ),
      ActionButton('Kaydet', onTap: () => c.saveName(_name.text)),
      _stats([('${c.level}', 'Seviye'), ('${c.state.races}', 'Yarış'), ('${c.state.wins}', 'Zafer')]),
      _mutedText(c.storageOK
          ? 'İlerlemen otomatik olarak bu cihazda saklanır.'
          : 'Cihaz kaydı kullanılamıyor; oyunu kapatırsan ilerleme kaybolabilir.'),
    ]);
  }
}

// ---------------- Envanter ----------------

Widget _inventoryCard({required Widget leading, required String title, required String small, List<Widget> actions = const [], bool locked = false}) {
  final card = Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFD5E0D6)))),
    child: Row(children: [
      leading,
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: nunito(14, color: ink)),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(small, style: nunito(12, color: const Color(0xFF57738A), height: 1.3)),
          ),
        ]),
      ),
      for (final a in actions) ...[const SizedBox(width: 10), a],
    ]),
  );
  return locked ? Opacity(opacity: .6, child: card) : card;
}

Widget _emoji(String e) => SizedBox(width: 42, child: Text(e, textAlign: TextAlign.center, style: const TextStyle(fontSize: 29)));

/// `.inventory-card>button:not(.modal-action)`
Widget _smallGreen(String label, VoidCallback onTap, {bool enabled = true}) => ActionButton(
      label,
      onTap: onTap,
      enabled: enabled,
      fontSize: 12,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      borderColor: const Color(0xFF17752D),
      gradient: const [Color(0xFF5FE347), Color(0xFF17B72D)],
    );

Widget _modalAction(String label, VoidCallback onTap, {bool enabled = true}) =>
    ActionButton(label, onTap: onTap, enabled: enabled, fontSize: 12, padding: const EdgeInsets.all(6));

Widget _inventory(GameController c) {
  const tabs = [('athletes', 'Sporcular'), ('equipment', 'Ekipman'), ('items', 'Eşyalar')];
  final header = Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: Row(children: [
      for (var i = 0; i < tabs.length; i++) ...[
        if (i > 0) const SizedBox(width: 5),
        Expanded(
          child: Btn(
            onTap: () => c.setInventoryTab(tabs[i].$1),
            child: GBox(
              gradient: c.inventoryTab == tabs[i].$1
                  ? vGradient(const [Color(0xFF75EB44), Color(0xFF16BC2A)])
                  : vGradient(const [Color(0xFFF8FBF6), Color(0xFFE5EDF1)]),
              borderColor: c.inventoryTab == tabs[i].$1 ? const Color(0xFF15852B) : const Color(0xFF17344C),
              borderWidth: 2,
              radius: 10,
              insets: c.inventoryTab == tabs[i].$1 ? const [Inset(Color(0x7AFFFFFF), dy: 2)] : const [],
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 7),
              alignment: Alignment.center,
              child: Text(tabs[i].$2, style: nunito(12, color: c.inventoryTab == tabs[i].$1 ? Colors.white : ink)),
            ),
          ),
        ),
      ],
    ]),
  );
  final s = c.state;
  if (c.inventoryTab == 'athletes') {
    return Column(children: [
      header,
      for (var i = 0; i < animals.length; i++)
        _inventoryCard(
          locked: s.races < animals[i].unlock,
          leading: Art(animals[i].art, width: 42, height: 42),
          title: animals[i].name,
          small: '${animals[i].trait} · Uzmanlık: ${specialtyLabel(i)}',
          actions: [
            _modalAction(
              s.races < animals[i].unlock ? '${animals[i].unlock} yarış' : s.selected == i ? 'Seçili' : 'Seç',
              () => c.selectAnimal(i),
              enabled: s.races >= animals[i].unlock && c.race == null,
            ),
          ],
        ),
    ]);
  }
  if (c.inventoryTab == 'equipment') {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      header,
      _p('Her ekipman en fazla 3 yıldıza yükselir. Etkileri sonraki yarışta uygulanır.', size: 12, color: const Color(0xFF57738A), bottom: 8),
      for (var i = 0; i < equipmentItems.length; i++) ...[
        if (i > 0) const SizedBox(height: 7),
        _equipmentCard(c, i),
      ],
    ]);
  }
  final cards = s.trainingCards.entries.where((e) => e.value > 0).map((e) => '${branchLabel(e.key)} ×${e.value}').join(', ');
  return Column(children: [
    header,
    _inventoryCard(leading: _emoji('⚙️'), title: 'Ekipman parçası ×${s.equipmentParts}', small: '5 parça ile bir ekipmanı yıldızla geliştir'),
    _inventoryCard(
      leading: _emoji('🎫'),
      title: 'Antrenman kartları',
      small: '${cards.isEmpty ? 'Henüz yok' : cards} · Sonraki ilgili yarışta otomatik kullanılır',
    ),
    _inventoryCard(
      leading: _emoji('✨'),
      title: 'Avatar çerçeveleri',
      small: '${s.cosmetics.length} / 4 açık · Tekrarı parçaya dönüşür',
      actions: [_smallGreen('Seç', () => c.open('cosmetics'))],
    ),
    _inventoryCard(
      leading: const Art('ticket', width: 42, height: 42),
      title: 'Çark bileti ×${s.spinTickets}',
      small: 'Ödül çarkında bir kez kullanılır',
      actions: [_modalAction('Aç', () => c.open('wheel'))],
    ),
    _inventoryCard(
      leading: _emoji('🎁'),
      title: 'Spor Çantaları ×${s.chests + s.cupChests + s.championChests}',
      small: 'Normal ${s.chests} · Kupa ${s.cupChests} · Şampiyon ${s.championChests}',
      actions: [_smallGreen('Aç', () => c.open('chests'))],
    ),
    _inventoryCard(
      leading: _emoji('⚡'),
      title: '2x gelir kuponu ×${s.boostTokens}',
      small: '30 saniye boyunca geliri ikiye katlar',
      actions: [_smallGreen('Kullan', c.useBoostToken, enabled: s.boostTokens >= 1)],
    ),
  ]);
}

Widget _equipmentCard(GameController c, int i) {
  final item = equipmentItems[i];
  final stars = c.state.equipmentStars[i];
  final parts = stars < 3 && c.state.equipmentParts >= 5;
  Widget button(String label, VoidCallback onTap, {bool enabled = true}) => ActionButton(
        label,
        onTap: onTap,
        enabled: enabled,
        full: false,
        fontSize: 11,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 7),
        borderColor: const Color(0xFF117427),
        borderWidth: 1.5,
        gradient: const [Color(0xFF66E843), Color(0xFF12B82B)],
      );
  return GBox(
    gradient: vGradient(const [Color(0xFFFFFEF6), Color(0xFFF8FAED)]),
    borderColor: const Color(0xFFCBD4D7),
    borderWidth: 2,
    radius: 12,
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
    child: Row(children: [
      Sprite(equipmentIcon(i), width: 52, height: 52),
      const SizedBox(width: 7),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.name, style: nunito(13, color: ink, height: 1.15)),
          Text(
            '${'★' * stars}${'☆' * (3 - stars)}',
            semanticsLabel: '$stars / 3 yıldız',
            style: TextStyle(
              fontSize: 19,
              height: 1.05,
              letterSpacing: 1,
              color: const Color(0xFFFFBF20),
              shadows: [...outlineShadows(const Color(0xFF8B5012), .7), const Shadow(color: Color(0xFF6D4A08), offset: Offset(0, 1))],
            ),
          ),
          Text('${item.effect}: +%${trNumber(stars * item.bonus, 3)}', style: nunito(11, color: const Color(0xFF58738A), height: 1.2)),
        ]),
      ),
      const SizedBox(width: 7),
      SizedBox(
        width: 74,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (parts) ...[button('5 parça', () => c.pressEquipment(i, useParts: true)), const SizedBox(height: 4)],
          button(stars >= 3 ? 'MAKS.' : '₺${fmt(c.equipmentCost(i))}', () => c.pressEquipment(i),
              enabled: stars < 3 && c.state.money >= c.equipmentCost(i)),
        ]),
      ),
    ]),
  );
}

// ---------------- Çantalar ----------------

Widget _chests(GameController c) {
  final p = c.state.pendingChest;
  if (p != null) {
    return Column(children: [
      Align(alignment: Alignment.centerLeft, child: _p('${chestNames[p.type]} · Bir çanta seç.')),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Btn(
                onTap: () => c.pressChooseChest(i),
                semanticLabel: '${i + 1}. çantayı aç',
                child: GBox(
                  constraints: const BoxConstraints(minHeight: 112),
                  gradient: vGradient(const [Color(0xFFFFF8DB), Color(0xFFFFCC63)]),
                  borderColor: const Color(0xFF122C3D),
                  borderWidth: 3,
                  radius: 14,
                  insets: const [Inset(Colors.white, dy: 3)],
                  shadows: const [BoxShadow(color: Color(0x44142D36), offset: Offset(0, 4))],
                  alignment: Alignment.center,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('🎁', style: TextStyle(fontSize: 39)),
                    const SizedBox(height: 4),
                    Text('${i + 1}. Çanta', style: nunito(11, color: ink)),
                  ]),
                ),
              ),
            ),
          ],
        ]),
      ),
      _mutedText('Seçimin kaydedilir; menüden çıksan da çanta burada kalır.'),
    ]);
  }
  final s = c.state;
  return Column(children: [
    _p('Çantaların envanterde. Her 5 yarışta yeni bir Spor Çantası kazanırsın.'),
    _row([_rowTitle('Spor Çantası ×${s.chests}'), ActionButton('Aç', onTap: () => c.pressOpenChest('normal'), enabled: s.chests >= 1)]),
    _row([_rowTitle('Kupa Çantası ×${s.cupChests}'), ActionButton('Aç', onTap: () => c.pressOpenChest('cup'), enabled: s.cupChests >= 1)]),
    _row(
      [_rowTitle('Şampiyon Çantası ×${s.championChests}'), ActionButton('Aç', onTap: () => c.pressOpenChest('champion'), enabled: s.championChests >= 1)],
      last: true,
    ),
  ]);
}

Widget _chestResult(GameController c, ChestItem prize) => Column(children: [
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        builder: (context, t, child) => Opacity(
          opacity: .3 + .7 * t,
          child: Transform.scale(scale: .75 + .25 * t, child: child),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF142D42), width: 3),
              borderRadius: BorderRadius.circular(16),
              gradient: const RadialGradient(
                radius: .75,
                colors: [Color(0xFFFFF4AD), Color(0xFFFFD25D), Color(0xFFF7AE3F)],
                stops: [0, .65, 1],
              ),
            ),
            child: Column(children: [
              Text(prize.icon, style: const TextStyle(fontSize: 55)),
              const SizedBox(height: 8),
              Text(prize.label, textAlign: TextAlign.center, style: nunito(18, color: ink)),
            ]),
          ),
        ),
      ),
      ActionButton('Envantere dön', full: true, onTap: () => c.open('inventory')),
    ]);

Widget _cosmetics(GameController c) {
  final s = c.state;
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _p("Yeni çerçeveler Şampiyon Çantası'ndan çıkabilir."),
    if (s.cosmetics.isEmpty) _p('Henüz çerçeve kazanmadın.'),
    for (var k = 0; k < s.cosmetics.length; k++)
      _row([
        Expanded(child: Text('✨ ${cosmeticNames[s.cosmetics[k]]}', style: nunito(14, color: ink))),
        ActionButton(s.selectedCosmetic == s.cosmetics[k] ? 'Seçili' : 'Seç', onTap: () => c.selectCosmetic(s.cosmetics[k])),
      ], last: k == s.cosmetics.length - 1),
  ]);
}

// ---------------- Ödüller ----------------

Widget _wheel(GameController c) {
  final used = c.state.spinDate == c.todayKey;
  return Column(children: [
    const Text('🎡', textAlign: TextAlign.center, style: TextStyle(fontSize: 90, height: 1.3)),
    _p('Günlük ücretsiz çeviriş ${used ? 'kullanıldı' : 'hazır'}. Ek bilet: ${c.state.spinTickets}', align: TextAlign.center, size: 15),
    ActionButton(
      used ? '1 biletle çevir' : 'Ücretsiz çevir',
      full: true,
      fontSize: 15,
      onTap: c.spinWheel,
      enabled: !(used && c.state.spinTickets < 1),
    ),
    Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text('₺5K–₺20K, elmas veya çark bileti kazan.',
          textAlign: TextAlign.center, style: nunito(12, weight: 700, color: const Color(0xFF536B85), height: 1.4)),
    ),
  ]);
}

// ---------------- Takım, lig, kupa, kamp, mağaza, branşlar ----------------

Widget _team(GameController c) {
  final s = c.state;
  return Column(children: [
    for (var i = 0; i < animals.length; i++)
      _row(
        [
          Art(animals[i].art, width: 36, height: 36, radius: BorderRadius.circular(18)),
          _rowTitle(animals[i].name, '${animals[i].trait} · Uzmanlık: ${specialtyLabel(i)}'),
          ActionButton(
            s.races < animals[i].unlock ? '${animals[i].unlock} yarış' : s.selected == i ? 'Seçili' : 'Seç',
            onTap: () => c.selectAnimal(i),
            enabled: s.races >= animals[i].unlock && c.race == null,
          ),
        ],
        locked: s.races < animals[i].unlock,
        last: i == animals.length - 1,
      ),
    if (c.race != null) _mutedText('Sporcunu yarış bitince değiştirebilirsin.'),
  ]);
}

Widget _league(GameController c) {
  final s = c.state;
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _p('Her 10 yarış bir sezon. Madalyalar ve rekorlar takımının ilerlemesini gösterir.'),
    _stats([('${s.races ~/ 10 + 1}', 'Sezon'), ('${s.races % 10}/10', 'Yarış'), ('${s.medals}', 'Madalya')]),
    _row([_rowTitle('En iyi derecen'), Text(s.best != null ? '${s.best!.toStringAsFixed(2)} sn' : 'Henüz yok', style: nunito(14, color: ink))]),
    _row([_rowTitle('Toplam zafer'), Text('${s.wins}', style: nunito(14, color: ink))], last: true),
    _mutedText('Rakipler bilgisayar tarafından yönetilir.'),
  ]);
}

Widget _tournament(GameController c) {
  final t = c.state.tournament;
  final branch = t?.branch ?? c.state.branch;
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _p(t != null ? 'Branş: ${branchLabel(branch)}' : 'Seçili branşta üç yarışlık kupa başlat.'),
    _stats([('${t?.attempts ?? 0}/3', 'Yarış'), ('${t?.podiums ?? 0}/2', 'Gerekli madalya'), ('${c.state.tournamentCups}', 'Kupa')]),
    _mutedText('Üç yarışta en az iki kez ilk üçe gir: Kupa Çantası ve 1 SP kazan.'),
    ActionButton(
      t != null && t.attempts >= 3 ? 'Yeni turnuva' : 'Turnuvayı başlat',
      full: true,
      onTap: c.pressTournamentStart,
      enabled: !(c.race != null || (t != null && t.attempts < 3)),
    ),
  ]);
}

Widget _camp(GameController c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _p('Kampı büyüt; takım gücünü ve sporcularının gelişimini artır.'),
      _stats([('${c.state.camp}', 'Kamp seviyesi'), ('${100 + (c.state.camp - 1) * 10}', 'Kamp gücü'), ('+10', 'Sonraki seviye')]),
      ActionButton('Kampı geliştir · ₺${fmt(c.campCost())}', full: true, onTap: c.buyCamp, enabled: c.state.money >= c.campCost()),
    ]);

Widget _shop(GameController c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _p('Oyun içi ödüller. Gerçek para ile satın alma yok.'),
      _row([_rowTitle('Günlük ödül', '7 günlük ödül takvimi'), ActionButton('Aç', onTap: () => c.openPanel('daily-rewards'))]),
      _row(
        [_rowTitle('Sponsor paketi', '+₺10.000 · 5 elmas'), ActionButton('Al', onTap: c.buyCoins, enabled: c.state.gems >= 5)],
        last: true,
      ),
    ]);

Widget _branches(GameController c) {
  const list = [
    ('sprint', '100 metre koşu'),
    ('hurdles', 'Engelli koşu'),
    ('swim', 'Yüzme'),
    ('longjump', 'Uzun atlama'),
    ('weights', 'Halter'),
    ('archery', 'Okçuluk'),
  ];
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _p('Oynamak istediğin yarışı seç.'),
    Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: ActionButton('🏆 Üç Yarışlık Kupa', full: true, onTap: () => c.open('tournament')),
    ),
    for (var i = 0; i < list.length; i++)
      _row([
        _rowTitle(list[i].$2),
        ActionButton(c.state.branch == list[i].$1 ? 'Seçili' : 'Oyna', onTap: () => c.selectBranch(list[i].$1), enabled: c.race == null),
      ], last: i == list.length - 1),
  ]);
}

Widget _info(GameController c, int i) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _p(c.activeUpgrades[i].desc),
      _mutedText('Yükseltmelerin yarış etkisi bir sonraki yarışta uygulanır. Karttaki yüzde, antrenman gelişimini gösterir.'),
    ]);

Widget _support(GameController c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _p('İlerlemen bu cihaza otomatik kaydedilir. Müzik ve ses düzeylerini Ayarlar bölümünden değiştirebilirsin.'),
      _p('Titreşim, cihaz destekliyorsa çalışır.'),
      ActionButton('Ayarlara dön', full: true, onTap: () => c.open('settings')),
    ]);

Widget _reset(GameController c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _p('Bu cihazdaki bütün yarışlar, seviyeler ve ödüller silinecek.'),
      ActionButton('Vazgeç', full: true, onTap: () => c.openPanel('settings')),
      ActionButton('Evet, sıfırla', full: true, onTap: c.confirmReset),
    ]);
