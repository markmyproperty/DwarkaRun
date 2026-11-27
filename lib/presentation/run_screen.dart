import 'dart:async';
import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../app_scope.dart';
import '../audio/game_audio.dart';
import '../data/player.dart';
import '../game/art_library.dart';
import '../game/dwarka_run_game.dart';
import '../game/realm.dart';
import '../game/run_simulation.dart';
import '../l10n/gen/app_localizations.dart';
import 'dr_theme.dart';
import 'run_hud.dart';
import 'run_panels.dart';
import 'ui/game_ui.dart';

/// `?autopilot=1` on the web build lets a bot play, for recording videos.
final bool _autopilot = kIsWeb && Uri.base.queryParameters['autopilot'] == '1';

enum _Phase { intro, playing, paused, revive, gameOver, complete }

/// One run of a realm: the stage intro and countdown, the game and its HUD,
/// and the pause, revive and results panels.
class RunScreen extends StatefulWidget {
  const RunScreen({super.key, required this.realm, this.seed, this.gentleStart, this.targetMetres, this.intro = true});

  final Realm realm;

  /// Fixed seed for a reproducible level. Random when null.
  final int? seed;

  /// Slow, sparse opening with swipe hints. Defaults to "first run ever".
  final bool? gentleStart;

  /// Overrides the realm's distance target (tests).
  final int? targetMetres;

  /// Whether the stage banner and countdown play first (tests can skip it).
  final bool intro;

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> with WidgetsBindingObserver {
  late DwarkaRunGame _game;
  late int _seed;
  late bool _gentle;
  _Phase _phase = _Phase.playing;
  int _attempt = 0;
  bool _started = false;

  /// Countdown overlay: null when hidden; true with the stage banner.
  bool? _countdown;
  int _countdownKey = 0;

  RunResult? _result;
  String? _cause;

  /// The run that is being shown on the results screen, so nothing records
  /// it twice.
  bool _recorded = false;

  /// The running simulation, for tests.
  @visibleForTesting
  RunSimulation get debugSim => _game.sim;

  final FocusNode _focus = FocusNode(debugLabel: 'run');
  final ValueNotifier<String?> _toast = ValueNotifier(null);
  final ValueNotifier<int> _nearMisses = ValueNotifier(0);
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
      if (widget.intro) _startCountdown(banner: true);
    }
  }

  DwarkaRunGame _newGame() {
    final scope = AppScope.read(context);
    final progress = scope.progress;
    final seed = _seed + _attempt;
    scope.analytics.runStart(realm: widget.realm.id, seed: seed);
    scope.audio.playMusic(widget.realm.id);
    _recorded = false;
    _result = null;
    return DwarkaRunGame(
      realm: widget.realm,
      seed: seed,
      gentleStart: _gentle && _attempt == 0,
      reduceMotion: reduceMotionOf(context),
      targetMetres: widget.targetMetres,
      onEvent: _onEvent,
      onCrashed: _onCrashed,
      onFinished: () => _finishRun(finished: true),
      autopilot: _autopilot,
      hold: widget.intro,
      boostSeconds: Upgrade.feather.seconds(progress.upgradeLevel(Upgrade.feather)),
      magnetSeconds: Upgrade.lotus.seconds(progress.upgradeLevel(Upgrade.lotus)),
    );
  }

  void _startCountdown({required bool banner}) {
    _game.hold = true;
    setState(() {
      _phase = _Phase.intro;
      _countdown = banner;
      _countdownKey++;
    });
  }

  void _go() {
    _game.hold = false;
    if (_phase == _Phase.intro) setState(() => _phase = _Phase.playing);
    _focus.requestFocus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _toastTimer?.cancel();
    _focus.dispose();
    _toast.dispose();
    _nearMisses.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && (_phase == _Phase.playing || _phase == _Phase.intro)) _pause();
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
      case RunEvent.nearMiss:
        _nearMisses.value++;
        HapticFeedback.selectionClick();
      case RunEvent.riverStart:
        _showToast(switch (widget.realm.gapStyle) {
          GapStyle.river => l.riverStart,
          GapStyle.crevasse => l.crevasseStart,
          GapStyle.moat => l.moatStart,
          GapStyle.trench => l.trenchStart,
        });
      case RunEvent.bridgeStart:
        _showToast(switch (widget.realm.gapStyle) {
          GapStyle.river => l.bridgeStart,
          GapStyle.crevasse => l.ropeBridgeStart,
          GapStyle.moat => l.fortressBridgeStart,
          GapStyle.trench => l.coralBridgeStart,
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

  /// After a crash: offer a revive if the player has the gems or the coins,
  /// else end.
  void _onCrashed() {
    if (!mounted || _phase == _Phase.gameOver || _phase == _Phase.complete) return;
    final progress = AppScope.read(context).progress;
    final cost = reviveCost(_game.sim.revives);
    if (!_autopilot && _game.sim.revives < maxRevives && (progress.gems >= cost || progress.wallet >= reviveCoinCost)) {
      AppScope.read(context).audio.pauseMusic();
      setState(() => _phase = _Phase.revive);
    } else {
      _finishRun(finished: false);
    }
  }

  Future<void> _revive({bool withCoins = false}) async {
    final scope = AppScope.read(context);
    final paid = withCoins
        ? await scope.progress.spend(reviveCoinCost)
        : await scope.progress.spendGems(reviveCost(_game.sim.revives));
    if (!paid) return;
    if (!mounted) return;
    _game.revive();
    scope.audio.resumeMusic();
    if (widget.intro) {
      _startCountdown(banner: false);
    } else {
      setState(() => _phase = _Phase.playing);
    }
  }

  Future<void> _finishRun({required bool finished}) async {
    if (!mounted || _recorded) return;
    _recorded = true;
    final scope = AppScope.read(context);
    final l = AppLocalizations.of(context);
    final sim = _game.sim;
    setState(() {
      _phase = finished ? _Phase.complete : _Phase.gameOver;
      _cause = finished
          ? null
          : sim.fellInWater
          ? switch (widget.realm.gapStyle) {
              GapStyle.river => l.gameOverSplash,
              GapStyle.crevasse => l.gameOverCrevasse,
              GapStyle.moat => l.gameOverMoat,
              GapStyle.trench => l.gameOverTrench,
            }
          : null;
    });
    if (!finished) {
      scope.audio.pauseMusic();
      scope.audio.play(Sfx.gameOver);
    }
    scope.analytics.runEnd(
      realm: widget.realm.id,
      reason: finished ? 'finish' : 'crash',
      metres: sim.metres,
      coins: sim.coins,
    );
    final stats = _stats(finished);
    final progress = scope.progress;
    final levelBefore = progress.level;
    final xp = Levels.xpFor(stats);
    final best = await progress.recordRun(metres: sim.metres, coins: sim.coins, gems: sim.gems, xp: xp);
    await progress.markTutorialDone();
    if (finished) {
      await progress.completeRealm(widget.realm);
      scope.analytics.realmComplete(realm: widget.realm.id, coins: sim.coins);
    }
    final missions = await progress.applyRunToMissions(stats);
    if (!mounted) return;
    if (missions.isNotEmpty) scope.audio.play(Sfx.mission);
    final levelAfter = progress.level;
    if (levelAfter > levelBefore) scope.audio.play(Sfx.unlock);
    setState(
      () => _result = RunResult(
        stats: stats,
        newBest: best,
        missions: missions,
        xp: xp,
        levelUpTo: levelAfter > levelBefore ? levelAfter : null,
      ),
    );
  }

  RunStats _stats(bool finished) {
    final sim = _game.sim;
    return (
      realm: widget.realm.id,
      metres: sim.metres,
      coins: sim.coins,
      gems: sim.gems,
      jumps: sim.jumps,
      slides: sim.slides,
      nearMisses: sim.nearMisses,
      boosts: sim.boostsUsed,
      finished: finished,
    );
  }

  // ── controls ──
  void _pause() {
    if (_phase != _Phase.playing && _phase != _Phase.intro) return;
    _game.pauseEngine();
    AppScope.read(context).audio.pauseMusic();
    setState(() {
      _phase = _Phase.paused;
      _countdown = null;
    });
  }

  void _resume() {
    _game.resumeEngine();
    AppScope.read(context).audio.resumeMusic();
    // A short countdown so the player has their thumbs ready.
    if (widget.intro) {
      _startCountdown(banner: false);
    } else {
      _game.hold = false;
      setState(() => _phase = _Phase.playing);
    }
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
      _nearMisses.value = 0;
    });
    if (widget.intro) _startCountdown(banner: false);
    _focus.requestFocus();
  }

  Future<void> _quit() async {
    if (_phase == _Phase.paused) {
      final scope = AppScope.read(context);
      final sim = _game.sim;
      scope.analytics.runEnd(realm: widget.realm.id, reason: 'quit', metres: sim.metres, coins: sim.coins);
      await scope.progress.recordRun(metres: sim.metres, coins: sim.coins, gems: sim.gems);
    }
    _back();
  }

  void _back() {
    AppScope.read(context).audio.stopMusic();
    if (mounted) Navigator.of(context).maybePop();
  }

  bool get _steerable => _phase == _Phase.playing;

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.keyP) {
      _phase == _Phase.paused ? _resume() : _pause();
      return KeyEventResult.handled;
    }
    if (!_steerable) return KeyEventResult.ignored;
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
    if (_swiped || !_steerable) return;
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
    final countdown = _countdown;
    return PopScope(
      canPop: _phase == _Phase.paused || _phase == _Phase.gameOver || _phase == _Phase.complete,
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
              RunHudOverlay(
                hud: _game.hud,
                targetMetres: target,
                worldName: widget.realm.name(l),
                onPause: _pause,
                onBoost: () {
                  if (_steerable) _game.sim.boost();
                },
              ),
              if (_game.gentleStart && _phase == _Phase.playing) TutorialHints(hud: _game.hud, sim: _game.sim),
              NearMissPop(count: _nearMisses),
              _Toast(toast: _toast),
              if (countdown != null)
                StageIntroOverlay(
                  key: ValueKey(_countdownKey),
                  realm: widget.realm,
                  banner: countdown,
                  onGo: _go,
                  onDone: () {
                    if (mounted) setState(() => _countdown = null);
                  },
                ),
              if (_phase == _Phase.paused) PausePanel(onResume: _resume, onRestart: _restart, onQuit: _quit),
              if (_phase == _Phase.revive)
                RevivePanel(
                  cost: reviveCost(_game.sim.revives),
                  gems: scope.progress.gems,
                  coins: scope.progress.wallet,
                  onRevive: _revive,
                  onReviveWithCoins: () => _revive(withCoins: true),
                  onDecline: () => _finishRun(finished: false),
                ),
              if (_phase == _Phase.gameOver || _phase == _Phase.complete)
                ResultsPanel(realm: widget.realm, result: _result, cause: _cause, onRetry: _restart, onHome: _back),
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
  Widget build(BuildContext context) => IgnorePointer(
    child: ValueListenableBuilder<String?>(
      valueListenable: toast,
      builder: (context, text, _) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, a) => ScaleTransition(
          scale: a,
          child: FadeTransition(opacity: a, child: child),
        ),
        child: text == null
            ? const SizedBox.shrink()
            : Align(
                key: ValueKey(text),
                alignment: const Alignment(0, -0.5),
                child: Semantics(
                  liveRegion: true,
                  child: Container(
                    key: const Key('run.toast'),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xE6331F8A), Color(0xE61F1452)]),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: GameColors.gold, width: 2),
                    ),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
      ),
    ),
  );
}
