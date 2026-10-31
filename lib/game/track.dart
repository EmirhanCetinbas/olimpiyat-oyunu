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

/// 100 m sahası görseli `BoxFit.cover` ile ortalı çizilir: saha oranı 1,72, görsel 1,5;
/// görselin üstünden ve altından %6,4'er kırpılır (üstte tribün, altta süsler yarım görünür).
const sprintFieldAspect = 1.72;
const _imageW = 1536.0, _imageH = 1024.0;
const _visibleH = 1.5 / sprintFieldAspect;
const _cropTop = (1 - _visibleH) / 2;

/// Stadyum pisti: 4 kulvar, saat yönünün tersine. Başlangıç sağ virajın girişindeki kademeli
/// çizgilerde (dış kulvar önde), rota üst düzlük → sol viraj → alt düzlük, bitiş alt düzlükteki
/// damalı çizgi. Kulvar 0 en içte. Ölçüler görsel pikseli (kulvar ortaları, virajlara elips oturtuldu).
class SprintTrack {
  SprintTrack._(this._points, this._lengths);

  static const lanes = 4;
  static const _finishX = 768.0;

  /// Kulvar ortası: dikey merkez ve yarıçap; sol ve sağ virajın merkezi ve yatay yarıçapı.
  static const _lane = [
    (cy: 534.3, ry: 225.8, left: 433.9, leftRx: 266.0, right: 1102.8, rightRx: 260.0),
    (cy: 535.5, ry: 259.0, left: 435.1, leftRx: 303.0, right: 1103.1, rightRx: 296.0),
    (cy: 536.5, ry: 292.5, left: 438.9, leftRx: 342.0, right: 1098.6, rightRx: 336.0),
    (cy: 538.0, ry: 325.5, left: 444.1, leftRx: 383.0, right: 1088.3, rightRx: 383.0),
  ];

  /// Kademeli başlangıç çizgilerinin sağ virajdaki açısı (tepeden, derece), içten dışa.
  static const _startAngle = [23.3, 14.8, 8.9, 4.0];

  static final List<SprintTrack> _lanes = [for (var k = 0; k < lanes; k++) _build(k)];

  final List<Point<double>> _points;
  final List<double> _lengths;

  static SprintTrack _build(int lane) {
    final l = _lane[lane];
    final pts = <Point<double>>[];
    // Sağ viraj: başlangıç açısından tepeye (saat yönünün tersine).
    final start = _startAngle[lane] * pi / 180;
    for (var i = 0; i <= 12; i++) {
      final a = start * (1 - i / 12);
      pts.add(Point(l.right + l.rightRx * sin(a), l.cy - l.ry * cos(a)));
    }
    // Üst düzlük sola, sol viraj (tepeden dibe), alt düzlük sağa bitiş çizgisine.
    pts.add(Point(l.left, l.cy - l.ry));
    for (var i = 1; i <= 36; i++) {
      final a = pi * i / 36;
      pts.add(Point(l.left - l.leftRx * sin(a), l.cy - l.ry * cos(a)));
    }
    pts.add(Point(_finishX, l.cy + l.ry));
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
    return (x: px / _imageW * 100, y: (py / _imageH - _cropTop) / _visibleH * 100);
  }
}
