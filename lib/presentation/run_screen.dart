import 'dart:async';
import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../game/art_library.dart';
import '../game/dwarka_run_game.dart';
import '../game/realm.dart';
import '../game/run_simulation.dart';
import '../l10n/gen/app_localizations.dart';
import 'dr_theme.dart';
import 'run_hud.dart';
import 'run_panels.dart';

/// `?autopilot=1` on the web build lets a bot play, for recording videos.
final bool _autopilot = kIsWeb && Uri.base.queryParameters['autopilot'] == '1';

enum _Phase { playing, paused, gameOver, complete }

/// One run of a realm: the game, its HUD and the pause, game-over and
/// realm-complete panels.
class RunScreen extends StatefulWidget {
  const RunScreen({super.key, required this.realm, this.seed, this.gentleStart, this.targetMetres});

  final Realm realm;

  /// Fixed seed for a reproducible level. Random when null.
  final int? seed;

  /// Slow, sparse opening with swipe hints. Defaults to "first run ever".
  final bool? gentleStart;

  /// Overrides the realm's distance target (tests).
  final int? targetMetres;

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> with WidgetsBindingObserver {
  late DwarkaRunGame _game;
  late int _seed;
  late bool _gentle;
  _Phase _phase = _Phase.playing;
  bool _newBest = false;
  int _attempt = 0;
  bool _started = false;

  /// The running simulation, for tests.
  @visibleForTesting
  RunSimulation get debugSim => _game.sim;

  final FocusNode _focus = FocusNode(debugLabel: 'run');
  final ValueNotifier<String?> _toast = ValueNotifier(null);
  Timer? _toastTimer;

  // Swipe tracking.
  Offset _drag = Offset.zero;
  bool _swiped = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _seed = widget.seed ?? math.Random().nextInt(1 << 31);
    ArtLibrary.instance.loadStage(widget.realm);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      final scope = AppScope.read(context);
      _gentle = widget.gentleStart ?? !scope.progress.tutorialDone;
      _game = _newGame();
    }
  }

  DwarkaRunGame _newGame() {
    final scope = AppScope.read(context);
    final seed = _seed + _attempt;
    scope.analytics.runStart(realm: widget.realm.id, seed: seed);
    scope.audio.playMusic(widget.realm.id);
    return DwarkaRunGame(
      realm: widget.realm,
      seed: seed,
      gentleStart: _gentle && _attempt == 0,
      reduceMotion: reduceMotionOf(context),
      targetMetres: widget.targetMetres,
      onEvent: _onEvent,
      onCrashed: () => _endRun('crash'),
      onFinished: () => _endRun('finish'),
      autopilot: _autopilot,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _toastTimer?.cancel();
    _focus.dispose();
    _toast.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _phase == _Phase.playing) _pause();
  }

  // ── events ──
  void _onEvent(RunEvent e) {
    final scope = AppScope.read(context);
    scope.audio.onRunEvent(e);
    final l = AppLocalizations.of(context);
    switch (e) {
      case RunEvent.monkeySteal:
        _showToast(l.monkeyStole(RunSimulation.monkeyTakes));
        HapticFeedback.lightImpact();
      case RunEvent.feather:
        _showToast(l.featherGot);
      case RunEvent.lotus:
        _showToast(l.lotusGot);
      case RunEvent.riverStart:
        _showToast(switch (widget.realm.gapStyle) {
          GapStyle.river => l.riverStart,
          GapStyle.crevasse => l.crevasseStart,
          GapStyle.moat => l.moatStart,
        });
      case RunEvent.bridgeStart:
        _showToast(switch (widget.realm.gapStyle) {
          GapStyle.river => l.bridgeStart,
          GapStyle.crevasse => l.ropeBridgeStart,
          GapStyle.moat => l.fortressBridgeStart,
        });
      case RunEvent.crash:
        HapticFeedback.heavyImpact();
      default:
        break;
    }
  }

  void _showToast(String text) {
    _toast.value = text;
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) _toast.value = null;
    });
  }

  Future<void> _endRun(String reason) async {
    if (!mounted || _phase == _Phase.gameOver || _phase == _Phase.complete) return;
    final scope = AppScope.read(context);
    final sim = _game.sim;
    final finished = reason == 'finish';
    setState(() => _phase = finished ? _Phase.complete : _Phase.gameOver);
    scope.analytics.runEnd(realm: widget.realm.id, reason: reason, metres: sim.metres, coins: sim.coins);
    final best = await scope.progress.recordRun(metres: sim.metres, coins: sim.coins);
    await scope.progress.markTutorialDone();
    if (finished) {
      await scope.progress.completeRealm(widget.realm);
      scope.analytics.realmComplete(realm: widget.realm.id, coins: sim.coins);
    }
    if (mounted) setState(() => _newBest = best);
  }

  // ── controls ──
  void _pause() {
    if (_phase != _Phase.playing) return;
    _game.pauseEngine();
    AppScope.read(context).audio.pauseMusic();
    setState(() => _phase = _Phase.paused);
  }

  void _resume() {
    _game.resumeEngine();
    AppScope.read(context).audio.resumeMusic();
    setState(() => _phase = _Phase.playing);
    _focus.requestFocus();
  }

  void _restart() {
    if (_phase == _Phase.paused) {
      AppScope.read(context).analytics
          .runEnd(realm: widget.realm.id, reason: 'restart', metres: _game.sim.metres, coins: _game.sim.coins);
    }
    setState(() {
      _attempt++;
      _game = _newGame();
      _phase = _Phase.playing;
      _newBest = false;
    });
    _focus.requestFocus();
  }

  Future<void> _quit() async {
    if (_phase == _Phase.paused) {
      final scope = AppScope.read(context);
      final sim = _game.sim;
      scope.analytics.runEnd(realm: widget.realm.id, reason: 'quit', metres: sim.metres, coins: sim.coins);
      await scope.progress.recordRun(metres: sim.metres, coins: sim.coins);
    }
    _back();
  }

  void _back() {
    AppScope.read(context).audio.stopMusic();
    if (mounted) Navigator.of(context).maybePop();
  }

  void _toggleMute() {
    final scope = AppScope.read(context);
    final muted = !scope.progress.muted;
    scope.progress.setMuted(muted);
    scope.audio.muted = muted;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.keyP) {
      _phase == _Phase.paused ? _resume() : _pause();
      return KeyEventResult.handled;
    }
    if (_phase != _Phase.playing) return KeyEventResult.ignored;
    final sim = _game.sim;
    if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
      sim.moveLeft();
    } else if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.keyD) {
      sim.moveRight();
    } else if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyW) {
      sim.jump();
    } else if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.keyS) {
      sim.slide();
    } else if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.shiftLeft) {
      sim.boost();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_swiped || _phase != _Phase.playing) return;
    _drag += d.delta;
    const threshold = 22.0;
    if (_drag.distance < threshold) return;
    _swiped = true;
    final sim = _game.sim;
    if (_drag.dx.abs() > _drag.dy.abs()) {
      _drag.dx < 0 ? sim.moveLeft() : sim.moveRight();
    } else {
      _drag.dy < 0 ? sim.jump() : sim.slide();
    }
  }

  void _onPanEnd() {
    _drag = Offset.zero;
    _swiped = false;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scope = AppScope.of(context);
    final target = widget.targetMetres ?? widget.realm.targetMetres;
    return PopScope(
      canPop: _phase != _Phase.playing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _pause();
      },
      child: Scaffold(
        backgroundColor: widget.realm.palette.skyBottom,
        body: Focus(
          focusNode: _focus,
          autofocus: true,
          onKeyEvent: _onKey,
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (_) => _onPanEnd(),
                onPanUpdate: _onPanUpdate,
                onPanEnd: (_) => _onPanEnd(),
                onPanCancel: _onPanEnd,
                child: GameWidget(key: ValueKey(_game), game: _game, autofocus: false),
              ),
              RunHudOverlay(hud: _game.hud, targetMetres: target, onPause: _pause, onBoost: () => _game.sim.boost()),
              if (_game.gentleStart && _phase == _Phase.playing) TutorialHints(hud: _game.hud, sim: _game.sim),
              _Toast(toast: _toast),
              if (_phase == _Phase.paused)
                PausePanel(
                  muted: scope.progress.muted,
                  onResume: _resume,
                  onRestart: _restart,
                  onQuit: _quit,
                  onToggleMute: _toggleMute,
                ),
              if (_phase == _Phase.gameOver)
                GameOverPanel(
                  score: _game.sim.metres,
                  coins: _game.sim.coins,
                  newBest: _newBest,
                  splash: _game.sim.fellInWater,
                  gapStyle: widget.realm.gapStyle,
                  onRetry: _restart,
                  onBack: _back,
                ),
              if (_phase == _Phase.complete)
                RealmCompletePanel(
                  title: l.realmCompleteTitle(widget.realm.name(l)),
                  coins: _game.sim.coins,
                  metres: _game.sim.metres,
                  onContinue: _back,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toast extends StatelessWidget {
  const _Toast({required this.toast});

  final ValueListenable<String?> toast;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String?>(
    valueListenable: toast,
    builder: (context, text, _) => text == null
        ? const SizedBox.shrink()
        : Align(
            alignment: const Alignment(0, -0.55),
            child: Semantics(
              liveRegion: true,
              child: Container(
                key: const Key('run.toast'),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xE62B1A4A), borderRadius: BorderRadius.circular(18)),
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
  );
}
