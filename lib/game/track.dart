import 'dart:math';

/// Pist geometrisi: sporcuların sahadaki yüzde konumları arena görsellerine göre ölçüldü
/// (stadium.png, hurdle-arena.png, swim-arena.png; 1536×1024).
/// İlerleme 0'da sporcu başlangıç çizgisinde, 1'de bitiş çizgisinde durur.

/// Engelli koşu: başlangıç çizgisi %7,2, damalı bitiş %94; kulvar ortaları.
const hurdleStartX = 7.2, hurdleFinishX = 94.0;
double hurdleLaneY(int lane) => 35.5 + lane * 9.2;

/// Engellerin yarıştaki yeri (ilerleme) ve sahadaki x'i.
const hurdleMarks = [.2, .42, .64, .84];
double hurdleX(double progress) => hurdleStartX + progress * (hurdleFinishX - hurdleStartX);

/// Yüzme: beyaz başlangıç çizgisi %7, karşı duvar (damalı) %93,8.
const swimStartX = 7.0, swimFinishX = 93.8;
double swimLaneY(int lane) => 38.0 + lane * 8;

/// 100 m sahası görseli `BoxFit.cover` ile alttan hizalı çizilir: saha oranı 1,72, görsel 1,5;
/// görselin üst %12,8'i kırpılır.
const sprintFieldAspect = 1.72;
const _imageW = 1536.0, _imageH = 1024.0;
const _visibleH = 1.5 / sprintFieldAspect;

/// Stadyum pisti: 4 kulvar, saat yönünün tersine. Başlangıç sağ üstteki kademeli çizgilerde
/// (dış kulvar önde), rota üst düzlük → sol viraj → alt düzlük, bitiş alt düzlükteki damalı
/// çizgi. Kulvar 0 en içte. Ölçüler görsel pikseli.
class SprintTrack {
  SprintTrack._(this._points, this._lengths);

  static const lanes = 4;
  static const _finishX = 768.0, _cy = 598.4;

  /// İç ve dış kulvar sınırları: viraj merkezleri (sol, sağ) ve yarıçaplar (yatay, dikey).
  static const _inner = (left: 359.0, right: 1180.0, rx: 75.0, ry: 70.5);
  static const _outer = (left: 376.0, right: 1156.0, rx: 301.0, ry: 237.5);

  /// Kademeli başlangıç çizgilerinin sağ virajdaki açısı (tepeden, derece), içten dışa.
  static const _startAngle = [44.0, 25.5, 16.0, 8.0];

  static final List<SprintTrack> _lanes = [for (var k = 0; k < lanes; k++) _build(k)];

  final List<Point<double>> _points;
  final List<double> _lengths;

  static SprintTrack _build(int lane) {
    final f = (lane + .5) / lanes;
    double mix(double a, double b) => a + (b - a) * f;
    final left = mix(_inner.left, _outer.left), right = mix(_inner.right, _outer.right);
    final rx = mix(_inner.rx, _outer.rx), ry = mix(_inner.ry, _outer.ry);
    final pts = <Point<double>>[];
    // Sağ viraj: başlangıç açısından tepeye (saat yönünün tersine).
    final start = _startAngle[lane] * pi / 180;
    for (var i = 0; i <= 12; i++) {
      final a = start * (1 - i / 12);
      pts.add(Point(right + rx * sin(a), _cy - ry * cos(a)));
    }
    // Üst düzlük sola, sol viraj (tepeden dibe), alt düzlük sağa bitiş çizgisine.
    pts.add(Point(left, _cy - ry));
    for (var i = 1; i <= 36; i++) {
      final a = pi * i / 36;
      pts.add(Point(left - rx * sin(a), _cy - ry * cos(a)));
    }
    pts.add(Point(_finishX, _cy + ry));
    final lengths = <double>[0];
    for (var i = 1; i < pts.length; i++) {
      lengths.add(lengths.last + pts[i].distanceTo(pts[i - 1]));
    }
    return SprintTrack._(pts, lengths);
  }

  /// Kulvarda [progress] (0–1) oranındaki nokta, sahanın yüzdesi olarak.
  static ({double x, double y}) point(double progress, int lane) {
    final t = _lanes[lane.clamp(0, lanes - 1)];
    final target = progress.clamp(0.0, 1.0) * t._lengths.last;
    var i = 1;
    while (i < t._lengths.length - 1 && t._lengths[i] < target) {
      i++;
    }
    final a = t._points[i - 1], b = t._points[i];
    final span = t._lengths[i] - t._lengths[i - 1];
    final u = span == 0 ? 0.0 : (target - t._lengths[i - 1]) / span;
    final px = a.x + (b.x - a.x) * u, py = a.y + (b.y - a.y) * u;
    return (x: px / _imageW * 100, y: (py / _imageH - (1 - _visibleH)) / _visibleH * 100);
  }
}
