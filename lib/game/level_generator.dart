import 'dart:math' as math;

import 'entities.dart';
import 'realm.dart';
import 'seeded_random.dart';

/// Fixed-size pools so a run never allocates entities after it starts.
class EntityPools {
  EntityPools({int obstacles = 48, int pickups = 192})
      : obstacles = List.generate(obstacles, (_) => Obstacle(), growable: false),
        pickups = List.generate(pickups, (_) => Pickup(), growable: false);

  final List<Obstacle> obstacles;
  final List<Pickup> pickups;

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
  }

  void clear() {
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
  })  : _rng = SeededRandom(seed),
        _nextRowZ = gentleStart ? 55 : 40;

  final Realm realm;
  final bool gentleStart;
  final double laneWidth;
  final SeededRandom _rng;

  double _nextRowZ;
  int _row = 0;

  /// Where the next row will go.
  double get nextRowZ => _nextRowZ;

  /// The opening rows of a first run: one obstacle each, teaching lane,
  /// jump and slide in that order.
  static const _tutorialRows = [
    (ObstacleKind.stoneWheel, 0),
    (ObstacleKind.fallenPillar, 0),
    (ObstacleKind.lowBranch, 0),
  ];

  /// Spawns rows until the track is laid out to [aheadZ]. [difficulty] runs
  /// from 0 (start) to 1 (top speed) and tightens the spacing.
  void fill(EntityPools pools, double aheadZ, double difficulty) {
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
      final (kind, lane) = _tutorialRows[_row];
      _obstacle(pools, kind, lane, z);
      _coinLine(pools, lane == 0 ? 1 : 0, z, 6);
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
    for (final lane in lanes) {
      var kind = kinds[_rng.nextInt(kinds.length)];
      // Never block two lanes outright: the second becomes a jump or slide.
      if (kind.clearance == Clearance.lane) {
        blockingCount++;
        if (blockingCount > 1) kind = ObstacleKind.fallenPillar;
      }
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
    pools.obtainPickup()?.spawn(kind, lane * laneWidth, y, z);
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
