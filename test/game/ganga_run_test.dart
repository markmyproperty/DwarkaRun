import 'package:dwarka_run/game/entities.dart';
import 'package:dwarka_run/game/level_generator.dart';
import 'package:dwarka_run/game/realm.dart';
import 'package:dwarka_run/game/run_simulation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lays out the whole river for [sim] by running the generator to the end.
void layOutAll(RunSimulation sim) => sim.generator.fill(sim.pools, sim.targetMetres.toDouble(), 0.6);

/// A Ganga run whose only content is the river surfaces (no obstacles or
/// pickups), starting [ahead] metres before open water.
RunSimulation riverOnly({int seed = 1, double ahead = 6}) {
  final sim = RunSimulation(realm: Realm.ganga, seed: seed, targetMetres: 1000);
  sim.distance = sim.waterStart - ahead;
  sim.generator.fill(sim.pools, sim.distance + 200, 0.5);
  for (final o in sim.pools.obstacles) {
    o.active = false;
  }
  return sim;
}

void step(RunSimulation sim, int ticks, {bool clearObstacles = true}) {
  for (var i = 0; i < ticks && sim.state == RunState.running; i++) {
    sim.update(RunSimulation.step);
    if (clearObstacles) {
      for (final o in sim.pools.obstacles) {
        o.active = false;
      }
    }
  }
}

void main() {
  test('Ganga Run has ghats, then open water, then the bridge finale', () {
    final sim = RunSimulation(realm: Realm.ganga, seed: 1);
    expect(sim.waterStart, greaterThan(0));
    expect(sim.bridgeStart, greaterThan(sim.waterStart));
    expect(sim.bridgeStart, lessThan(sim.targetMetres));
    // Dry stages have no river.
    final dry = RunSimulation(realm: Realm.ayodhya, seed: 1);
    expect(dry.waterStart, double.infinity);
    expect(dry.pools.platforms.where((p) => p.active), isEmpty);
  });

  test('on the river, some lane is always solid and every gap can be jumped', () {
    for (var seed = 0; seed < 25; seed++) {
      final sim = RunSimulation(realm: Realm.ganga, seed: seed, targetMetres: 900);
      final pools = EntityPools(obstacles: 48, pickups: 400, platforms: 400);
      final gen = LevelGenerator(
        realm: Realm.ganga,
        seed: seed,
        gentleStart: false,
        laneWidth: RunSimulation.laneWidth,
        waterStart: sim.waterStart,
        bridgeStart: sim.bridgeStart,
      );
      gen.fill(pools, 900, 1.0);
      for (var z = sim.waterStart; z < 880; z += 0.25) {
        final solid = [for (var lane = -1; lane <= 1; lane++) pools.surfaceAt(lane, z)];
        expect(solid.contains(true), isTrue, reason: 'seed $seed, z $z: every lane is water');
      }
      for (var lane = -1; lane <= 1; lane++) {
        var gapFrom = -1.0;
        for (var z = sim.waterStart; z < 880; z += 0.1) {
          final s = pools.surfaceAt(lane, z);
          if (!s && gapFrom < 0) gapFrom = z;
          if (s && gapFrom >= 0) {
            expect(z - gapFrom, lessThanOrEqualTo(LevelGenerator.maxGap + 0.2), reason: 'seed $seed lane $lane');
            gapFrom = -1;
          }
        }
      }
    }
  });

  test('boats, planks and the bridge all appear', () {
    final sim = RunSimulation(realm: Realm.ganga, seed: 4, targetMetres: 600);
    final pools = EntityPools(platforms: 400);
    LevelGenerator(
      realm: Realm.ganga,
      seed: 4,
      gentleStart: false,
      laneWidth: RunSimulation.laneWidth,
      waterStart: sim.waterStart,
      bridgeStart: sim.bridgeStart,
    ).fill(pools, 600, 0.5);
    final kinds = pools.platforms.where((p) => p.active).map((p) => p.kind).toSet();
    expect(kinds, containsAll(PlatformKind.values));
    for (final p in pools.platforms.where((p) => p.active)) {
      expect(p.kind == PlatformKind.bridge, p.z0 >= sim.bridgeStart - 0.01, reason: 'bridge only in the finale');
    }
  });

  test('stepping off into the river ends the run with a splash', () {
    final events = <RunEvent>[];
    final sim = riverOnly();
    sim.onEvent = events.add;
    // Remove every surface: open water ahead.
    for (final p in sim.pools.platforms) {
      p.active = false;
    }
    step(sim, 240);
    expect(sim.state, RunState.crashed);
    expect(sim.fellInWater, isTrue);
    expect(events, containsAllInOrder([RunEvent.riverStart, RunEvent.splash, RunEvent.crash]));
  });

  test('a jump carries the hero over a gap', () {
    final sim = riverOnly();
    for (final p in sim.pools.platforms) {
      p.active = false;
    }
    // Solid up to a 3.5 m gap in the centre lane, then solid again.
    final w = sim.waterStart;
    sim.pools.platforms[0].spawn(PlatformKind.plank, 0, w, w + 10, 0);
    sim.pools.platforms[1].spawn(PlatformKind.boat, 0, w + 13.5, w + 60, 0);
    var jumped = false;
    for (var i = 0; i < 360 && sim.state == RunState.running; i++) {
      if (!jumped && sim.distance > w + 9.0) {
        sim.jump();
        jumped = true;
      }
      sim.update(RunSimulation.step);
      for (final o in sim.pools.obstacles) {
        o.active = false;
      }
    }
    expect(jumped, isTrue);
    expect(sim.state, RunState.running);
    expect(sim.distance, greaterThan(w + 20));
  });

  test('a Garuda feather flight crosses open water', () {
    final sim = riverOnly();
    for (final p in sim.pools.platforms) {
      p.active = false;
    }
    sim.boostCharges = 1;
    sim.boost();
    step(sim, 120);
    expect(sim.state, RunState.running);
  });

  test('river obstacles only stand on long unbroken stretches', () {
    for (var seed = 0; seed < 20; seed++) {
      final sim = RunSimulation(realm: Realm.ganga, seed: seed, targetMetres: 900);
      sim.generator.fill(sim.pools, 400, 0.6);
      for (final o in sim.pools.obstacles.where((o) => o.active && o.z > sim.waterStart)) {
        expect(sim.pools.solidBetween(o.lane, o.z - 6.9, o.z + 6.9), isTrue, reason: 'seed $seed ${o.kind} at ${o.z}');
      }
    }
  });

  test('the bridge finale is announced', () {
    final events = <RunEvent>[];
    final sim = RunSimulation(realm: Realm.ganga, seed: 2, targetMetres: 200, onEvent: events.add);
    for (var i = 0; i < 60 * 30 && sim.state == RunState.running; i++) {
      sim.boostLeft = 1; // fly over everything
      sim.update(1 / 60);
    }
    expect(sim.state, RunState.finished);
    expect(events, containsAllInOrder([RunEvent.riverStart, RunEvent.bridgeStart, RunEvent.finish]));
  });
}
