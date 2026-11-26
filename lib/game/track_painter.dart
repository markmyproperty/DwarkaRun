import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'camera.dart';
import 'entities.dart';
import 'realm.dart';
import 'run_simulation.dart';

/// Paints a run: sky, path, scenery, obstacles, pickups and the hero.
///
/// Everything is drawn with plain canvas calls, far to near, with no images.
/// Paints, paths and the draw-order buffers are created once and reused, so
/// painting a frame allocates nothing.
class TrackPainter {
  TrackPainter(this.realm) : pal = realm.palette;

  final Realm realm;
  final RealmPalette pal;

  /// Calmer visuals: no shake, no spinning coins.
  bool reduceMotion = false;

  final Paint _fill = Paint()..isAntiAlias = true;
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;
  final Paint _sky = Paint();
  final Paint _haze = Paint();
  final Path _path = Path();
  final Path _hills = Path();
  final Path _hillsNear = Path();

  // Draw-order buffers: what to draw (kind << 16 | index) sorted by depth.
  static const _maxDraw = 512;
  final Float64List _drawZ = Float64List(_maxDraw);
  final Int32List _drawRef = Int32List(_maxDraw);
  int _drawCount = 0;

  static const _kObstacle = 1;
  static const _kPickup = 2;
  static const _kScenery = 3;

  static const double sceneryEvery = 7.0;
  static const double hazeFrom = 70;
  static const double pathHalfWidth = 3.7;

  double _w = 0, _h = 0;

  void resize(TrackCamera cam) {
    _w = cam.width;
    _h = cam.height;
    _sky.shader = Gradient.linear(
      Offset(0, 0),
      Offset(0, cam.horizon),
      [pal.skyTop, pal.skyBottom],
    );
    _haze.shader = Gradient.linear(
      Offset(0, cam.horizon),
      Offset(0, cam.horizon + _h * 0.16),
      [pal.haze.withValues(alpha: 0.85), pal.haze.withValues(alpha: 0)],
    );
    // Distant hills, fixed to the horizon.
    _hills.reset();
    _hillsNear.reset();
    final hz = cam.horizon;
    _hills.moveTo(0, hz);
    _hillsNear.moveTo(0, hz);
    for (var i = 0; i <= 12; i++) {
      final px = _w * i / 12;
      _hills.lineTo(px, hz - _h * (0.05 + 0.04 * math.sin(i * 1.7) + 0.02 * math.sin(i * 4.1)));
      _hillsNear.lineTo(px, hz - _h * (0.025 + 0.025 * math.sin(i * 2.3 + 1)));
    }
    _hills
      ..lineTo(_w, hz)
      ..close();
    _hillsNear
      ..lineTo(_w, hz)
      ..close();
  }

  void paint(Canvas canvas, TrackCamera cam, RunSimulation sim) {
    _paintSky(canvas, cam);
    _paintGround(canvas, cam);
    _paintPath(canvas, cam);
    _collect(cam, sim);

    var hazeDrawn = false;
    var heroDrawn = false;
    for (var i = 0; i < _drawCount; i++) {
      final z = _drawZ[i];
      if (!hazeDrawn && z - cam.camZ < hazeFrom) {
        canvas.drawRect(Rect.fromLTWH(0, cam.horizon, _w, _h * 0.16), _haze);
        hazeDrawn = true;
      }
      if (!heroDrawn && z < sim.distance) {
        _paintHero(canvas, cam, sim);
        heroDrawn = true;
      }
      final ref = _drawRef[i];
      final kind = ref >> 16;
      final idx = ref & 0xFFFF;
      switch (kind) {
        case _kObstacle:
          _paintObstacle(canvas, cam, sim.pools.obstacles[idx], sim.time);
        case _kPickup:
          _paintPickup(canvas, cam, sim.pools.pickups[idx], sim.time);
        case _kScenery:
          _paintScenery(canvas, cam, idx);
      }
    }
    if (!hazeDrawn) {
      canvas.drawRect(Rect.fromLTWH(0, cam.horizon, _w, _h * 0.16), _haze);
    }
    if (!heroDrawn) _paintHero(canvas, cam, sim);
  }

  // ── backdrop ──
  void _paintSky(Canvas canvas, TrackCamera cam) {
    canvas.drawRect(Rect.fromLTWH(0, 0, _w, cam.horizon + 1), _sky);
    _fill.color = const Color(0xFFFFF3D0);
    canvas.drawCircle(Offset(_w * 0.78, cam.horizon * 0.42), _h * 0.045, _fill);
    _fill.color = pal.foliageLight.withValues(alpha: 0.55);
    canvas.drawPath(_hills, _fill);
    _fill.color = pal.foliageDark.withValues(alpha: 0.6);
    canvas.drawPath(_hillsNear, _fill);
  }

  void _paintGround(Canvas canvas, TrackCamera cam) {
    _fill.color = pal.ground;
    canvas.drawRect(Rect.fromLTWH(0, cam.horizon, _w, _h - cam.horizon), _fill);
    _fill.color = pal.groundFar;
    canvas.drawRect(Rect.fromLTWH(0, cam.horizon, _w, _h * 0.05), _fill);
  }

  /// The path as 3-metre tiles, far to near. The tile colour comes from the
  /// tile's world position, so the path appears to scroll.
  void _paintPath(Canvas canvas, TrackCamera cam) {
    const tile = 3.0;
    final near = cam.camZ + 0.8;
    final far = cam.camZ + 170;
    var z = (far / tile).floor() * tile;
    while (z + tile > near) {
      final z0 = math.max(z, near);
      final z1 = z + tile;
      final even = ((z / tile).floor() & 1) == 0;
      // Edge strip, then the stone path.
      _quad(canvas, cam, -pathHalfWidth - 0.35, pathHalfWidth + 0.35, z0, z1, pal.pathEdge);
      _quad(canvas, cam, -pathHalfWidth, pathHalfWidth, z0, z1, even ? pal.pathA : pal.pathB);
      // Faint lane joints.
      if (cam.scaleAt(z0) > 6) {
        _stroke
          ..color = pal.pathEdge.withValues(alpha: 0.35)
          ..strokeWidth = math.max(1, 0.05 * cam.scaleAt(z0));
        for (final lx in const [-RunSimulation.laneWidth / 2, RunSimulation.laneWidth / 2]) {
          canvas.drawLine(
            Offset(cam.sx(lx, z0), cam.sy(0, z0)),
            Offset(cam.sx(lx, z1), cam.sy(0, z1)),
            _stroke,
          );
        }
      }
      z -= tile;
    }
  }

  void _quad(Canvas canvas, TrackCamera cam, double x0, double x1, double z0, double z1, Color c) {
    _path
      ..reset()
      ..moveTo(cam.sx(x0, z0), cam.sy(0, z0))
      ..lineTo(cam.sx(x1, z0), cam.sy(0, z0))
      ..lineTo(cam.sx(x1, z1), cam.sy(0, z1))
      ..lineTo(cam.sx(x0, z1), cam.sy(0, z1))
      ..close();
    _fill.color = c;
    canvas.drawPath(_path, _fill);
  }

  // ── draw order ──
  void _collect(TrackCamera cam, RunSimulation sim) {
    _drawCount = 0;
    final far = cam.camZ + 165;
    final obs = sim.pools.obstacles;
    for (var i = 0; i < obs.length; i++) {
      final o = obs[i];
      if (o.active && cam.visible(o.z) && o.z < far) _push(o.z, (_kObstacle << 16) | i);
    }
    final pk = sim.pools.pickups;
    for (var i = 0; i < pk.length; i++) {
      final p = pk[i];
      if (p.active && cam.visible(p.z) && p.z < far) _push(p.z, (_kPickup << 16) | i);
    }
    final first = ((cam.camZ + 1) / sceneryEvery).ceil();
    final last = (far / sceneryEvery).floor();
    for (var i = first; i <= last; i++) {
      _push(i * sceneryEvery, (_kScenery << 16) | (i & 0xFFFF));
    }
    // Insertion sort, far first. The order barely changes between frames.
    for (var i = 1; i < _drawCount; i++) {
      final z = _drawZ[i];
      final r = _drawRef[i];
      var j = i - 1;
      while (j >= 0 && _drawZ[j] < z) {
        _drawZ[j + 1] = _drawZ[j];
        _drawRef[j + 1] = _drawRef[j];
        j--;
      }
      _drawZ[j + 1] = z;
      _drawRef[j + 1] = r;
    }
  }

  void _push(double z, int ref) {
    if (_drawCount >= _maxDraw) return;
    _drawZ[_drawCount] = z;
    _drawRef[_drawCount] = ref;
    _drawCount++;
  }

  // ── scenery (Forest Kingdom) ──
  static double _hash(int i, int salt) {
    final v = math.sin(i * 12.9898 + salt * 78.233) * 43758.5453;
    return v - v.floorToDouble();
  }

  void _paintScenery(Canvas canvas, TrackCamera cam, int i) {
    final z = i * sceneryEvery;
    for (final side in const [-1, 1]) {
      final h = _hash(i, side + 3);
      final x = side * (pathHalfWidth + 1.6 + _hash(i, side + 7) * 5);
      if (h < 0.42) {
        _banyan(canvas, cam, x, z, 0.8 + _hash(i, side + 11) * 0.6);
      } else if (h < 0.62) {
        _bush(canvas, cam, x, z);
      } else if (h < 0.8) {
        _ruin(canvas, cam, x, z, _hash(i, side + 13));
      } else if (h < 0.84) {
        _shrine(canvas, cam, side * (pathHalfWidth + 1.4), z);
      } else {
        _bush(canvas, cam, x, z);
        _banyan(canvas, cam, x + side * 4, z + 2, 1.1);
      }
    }
  }

  /// A banyan: thick trunk, hanging aerial roots and a broad canopy.
  void _banyan(Canvas canvas, TrackCamera cam, double x, double z, double size) {
    final s = cam.scaleAt(z);
    if (s <= 0) return;
    final bx = cam.sx(x, z);
    final by = cam.sy(0, z);
    final trunkW = 0.9 * size * s;
    final trunkH = 3.2 * size * s;
    _fill.color = const Color(0xFF6B4A2E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(bx - trunkW / 2, by - trunkH, trunkW, trunkH), Radius.circular(trunkW * 0.3)),
      _fill,
    );
    _stroke
      ..color = const Color(0xFF7D5A3A)
      ..strokeWidth = math.max(1, 0.08 * size * s);
    for (var k = -2; k <= 2; k++) {
      final rx = bx + k * 0.75 * size * s;
      canvas.drawLine(Offset(rx, by - trunkH * 0.95), Offset(rx + k * 0.1 * s, by - trunkH * 0.15), _stroke);
    }
    final cy = by - trunkH - 0.6 * size * s;
    _fill.color = pal.foliageDark;
    canvas.drawOval(Rect.fromCenter(center: Offset(bx, cy), width: 5.2 * size * s, height: 2.4 * size * s), _fill);
    _fill.color = pal.foliageLight;
    canvas.drawCircle(Offset(bx - 1.2 * size * s, cy - 0.5 * size * s), 1.1 * size * s, _fill);
    canvas.drawCircle(Offset(bx + 1.0 * size * s, cy - 0.7 * size * s), 1.2 * size * s, _fill);
    _fill.color = pal.foliageDark.withValues(alpha: 0.6);
    canvas.drawCircle(Offset(bx + 0.1 * size * s, cy - 1.0 * size * s), 0.9 * size * s, _fill);
  }

  void _bush(Canvas canvas, TrackCamera cam, double x, double z) {
    final s = cam.scaleAt(z);
    if (s <= 0) return;
    final bx = cam.sx(x, z);
    final by = cam.sy(0, z);
    _fill.color = pal.foliageDark;
    canvas.drawCircle(Offset(bx - 0.4 * s, by - 0.4 * s), 0.6 * s, _fill);
    _fill.color = pal.foliageLight;
    canvas.drawCircle(Offset(bx + 0.3 * s, by - 0.5 * s), 0.55 * s, _fill);
  }

  /// Broken stone columns and a wall stub.
  void _ruin(Canvas canvas, TrackCamera cam, double x, double z, double v) {
    final s = cam.scaleAt(z);
    if (s <= 0) return;
    final bx = cam.sx(x, z);
    final by = cam.sy(0, z);
    final colH = (1.6 + v * 2.2) * s;
    final colW = 0.7 * s;
    _fill.color = pal.stoneDark;
    canvas.drawRect(Rect.fromLTWH(bx - 1.6 * s, by - 0.9 * s, 3.2 * s, 0.9 * s), _fill);
    _fill.color = pal.stone;
    canvas.drawRect(Rect.fromLTWH(bx - colW / 2, by - colH, colW, colH), _fill);
    canvas.drawRect(Rect.fromLTWH(bx - colW * 0.7, by - colH - 0.18 * s, colW * 1.4, 0.2 * s), _fill);
    // Moss.
    _fill.color = pal.foliageLight.withValues(alpha: 0.7);
    canvas.drawOval(Rect.fromLTWH(bx - colW * 0.6, by - colH - 0.3 * s, colW * 0.9, 0.3 * s), _fill);
    _stroke
      ..color = pal.stoneDark
      ..strokeWidth = math.max(1, 0.04 * s);
    canvas.drawLine(Offset(bx - colW * 0.2, by - colH * 0.7), Offset(bx + colW * 0.15, by - colH * 0.45), _stroke);
  }

  /// A small wayside shrine with a lamp: a peaceful presence beside the path,
  /// never on it.
  void _shrine(Canvas canvas, TrackCamera cam, double x, double z) {
    final s = cam.scaleAt(z);
    if (s <= 0) return;
    final bx = cam.sx(x, z);
    final by = cam.sy(0, z);
    _fill.color = pal.stoneDark;
    canvas.drawRect(Rect.fromLTWH(bx - 0.6 * s, by - 0.5 * s, 1.2 * s, 0.5 * s), _fill);
    _fill.color = pal.stone;
    canvas.drawRect(Rect.fromLTWH(bx - 0.45 * s, by - 1.5 * s, 0.9 * s, 1.0 * s), _fill);
    _path
      ..reset()
      ..moveTo(bx - 0.6 * s, by - 1.5 * s)
      ..lineTo(bx, by - 2.1 * s)
      ..lineTo(bx + 0.6 * s, by - 1.5 * s)
      ..close();
    canvas.drawPath(_path, _fill);
    _fill.color = const Color(0xFF4A3A2A);
    canvas.drawRect(Rect.fromLTWH(bx - 0.25 * s, by - 1.3 * s, 0.5 * s, 0.6 * s), _fill);
    // Warm lamp glow.
    _fill.color = const Color(0x55FFC857);
    canvas.drawCircle(Offset(bx, by - 0.85 * s), 0.35 * s, _fill);
    _fill.color = const Color(0xFFFFC857);
    canvas.drawCircle(Offset(bx, by - 0.85 * s), 0.09 * s, _fill);
  }

  // ── obstacles ──
  void _paintObstacle(Canvas canvas, TrackCamera cam, Obstacle o, double t) {
    final x = o.lane * RunSimulation.laneWidth;
    final z = o.z - o.kind.depth / 2;
    final s = cam.scaleAt(z);
    if (s <= 0) return;
    final cx = cam.sx(x, z);
    final gy = cam.sy(0, z);
    final halfW = 0.95 * s;

    // Soft contact shadow.
    _fill.color = const Color(0x33000000);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, gy), width: halfW * 2.1, height: 0.35 * s), _fill);

    switch (o.kind) {
      case ObstacleKind.fallenPillar:
        final h = o.kind.height * s;
        _fill.color = pal.stone;
        canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTRB(cx - halfW, gy - h, cx + halfW, gy), Radius.circular(h * 0.45)), _fill);
        _fill.color = pal.stoneDark;
        canvas.drawRect(Rect.fromLTRB(cx - halfW * 0.55, gy - h, cx - halfW * 0.45, gy), _fill);
        canvas.drawRect(Rect.fromLTRB(cx + halfW * 0.45, gy - h, cx + halfW * 0.55, gy), _fill);
        _fill.color = const Color(0x33FFFFFF);
        canvas.drawRect(Rect.fromLTRB(cx - halfW * 0.9, gy - h * 0.92, cx + halfW * 0.9, gy - h * 0.72), _fill);
        _fill.color = pal.stoneDark;
        canvas.drawOval(Rect.fromCenter(center: Offset(cx - halfW, gy - h / 2), width: h * 0.5, height: h), _fill);
      case ObstacleKind.lowBranch:
        final under = o.kind.height * s;
        final thick = 0.45 * s;
        final side = o.variant < 0.5 ? -1.0 : 1.0;
        _fill.color = const Color(0xFF5E4027);
        canvas.drawRect(Rect.fromLTWH(cx + side * halfW - 0.2 * s, gy - under - thick, 0.4 * s, under + thick), _fill);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTRB(cx - halfW * 1.1, gy - under - thick, cx + halfW * 1.1, gy - under), Radius.circular(thick / 2)),
            _fill);
        _fill.color = pal.foliageLight;
        for (var k = -2; k <= 2; k++) {
          canvas.drawCircle(Offset(cx + k * halfW * 0.45, gy - under - thick * 1.2), 0.32 * s, _fill);
        }
        _fill.color = pal.foliageDark;
        canvas.drawCircle(Offset(cx - halfW * 0.2, gy - under - thick * 1.6), 0.3 * s, _fill);
      case ObstacleKind.stoneWheel:
        // A rolling millstone: plain stone, a square axle hole, no markings.
        final r = 1.0 * s;
        final c = Offset(cx, gy - r);
        _fill.color = pal.stoneDark;
        canvas.drawCircle(c, r, _fill);
        _fill.color = pal.stone;
        canvas.drawCircle(c, r * 0.86, _fill);
        _fill.color = pal.stoneDark;
        canvas.drawRect(Rect.fromCenter(center: c, width: r * 0.28, height: r * 0.28), _fill);
        _stroke
          ..color = pal.stoneDark
          ..strokeWidth = math.max(1, 0.05 * s);
        final spin = reduceMotion ? 0.6 : o.z * 1.1;
        canvas.drawLine(
          Offset(c.dx + math.cos(spin) * r * 0.3, c.dy + math.sin(spin) * r * 0.3),
          Offset(c.dx + math.cos(spin) * r * 0.75, c.dy + math.sin(spin) * r * 0.75),
          _stroke,
        );
      case ObstacleKind.ropeBarrier:
        final postH = 1.1 * s;
        _fill.color = const Color(0xFF7A5634);
        canvas.drawRect(Rect.fromLTWH(cx - halfW, gy - postH, 0.16 * s, postH), _fill);
        canvas.drawRect(Rect.fromLTWH(cx + halfW - 0.16 * s, gy - postH, 0.16 * s, postH), _fill);
        _path
          ..reset()
          ..moveTo(cx - halfW, gy - postH * 0.9)
          ..quadraticBezierTo(cx, gy - postH * 0.6, cx + halfW, gy - postH * 0.9);
        _stroke
          ..color = const Color(0xFFD9C08A)
          ..strokeWidth = math.max(1.5, 0.08 * s);
        canvas.drawPath(_path, _stroke);
        // Plain cloth strips.
        const cloth = [Color(0xFFE85D4A), Color(0xFFF2B33D), Color(0xFF3FA796)];
        for (var k = 0; k < 3; k++) {
          final fx = cx - halfW * 0.5 + k * halfW * 0.5;
          _fill.color = cloth[k];
          canvas.drawRect(Rect.fromLTWH(fx - 0.08 * s, gy - postH * 0.73, 0.16 * s, 0.3 * s), _fill);
        }
      case ObstacleKind.firePit:
        _fill.color = pal.stoneDark;
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, gy - 0.1 * s), width: halfW * 1.9, height: 0.6 * s), _fill);
        _fill.color = const Color(0xFF3A2416);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, gy - 0.12 * s), width: halfW * 1.5, height: 0.4 * s), _fill);
        for (var k = -2; k <= 2; k++) {
          final flick = reduceMotion ? 0.8 : 0.7 + 0.3 * math.sin(t * 13 + k * 2.1 + o.variant * 6);
          final fh = (0.55 + 0.15 * (2 - k.abs())) * flick * s;
          final fx = cx + k * halfW * 0.3;
          _path
            ..reset()
            ..moveTo(fx - 0.16 * s, gy - 0.12 * s)
            ..quadraticBezierTo(fx, gy - 0.12 * s - fh * 1.3, fx + 0.16 * s, gy - 0.12 * s)
            ..close();
          _fill.color = k.isEven ? const Color(0xFFFF8A2A) : const Color(0xFFFFC94A);
          canvas.drawPath(_path, _fill);
        }
      case ObstacleKind.marketCart:
        final h = 1.4 * s;
        _fill.color = const Color(0xFF8A5A33);
        canvas.drawRect(Rect.fromLTRB(cx - halfW, gy - h, cx + halfW, gy - 0.4 * s), _fill);
        _fill.color = const Color(0xFFE85D4A);
        canvas.drawRect(Rect.fromLTRB(cx - halfW * 1.1, gy - 2.1 * s, cx + halfW * 1.1, gy - 1.8 * s), _fill);
        _fill.color = const Color(0xFF3A2416);
        canvas.drawCircle(Offset(cx - halfW * 0.7, gy - 0.35 * s), 0.35 * s, _fill);
        canvas.drawCircle(Offset(cx + halfW * 0.7, gy - 0.35 * s), 0.35 * s, _fill);
      case ObstacleKind.monkey:
        _paintMonkey(canvas, cx, gy, s, t, o.variant);
    }
  }

  /// A cheeky monkey sitting on the path, eyeing your coins.
  void _paintMonkey(Canvas canvas, double cx, double gy, double s, double t, double v) {
    final bob = reduceMotion ? 0.0 : math.sin(t * 6 + v * 9).abs() * 0.12 * s;
    final by = gy - bob;
    _stroke
      ..color = const Color(0xFF7A5234)
      ..strokeWidth = math.max(1, 0.09 * s);
    _path
      ..reset()
      ..moveTo(cx + 0.25 * s, by - 0.2 * s)
      ..quadraticBezierTo(cx + 0.8 * s, by - 0.3 * s, cx + 0.6 * s, by - 0.8 * s);
    canvas.drawPath(_path, _stroke);
    _fill.color = const Color(0xFF8B5E3C);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, by - 0.35 * s), width: 0.6 * s, height: 0.7 * s), _fill);
    canvas.drawCircle(Offset(cx, by - 0.85 * s), 0.25 * s, _fill);
    canvas.drawCircle(Offset(cx - 0.24 * s, by - 0.9 * s), 0.09 * s, _fill);
    canvas.drawCircle(Offset(cx + 0.24 * s, by - 0.9 * s), 0.09 * s, _fill);
    _fill.color = const Color(0xFFE8C9A0);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, by - 0.8 * s), width: 0.3 * s, height: 0.24 * s), _fill);
    _fill.color = const Color(0xFF2A1A10);
    canvas.drawCircle(Offset(cx - 0.07 * s, by - 0.88 * s), 0.03 * s, _fill);
    canvas.drawCircle(Offset(cx + 0.07 * s, by - 0.88 * s), 0.03 * s, _fill);
  }

  // ── pickups ──
  // Shapes differ as well as colours (round coin, diamond gem, long feather,
  // petalled lotus), so they read clearly with any kind of colour vision.
  void _paintPickup(Canvas canvas, TrackCamera cam, Pickup p, double t) {
    final s = cam.scaleAt(p.z);
    if (s <= 0) return;
    final bob = reduceMotion ? 0.0 : math.sin(t * 3 + p.z) * 0.08;
    final cx = cam.sx(p.x, p.z);
    final cy = cam.sy(p.y + bob, p.z);
    switch (p.kind) {
      case PickupKind.coin:
        final r = 0.3 * s;
        final squash = reduceMotion ? 1.0 : math.max(0.25, math.cos(t * 4 + p.z * 0.5).abs());
        _fill.color = const Color(0xFFB07A12);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: r * 2 * squash, height: r * 2), _fill);
        _fill.color = const Color(0xFFF5C542);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: r * 1.7 * squash, height: r * 1.7), _fill);
        _fill.color = const Color(0xFFB07A12);
        canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: r * 0.5 * squash, height: r * 0.5), _fill);
      case PickupKind.gem:
        final r = 0.38 * s;
        _path
          ..reset()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r * 0.75, cy)
          ..lineTo(cx, cy + r)
          ..lineTo(cx - r * 0.75, cy)
          ..close();
        _fill.color = const Color(0xFF5B3FD6);
        canvas.drawPath(_path, _fill);
        _stroke
          ..color = const Color(0xFFFFFFFF)
          ..strokeWidth = math.max(1, 0.05 * s);
        canvas.drawPath(_path, _stroke);
        canvas.drawLine(Offset(cx - r * 0.75, cy), Offset(cx + r * 0.75, cy), _stroke);
      case PickupKind.feather:
        final r = 0.55 * s;
        _fill.color = const Color(0x553FD0C9);
        canvas.drawCircle(Offset(cx, cy), r * 1.1, _fill);
        _path
          ..reset()
          ..moveTo(cx - r * 0.5, cy + r)
          ..quadraticBezierTo(cx - r * 0.6, cy - r * 0.2, cx + r * 0.45, cy - r)
          ..quadraticBezierTo(cx + r * 0.3, cy + r * 0.2, cx - r * 0.5, cy + r)
          ..close();
        _fill.color = const Color(0xFF1F8A8A);
        canvas.drawPath(_path, _fill);
        _stroke
          ..color = const Color(0xFFFFFFFF)
          ..strokeWidth = math.max(1, 0.05 * s);
        canvas.drawPath(_path, _stroke);
        _fill.color = const Color(0xFFF29E38);
        canvas.drawCircle(Offset(cx + r * 0.3, cy - r * 0.7), r * 0.16, _fill);
      case PickupKind.lotus:
        final r = 0.5 * s;
        _fill.color = const Color(0x55FFFFFF);
        canvas.drawCircle(Offset(cx, cy), r * 1.15, _fill);
        _fill.color = const Color(0xFFE86FA0);
        for (var k = 0; k < 5; k++) {
          final a = -math.pi / 2 + (k - 2) * 0.55;
          canvas.drawCircle(Offset(cx + math.cos(a) * r * 0.5, cy + math.sin(a) * r * 0.5 + r * 0.2), r * 0.32, _fill);
        }
        _fill.color = const Color(0xFFFFD34A);
        canvas.drawCircle(Offset(cx, cy + r * 0.15), r * 0.2, _fill);
    }
  }

  // ── hero ──
  /// The traveller: an original young pilgrim with a saffron tunic, a satchel
  /// and a red scarf, seen from behind.
  void _paintHero(Canvas canvas, TrackCamera cam, RunSimulation sim) {
    final z = sim.distance;
    final s = cam.scaleAt(z);
    final cx = cam.sx(sim.x, z);
    final groundY = cam.sy(0, z);
    final y = sim.y;
    final footY = cam.sy(y, z);

    // Shadow shrinks as the hero rises.
    final shadow = 1 / (1 + y * 0.6);
    _fill.color = const Color(0x40000000);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, groundY), width: 0.9 * s * shadow, height: 0.25 * s * shadow), _fill);

    if (sim.boosting) _paintWings(canvas, cx, footY - 1.2 * s, s, sim.time);

    if (sim.sliding && !sim.boosting) {
      _paintHeroSliding(canvas, cx, footY, s);
      return;
    }

    final crashed = sim.state == RunState.crashed;
    final run = crashed ? 0.0 : sim.time * (sim.speed * 0.9);
    final airborne = y > 0.05 || sim.boosting;
    final legA = airborne ? 0.15 : math.max(0.0, math.sin(run)) * 0.28;
    final legB = airborne ? 0.15 : math.max(0.0, -math.sin(run)) * 0.28;

    // Legs (white trousers) and feet.
    _stroke
      ..color = const Color(0xFFF4EEE2)
      ..strokeWidth = 0.2 * s;
    final hipY = footY - 0.85 * s;
    canvas.drawLine(Offset(cx - 0.12 * s, hipY), Offset(cx - 0.14 * s, footY - legA * s), _stroke);
    canvas.drawLine(Offset(cx + 0.12 * s, hipY), Offset(cx + 0.14 * s, footY - legB * s), _stroke);
    _fill.color = const Color(0xFF5A3A22);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 0.14 * s, footY - legA * s), width: 0.2 * s, height: 0.1 * s), _fill);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 0.14 * s, footY - legB * s), width: 0.2 * s, height: 0.1 * s), _fill);

    // Arms swing opposite to the legs.
    final armSwing = airborne ? -0.3 : math.sin(run) * 0.18;
    _stroke
      ..color = const Color(0xFFB9784A)
      ..strokeWidth = 0.12 * s;
    final shoulderY = footY - 1.38 * s;
    canvas.drawLine(Offset(cx - 0.26 * s, shoulderY), Offset(cx - 0.36 * s, shoulderY + (0.5 + armSwing) * s), _stroke);
    canvas.drawLine(Offset(cx + 0.26 * s, shoulderY), Offset(cx + 0.36 * s, shoulderY + (0.5 - armSwing) * s), _stroke);

    // Tunic.
    _fill.color = const Color(0xFFF29E38);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(cx - 0.28 * s, shoulderY - 0.05 * s, cx + 0.28 * s, hipY + 0.12 * s),
          Radius.circular(0.12 * s)),
      _fill,
    );
    // Sash.
    _fill.color = const Color(0xFF7A2E8E);
    canvas.drawRect(Rect.fromLTRB(cx - 0.28 * s, hipY - 0.05 * s, cx + 0.28 * s, hipY + 0.04 * s), _fill);
    // Satchel strap and bag.
    _stroke
      ..color = const Color(0xFF6B4A2E)
      ..strokeWidth = 0.06 * s;
    canvas.drawLine(Offset(cx - 0.22 * s, shoulderY), Offset(cx + 0.22 * s, hipY - 0.1 * s), _stroke);
    _fill.color = const Color(0xFF8A6238);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx + 0.12 * s, hipY - 0.2 * s, 0.26 * s, 0.24 * s), Radius.circular(0.05 * s)),
      _fill,
    );

    // Scarf trailing back.
    final wave = reduceMotion ? 0.0 : math.sin(sim.time * 10) * 0.08;
    _path
      ..reset()
      ..moveTo(cx - 0.1 * s, shoulderY - 0.02 * s)
      ..quadraticBezierTo(cx - 0.45 * s, shoulderY + (0.15 + wave) * s, cx - 0.55 * s, shoulderY + (0.35 - wave) * s)
      ..lineTo(cx - 0.42 * s, shoulderY + (0.38 - wave) * s)
      ..quadraticBezierTo(cx - 0.3 * s, shoulderY + 0.15 * s, cx + 0.05 * s, shoulderY + 0.04 * s)
      ..close();
    _fill.color = const Color(0xFFD93A3A);
    canvas.drawPath(_path, _fill);

    // Head, hair and top-knot.
    final headY = shoulderY - 0.2 * s;
    _fill.color = const Color(0xFFB9784A);
    canvas.drawCircle(Offset(cx, headY), 0.17 * s, _fill);
    _fill.color = const Color(0xFF2A1A12);
    canvas.drawCircle(Offset(cx, headY - 0.02 * s), 0.16 * s, _fill);
    canvas.drawCircle(Offset(cx, headY - 0.2 * s), 0.08 * s, _fill);
  }

  void _paintHeroSliding(Canvas canvas, double cx, double footY, double s) {
    _fill.color = const Color(0xFFF4EEE2);
    canvas.drawOval(Rect.fromLTRB(cx - 0.35 * s, footY - 0.3 * s, cx + 0.35 * s, footY), _fill);
    _fill.color = const Color(0xFFF29E38);
    canvas.drawOval(Rect.fromLTRB(cx - 0.3 * s, footY - 0.7 * s, cx + 0.3 * s, footY - 0.2 * s), _fill);
    _fill.color = const Color(0xFFD93A3A);
    canvas.drawRect(Rect.fromLTRB(cx - 0.3 * s, footY - 0.62 * s, cx + 0.05 * s, footY - 0.54 * s), _fill);
    _fill.color = const Color(0xFF2A1A12);
    canvas.drawCircle(Offset(cx, footY - 0.78 * s), 0.16 * s, _fill);
  }

  /// Golden-teal wings of light while a Garuda feather boost lasts.
  void _paintWings(Canvas canvas, double cx, double cy, double s, double t) {
    final flap = reduceMotion ? 0.0 : math.sin(t * 9) * 0.25;
    _fill.color = const Color(0x40FFD34A);
    canvas.drawCircle(Offset(cx, cy), 1.3 * s, _fill);
    for (final side in const [-1.0, 1.0]) {
      _path
        ..reset()
        ..moveTo(cx, cy)
        ..quadraticBezierTo(cx + side * 1.0 * s, cy - (0.9 + flap) * s, cx + side * 1.9 * s, cy - (0.4 + flap) * s)
        ..quadraticBezierTo(cx + side * 1.2 * s, cy + 0.1 * s, cx, cy + 0.25 * s)
        ..close();
      _fill.color = const Color(0xFFF5C542);
      canvas.drawPath(_path, _fill);
      _stroke
        ..color = const Color(0xFF1F8A8A)
        ..strokeWidth = 0.05 * s;
      canvas.drawPath(_path, _stroke);
    }
  }
}
