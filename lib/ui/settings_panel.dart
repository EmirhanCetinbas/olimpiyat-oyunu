import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../game/controller.dart';
import 'theme.dart';
import 'widgets.dart';

const _panelInk = Color(0xFF0C2034);
const _headingInk = Color(0xFF102633);

/// settings.js `settingsIcon`: aynı SVG yolları.
Widget settingsIcon(String name, {double size = 34}) {
  if (name == 'shoe') return Art('shoe', width: size, height: size);
  const paths = {
    'music': '<path fill="url(#prefs-gold)" d="M23 34V12l25-5v23l-8 2V17l-9 2v19c0 12-19 15-19 4 0-6 6-9 11-8Z"/>',
    'sound':
        '<path fill="url(#prefs-blue)" d="M9 25h10L34 12v40L19 39H9Z"/><path d="M42 23q10 9 0 18m7-26q17 17 0 34" fill="none" stroke="#ffc72a"/>',
    'vibration':
        '<rect x="20" y="8" width="26" height="48" rx="5" fill="url(#prefs-blue)"/><path d="M27 14h12M30 49h6M11 19l-5 7 5 7-5 7m48-21 5 7-5 7 5 7" fill="none"/>',
    'pause': '<circle cx="32" cy="32" r="26" fill="#1aabf1"/><path d="M23 20h6v24h-6zm12 0h6v24h-6z" fill="white"/>',
    'save':
        '<path d="M15 49C-1 45 3 26 17 25 17 8 40 7 45 23c20-1 22 26 5 26Z" fill="#a9e7ff"/><path d="m23 34 7 7 15-16" fill="none" stroke="#1acb24" stroke-width="7"/>',
    'support': '<rect x="7" y="13" width="50" height="39" rx="6" fill="#eaf6ff"/><path d="m9 17 23 18 23-18" fill="#ff6256"/>',
    'reset': '<path d="M48 17A23 23 0 1 0 52 44l-10-5A12 12 0 1 1 40 25l-9 2 25 7V9Z" fill="#63df24"/>',
  };
  final svg =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none" stroke="#0c2034" stroke-width="3" '
      'stroke-linecap="round" stroke-linejoin="round"><defs>'
      '<linearGradient id="prefs-gold" x1="0" y1="0" x2=".3" y2="1"><stop offset="0" stop-color="#fff381"/><stop offset=".5" stop-color="#ffcf27"/><stop offset="1" stop-color="#f2a509"/></linearGradient>'
      '<linearGradient id="prefs-blue" x1="0" y1="0" x2=".8" y2="1"><stop offset="0" stop-color="#bdeaff"/><stop offset=".55" stop-color="#70b6df"/><stop offset="1" stop-color="#3981b2"/></linearGradient>'
      '</defs>${paths[name]}</svg>';
  return SizedBox(
    width: size,
    height: size,
    child: Stack(
      children: [
        // drop-shadow(0 2px #c6b792)
        Positioned(
          top: 2,
          left: 0,
          child: SvgPicture.string(svg, width: size, height: size, colorFilter: const ColorFilter.mode(Color(0xFFC6B792), BlendMode.srcIn)),
        ),
        SvgPicture.string(svg, width: size, height: size),
      ],
    ),
  );
}

/// Ayarlar: tamamen kodla kurulan panel (görsel ya da koordinat yaması yok).
class SettingsPanel extends StatelessWidget {
  const SettingsPanel(this.c, {super.key});
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final s = c.state;
    final width = MediaQuery.sizeOf(context).width;
    final narrow = width <= 360;
    Widget section(String title, List<Widget> rows) => Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 7, bottom: 5),
            child: Text(
              title,
              style: nunito(17, weight: 1000, color: _panelInk, height: 20 / 17, letterSpacing: -.3),
            ),
          ),
          ...rows,
        ],
      ),
    );
    Widget row(String icon, String label, Widget control, {bool audio = false}) => Container(
      constraints: const BoxConstraints(minHeight: 54),
      margin: const EdgeInsets.only(bottom: 6),
      child: GBox(
        gradient: angleGradient(110, const [Color(0xFFFFFCF1), Color(0xFFFFF9E9)]),
        borderColor: const Color(0xFF142A3B),
        borderWidth: 2,
        radius: 15,
        shadows: const [BoxShadow(color: Color(0x75D8CAA5), offset: Offset(0, 3))],
        insets: const [Inset(Colors.white, dy: 2)],
        padding: EdgeInsets.symmetric(horizontal: narrow ? 6 : 9, vertical: 6),
        constraints: const BoxConstraints(minHeight: 54),
        child: Row(
          children: [
            SizedBox(
              width: narrow ? 30 : 35,
              child: Center(child: settingsIcon(icon, size: narrow ? 30 : 34)),
            ),
            SizedBox(width: narrow ? 5 : 8),
            if (audio)
              SizedBox(
                width: narrow ? 66 : 76,
                child: Text(label, style: nunito(narrow ? 12 : 13, weight: 850, color: _panelInk, height: 1.1, letterSpacing: -.3)),
              )
            else
              Expanded(
                child: Text(label, style: nunito(narrow ? 12 : 13, weight: 850, color: _panelInk, height: 1.1, letterSpacing: -.3)),
              ),
            SizedBox(width: narrow ? 5 : 8),
            if (audio)
              Expanded(child: Align(alignment: Alignment.centerRight, child: control))
            else
              SizedBox(
                width: narrow ? 96 : 108,
                child: Align(alignment: Alignment.centerRight, child: control),
              ),
          ],
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF0B2635), width: 3),
        borderRadius: BorderRadius.circular(25),
        gradient: const RadialGradient(
          center: Alignment(-.4, -.5),
          radius: 1.1,
          colors: [Color(0xFFFFFBED), Color(0xFFFFF5DF)],
          stops: [0, .75],
        ),
        boxShadow: const [BoxShadow(color: Color(0x20061D25), offset: Offset(0, 8))],
      ),
      padding: EdgeInsets.fromLTRB(narrow ? 9 : 12, 0, narrow ? 9 : 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Heading(c),
          section('SES', [
            row('music', 'MÜZİK', _PrefsRange(value: s.musicVolume, label: 'Müzik', onChanged: c.setMusicVolume), audio: true),
            row('sound', 'SES', _PrefsRange(value: s.sound ? s.soundVolume : 0, label: 'Ses', onChanged: c.setSoundVolume), audio: true),
            row(
              'vibration',
              'TİTREŞİM',
              _PrefsSwitch(value: s.vibration, label: 'Titreşim', onChanged: c.setVibration, width: narrow ? 96 : 108),
              audio: true,
            ),
          ]),
          section('OYUN', [
            row(
              'shoe',
              'OTOMATİK YARIŞ',
              _PrefsSwitch(value: s.auto, label: 'Otomatik yarış', onChanged: c.setAutoSetting, width: narrow ? 96 : 108),
            ),
            row(
              'pause',
              'OYUNU DURAKLAT',
              _PrefsSwitch(value: c.paused, label: 'Oyunu duraklat', onChanged: c.setPaused, width: narrow ? 96 : 108),
            ),
          ]),
          section('KAYIT', [
            row(
              'save',
              'CİHAZ KAYDI',
              Semantics(
                liveRegion: true,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 150),
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: c.storageOK ? vGradient(const [Color(0xFFEEF7D6), Color(0xFFDAEDC4)]) : null,
                    color: c.storageOK ? null : const Color(0xFF8C9DAA),
                    border: Border.all(color: const Color(0xFFC9DDB4), width: 2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    c.storageOK ? 'AKTİF' : 'KAPALI',
                    style: nunito(14, weight: 1000, color: const Color(0xFF308040), height: 1.1),
                  ),
                ),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                Expanded(
                  child: _ActionTile(icon: 'support', label: 'DESTEK', onTap: c.openSupport, narrow: narrow),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionTile(icon: 'reset', label: 'İLERLEMEYİ\nSIFIRLA', onTap: c.askReset, narrow: narrow),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'SÜRÜM 1.0',
              textAlign: TextAlign.center,
              style: nunito(11, color: const Color(0xFF7B8988), height: 14 / 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.c);
  final GameController c;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final narrow = width <= 360;
    return LayoutBuilder(
      builder: (context, box) {
        final headingShadows = [
          for (final o in const [
            Offset(-2, -2),
            Offset(0, -2),
            Offset(2, -2),
            Offset(2, 0),
            Offset(2, 2),
            Offset(0, 3),
            Offset(-2, 2),
            Offset(-2, 0),
          ])
            Shadow(color: _headingInk, offset: o),
        ];
        return Padding(
          padding: EdgeInsets.only(left: box.maxWidth * (narrow ? .08 : .11), bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: GBox(
                  gradient: angleGradient(
                    170,
                    const [Color(0xFFFF8270), Color(0xFFFF6456), Color(0xFFFF6254), Color(0xFFFF5347)],
                    const [0, .2, .7, 1],
                  ),
                  borderColor: const Color(0xFF0A2033),
                  borderWidth: 3,
                  radius: 21,
                  shadows: const [BoxShadow(color: Color(0x75D4C39A), offset: Offset(0, 5))],
                  insets: const [Inset(Color(0xFFFFAD9F), dy: 5), Inset(Color(0xFFE34137), dy: -4)],
                  padding: const EdgeInsets.fromLTRB(3, 9, 3, 11),
                  alignment: Alignment.center,
                  child: Text(
                    'AYARLAR',
                    semanticsLabel: 'Ayarlar',
                    style: nunito(vwClamp(context, 27, 7.7, 38), color: Colors.white, height: 1.12, shadows: headingShadows),
                  ),
                ),
              ),
              SizedBox(width: narrow ? 7 : 10),
              Btn(
                onTap: c.closeModal,
                semanticLabel: 'Ayarları kapat',
                child: GBox(
                  width: 42,
                  height: 42,
                  gradient: angleGradient(135, const [Color(0xFF86FB69), Color(0xFF16C535)], const [0, .65]),
                  borderColor: _panelInk,
                  borderWidth: 3,
                  radius: 21,
                  insets: const [Inset(Color(0xFFB6FF99), dy: 3), Inset(Color(0xFF009D24), dy: -3)],
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      for (final angle in const [.785398, -.785398])
                        Transform.rotate(
                          angle: angle,
                          child: Container(
                            width: 25,
                            height: 7,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: const [BoxShadow(color: Color(0xFF203744), offset: Offset(0, 1))],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// `.prefs-range`: yeşil dolgulu kaydırıcı.
class _PrefsRange extends StatelessWidget {
  const _PrefsRange({required this.value, required this.label, required this.onChanged});
  final double value;
  final String label;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        const thumb = 28.0;
        void set(double dx) => onChanged(((dx - thumb / 2) / (w - thumb)).clamp(0.0, 1.0).toDouble());
        final fill = value.clamp(0.0, 1.0);
        return Semantics(
          slider: true,
          label: label,
          value: '${(fill * 100).round()}',
          increasedValue: '${((fill + .1).clamp(0, 1) * 100).round()}',
          decreasedValue: '${((fill - .1).clamp(0, 1) * 100).round()}',
          onIncrease: () => onChanged((fill + .1).clamp(0.0, 1.0).toDouble()),
          onDecrease: () => onChanged((fill - .1).clamp(0.0, 1.0).toDouble()),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => set(d.localPosition.dx),
            onHorizontalDragUpdate: (d) => set(d.localPosition.dx),
            child: SizedBox(
              height: 34,
              child: Stack(
                alignment: Alignment.centerLeft,
                clipBehavior: Clip.none,
                children: [
                  GBox(
                    width: w,
                    height: 19,
                    borderColor: const Color(0xFF193348),
                    borderWidth: 2,
                    radius: 20,
                    gradient: LinearGradient(
                      colors: const [Color(0xFF35C836), Color(0xFF35C836), Color(0xFFBFC8CF), Color(0xFFBFC8CF)],
                      stops: [0, fill, fill, 1],
                    ),
                    insets: const [Inset(Color(0x90FFFFFF), dy: 3), Inset(Color(0x3023463F), dy: -2)],
                  ),
                  Positioned(
                    left: (w - thumb) * fill,
                    child: Container(
                      width: thumb,
                      height: thumb,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0A2238), width: 2.5),
                        gradient: angleGradient(125, const [Colors.white, Color(0xFFEDF5FA), Color(0xFFC9D9E2)], const [0, .65, 1]),
                        boxShadow: const [BoxShadow(color: Color(0x40567084), offset: Offset(0, 2))],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// `.prefs-switch`: metin ve hareketli düğme ayrı alanlarda.
class _PrefsSwitch extends StatelessWidget {
  const _PrefsSwitch({required this.value, required this.label, required this.onChanged, required this.width});
  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    const height = 35.0, knob = 29.0;
    return Semantics(
      toggled: value,
      label: label,
      child: Btn(
        onTap: () => onChanged(!value),
        child: GBox(
          width: width,
          height: height,
          gradient: value
              ? vGradient(const [Color(0xFF42DE41), Color(0xFF1ACB28)])
              : vGradient(const [Color(0xFFC6D2D9), Color(0xFF9CABB5)]),
          borderColor: const Color(0xFF112C3C),
          borderWidth: 2,
          radius: 30,
          insets: value
              ? const [Inset(Color(0xFFCAFF9C), dy: 3), Inset(Color(0x30078E24), dy: -3)]
              : const [Inset(Color(0xFFDCE7ED), dy: 3)],
          child: Stack(
            children: [
              Positioned.fill(
                left: value ? 5 : 33 - 2,
                right: value ? 33 - 2 : 5,
                child: Center(
                  child: Text(
                    value ? 'AÇIK' : 'KAPALI',
                    maxLines: 1,
                    style: nunito(
                      width < 100 ? 11 : 12,
                      color: Colors.white,
                      height: 1,
                      shadows: const [Shadow(color: Color(0xFF23502D), offset: Offset(0, 1))],
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 150),
                left: value ? width - 4 - knob - 1 : 1,
                top: 1,
                child: Container(
                  width: knob,
                  height: knob,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF163344), width: 2),
                    gradient: angleGradient(130, const [Colors.white, Color(0xFFDCEBF0)]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.onTap, required this.narrow});
  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool narrow;

  @override
  Widget build(BuildContext context) => Btn(
    onTap: onTap,
    child: GBox(
      constraints: const BoxConstraints(minHeight: 50),
      gradient: vGradient(const [Color(0xFFFFFDF3), Color(0xFFFFF7E5)]),
      borderColor: const Color(0xFF102B40),
      borderWidth: 2,
      radius: 15,
      shadows: const [BoxShadow(color: Color(0x75D8CAA5), offset: Offset(0, 3))],
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          settingsIcon(icon, size: 31),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label, style: nunito(narrow ? 11 : 12, color: _panelInk, height: 1.1)),
          ),
        ],
      ),
    ),
  );
}
