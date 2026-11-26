/// A small, fast pseudo-random generator (mulberry32).
///
/// It gives the same sequence for the same seed on Android, iOS and web, so a
/// seeded run lays out exactly the same level everywhere. `dart:math`'s
/// `Random` is not guaranteed to match between the VM and JavaScript.
class SeededRandom {
  SeededRandom(int seed) : _state = seed & 0xFFFFFFFF;

  int _state;

  /// Next unsigned 32-bit value.
  int nextUint32() {
    _state = (_state + 0x6D2B79F5) & 0xFFFFFFFF;
    var t = _state;
    t = _imul(t ^ (t >> 15), t | 1);
    t ^= (t + _imul(t ^ (t >> 7), t | 61)) & 0xFFFFFFFF;
    return (t ^ (t >> 14)) & 0xFFFFFFFF;
  }

  /// A double in [0, 1).
  double nextDouble() => nextUint32() / 4294967296.0;

  /// An int in [0, max).
  int nextInt(int max) => (nextDouble() * max).floor();

  /// True with probability [p].
  bool chance(double p) => nextDouble() < p;

  /// 32-bit integer multiply that behaves the same on the VM and on the web.
  static int _imul(int a, int b) {
    final aHi = (a >> 16) & 0xFFFF;
    final aLo = a & 0xFFFF;
    final bHi = (b >> 16) & 0xFFFF;
    final bLo = b & 0xFFFF;
    return ((aLo * bLo) + ((((aHi * bLo) + (aLo * bHi)) << 16) & 0xFFFFFFFF)) &
        0xFFFFFFFF;
  }
}
