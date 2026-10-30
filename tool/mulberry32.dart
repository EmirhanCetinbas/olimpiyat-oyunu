import 'dart:math';

/// Web referansındaki `Math.random` yerine konan mulberry32 ile aynı dizi;
/// iki taraf aynı tohumla aynı yarışı oynar.
class Mulberry32 implements Random {
  Mulberry32(int seed) : _a = seed.toSigned(32);
  int _a;

  static int _imul(int a, int b) => (a.toSigned(32) * b.toSigned(32)).toSigned(32);

  @override
  double nextDouble() {
    _a = (_a + 0x6D2B79F5).toSigned(32);
    var t = _imul(_a ^ (_a.toUnsigned(32) >> 15), 1 | _a);
    t = (t + _imul(t ^ (t.toUnsigned(32) >> 7), 61 | t)).toSigned(32) ^ t;
    return (t ^ (t.toUnsigned(32) >> 14)).toUnsigned(32) / 4294967296;
  }

  @override
  int nextInt(int max) => (nextDouble() * max).floor();

  @override
  bool nextBool() => nextDouble() < .5;
}
