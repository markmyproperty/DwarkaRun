import 'dart:math' as math;

import 'entities.dart';
import 'level_generator.dart';
import 'realm.dart';

/// Things that happen in a run, for sound, haptics and analytics.
enum RunEvent {
  coin,
  gem,
  feather,
  lotus,
  jump,
  slide,
  laneChange,
  boostStart,
  monkeySteal,
  crash,
  finish,
}

enum RunState { running, crashed, finished }

/// The rules of a run, with no Flutter or Flame in it, so tests can step it
/// directly. It advances in fixed steps, so the same seed and inputs always
/// play out the same way whatever the frame rate.
class RunSimulation {
  RunSimulation({
    required this.realm,
    required int seed,
    this.gentleStart = false,
    int? targetMetres,
    this.onEvent,
  })  : targetMetres = targetMetres ?? realm.targetMetres,
        speed = gentleStart ? gentleSpeed : startSpeed {
    generator = LevelGenerator(
      realm: realm,
      seed: seed,
      gentleStart: gentleStart,
      laneWidth: laneWidth,
    );
    generator.fill(pools, viewAhead, 0);
  }

  // ── tuning ──
  static const double laneWidth = 2.2;
  static const double startSpeed = 13;
  static const double gentleSpeed = 9;
  static const double maxSpeed = 28;
  static const double acceleration = 0.12;
  static const double gentleSeconds = 20;
  static const double jumpVelocity = 9.5;
  static const double gravity = 28;
  static const double slideSeconds = 0.75;
  static const double laneChangeSpeed = 14;
  static const double boostSeconds = 3.2;
  static const double boostHeight = 2.8;
  static const double magnetSeconds = 8;
  static const double viewAhead = 160;
  static const int maxBoostCharges = 3;
  static const int monkeyTakes = 5;
  static const double step = 1 / 120;

  final Realm realm;
  final bool gentleStart;
  final int targetMetres;
  void Function(RunEvent event)? onEvent;

  final EntityPools pools = EntityPools();
  late final LevelGenerator generator;

  // ── state ──
  RunState state = RunState.running;
  double time = 0;
  double distance = 0;
  double speed;
  int coins = 0;
  int gems = 0;
  int boostCharges = 0;

  /// Target lane (-1, 0, 1) and the hero's actual sideways position.
  int lane = 0;
  double x = 0;

  /// Height of the hero's feet above the path.
  double y = 0;
  double vy = 0;
  double slideLeft = 0;
  double boostLeft = 0;
  double magnetLeft = 0;

  /// Set when the last crash happened, for the crash wobble.
  ObstacleKind? crashedInto;

  double _accumulator = 0;

  bool get onGround => y <= 0 && boostLeft <= 0;
  bool get sliding => slideLeft > 0;
  bool get boosting => boostLeft > 0;
  bool get magnet => magnetLeft > 0;
  int get metres => distance.floor();
  double get progress => math.min(1, distance / targetMetres);

  /// 0 at the start, 1 at top speed.
  double get difficulty => ((speed - startSpeed) / (maxSpeed - startSpeed)).clamp(0.0, 1.0);

  // ── input ──
  void moveLeft() => _changeLane(-1);
  void moveRight() => _changeLane(1);

  void _changeLane(int dir) {
    if (state != RunState.running) return;
    final next = (lane + dir).clamp(-1, 1);
    if (next == lane) return;
    lane = next;
    onEvent?.call(RunEvent.laneChange);
  }

  void jump() {
    if (state != RunState.running || boosting) return;
    if (y > 0.05) return;
    slideLeft = 0;
    vy = jumpVelocity;
    y = 0.001;
    onEvent?.call(RunEvent.jump);
  }

  void slide() {
    if (state != RunState.running || boosting) return;
    // Sliding while airborne pulls the hero down fast.
    if (y > 0) vy = -jumpVelocity * 1.4;
    slideLeft = slideSeconds;
    onEvent?.call(RunEvent.slide);
  }

  /// Uses one Garuda feather charge: a short flight over everything.
  bool boost() {
    if (state != RunState.running || boostCharges <= 0 || boosting) return false;
    boostCharges--;
    boostLeft = boostSeconds;
    slideLeft = 0;
    vy = 0;
    onEvent?.call(RunEvent.boostStart);
    return true;
  }

  // ── stepping ──
  /// Advances by [dt] seconds of real time, in fixed steps.
  void update(double dt) {
    if (state != RunState.running) return;
    _accumulator += math.min(dt, 0.1);
    while (_accumulator >= step && state == RunState.running) {
      _accumulator -= step;
      _tick(step);
    }
  }

  void _tick(double dt) {
    time += dt;

    // Speed: slow and steady at the start of a first run, then rising.
    final ramp = gentleStart && time < gentleSeconds;
    if (!ramp) speed = math.min(maxSpeed, speed + acceleration * dt);
    final runSpeed = boosting ? speed * 1.35 : speed;
    distance += runSpeed * dt;

    // Sideways.
    final targetX = lane * laneWidth;
    final dx = targetX - x;
    final stepX = laneChangeSpeed * dt;
    x = dx.abs() <= stepX ? targetX : x + stepX * dx.sign;

    // Up and down.
    if (boosting) {
      boostLeft -= dt;
      y += (boostHeight - y) * math.min(1, dt * 8);
      if (boostLeft <= 0) {
        boostLeft = 0;
        vy = 0;
      }
    } else if (y > 0 || vy > 0) {
      vy -= gravity * dt;
      y += vy * dt;
      if (y <= 0) {
        y = 0;
        vy = 0;
      }
    }
    if (slideLeft > 0) slideLeft = math.max(0, slideLeft - dt);
    if (magnetLeft > 0) magnetLeft = math.max(0, magnetLeft - dt);

    _moveObstacles(dt);
    _collectPickups();
    _checkObstacles();
    if (state != RunState.running) return;

    if (distance >= targetMetres) {
      state = RunState.finished;
      onEvent?.call(RunEvent.finish);
      return;
    }

    // Keep the track laid out ahead, but never past the finish.
    final ahead = math.min(distance + viewAhead, targetMetres - 10.0);
    generator.fill(pools, ahead, difficulty);
    pools.recycleBehind(distance - 8);
  }

  void _moveObstacles(double dt) {
    for (final o in pools.obstacles) {
      if (!o.active || o.kind.speed == 0) continue;
      // Rolling wheels only start once they are in view.
      if (o.z - distance < 90) o.z -= o.kind.speed * dt;
    }
  }

  void _collectPickups() {
    final heroMid = y + (sliding ? 0.4 : 0.9);
    for (final p in pools.pickups) {
      if (!p.active) continue;
      final dz = p.z - distance;
      if (dz > 12 || dz < -1.5) continue;

      if (magnet && (p.kind == PickupKind.coin || p.kind == PickupKind.gem) && dz < 10) {
        // Pull towards the hero.
        p.x += (x - p.x) * 0.12;
        p.y += (heroMid - p.y) * 0.12;
        p.z -= math.min(dz + 0.2, 0.6);
      }

      if (dz.abs() < 1.0 && (p.x - x).abs() < 1.2 && (p.y - heroMid).abs() < 1.4) {
        p.active = false;
        switch (p.kind) {
          case PickupKind.coin:
            coins++;
            onEvent?.call(RunEvent.coin);
          case PickupKind.gem:
            gems++;
            coins += gemValue;
            onEvent?.call(RunEvent.gem);
          case PickupKind.feather:
            boostCharges = math.min(maxBoostCharges, boostCharges + 1);
            onEvent?.call(RunEvent.feather);
          case PickupKind.lotus:
            magnetLeft = magnetSeconds;
            onEvent?.call(RunEvent.lotus);
        }
      }
    }
  }

  void _checkObstacles() {
    for (final o in pools.obstacles) {
      if (!o.active || o.spent) continue;
      final dz = o.z - distance;
      if (dz > o.kind.depth / 2 + 0.35 || dz < -(o.kind.depth / 2 + 0.35)) continue;
      if ((o.lane * laneWidth - x).abs() > laneWidth * 0.62) continue;

      if (boosting) continue;
      final cleared = switch (o.kind.clearance) {
        Clearance.jump => y > o.kind.height,
        Clearance.slide => sliding,
        Clearance.lane => false,
        Clearance.steal => y > o.kind.height,
      };
      if (cleared) continue;

      o.spent = true;
      if (o.kind.clearance == Clearance.steal) {
        coins = math.max(0, coins - monkeyTakes);
        onEvent?.call(RunEvent.monkeySteal);
        continue;
      }
      crashedInto = o.kind;
      state = RunState.crashed;
      onEvent?.call(RunEvent.crash);
      return;
    }
  }
}
