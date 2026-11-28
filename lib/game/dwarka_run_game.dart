import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import 'camera.dart';
import 'fx_particles.dart';
import 'realm.dart';
import 'run_autopilot.dart';
import 'run_simulation.dart';
import 'track_painter.dart';

/// What the Flutter HUD shows. A record, so the notifier only fires when a
/// value actually changes.
typedef RunHud = ({int coins, int metres, double progress, int boostCharges, bool boosting, int score, bool magnet});

/// The Flame game for one run of one realm.
///
/// [RunSimulation] owns the rules; this class owns the frame loop, the camera
/// and painting. Input arrives from the Flutter layer through [sim].
class DwarkaRunGame extends FlameGame {
  DwarkaRunGame({
    required this.realm,
    required this.seed,
    this.gentleStart = false,
    this.reduceMotion = false,
    int? targetMetres,
    this.onEvent,
    this.onCrashed,
    this.onFinished,
    bool autopilot = false,
    this.hold = false,
    double boostSeconds = RunSimulation.baseBoostSeconds,
    double magnetSeconds = RunSimulation.baseMagnetSeconds,
  }) : sim = RunSimulation(
         realm: realm,
         seed: seed,
         gentleStart: gentleStart,
         targetMetres: targetMetres,
         boostSeconds: boostSeconds,
         magnetSeconds: magnetSeconds,
       ),
       painter = TrackPainter(realm) {
    sim.onEvent = _handleEvent;
    if (autopilot) _autopilot = RunAutopilot(sim);
    painter.reduceMotion = reduceMotion;
  }

  final Realm realm;
  final int seed;
  final bool gentleStart;
  final bool reduceMotion;
  final RunSimulation sim;
  final TrackPainter painter;
  final TrackCamera trackCamera = TrackCamera();

  final void Function(RunEvent event)? onEvent;
  final VoidCallback? onCrashed;
  final VoidCallback? onFinished;

  final ValueNotifier<RunHud> hud = ValueNotifier((
    coins: 0,
    metres: 0,
    progress: 0,
    boostCharges: 0,
    boosting: false,
    score: 0,
    magnet: false,
  ));

  /// While true the world is drawn but the run does not move: the stage
  /// intro and the countdown play over it.
  bool hold;

  final FxParticles fx = FxParticles();

  /// Live score, the same formula as the results screen.
  int get score => sim.metres + sim.coins * 5 + sim.gems * 50 + sim.nearMisses * 25;

  /// Seconds left of the crash wobble before game over is reported.
  RunAutopilot? _autopilot;

  double _crashTimer = -1;
  double _shake = 0;
  bool _reported = false;

  @override
  Color backgroundColor() => realm.palette.skyBottom;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    trackCamera.resize(size.x, size.y);
    painter.resize(trackCamera);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!hold) {
      _autopilot?.drive();
      sim.update(dt);
    }
    trackCamera.follow(sim.distance, sim.x);
    // A slight widening of the view while flying, for a sense of speed.
    final targetZoom = sim.boosting && !reduceMotion ? 0.9 : 1.0;
    trackCamera.zoom += (targetZoom - trackCamera.zoom) * math.min(1, dt * 4);
    fx.update(dt);

    if (_shake > 0 && !reduceMotion) {
      _shake = math.max(0, _shake - dt);
      final a = _shake * 26;
      trackCamera.shakeX = math.sin(sim.time * 90) * a;
      trackCamera.shakeY = math.cos(sim.time * 70) * a * 0.6;
    } else {
      trackCamera.shakeX = 0;
      trackCamera.shakeY = 0;
    }

    if (_crashTimer > 0) {
      _crashTimer -= dt;
      if (_crashTimer <= 0 && !_reported) {
        _reported = true;
        onCrashed?.call();
      }
    }

    hud.value = (
      coins: sim.coins,
      metres: sim.metres,
      progress: sim.progress,
      boostCharges: sim.boostCharges,
      boosting: sim.boosting,
      score: score,
      magnet: sim.magnet,
    );
  }

  /// Brings the hero back after a crash (see [RunSimulation.revive]).
  void revive() {
    if (!sim.revive()) return;
    _crashTimer = -1;
    _reported = false;
    _shake = 0;
    resumeEngine();
  }

  @override
  void render(Canvas canvas) {
    painter.paint(canvas, trackCamera, sim);
    fx.paint(canvas);
    super.render(canvas);
  }

  /// Where the hero's chest is on screen now.
  Offset get _heroChest => trackCamera.project(sim.x, sim.y + (sim.sliding ? 0.5 : 1.2), sim.distance);

  void _handleEvent(RunEvent e) {
    if (!reduceMotion) {
      switch (e) {
        case RunEvent.coin:
          fx.burst(_heroChest, FxKind.coin);
        case RunEvent.gem:
          fx.burst(_heroChest, FxKind.gem);
        case RunEvent.feather || RunEvent.lotus || RunEvent.boostStart || RunEvent.revive:
          fx.burst(_heroChest, FxKind.power);
        case RunEvent.nearMiss:
          fx.burst(_heroChest, FxKind.whoosh);
          _shake = math.max(_shake, 0.08);
        case RunEvent.crash:
          fx.burst(_heroChest, FxKind.dust);
        default:
          break;
      }
    }
    switch (e) {
      case RunEvent.crash:
        _shake = 0.35;
        _crashTimer = 0.6;
      case RunEvent.finish:
        if (!_reported) {
          _reported = true;
          onFinished?.call();
        }
      default:
        break;
    }
    onEvent?.call(e);
  }
}
