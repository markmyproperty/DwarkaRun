import 'dart:math' as math;
import 'dart:ui';

enum FxKind { coin, gem, power, whoosh, dust }

/// Small screen-space sparks for pickups, near misses and crashes. A fixed
/// pool, so a busy run allocates nothing.
class FxParticles {
  static const _size = 96;

  final _x = List<double>.filled(_size, 0);
  final _y = List<double>.filled(_size, 0);
  final _vx = List<double>.filled(_size, 0);
  final _vy = List<double>.filled(_size, 0);
  final _life = List<double>.filled(_size, 0);
  final _max = List<double>.filled(_size, 1);
  final _r = List<double>.filled(_size, 1);
  final _color = List<int>.filled(_size, 0);
  final _streak = List<bool>.filled(_size, false);
  int _next = 0;
  final _rng = math.Random(5);
  final Paint _paint = Paint()..isAntiAlias = true;

  int get alive => _life.where((l) => l > 0).length;

  void burst(Offset at, FxKind kind) {
    final (count, colors, speed, life, radius, gravity) = switch (kind) {
      FxKind.coin => (6, const [0xFFFFE27A, 0xFFFFC52E, 0xFFFFFFFF], 150.0, 0.35, 3.2, 0.0),
      FxKind.gem => (12, const [0xFF8BF0FF, 0xFF3FB4FF, 0xFFFFFFFF], 210.0, 0.5, 3.6, 0.0),
      FxKind.power => (18, const [0xFF6FF0D8, 0xFFFFD34A, 0xFFFFFFFF], 260.0, 0.6, 4.0, 0.0),
      FxKind.whoosh => (8, const [0xCCFFFFFF, 0x99BFE9FF], 320.0, 0.25, 2.2, 0.0),
      FxKind.dust => (16, const [0xFFB8A58A, 0xFF8A7A66, 0xFFE0D3BC], 200.0, 0.6, 6.0, 400.0),
    };
    for (var i = 0; i < count; i++) {
      final k = _next;
      _next = (_next + 1) % _size;
      final a = kind == FxKind.whoosh
          ? (i.isEven ? math.pi : 0) + (_rng.nextDouble() - 0.5) * 0.5
          : _rng.nextDouble() * math.pi * 2;
      final v = speed * (0.5 + _rng.nextDouble() * 0.6);
      _x[k] = at.dx;
      _y[k] = at.dy;
      _vx[k] = math.cos(a) * v;
      _vy[k] = math.sin(a) * v - (kind == FxKind.dust ? 120 : 30);
      _max[k] = life * (0.7 + _rng.nextDouble() * 0.5);
      _life[k] = _max[k];
      _r[k] = radius * (0.6 + _rng.nextDouble() * 0.7);
      _color[k] = colors[i % colors.length];
      _streak[k] = kind == FxKind.whoosh;
      _gravity[k] = gravity;
    }
  }

  final _gravity = List<double>.filled(_size, 0);

  void update(double dt) {
    for (var k = 0; k < _size; k++) {
      if (_life[k] <= 0) continue;
      _life[k] -= dt;
      _vy[k] += _gravity[k] * dt;
      _vx[k] *= 1 - 2.5 * dt;
      _vy[k] *= 1 - 2.5 * dt;
      _x[k] += _vx[k] * dt;
      _y[k] += _vy[k] * dt;
    }
  }

  void paint(Canvas canvas) {
    for (var k = 0; k < _size; k++) {
      if (_life[k] <= 0) continue;
      final f = (_life[k] / _max[k]).clamp(0.0, 1.0);
      final c = Color(_color[k]);
      _paint.color = c.withValues(alpha: c.a * f);
      if (_streak[k]) {
        _paint.strokeWidth = _r[k];
        canvas.drawLine(Offset(_x[k], _y[k]), Offset(_x[k] - _vx[k] * 0.06, _y[k] - _vy[k] * 0.06), _paint);
      } else {
        final r = _r[k] * (0.5 + f * 0.8);
        // A four-point sparkle: a small diamond and a dot.
        canvas.drawCircle(Offset(_x[k], _y[k]), r, _paint);
        _paint.strokeWidth = r * 0.5;
        canvas.drawLine(Offset(_x[k] - r * 2, _y[k]), Offset(_x[k] + r * 2, _y[k]), _paint);
        canvas.drawLine(Offset(_x[k], _y[k] - r * 2), Offset(_x[k], _y[k] + r * 2), _paint);
      }
    }
  }
}
