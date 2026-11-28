import 'dart:math' as math;

import 'entities.dart';
import 'realm.dart';
import 'seeded_random.dart';

/// Fixed-size pools so a run never allocates entities after it starts.
class EntityPools {
  EntityPools({int obstacles = 48, int pickups = 192, int platforms = 128})
    : obstacles = List.generate(obstacles, (_) => Obstacle(), growable: false),
      pickups = List.generate(pickups, (_) => Pickup(), growable: false),
      platforms = List.generate(platforms, (_) => Platform(), growable: false);

  final List<Obstacle> obstacles;
  final List<Pickup> pickups;
  final List<Platform> platforms;

  Platform? obtainPlatform() {
    for (final p in platforms) {
      if (!p.active) return p;
    }
    return null;
  }

  /// Whether [lane] has something to stand on at [z].
  bool surfaceAt(int lane, double z, [double tolerance = 0]) {
    for (final p in platforms) {
      if (p.lane == lane && p.covers(z, tolerance)) return true;
    }
    return false;
  }

  /// Whether [lane] is solid all the way from [from] to [to].
  bool solidBetween(int lane, double from, double to) {
    var z = from;
    // Walk forward through touching platforms.
    for (var guard = 0; guard < 16; guard++) {
      Platform? best;
      for (final p in platforms) {
        if (p.lane == lane && p.covers(z, 0.01) && (best == null || p.z1 > best.z1)) best = p;
      }
      if (best == null) return false;
      if (best.z1 >= to) return true;
      z = best.z1;
    }
    return false;
  }

  Obstacle? obtainObstacle() {
    for (final o in obstacles) {
      if (!o.active) return o;
    }
    return null;
  }

  Pickup? obtainPickup() {
    for (final p in pickups) {
      if (!p.active) return p;
    }
    return null;
  }

  /// Frees everything that has fallen behind [z].
  void recycleBehind(double z) {
    for (final o in obstacles) {
      if (o.active && o.z < z) o.active = false;
    }
    for (final p in pickups) {
      if (p.active && p.z < z) p.active = false;
    }
    for (final p in platforms) {
      if (p.active && p.z1 < z) p.active = false;
    }
  }

  void clear() {
    for (final p in platforms) {
      p.active = false;
    }
    for (final o in obstacles) {
      o.active = false;
    }
    for (final p in pickups) {
      p.active = false;
    }
  }
}

/// Lays the track out ahead of the hero, one row at a time, from a seed.
///
/// The same seed and realm always give the same level. Every row leaves at
/// least one lane the hero can get through without a power-up.
class LevelGenerator {
  LevelGenerator({
    required this.realm,
    required int seed,
    required this.gentleStart,
    required this.laneWidth,
    this.waterStart = double.infinity,
    this.bridgeStart = double.infinity,
  }) : _rng = SeededRandom(seed),
       _riverRng = SeededRandom(seed ^ 0x5EA5EA),
       _nextRowZ = gentleStart ? 55 : 40,
       _cellZ = waterStart;

  final Realm realm;

  /// River stages: open water from here on, and the bridge finale from
  /// [bridgeStart]. Infinity on dry land.
  final double waterStart;
  final double bridgeStart;

  /// The river layout has its own random stream, so dry stages keep exactly
  /// the levels they always had.
  final SeededRandom _riverRng;
  double _cellZ;
  final List<Platform?> _open = [null, null, null];

  /// River surfaces are laid out in cells this long. In each cell at most two
  /// lanes have a gap, and every gap is short enough to jump.
  static const double cell = 12;
  static const double maxGap = 4.2;
  final bool gentleStart;
  final double laneWidth;
  final SeededRandom _rng;

  double _nextRowZ;
  int _row = 0;

  /// Where the next row will go.
  double get nextRowZ => _nextRowZ;

  /// The opening rows of a first run: one obstacle each, teaching lane,
  /// jump and slide in that order, using this realm's own obstacles.
  late final List<ObstacleKind> _tutorialRows = [
    _firstOf(Clearance.lane, ObstacleKind.stoneWheel),
    _firstOf(Clearance.jump, ObstacleKind.fallenPillar),
    _firstOf(Clearance.slide, ObstacleKind.lowBranch),
  ];

  /// What a second lane-blocker in a row turns into: a jump obstacle.
  late final ObstacleKind _fallbackJump = _firstOf(Clearance.jump, ObstacleKind.fallenPillar);

  ObstacleKind _firstOf(Clearance c, ObstacleKind orElse) {
    for (final k in realm.obstacles) {
      if (k.clearance == c && k.speed == 0) return k;
    }
    return orElse;
  }

  /// Spawns rows until the track is laid out to [aheadZ]. [difficulty] runs
  /// from 0 (start) to 1 (top speed) and tightens the spacing.
  void fill(EntityPools pools, double aheadZ, double difficulty) {
    // Surfaces go down first, a little further ahead, so rows can check them.
    _fillRiver(pools, aheadZ + 30, difficulty);
    while (_nextRowZ < aheadZ) {
      _spawnRow(pools, _nextRowZ, difficulty);
      final gentle = gentleStart && _row < 8;
      final gap = gentle ? 40.0 : _lerp(30, 15, difficulty) + _rng.nextDouble() * 8;
      _nextRowZ += gap;
      _row++;
    }
  }

  void _spawnRow(EntityPools pools, double z, double difficulty) {
    if (gentleStart && _row < _tutorialRows.length) {
      _obstacle(pools, _tutorialRows[_row], 0, z);
      _coinLine(pools, 1, z, 6);
      return;
    }

    final kinds = realm.obstacles;
    // How many lanes get an obstacle: 1, or 2 as things speed up.
    final twoLanes = _rng.chance(0.25 + 0.35 * difficulty);
    final first = _rng.nextInt(3) - 1;
    final lanes = <int>[first];
    if (twoLanes) {
      lanes.add(((first + 1 + _rng.nextInt(2)) + 1) % 3 - 1);
    }

    var blockingCount = 0;
    final onWater = z >= waterStart - 6;
    for (final lane in lanes) {
      var kind = kinds[_rng.nextInt(kinds.length)];
      // Never block two lanes outright: the second becomes a jump or slide.
      if (kind.clearance == Clearance.lane) {
        blockingCount++;
        if (blockingCount > 1) kind = _fallbackJump;
      }
      // On the river, obstacles only stand on long, unbroken stretches, so a
      // dodge never ends in the water.
      if (onWater && !pools.solidBetween(lane, z - 7, z + 7)) continue;
      _obstacle(pools, kind, lane, z);
    }

    // Coins in the first free lane, or an arc over a jump obstacle.
    final freeLane = _firstFreeLane(lanes);
    final jumpLane = _jumpLane(pools, z);
    if (jumpLane != null && _rng.chance(0.4)) {
      _coinArc(pools, jumpLane, z);
    } else if (freeLane != null) {
      _coinLine(pools, freeLane, z, 5 + _rng.nextInt(3));
    }

    // Rare pickups between rows.
    final lane = freeLane ?? 0;
    final roll = _rng.nextDouble();
    if (roll < 0.035) {
      _pickup(pools, PickupKind.feather, lane, 1.0, z + 8);
    } else if (roll < 0.065) {
      _pickup(pools, PickupKind.lotus, lane, 1.0, z + 8);
    } else if (roll < 0.11) {
      _pickup(pools, PickupKind.gem, lane, 0.8, z + 8);
    }
  }

  int? _firstFreeLane(List<int> taken) {
    final start = _rng.nextInt(3);
    for (var i = 0; i < 3; i++) {
      final lane = (start + i) % 3 - 1;
      if (!taken.contains(lane)) return lane;
    }
    return null;
  }

  int? _jumpLane(EntityPools pools, double z) {
    for (final o in pools.obstacles) {
      if (o.active && o.z == z && o.kind.clearance == Clearance.jump) return o.lane;
    }
    return null;
  }

  void _obstacle(EntityPools pools, ObstacleKind kind, int lane, double z) {
    pools.obtainObstacle()?.spawn(kind, lane, z, _rng.nextDouble());
  }

  void _pickup(EntityPools pools, PickupKind kind, int lane, double y, double z) {
    // Over a gap in the river, lift it to jump height: a hint to jump.
    if (z >= waterStart && !pools.surfaceAt(lane, z, 0.5)) y = math.max(y, 1.6);
    pools.obtainPickup()?.spawn(kind, lane * laneWidth, y, z);
  }

  // ── river ──
  void _fillRiver(EntityPools pools, double aheadZ, double difficulty) {
    while (_cellZ < aheadZ) {
      final c = _cellZ;
      final bridge = c >= bridgeStart;
      // The first cell of the water and of the bridge stays whole.
      final whole = c == waterStart || (bridge && c - cell < bridgeStart);
      var gaps = whole ? 0 : (_riverRng.chance(0.85) ? 1 : 0);
      if (!whole && _riverRng.chance(0.15 + 0.35 * difficulty + (bridge ? 0.2 : 0))) gaps = 2;
      final a = _riverRng.nextInt(3) - 1;
      final b = (a + 1 + _riverRng.nextInt(2)) % 3;
      final second = b > 1 ? b - 3 : b;
      for (var lane = -1; lane <= 1; lane++) {
        final gapped = (gaps >= 1 && lane == a) || (gaps == 2 && lane == second);
        if (!gapped) {
          _extend(pools, lane, c, c + cell, bridge);
          continue;
        }
        final g0 = c + 3 + _riverRng.nextDouble() * 4;
        final len = 2.4 + _riverRng.nextDouble() * (maxGap - 2.4);
        _extend(pools, lane, c, g0, bridge);
        _open[lane + 1] = null;
        _extend(pools, lane, g0 + len, c + cell, bridge);
      }
      _cellZ += cell;
    }
  }

  void _extend(EntityPools pools, int lane, double from, double to, bool bridge) {
    final open = _open[lane + 1];
    if (open != null && open.active && (open.z1 - from).abs() < 0.01 && (open.kind == PlatformKind.bridge) == bridge) {
      final maxLen = open.kind == PlatformKind.boat ? 13.0 : 36.0;
      if (to - open.z0 <= maxLen) {
        open.z1 = to;
        return;
      }
    }
    final p = pools.obtainPlatform();
    if (p == null) return;
    final kind = bridge ? PlatformKind.bridge : (_riverRng.chance(0.35) ? PlatformKind.boat : PlatformKind.plank);
    p.spawn(kind, lane, from, to, _riverRng.nextDouble());
    _open[lane + 1] = p;
  }

  /// A line of coins in [lane], centred on the row at [z]. Placed beside the
  /// row's obstacles, it points the hero at the safe lane.
  void _coinLine(EntityPools pools, int lane, double z, int count) {
    final start = z - (count - 1);
    for (var i = 0; i < count; i++) {
      _pickup(pools, PickupKind.coin, lane, 0.7, start + i * 2.0);
    }
  }

  void _coinArc(EntityPools pools, int lane, double z) {
    for (var i = -3; i <= 3; i++) {
      final t = i / 3.0;
      _pickup(pools, PickupKind.coin, lane, 0.7 + 1.3 * (1 - t * t), z + i * 1.4);
    }
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * math.min(1, math.max(0, t));
}
