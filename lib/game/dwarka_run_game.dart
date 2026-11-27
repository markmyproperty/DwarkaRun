import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import 'camera.dart';
import 'realm.dart';
import 'run_autopilot.dart';
import 'run_simulation.dart';
import 'track_painter.dart';

/// What the Flutter HUD shows. A record, so the notifier only fires when a
/// value actually changes.
typedef RunHud = ({int coins, int metres, double progress, int boostCharges, bool boosting});

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
  }) : sim = RunSimulation(realm: realm, seed: seed, gentleStart: gentleStart, targetMetres: targetMetres),
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

  final ValueNotifier<RunHud> hud = ValueNotifier((coins: 0, metres: 0, progress: 0, boostCharges: 0, boosting: false));

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
    _autopilot?.drive();
    sim.update(dt);
    trackCamera.follow(sim.distance, sim.x);

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
    );
  }

  @override
  void render(Canvas canvas) {
    painter.paint(canvas, trackCamera, sim);
    super.render(canvas);
  }

  void _handleEvent(RunEvent e) {
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
