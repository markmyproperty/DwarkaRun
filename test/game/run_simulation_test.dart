import 'package:dwarka_run/game/entities.dart';
import 'package:dwarka_run/game/realm.dart';
import 'package:dwarka_run/game/run_autopilot.dart';
import 'package:dwarka_run/game/run_simulation.dart';
import 'package:dwarka_run/game/seeded_random.dart';
import 'package:flutter_test/flutter_test.dart';

/// Steps [sim] for [seconds] of game time.
void run(RunSimulation sim, double seconds) {
  for (var t = 0.0; t < seconds; t += 1 / 60) {
    sim.update(1 / 60);
  }
}

List<String> layout(RunSimulation sim) => [
      for (final o in sim.pools.obstacles)
        if (o.active) '${o.kind.name}@${o.lane}:${o.z.toStringAsFixed(2)}',
    ]..sort();

void main() {
  test('the random generator is reproducible', () {
    final a = SeededRandom(42), b = SeededRandom(42), c = SeededRandom(43);
    final sa = [for (var i = 0; i < 20; i++) a.nextUint32()];
    final sb = [for (var i = 0; i < 20; i++) b.nextUint32()];
    final sc = [for (var i = 0; i < 20; i++) c.nextUint32()];
    expect(sa, sb);
    expect(sa, isNot(sc));
    for (var i = 0; i < 1000; i++) {
      final d = a.nextDouble();
      expect(d >= 0 && d < 1, isTrue);
    }
  });

  test('the same seed lays out the same level', () {
    final a = RunSimulation(realm: Realm.forest, seed: 7);
    final b = RunSimulation(realm: Realm.forest, seed: 7);
    final c = RunSimulation(realm: Realm.forest, seed: 8);
    expect(layout(a), layout(b));
    expect(layout(a), isNot(layout(c)));
  });

  test('every row leaves a lane the hero can get through', () {
    for (var seed = 0; seed < 40; seed++) {
      final sim = RunSimulation(realm: Realm.forest, seed: seed);
      final rows = <double, List<Obstacle>>{};
      for (final o in sim.pools.obstacles.where((o) => o.active)) {
        rows.putIfAbsent(o.z, () => []).add(o);
      }
      for (final row in rows.values) {
        final blocked = row.where((o) => o.kind.clearance == Clearance.lane).length;
        expect(blocked, lessThan(3), reason: 'seed $seed');
        expect(row.length, lessThanOrEqualTo(2), reason: 'seed $seed');
      }
    }
  });

  test('standing still in the centre lane ends in a crash', () {
    final sim = RunSimulation(realm: Realm.forest, seed: 3);
    run(sim, 60);
    expect(sim.state, RunState.crashed);
    expect(sim.crashedInto, isNotNull);
  });

  test('the speed rises gradually and is capped', () {
    final sim = RunSimulation(realm: Realm.forest, seed: 1, targetMetres: 100000);
    final start = sim.speed;
    sim.boostCharges = 0;
    // Make the hero untouchable to watch the speed alone.
    for (var i = 0; i < 200 * 60; i++) {
      sim.boostLeft = 1;
      sim.update(1 / 60);
    }
    expect(sim.speed, greaterThan(start));
    expect(sim.speed, lessThanOrEqualTo(RunSimulation.maxSpeed));
  });

  test('a gentle start runs slower', () {
    final gentle = RunSimulation(realm: Realm.forest, seed: 1, gentleStart: true);
    final normal = RunSimulation(realm: Realm.forest, seed: 1);
    expect(gentle.speed, lessThan(normal.speed));
  });

  test('jumping clears a fallen pillar, sliding clears a branch', () {
    final sim = RunSimulation(realm: Realm.forest, seed: 1);
    sim.pools.clear();
    sim.pools.obstacles[0].spawn(ObstacleKind.fallenPillar, 0, 8, 0);
    sim.pools.obstacles[1].spawn(ObstacleKind.lowBranch, 0, 30, 0);
    // Stop the generator adding more rows in the way.
    sim.generator.fill(sim.pools, 0, 0);
    var jumped = false, slid = false;
    for (var i = 0; i < 4 * 120 && sim.state == RunState.running; i++) {
      for (final o in sim.pools.obstacles) {
        if (!o.active || o.spent) continue;
        final dz = o.z - sim.distance;
        if (o.kind == ObstacleKind.fallenPillar && !jumped && dz < 3) {
          sim.jump();
          jumped = true;
        }
        if (o.kind == ObstacleKind.lowBranch && !slid && dz < 4) {
          sim.slide();
          slid = true;
        }
      }
      sim.update(1 / 120);
      // Remove anything the generator added behind our two.
      for (final o in sim.pools.obstacles.skip(2)) {
        o.active = false;
      }
    }
    expect(jumped && slid, isTrue);
    expect(sim.state, RunState.running);
    expect(sim.distance, greaterThan(31));
  });

  test('a monkey snatches coins without ending the run', () {
    final sim = RunSimulation(realm: Realm.forest, seed: 1);
    sim.pools.clear();
    sim.coins = 12;
    sim.pools.obstacles[0].spawn(ObstacleKind.monkey, 0, 5, 0);
    for (var i = 0; i < 120; i++) {
      sim.update(1 / 120);
      for (final o in sim.pools.obstacles.skip(1)) {
        o.active = false;
      }
    }
    expect(sim.state, RunState.running);
    expect(sim.coins, 12 - RunSimulation.monkeyTakes);
  });

  test('pickups: coins, gems, feathers and the lotus magnet', () {
    final sim = RunSimulation(realm: Realm.forest, seed: 1);
    sim.pools.clear();
    sim.pools.pickups[0].spawn(PickupKind.coin, 0, 0.7, 3);
    sim.pools.pickups[1].spawn(PickupKind.gem, 0, 0.8, 5);
    sim.pools.pickups[2].spawn(PickupKind.feather, 0, 1.0, 7);
    sim.pools.pickups[3].spawn(PickupKind.lotus, 0, 1.0, 9);
    for (var i = 0; i < 120; i++) {
      sim.update(1 / 120);
      for (final o in sim.pools.obstacles) {
        o.active = false;
      }
    }
    expect(sim.coins, 1 + gemValue);
    expect(sim.gems, 1);
    expect(sim.boostCharges, 1);
    expect(sim.magnet, isTrue);
  });

  test('a Garuda feather boost flies over obstacles', () {
    final sim = RunSimulation(realm: Realm.forest, seed: 1);
    sim.pools.clear();
    sim.boostCharges = 1;
    expect(sim.boost(), isTrue);
    expect(sim.boostCharges, 0);
    sim.pools.obstacles[0].spawn(ObstacleKind.marketCart, 0, 12, 0);
    for (var i = 0; i < 120; i++) {
      sim.update(1 / 120);
      for (final o in sim.pools.obstacles.skip(1)) {
        o.active = false;
      }
    }
    expect(sim.state, RunState.running);
    expect(sim.boost(), isFalse);
  });

  test('reaching the distance target finishes the realm', () {
    final events = <RunEvent>[];
    final sim = RunSimulation(realm: Realm.forest, seed: 1, targetMetres: 60, onEvent: events.add);
    for (var i = 0; i < 60 * 30 && sim.state == RunState.running; i++) {
      sim.boostLeft = 1; // untouchable
      sim.update(1 / 60);
    }
    expect(sim.state, RunState.finished);
    expect(events, contains(RunEvent.finish));
  });

  test('lane changes stay within the three lanes', () {
    final sim = RunSimulation(realm: Realm.forest, seed: 1);
    sim.moveLeft();
    sim.moveLeft();
    expect(sim.lane, -1);
    sim.moveRight();
    sim.moveRight();
    sim.moveRight();
    expect(sim.lane, 1);
  });

  test('the autopilot can cross the Forest Kingdom on most seeds', () {
    var finished = 0;
    for (var seed = 0; seed < 10; seed++) {
      final sim = RunSimulation(realm: Realm.forest, seed: seed);
      final bot = RunAutopilot(sim);
      for (var i = 0; i < 60 * 240 && sim.state == RunState.running; i++) {
        bot.drive();
        sim.update(1 / 60);
      }
      if (sim.state == RunState.finished) finished++;
    }
    // The level must be beatable: a simple bot gets through most of the time.
    expect(finished, greaterThanOrEqualTo(6));
  });
}
