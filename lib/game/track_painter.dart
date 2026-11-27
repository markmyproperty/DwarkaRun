import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'art_library.dart';
import 'camera.dart';
import 'entities.dart';
import 'realm.dart';
import 'run_simulation.dart';
import 'stage_art.dart';

/// Paints a run: sky, path, scenery, obstacles, pickups and the hero.
///
/// Everything is drawn with plain canvas calls, far to near, with no images.
/// Paints, paths and the draw-order buffers are created once and reused, so
/// painting a frame allocates nothing.
class TrackPainter {
  TrackPainter(this.realm, {ArtLibrary? art})
    : pal = realm.palette,
      stage = StageArt.of(realm),
      art = art ?? ArtLibrary.instance;

  /// Art-pack dressing for stage 3 onwards; null for the first two
  /// stages, which have their own scenery painters.
  final StageArt? stage;

  /// Art-pack images. Anything not loaded yet is drawn in code instead.
  final ArtLibrary art;
  final Paint _image = Paint()
    ..filterQuality = FilterQuality.medium
    ..isAntiAlias = true;
  Rect? _skySrc;

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
  static const _kGate = 4;

  static const double sceneryEvery = 7.0;
  static const double hazeFrom = 70;
  static const double pathHalfWidth = 3.7;

  double _w = 0, _h = 0;

  void resize(TrackCamera cam) {
    _w = cam.width;
    _h = cam.height;
    _skySrc = null;
    _riverSkySrc = null;
    _sky.shader = Gradient.linear(Offset(0, 0), Offset(0, cam.horizon), [pal.skyTop, pal.skyBottom]);
    _haze.shader = Gradient.linear(Offset(0, cam.horizon), Offset(0, cam.horizon + _h * 0.16), [
      pal.haze.withValues(alpha: 0.85),
      pal.haze.withValues(alpha: 0),
    ]);
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
    _paintPath(canvas, cam, sim);
    if (realm.hasRiver) _paintPlatforms(canvas, cam, sim);
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
          switch (realm) {
            case Realm.ayodhya:
              _paintCityScenery(canvas, cam, idx);
            case Realm.ganga:
              _paintRiverScenery(canvas, cam, idx, sim);
            default:
              final st = stage;
              st == null ? _paintScenery(canvas, cam, idx) : _paintStageScenery(canvas, cam, idx, sim, st);
          }
        case _kGate:
          _paintGate(canvas, cam, z);
      }
    }
    if (!hazeDrawn) {
      canvas.drawRect(Rect.fromLTWH(0, cam.horizon, _w, _h * 0.16), _haze);
    }
    if (!heroDrawn) _paintHero(canvas, cam, sim);
  }

  // ── backdrop ──
  void _paintSky(Canvas canvas, TrackCamera cam) {
    if (realm == Realm.ayodhya &&
        _paintBandSky(canvas, cam, 'backgrounds/sky_india', 'backgrounds/temple_hills', 'backgrounds/skyline_dwarka')) {
      return;
    }
    if (realm == Realm.ganga && _paintRiverSky(canvas, cam)) return;
    final st = stage;
    if (st != null && _paintBandSky(canvas, cam, st.sky, st.farBand, st.nearBand)) return;
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
  void _paintPath(Canvas canvas, TrackCamera cam, RunSimulation sim) {
    const tile = 3.0;
    final near = cam.camZ + 0.8;
    final far = cam.camZ + 170;
    var z = (far / tile).floor() * tile;
    while (z + tile > near) {
      final z0 = math.max(z, near);
      final z1 = z + tile;
      final even = ((z / tile).floor() & 1) == 0;
      if (realm.hasCrevasse) {
        if (z + tile > sim.waterStart) {
          // An ice crevasse under the path: snowy lips, blue ice walls and
          // a deep, dark floor.
          _quad(canvas, cam, -pathHalfWidth - 0.9, pathHalfWidth + 0.9, z0, z1, const Color(0xFFDCE8F3));
          _quad(canvas, cam, -pathHalfWidth - 0.5, pathHalfWidth + 0.5, z0, z1, even ? _iceWall : _iceWallB);
          _quad(canvas, cam, -pathHalfWidth + 0.4, pathHalfWidth - 0.4, z0, z1, even ? _iceDeep : _iceDeepB);
          z -= tile;
          continue;
        }
      } else if (realm.hasMoat) {
        if (z + tile > sim.waterStart) {
          // The palace moat: open blue water with gentle bands.
          _quad(canvas, cam, -40, 40, z0, z1, even ? _moat : _moatB);
          z -= tile;
          continue;
        }
      } else if (realm.hasRiver) {
        // Gentle bands on the water, scrolling with the run.
        if (even) _quad(canvas, cam, -60, 60, z0, z1, _waterBand);
        if (z >= sim.waterStart) {
          z -= tile;
          continue;
        }
        // Along the ghats: stone bank on the right, river on the left.
        _quad(canvas, cam, pathHalfWidth, 60, z0, z1, even ? pal.stone : pal.stoneDark);
      }
      // Edge strip, then the stone path.
      _quad(canvas, cam, -pathHalfWidth - 0.35, pathHalfWidth + 0.35, z0, z1, pal.pathEdge);
      _quad(canvas, cam, -pathHalfWidth, pathHalfWidth, z0, z1, even ? pal.pathA : pal.pathB);
      // Faint lane joints.
      if (cam.scaleAt(z0) > 6) {
        _stroke
          ..color = pal.pathEdge.withValues(alpha: 0.35)
          ..strokeWidth = math.max(1, 0.05 * cam.scaleAt(z0));
        for (final lx in const [-RunSimulation.laneWidth / 2, RunSimulation.laneWidth / 2]) {
          canvas.drawLine(Offset(cam.sx(lx, z0), cam.sy(0, z0)), Offset(cam.sx(lx, z1), cam.sy(0, z1)), _stroke);
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

  static const Color _waterBand = Color(0x1AFFFFFF);
  static const Color _moat = Color(0xFF6FB7CC);
  static const Color _moatB = Color(0xFF79BFD3);
  static const Color _iceWall = Color(0xFF7FA9CF);
  static const Color _iceWallB = Color(0xFF7AA3C9);
  static const Color _iceDeep = Color(0xFF34557A);
  static const Color _iceDeepB = Color(0xFF3A5C82);

  /// Floating planks, boats and the bridge deck, drawn flat on the water.
  void _paintPlatforms(Canvas canvas, TrackCamera cam, RunSimulation sim) {
    final far = cam.camZ + 168;
    for (final p in sim.pools.platforms) {
      if (!p.active || p.z1 < cam.camZ + 0.8 || p.z0 > far) continue;
      final z0 = math.max(p.z0, cam.camZ + 0.8);
      final z1 = math.min(p.z1, far);
      final x = p.lane * RunSimulation.laneWidth;
      if (realm.hasCrevasse) {
        _paintIcePlatform(canvas, cam, x, z0, z1, p);
        continue;
      }
      if (realm.hasMoat) {
        _paintMoatPlatform(canvas, cam, x, z0, z1, p);
        continue;
      }
      switch (p.kind) {
        case PlatformKind.plank:
          _quad(canvas, cam, x - 1.0, x + 1.0, z0, z1, const Color(0xFF8A6238));
          _quad(
            canvas,
            cam,
            x - 0.92,
            x + 0.92,
            z0,
            z1,
            p.variant < 0.5 ? const Color(0xFFA87951) : const Color(0xFFB48660),
          );
          _seams(canvas, cam, x, 0.92, z0, z1, 1.2, const Color(0x55603F22));
        case PlatformKind.boat:
          _boat(canvas, cam, x, z0, z1, p);
        case PlatformKind.bridge:
          _quad(canvas, cam, x - 1.1, x + 1.1, z0, z1, const Color(0xFF9C7A52));
          _quad(canvas, cam, x - 1.05, x + 1.05, z0, z1, const Color(0xFFC9A47A));
          _seams(canvas, cam, x, 1.05, z0, z1, 0.9, const Color(0x66704C2C));
      }
      // The near edge shows its thickness.
      if (p.z0 >= cam.camZ + 0.8 && p.kind != PlatformKind.boat) {
        final s0 = cam.scaleAt(p.z0);
        _fill.color = const Color(0xFF5C4027);
        final hw = p.kind == PlatformKind.bridge ? 1.1 : 1.0;
        canvas.drawRect(
          Rect.fromLTRB(cam.sx(x - hw, p.z0), cam.sy(0, p.z0), cam.sx(x + hw, p.z0), cam.sy(0, p.z0) + 0.28 * s0),
          _fill,
        );
      }
    }
  }

  /// Over the palace moat: golden platforms, marble walkways and the
  /// sandstone fortress bridge.
  void _paintMoatPlatform(Canvas canvas, TrackCamera cam, double x, double z0, double z1, Platform p) {
    final Color rim, top;
    switch (p.kind) {
      case PlatformKind.plank:
        rim = const Color(0xFFD9AE58);
        top = p.variant < 0.5 ? const Color(0xFFF6C9A6) : const Color(0xFFF2C09A);
      case PlatformKind.boat:
        rim = const Color(0xFFCDBFA8);
        top = const Color(0xFFF7F4EE);
      case PlatformKind.bridge:
        rim = const Color(0xFFB8864A);
        top = const Color(0xFFE6B67A);
    }
    _quad(canvas, cam, x - 1.08, x + 1.08, z0, z1, rim);
    _quad(canvas, cam, x - 0.94, x + 0.94, z0, z1, top);
    _seams(canvas, cam, x, 0.94, z0, z1, p.kind == PlatformKind.bridge ? 1.0 : 2.0, const Color(0x44A0703A));
    if (p.z0 >= cam.camZ + 0.8) {
      final s0 = cam.scaleAt(p.z0);
      _fill.color = rim;
      canvas.drawRect(
        Rect.fromLTRB(cam.sx(x - 1.08, p.z0), cam.sy(0, p.z0), cam.sx(x + 1.08, p.z0), cam.sy(0, p.z0) + 0.32 * s0),
        _fill,
      );
    }
  }

  /// Over a crevasse: ice slabs, long snow ledges and the rope bridge.
  void _paintIcePlatform(Canvas canvas, TrackCamera cam, double x, double z0, double z1, Platform p) {
    switch (p.kind) {
      case PlatformKind.plank:
        _quad(canvas, cam, x - 1.0, x + 1.0, z0, z1, const Color(0xFF9CC3E0));
        _quad(
          canvas,
          cam,
          x - 0.9,
          x + 0.9,
          z0,
          z1,
          p.variant < 0.5 ? const Color(0xFFD6EAF7) : const Color(0xFFCBE3F4),
        );
        _seams(canvas, cam, x, 0.9, z0, z1, 2.4, const Color(0x55FFFFFF));
      case PlatformKind.boat:
        _quad(canvas, cam, x - 1.05, x + 1.05, z0, z1, const Color(0xFFB9D0E3));
        _quad(canvas, cam, x - 0.95, x + 0.95, z0, z1, const Color(0xFFF4F8FC));
      case PlatformKind.bridge:
        // Rope bridge: two ropes and wooden slats.
        _quad(canvas, cam, x - 1.05, x + 1.05, z0, z1, const Color(0xFF8A6238));
        _quad(canvas, cam, x - 0.98, x + 0.98, z0, z1, const Color(0xFFB48660));
        _seams(canvas, cam, x, 0.98, z0, z1, 0.6, const Color(0x99603F22));
    }
    if (p.z0 >= cam.camZ + 0.8) {
      final s0 = cam.scaleAt(p.z0);
      _fill.color = p.kind == PlatformKind.bridge ? const Color(0xFF5C4027) : const Color(0xFF6E98BD);
      canvas.drawRect(
        Rect.fromLTRB(cam.sx(x - 1.05, p.z0), cam.sy(0, p.z0), cam.sx(x + 1.05, p.z0), cam.sy(0, p.z0) + 0.3 * s0),
        _fill,
      );
    }
  }

  void _seams(Canvas canvas, TrackCamera cam, double x, double hw, double z0, double z1, double every, Color c) {
    _stroke
      ..color = c
      ..strokeWidth = 1;
    var z = (z0 / every).ceil() * every;
    while (z < z1) {
      if (cam.scaleAt(z) > 3) {
        canvas.drawLine(Offset(cam.sx(x - hw, z), cam.sy(0, z)), Offset(cam.sx(x + hw, z), cam.sy(0, z)), _stroke);
      }
      z += every;
    }
  }

  /// A long wooden river boat seen from above: teal hull, saffron rim and a
  /// plank deck to run along.
  void _boat(Canvas canvas, TrackCamera cam, double x, double z0, double z1, Platform p) {
    final bow = math.min(1.6, (p.z1 - p.z0) / 3);
    final a = math.max(z0, p.z0 + bow);
    final b = math.min(z1, p.z1 - bow);
    _path
      ..reset()
      ..moveTo(cam.sx(x - 0.35, z0), cam.sy(0, z0))
      ..lineTo(cam.sx(x + 0.35, z0), cam.sy(0, z0))
      ..lineTo(cam.sx(x + 1.05, a), cam.sy(0, a))
      ..lineTo(cam.sx(x + 1.05, b), cam.sy(0, b))
      ..lineTo(cam.sx(x + 0.35, z1), cam.sy(0, z1))
      ..lineTo(cam.sx(x - 0.35, z1), cam.sy(0, z1))
      ..lineTo(cam.sx(x - 1.05, b), cam.sy(0, b))
      ..lineTo(cam.sx(x - 1.05, a), cam.sy(0, a))
      ..close();
    _fill.color = const Color(0xFF2E8C8C);
    canvas.drawPath(_path, _fill);
    _stroke
      ..color = const Color(0xFFE8743B)
      ..strokeWidth = math.max(1.5, 0.08 * cam.scaleAt(z0));
    canvas.drawPath(_path, _stroke);
    _quad(canvas, cam, x - 0.78, x + 0.78, a, b, const Color(0xFFB48660));
    _seams(canvas, cam, x, 0.78, a, b, 2.0, const Color(0x88603F22));
  }

  // ── Ganga Run (art pack part 2) ──
  Rect? _riverSkySrc;

  bool _paintRiverSky(Canvas canvas, TrackCamera cam) {
    final img = art['backgrounds/coastal_background'];
    if (img == null) return false;
    final hz = cam.horizon + 1;
    if (_riverSkySrc == null) {
      // Line the backdrop's own water line up with our horizon.
      final src = art.src('backgrounds/coastal_background')!;
      final waterLine = src.height * 0.64;
      var w = src.width;
      var h = w * hz / _w;
      if (h > waterLine) {
        h = waterLine;
        w = h * _w / hz;
      }
      _riverSkySrc = Rect.fromLTWH((src.width - w) / 2, waterLine - h, w, h);
    }
    canvas.drawImageRect(img, _riverSkySrc!, Rect.fromLTWH(0, 0, _w, hz), _image);
    return true;
  }

  static const _riverTemples = [
    'monuments/sacred_shrine',
    'monuments/temple_tower',
    'monuments/dwarka_temple',
    'monuments/golden_palace',
  ];
  static const _riverTempleWidth = [7.0, 7.0, 11.0, 20.0];

  void _paintRiverScenery(Canvas canvas, TrackCamera cam, int i, RunSimulation sim) {
    final z = i * sceneryEvery;
    final s = cam.scaleAt(z);
    if (s <= 0) return;
    final water = z >= sim.waterStart;
    final bridge = z >= sim.bridgeStart;
    for (final side in const [-1, 1]) {
      final h = _hash(i, side + 3);
      if (!water && side > 0) {
        // The ghats: stone steps down to the water, houses and, set back,
        // riverside temples and palaces as a backdrop.
        if ((i + 3) % 9 == 0) {
          final m = (i ~/ 9) % _riverTemples.length;
          _sprite(
            canvas,
            _riverTemples[m],
            cam.sx(pathHalfWidth + 11 + _riverTempleWidth[m] / 2, z),
            cam.sy(0, z),
            _riverTempleWidth[m] * s,
          );
        } else if (h < 0.55) {
          final b = (_hash(i, 5) * _buildings.length).floor() % _buildings.length;
          _sprite(canvas, _buildings[b], cam.sx(pathHalfWidth + 6.5, z), cam.sy(0, z), 7.0 * s, pad: 0.04);
        }
        _sprite(canvas, 'river/coastal_steps', cam.sx(pathHalfWidth + 2.6, z), cam.sy(0, z), 4.6 * s);
        continue;
      }
      // Out on the water.
      if (bridge && i.isEven) {
        _railPost(canvas, cam, side * (RunSimulation.laneWidth * 1.5 + 0.15), z);
        if (h < 0.3) {
          _sprite(canvas, 'river/water_splash', cam.sx(side * 4.8, z), cam.sy(0, z), 3.0 * s);
        }
      } else if (h < 0.18) {
        _sprite(canvas, 'river/boat_side', cam.sx(side * (7 + _hash(i, 9) * 8), z), cam.sy(0, z), 6.5 * s, pad: 0.2);
      } else if (h < 0.34) {
        _sprite(canvas, 'river/water_rock', cam.sx(side * (5.5 + _hash(i, 11) * 6), z), cam.sy(0, z), 2.2 * s);
      } else if (h < 0.44) {
        _sprite(canvas, 'river/sea_pillar', cam.sx(side * 5.2, z), cam.sy(0, z), 1.2 * s);
      }
      // Floating diyas drifting by: a gentle, respectful touch on the water.
      if (_hash(i, side + 13) < 0.3) {
        _sprite(
          canvas,
          'river/coastal_lamp',
          cam.sx(side * (4.6 + _hash(i, 15) * 3), z + 2),
          cam.sy(0, z + 2),
          0.6 * cam.scaleAt(z + 2),
          pad: 0.1,
        );
      }
    }
  }

  void _railPost(Canvas canvas, TrackCamera cam, double x, double z) {
    final s = cam.scaleAt(z);
    final bx = cam.sx(x, z);
    final by = cam.sy(0, z);
    _fill.color = const Color(0xFF7A5634);
    canvas.drawRect(Rect.fromLTWH(bx - 0.09 * s, by - 1.1 * s, 0.18 * s, 1.1 * s), _fill);
    final z2 = z + sceneryEvery * 2;
    _stroke
      ..color = const Color(0xFF8A6238)
      ..strokeWidth = math.max(1, 0.08 * s);
    canvas.drawLine(Offset(bx, by - 1.0 * s), Offset(cam.sx(x, z2), cam.sy(1.0, z2)), _stroke);
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
    // City gateways at the start and at the far edge of Ayodhya.
    if (realm == Realm.ayodhya) {
      for (final gz in [gateStartZ, sim.targetMetres.toDouble()]) {
        if (cam.visible(gz) && gz < far) _push(gz, (_kGate << 16));
      }
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
        Rect.fromLTWH(bx - trunkW / 2, by - trunkH, trunkW, trunkH),
        Radius.circular(trunkW * 0.3),
      ),
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

    final sprite = o.kind.sprite;
    if (sprite != null && o.kind.clearance != Clearance.slide) {
      if (o.kind.speed > 0 && !reduceMotion && art[sprite] != null) {
        // Rolling boulders rock from side to side as they come.
        final w = o.kind.spriteWidth * s;
        canvas.save();
        canvas.translate(cx, gy - w * 0.45);
        canvas.rotate(math.sin(o.z * 1.6) * 0.12);
        canvas.translate(-cx, -(gy - w * 0.45));
        _sprite(canvas, sprite, cx, gy, w);
        canvas.restore();
        return;
      }
      if (_sprite(canvas, sprite, cx, gy, o.kind.spriteWidth * s)) return;
    }

    switch (o.kind) {
      case ObstacleKind.fallenPillar:
        final h = o.kind.height * s;
        _fill.color = pal.stone;
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTRB(cx - halfW, gy - h, cx + halfW, gy), Radius.circular(h * 0.45)),
          _fill,
        );
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
            Rect.fromLTRB(cx - halfW * 1.1, gy - under - thick, cx + halfW * 1.1, gy - under),
            Radius.circular(thick / 2),
          ),
          _fill,
        );
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
      case ObstacleKind.garlandBeam:
        _paintGarlandBeam(canvas, cx, gy, s, halfW, t);
      case ObstacleKind.hangingLanterns:
        _paintLanterns(canvas, cx, gy, s, halfW, t);
      case ObstacleKind.stoneSteps:
        // A short flight of ghat steps across the lane: jump it.
        for (var k = 0; k < 3; k++) {
          final top = gy - (0.25 * (k + 1)) * s;
          final inset = k * 0.12 * halfW;
          _fill.color = k.isEven ? pal.stone : const Color(0xFFE6CBA0);
          canvas.drawRect(Rect.fromLTRB(cx - halfW + inset, top, cx + halfW - inset, top + 0.25 * s), _fill);
        }
        _fill.color = pal.stoneDark;
        canvas.drawRect(Rect.fromLTRB(cx - halfW, gy - 0.04 * s, cx + halfW, gy), _fill);
      // Code-drawn stand-ins while the art pack is still loading.
      case ObstacleKind.clayPot:
        _fill.color = const Color(0xFFD56B4F);
        canvas.drawOval(Rect.fromLTRB(cx - halfW * 0.7, gy - 0.95 * s, cx + halfW * 0.7, gy), _fill);
      case ObstacleKind.stoneDebris:
        _fill.color = pal.stoneDark;
        canvas.drawRect(Rect.fromLTRB(cx - halfW, gy - 0.5 * s, cx + halfW * 0.2, gy), _fill);
        _fill.color = pal.stone;
        canvas.drawRect(Rect.fromLTRB(cx - halfW * 0.1, gy - 0.75 * s, cx + halfW, gy), _fill);
      case ObstacleKind.woodenCrate:
        _fill.color = const Color(0xFFA87951);
        canvas.drawRect(Rect.fromLTRB(cx - halfW, gy - 1.6 * s, cx + halfW, gy), _fill);
      case ObstacleKind.brokenPillar:
        _fill.color = pal.stone;
        canvas.drawRect(Rect.fromLTRB(cx - halfW * 0.6, gy - 2.6 * s, cx + halfW * 0.6, gy), _fill);
      // Slide obstacles from the later art packs: a frame over the lane.
      case ObstacleKind.bladeGate:
        // A sandstone doorway with blades swinging under the lintel.
        if (!_sprite(canvas, o.kind.sprite!, cx, gy, 2.7 * s)) _paintStandInBeam(canvas, cx, gy, s, halfW);
      case ObstacleKind.icicles:
        _paintIcicles(canvas, cx, gy, s, halfW, t);
      case ObstacleKind.mandapaBeam:
        _paintMandapaBeam(canvas, cx, gy, s, halfW);
      case ObstacleKind.flamingArrows:
        _paintArrows(canvas, cx, gy, s, halfW, t);
      // Stand-ins for the later art packs while they load.
      case ObstacleKind.sandBoulder:
      case ObstacleKind.snowBoulder:
      case ObstacleKind.graniteBoulder:
        _fill.color = pal.stoneDark;
        canvas.drawCircle(Offset(cx, gy - 1.0 * s), 1.0 * s, _fill);
      case ObstacleKind.brokenColumn:
      case ObstacleKind.bladeTrap:
      case ObstacleKind.turretPillar:
      case ObstacleKind.closingGate:
      case ObstacleKind.leaningPillar:
      case ObstacleKind.fallenLintel:
      case ObstacleKind.fallenRocks:
      case ObstacleKind.snowCrate:
      case ObstacleKind.oxCart:
        _fill.color = pal.stoneDark;
        canvas.drawRect(Rect.fromLTRB(cx - halfW * 0.8, gy - o.kind.height * s, cx + halfW * 0.8, gy), _fill);
      case ObstacleKind.stoneBlocks:
      case ObstacleKind.goldenBlock:
      case ObstacleKind.gardenPot:
      case ObstacleKind.spikeTrap:
      case ObstacleKind.sandPit:
      case ObstacleKind.collapsingTiles:
      case ObstacleKind.snowMound:
      case ObstacleKind.crackedIce:
      case ObstacleKind.bazaarPot:
      case ObstacleKind.graniteRubble:
        _fill.color = pal.stoneDark;
        canvas.drawRect(Rect.fromLTRB(cx - halfW, gy - o.kind.height * s, cx + halfW, gy), _fill);
    }
  }

  /// A volley of flaming arrows flying at head height, between two golden
  /// columns: slide under.
  void _paintArrows(Canvas canvas, double cx, double gy, double s, double halfW, double t) {
    final under = ObstacleKind.flamingArrows.height * s;
    for (final side in const [-1, 1]) {
      final px = cx + side * halfW * 1.15;
      if (!_sprite(canvas, 'lanka/props/golden_column', px, gy, 0.62 * s)) {
        _fill.color = const Color(0xFFD9AE58);
        canvas.drawRect(Rect.fromLTRB(px - 0.12 * s, gy - under - 1.1 * s, px + 0.12 * s, gy), _fill);
      }
    }
    final drift = reduceMotion ? 0.0 : math.sin(t * 6) * 0.04 * s;
    if (!_sprite(canvas, ObstacleKind.flamingArrows.sprite!, cx + drift, gy - under + 0.05 * s, 2.0 * s, pad: 0.3)) {
      _stroke
        ..color = const Color(0xFFE8743B)
        ..strokeWidth = math.max(1.5, 0.08 * s);
      for (var k = 0; k < 3; k++) {
        final y = gy - under - (0.2 + k * 0.25) * s;
        canvas.drawLine(Offset(cx - halfW, y), Offset(cx + halfW, y - 0.1 * s), _stroke);
      }
    }
  }

  /// A plain beam over the lane, used while art loads.
  void _paintStandInBeam(Canvas canvas, double cx, double gy, double s, double halfW) {
    final under = 1.1 * s;
    _fill.color = pal.stoneDark;
    canvas.drawRect(Rect.fromLTWH(cx - halfW * 1.1, gy - under - 1.2 * s, 0.22 * s, under + 1.2 * s), _fill);
    canvas.drawRect(Rect.fromLTWH(cx + halfW * 1.1 - 0.22 * s, gy - under - 1.2 * s, 0.22 * s, under + 1.2 * s), _fill);
    canvas.drawRect(Rect.fromLTRB(cx - halfW * 1.2, gy - under - 0.5 * s, cx + halfW * 1.2, gy - under), _fill);
  }

  /// A snowy ice ledge across the lane with icicles hanging from it: slide.
  void _paintIcicles(Canvas canvas, double cx, double gy, double s, double halfW, double t) {
    final under = ObstacleKind.icicles.height * s;
    // Ice posts and the snowy ledge.
    _fill.color = const Color(0xFFB9D6EA);
    canvas.drawRect(Rect.fromLTWH(cx - halfW * 1.15, gy - under - 1.4 * s, 0.26 * s, under + 1.4 * s), _fill);
    canvas.drawRect(
      Rect.fromLTWH(cx + halfW * 1.15 - 0.26 * s, gy - under - 1.4 * s, 0.26 * s, under + 1.4 * s),
      _fill,
    );
    final top = gy - under - 1.3 * s;
    final sway = reduceMotion ? 0.0 : math.sin(t * 2) * 0.02 * s;
    // Icicles hang from just under the ledge down to the slide height.
    for (var k = -1; k <= 1; k++) {
      final ix = cx + k * halfW * 0.62 + sway;
      if (!_sprite(canvas, ObstacleKind.icicles.sprite!, ix, gy - under + 0.08 * s, 0.68 * s)) {
        _fill.color = const Color(0xFFD8ECF8);
        _path
          ..reset()
          ..moveTo(ix - 0.22 * s, top)
          ..lineTo(ix + 0.22 * s, top)
          ..lineTo(ix, gy - under)
          ..close();
        canvas.drawPath(_path, _fill);
      }
    }
    _fill.color = const Color(0xFFF7FBFF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(cx - halfW * 1.3, top - 0.35 * s, cx + halfW * 1.3, top + 0.1 * s),
        Radius.circular(0.2 * s),
      ),
      _fill,
    );
    _fill.color = const Color(0xFFC9DDF0);
    canvas.drawRect(Rect.fromLTRB(cx - halfW * 1.25, top + 0.02 * s, cx + halfW * 1.25, top + 0.1 * s), _fill);
  }

  /// A granite lintel across the lane on two carved columns: slide under.
  void _paintMandapaBeam(Canvas canvas, double cx, double gy, double s, double halfW) {
    final under = ObstacleKind.mandapaBeam.height * s;
    final colH = under + 0.9 * s;
    final colW = colH * 0.25 / 0.95;
    for (final side in const [-1, 1]) {
      final px = cx + side * (halfW * 1.1);
      if (!_sprite(canvas, ObstacleKind.mandapaBeam.sprite!, px, gy, colW)) {
        _fill.color = pal.stone;
        canvas.drawRect(Rect.fromLTRB(px - 0.14 * s, gy - colH, px + 0.14 * s, gy), _fill);
      }
    }
    final top = gy - colH + 0.05 * s;
    _fill.color = const Color(0xFFB9A78E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(cx - halfW * 1.35, top - 0.1 * s, cx + halfW * 1.35, gy - under),
        Radius.circular(0.06 * s),
      ),
      _fill,
    );
    _fill.color = const Color(0xFFD8C7AE);
    canvas.drawRect(Rect.fromLTRB(cx - halfW * 1.35, top - 0.1 * s, cx + halfW * 1.35, top + 0.12 * s), _fill);
    // A plain band of geometric carving.
    _fill.color = const Color(0x55806A50);
    for (var k = -4; k <= 4; k++) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(cx + k * halfW * 0.28, (top + gy - under) / 2 + 0.05 * s),
          width: 0.1 * s,
          height: 0.14 * s,
        ),
        _fill,
      );
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

  /// Draws an art-pack image standing on the ground at ([cx], [gy]), [width]
  /// pixels wide. Pack images have about 5% transparent padding, which the
  /// base offset absorbs. Returns false if the image is not loaded yet.
  bool _sprite(Canvas canvas, String name, double cx, double gy, double width, {double pad = 0.05}) {
    final img = art[name];
    if (img == null) return false;
    final src = art.src(name)!;
    final height = width * src.height / src.width;
    canvas.drawImageRect(img, src, Rect.fromLTWH(cx - width / 2, gy - height * (1 - pad), width, height), _image);
    return true;
  }

  /// A wooden beam across the lane with marigold garlands: slide under it.
  void _paintGarlandBeam(Canvas canvas, double cx, double gy, double s, double halfW, double t) {
    final under = ObstacleKind.garlandBeam.height * s;
    _fill.color = const Color(0xFF8A5A33);
    canvas.drawRect(Rect.fromLTWH(cx - halfW * 1.1, gy - under - 1.3 * s, 0.22 * s, under + 1.3 * s), _fill);
    canvas.drawRect(Rect.fromLTWH(cx + halfW * 1.1 - 0.22 * s, gy - under - 1.3 * s, 0.22 * s, under + 1.3 * s), _fill);
    _fill.color = const Color(0xFFA87951);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(cx - halfW * 1.2, gy - under - 0.5 * s, cx + halfW * 1.2, gy - under - 0.2 * s),
        Radius.circular(0.06 * s),
      ),
      _fill,
    );
    // Swags of marigolds hanging from the beam.
    final sway = reduceMotion ? 0.0 : math.sin(t * 3) * 0.03 * s;
    for (var k = 0; k < 9; k++) {
      final u = k / 8.0;
      final px = cx - halfW * 1.1 + u * halfW * 2.2 + sway;
      final py = gy - under - 0.2 * s + math.sin(u * math.pi * 2).abs() * 0.18 * s;
      _fill.color = k.isEven ? const Color(0xFFF29E38) : const Color(0xFFFCC23A);
      canvas.drawCircle(Offset(px, py), 0.1 * s, _fill);
    }
  }

  /// Paper lanterns strung across the lane on a wooden frame: slide under.
  void _paintLanterns(Canvas canvas, double cx, double gy, double s, double halfW, double t) {
    final under = ObstacleKind.hangingLanterns.height * s;
    _fill.color = const Color(0xFF7A5634);
    canvas.drawRect(Rect.fromLTWH(cx - halfW * 1.1, gy - under - 1.2 * s, 0.2 * s, under + 1.2 * s), _fill);
    canvas.drawRect(Rect.fromLTWH(cx + halfW * 1.1 - 0.2 * s, gy - under - 1.2 * s, 0.2 * s, under + 1.2 * s), _fill);
    _stroke
      ..color = const Color(0xFF5C4027)
      ..strokeWidth = math.max(1.5, 0.06 * s);
    final ropeY = gy - under - 0.75 * s;
    canvas.drawLine(Offset(cx - halfW * 1.1, ropeY), Offset(cx + halfW * 1.1, ropeY), _stroke);
    const colors = [Color(0xFFE85D4A), Color(0xFFF2B33D), Color(0xFFE86FA0), Color(0xFF3FA796)];
    for (var k = 0; k < 4; k++) {
      final sway = reduceMotion ? 0.0 : math.sin(t * 2.5 + k) * 0.04 * s;
      final lx = cx - halfW * 0.75 + k * halfW * 0.5 + sway;
      _fill.color = colors[k];
      canvas.drawOval(Rect.fromLTRB(lx - 0.17 * s, ropeY + 0.05 * s, lx + 0.17 * s, gy - under), _fill);
      _fill.color = const Color(0x66FFF3C4);
      canvas.drawOval(Rect.fromLTRB(lx - 0.08 * s, ropeY + 0.15 * s, lx + 0.08 * s, gy - under - 0.1 * s), _fill);
    }
  }

  // ── Ayodhya Run (art pack) ──
  static const double gateStartZ = 18;
  static const _buildings = [
    'buildings/ancient_b01',
    'buildings/ancient_b02',
    'buildings/ancient_b03',
    'buildings/ancient_b04',
    'buildings/ancient_b05',
    'buildings/ancient_b06',
  ];
  static const _streetProps = ['props/ancient_torch', 'props/marigold_pot', 'props/golden_vase', 'props/stone_pillar'];
  static const _streetPropWidth = [0.9, 1.3, 0.8, 0.7];

  /// Monuments set well back from the street, as a backdrop. Temples and
  /// shrines only ever appear here, never on the path.
  static const _monuments = [
    'monuments/dwarka_temple',
    'monuments/royal_fort',
    'monuments/golden_palace',
    'monuments/temple_tower',
    'monuments/stone_monument',
  ];
  static const _monumentWidth = [13.0, 26.0, 22.0, 9.0, 4.5];

  /// A sky image with two horizon bands (far hills, near skyline).
  bool _paintBandSky(Canvas canvas, TrackCamera cam, String skyName, String far, String near) {
    final sky = art[skyName];
    if (sky == null) return false;
    final hz = cam.horizon + 1;
    if (_skySrc == null) {
      // Cover-fit the sky image to the sky area (made once, then reused).
      final src = art.src(skyName)!;
      final want = _w / hz;
      final have = src.width / src.height;
      _skySrc = want > have
          ? Rect.fromLTWH(0, 0, src.width, src.width / want)
          : Rect.fromLTWH((src.width - src.height * want) / 2, 0, src.height * want, src.height);
    }
    canvas.drawImageRect(sky, _skySrc!, Rect.fromLTWH(0, 0, _w, hz), _image);
    _band(canvas, far, cam.horizon + 2, _h * 0.13, -cam.camX * 2);
    _band(canvas, near, cam.horizon + 2, _h * 0.085, -cam.camX * 5);
    return true;
  }

  /// A horizon strip, bottom-aligned at [bottom], tiled across the screen.
  void _band(Canvas canvas, String name, double bottom, double height, double shift) {
    final img = art[name];
    if (img == null) return;
    final src = art.src(name)!;
    final width = src.width * height / src.height;
    var x = (shift % width) - width;
    while (x < _w) {
      canvas.drawImageRect(img, src, Rect.fromLTWH(x, bottom - height, width, height), _image);
      x += width;
    }
  }

  void _paintCityScenery(Canvas canvas, TrackCamera cam, int i) {
    final z = i * sceneryEvery;
    final s = cam.scaleAt(z);
    if (s <= 0) return;
    for (final side in const [-1, 1]) {
      // A monument now and then, far back from the street.
      if ((i + (side > 0 ? 0 : 6)) % 12 == 0) {
        final m = (i ~/ 12 + (side > 0 ? 1 : 0)) % _monuments.length;
        final mx = side * (pathHalfWidth + 9 + _monumentWidth[m] / 2);
        _sprite(canvas, _monuments[m], cam.sx(mx, z), cam.sy(0, z), _monumentWidth[m] * s);
      }
      // Shop-houses line the street.
      final h = _hash(i, side + 3);
      if (h < 0.8) {
        final b = (_hash(i, side + 5) * _buildings.length).floor() % _buildings.length;
        final bx = side * (pathHalfWidth + 3.6);
        if (!_sprite(canvas, _buildings[b], cam.sx(bx, z), cam.sy(0, z), 7.2 * s, pad: 0.04)) {
          _ruin(canvas, cam, bx, z, h);
        }
      }
      // Lamps, pots and pillars along the kerb: decoration only.
      final hp = _hash(i, side + 9);
      if (hp < 0.55) {
        final p = (hp * 7).floor() % _streetProps.length;
        final px = side * (pathHalfWidth + 0.9);
        _sprite(canvas, _streetProps[p], cam.sx(px, z + 3), cam.sy(0, z + 3), _streetPropWidth[p] * cam.scaleAt(z + 3));
      }
    }
  }

  /// The city gateway the path runs through, wide enough to clear all lanes.
  void _paintGate(Canvas canvas, TrackCamera cam, double z) {
    final s = cam.scaleAt(z);
    if (s <= 0) return;
    _sprite(canvas, 'monuments/ancient_gateway', cam.sx(0, z), cam.sy(0, z), 19 * s);
  }

  // ── stage 3 onwards (one art pack per stage) ──
  /// Houses along the path, wild scenery behind them, monuments set well
  /// back and small props on the kerb. Beside a crevasse, only wild scenery.
  void _paintStageScenery(Canvas canvas, TrackCamera cam, int i, RunSimulation sim, StageArt st) {
    final z = i * sceneryEvery;
    final s = cam.scaleAt(z);
    if (s <= 0) return;
    final gapped = z >= sim.waterStart - 4;
    for (final side in const [-1, 1]) {
      // A monument now and then, far back.
      if ((i + (side > 0 ? 0 : 6)) % 12 == 0) {
        final m = st.monuments[(i ~/ 12 * 2 + (side > 0 ? 1 : 0)) % st.monuments.length];
        _sprite(canvas, m.name, cam.sx(side * (pathHalfWidth + 12 + m.width / 2), z), cam.sy(0, z), m.width * s);
      }
      final h = _hash(i, side + 3);
      if (z >= sim.bridgeStart && i.isEven) {
        _railPost(canvas, cam, side * (RunSimulation.laneWidth * 1.5 + 0.15), z);
      }
      if (gapped && st.gapWild.isNotEmpty) {
        // Ice cliffs, rocks and pines along the crevasse.
        if (h < 0.75) {
          final p = st.gapWild[(_hash(i, side + 5) * st.gapWild.length).floor() % st.gapWild.length];
          final x = side * (pathHalfWidth + 1.4 + p.width / 2 + _hash(i, side + 7) * 3);
          _sprite(canvas, p.name, cam.sx(x, z), cam.sy(0, z), p.width * s);
        }
        continue;
      }
      // Wild scenery behind the houses.
      final hw = _hash(i, side + 11);
      if (hw < 0.6) {
        final p = st.wild[(hw * 17).floor() % st.wild.length];
        final x = side * (pathHalfWidth + st.buildingWidth + 1 + p.width / 2 + _hash(i, side + 13) * 4);
        _sprite(canvas, p.name, cam.sx(x, z + 3), cam.sy(0, z + 3), p.width * cam.scaleAt(z + 3));
      }
      // Houses along the path.
      if (h < st.buildingChance) {
        final b = st.buildings[(_hash(i, side + 5) * st.buildings.length).floor() % st.buildings.length];
        final bx = side * (pathHalfWidth + 1.2 + st.buildingWidth / 2);
        if (!_sprite(canvas, b, cam.sx(bx, z), cam.sy(0, z), st.buildingWidth * s, pad: 0.04)) {
          _ruin(canvas, cam, bx, z, h);
        }
      }
      // Lamps, vases and columns along the kerb: decoration only.
      final hp = _hash(i, side + 9);
      if (hp < 0.5) {
        final p = st.kerb[(hp * 7).floor() % st.kerb.length];
        final px = side * (pathHalfWidth + 0.8);
        _sprite(canvas, p.name, cam.sx(px, z + 3), cam.sy(0, z + 3), p.width * cam.scaleAt(z + 3));
      }
    }
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
    if (sim.fellInWater && realm.hasCrevasse) {
      // Down into the crevasse: a puff of snow where the hero slipped.
      _fill.color = const Color(0xDDFFFFFF);
      final px = cam.sx(sim.x, z), py = cam.sy(0, z);
      for (var k = -1; k <= 1; k++) {
        canvas.drawCircle(Offset(px + k * 0.45 * s, py - (0.3 - 0.1 * k.abs()) * s), (0.42 - 0.1 * k.abs()) * s, _fill);
      }
      return;
    }
    if (sim.fellInWater) {
      // Into the river: just the splash.
      if (!_sprite(canvas, 'river/water_splash', cam.sx(sim.x, z), cam.sy(0, z), 2.6 * s)) {
        _fill.color = const Color(0xCCFFFFFF);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cam.sx(sim.x, z), cam.sy(0, z)), width: 1.6 * s, height: 0.6 * s),
          _fill,
        );
      }
      return;
    }
    final cx = cam.sx(sim.x, z);
    final groundY = cam.sy(0, z);
    final y = sim.y;
    final footY = cam.sy(y, z);

    // Shadow shrinks as the hero rises.
    final shadow = 1 / (1 + y * 0.6);
    _fill.color = const Color(0x40000000);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, groundY), width: 0.9 * s * shadow, height: 0.25 * s * shadow),
      _fill,
    );

    if (sim.boosting) _paintWings(canvas, cx, footY - 1.2 * s, s, sim.time);

    if (_paintHeroSprite(canvas, sim, cx, footY, s)) return;

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
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 0.14 * s, footY - legA * s), width: 0.2 * s, height: 0.1 * s),
      _fill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 0.14 * s, footY - legB * s), width: 0.2 * s, height: 0.1 * s),
      _fill,
    );

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
      RRect.fromRectAndRadius(
        Rect.fromLTRB(cx - 0.28 * s, shoulderY - 0.05 * s, cx + 0.28 * s, hipY + 0.12 * s),
        Radius.circular(0.12 * s),
      ),
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
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 0.12 * s, hipY - 0.2 * s, 0.26 * s, 0.24 * s),
        Radius.circular(0.05 * s),
      ),
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

  static const _heroFrames = [
    'hero/run_01',
    'hero/run_02',
    'hero/run_03',
    'hero/run_04',
    'hero/run_05',
    'hero/run_06',
    'hero/run_07',
    'hero/run_08',
    'hero/run_09',
    'hero/run_10',
    'hero/run_11',
    'hero/run_12',
    'hero/run_13',
    'hero/run_14',
    'hero/run_15',
    'hero/run_16',
  ];

  /// The rendered 16-frame run cycle, when its frames are loaded. In the
  /// air the hero holds a flight frame; sliding is the run pose crouched low.
  bool _paintHeroSprite(Canvas canvas, RunSimulation sim, double cx, double footY, double s) {
    final int frame;
    if (sim.state == RunState.crashed) {
      frame = 0;
    } else if (sim.y > 0.05 || sim.boosting) {
      frame = 6;
    } else if (sim.sliding) {
      frame = 2;
    } else {
      // About two strides a second, a little quicker as the run speeds up.
      final cycles = sim.time * (1.7 + sim.speed * 0.035);
      frame = ((cycles * 16).floor()) % 16;
    }
    final name = _heroFrames[frame];
    final img = art[name];
    if (img == null) return false;
    final src = art.src(name)!;
    final crouch = sim.sliding && !sim.boosting && sim.state != RunState.crashed;
    final h = 2.0 * s * (crouch ? 0.6 : 1.0);
    final w = 2.0 * s * src.width / src.height;
    canvas.drawImageRect(img, src, Rect.fromLTWH(cx - w / 2, footY - h, w, h), _image);
    return true;
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
