import 'entities.dart';
import 'run_simulation.dart';

/// A simple bot that plays a run. Used to record gameplay videos and for
/// soak tests; open the web build with `?autopilot=1` to watch it.
class RunAutopilot {
  RunAutopilot(this.sim);

  final RunSimulation sim;

  /// Decides on an input for this frame.
  void drive() {
    if (sim.state != RunState.running || sim.boosting) return;
    final reach = sim.speed * 0.55 + 4;

    // River gaps: hop to a lane that stays solid, or jump the gap.
    final threatFirst = _nearest(sim.lane, reach);
    if (sim.onRiver || sim.distance + reach > sim.waterStart) {
      final gapAt = _gapAhead(sim.lane, reach);
      if (gapAt != null && (threatFirst == null || threatFirst.z - threatFirst.kind.depth / 2 > gapAt)) {
        for (final dir in const [-1, 1]) {
          final lane = sim.lane + dir;
          if (lane < -1 || lane > 1) continue;
          if (_gapAhead(lane, reach) == null && _nearest(lane, reach) == null) {
            dir < 0 ? sim.moveLeft() : sim.moveRight();
            return;
          }
        }
        if (gapAt - sim.distance < sim.speed * 0.12 + 0.6) sim.jump();
        return;
      }
    }

    final threat = _nearest(sim.lane, reach);
    if (threat != null) {
      final dz = threat.z - sim.distance;
      switch (threat.kind.clearance) {
        case Clearance.jump:
        case Clearance.steal:
          if (dz < sim.speed * 0.2 + 1.2) sim.jump();
          return;
        case Clearance.slide:
          if (dz < sim.speed * 0.18 + 1.5) sim.slide();
          return;
        case Clearance.lane:
          final dir = _safestSide(reach * 1.5);
          if (dir == 0) {
            sim.boost();
          } else {
            dir < 0 ? sim.moveLeft() : sim.moveRight();
          }
          return;
      }
    }

    // Nothing in the way: drift towards coins if that lane is clear.
    for (final dir in const [-1, 1]) {
      final lane = sim.lane + dir;
      if (lane < -1 || lane > 1) continue;
      if (_nearest(lane, reach * 1.5) == null &&
          _gapAhead(lane, reach * 1.5) == null &&
          _coinsIn(lane, reach) > _coinsIn(sim.lane, reach)) {
        dir < 0 ? sim.moveLeft() : sim.moveRight();
        return;
      }
    }
  }

  /// Where the first gap in [lane] starts within [reach], or null.
  double? _gapAhead(int lane, double reach) {
    for (var dz = 0.0; dz < reach; dz += 0.5) {
      final z = sim.distance + dz;
      if (!sim.surfaceAt(lane, z)) return z;
    }
    return null;
  }

  Obstacle? _nearest(int lane, double reach) {
    Obstacle? best;
    for (final o in sim.pools.obstacles) {
      if (!o.active || o.spent || o.lane != lane) continue;
      final dz = o.z - sim.distance;
      if (dz < -0.5 || dz > reach) continue;
      if (best == null || o.z < best.z) best = o;
    }
    return best;
  }

  /// -1 or 1 for the neighbouring lane with nothing blocking it, or 0.
  int _safestSide(double reach) {
    // Prefer a neighbour with no blocker and no gap; else one with no blocker
    // (its gap can be jumped).
    for (final needSolid in const [true, false]) {
      for (final dir in const [-1, 1]) {
        final lane = sim.lane + dir;
        if (lane < -1 || lane > 1) continue;
        final o = _nearest(lane, reach);
        if (o != null && o.kind.clearance == Clearance.lane) continue;
        if (needSolid && _gapAhead(lane, reach) != null) continue;
        return dir;
      }
    }
    return 0;
  }

  int _coinsIn(int lane, double reach) {
    var n = 0;
    final x = lane * RunSimulation.laneWidth;
    for (final p in sim.pools.pickups) {
      if (!p.active) continue;
      final dz = p.z - sim.distance;
      if (dz > 0 && dz < reach && (p.x - x).abs() < 0.5) n++;
    }
    return n;
  }
}
