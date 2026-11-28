import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:lottie/lottie.dart';
import 'package:material_ui/material_ui.dart';

import '../app_scope.dart';
import '../audio/game_audio.dart';
import '../data/player.dart';
import '../game/dwarka_run_game.dart';
import '../game/realm.dart';
import '../game/run_simulation.dart';
import '../l10n/gen/app_localizations.dart';
import 'dr_theme.dart';
import 'menu_sheets.dart';
import 'pickup_icons.dart';
import 'realm_postcard.dart';
import 'ui/game_ui.dart';

/// Dims the run behind a panel.
class _Scrim extends StatelessWidget {
  const _Scrim({required this.child, this.opacity = 0.72});

  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) => Material(
    color: Color.fromRGBO(8, 4, 24, opacity),
    child: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 28, 18, 18),
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: child),
        ),
      ),
    ),
  );
}

/// A panel with a ribbon title over its top edge.
class _TitledPanel extends StatelessWidget {
  const _TitledPanel({super.key, required this.title, required this.child, this.tone = GameTone.orange});

  final String title;
  final Widget child;
  final GameTone tone;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      GamePanel(padding: const EdgeInsets.fromLTRB(18, 44, 18, 20), child: child),
      Positioned(
        top: -22,
        left: 0,
        right: 0,
        child: Center(child: RibbonTitle(title, tone: tone)),
      ),
    ],
  );
}

// ── stage intro and countdown ──

/// Plays over a frozen run: the world's name card slides in, then 3, 2, 1,
/// GO. [onGo] fires on GO, when the run should start moving, and [onDone]
/// once the overlay has faded. With [banner] false (after a pause or a
/// revive) only the countdown plays.
class StageIntroOverlay extends StatefulWidget {
  const StageIntroOverlay({
    super.key,
    required this.realm,
    required this.onGo,
    required this.onDone,
    this.banner = true,
  });

  final Realm realm;
  final VoidCallback onGo;
  final VoidCallback onDone;
  final bool banner;

  static const bannerTime = Duration(milliseconds: 1300);
  static const beat = Duration(milliseconds: 520);

  @override
  State<StageIntroOverlay> createState() => _StageIntroOverlayState();
}

class _StageIntroOverlayState extends State<StageIntroOverlay> {
  final List<Timer> _timers = [];

  /// 3, 2, 1, 0 (GO), or null before the countdown.
  int? _count;
  bool _bannerOut = false;

  @override
  void initState() {
    super.initState();
    final start = widget.banner ? StageIntroOverlay.bannerTime : Duration.zero;
    final audio = AppScope.read(context).audio;
    if (widget.banner) {
      audio.play(Sfx.stageWhoosh, volume: 0.6);
      _at(start - const Duration(milliseconds: 250), () => setState(() => _bannerOut = true));
    }
    for (var i = 0; i < 3; i++) {
      _at(start + StageIntroOverlay.beat * i, () {
        audio.play(Sfx.tick);
        setState(() => _count = 3 - i);
      });
    }
    _at(start + StageIntroOverlay.beat * 3, () {
      audio.play(Sfx.go);
      setState(() => _count = 0);
      widget.onGo();
    });
    _at(start + StageIntroOverlay.beat * 3 + const Duration(milliseconds: 450), widget.onDone);
  }

  void _at(Duration d, VoidCallback f) => _timers.add(
    Timer(d, () {
      if (mounted) f();
    }),
  );

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final count = _count;
    return IgnorePointer(
      child: Stack(
        key: const Key('run.intro'),
        fit: StackFit.expand,
        children: [
          if (widget.banner)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: _bannerOut ? 0 : 1,
              child: Align(
                alignment: const Alignment(0, -0.25),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                  builder: (context, v, child) => Transform.translate(offset: Offset((1 - v) * -300, 0), child: child),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0x00120A2E), Color(0xE6120A2E), Color(0xE6120A2E), Color(0x00120A2E)],
                        stops: [0, 0.2, 0.8, 1],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${l.seasonJambudvipa} · ${l.stageNumber(widget.realm.index + 1)}',
                          style: const TextStyle(color: GameColors.gold, fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        StrokeText(widget.realm.name(l), size: 34),
                        Text(
                          widget.realm.blurb(l),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (count != null)
            Align(
              alignment: const Alignment(0, -0.1),
              child: TweenAnimationBuilder<double>(
                key: ValueKey(count),
                tween: Tween(begin: 1.8, end: 1),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                builder: (context, v, child) => Opacity(
                  opacity: (2 - v).clamp(0.0, 1.0),
                  child: Transform.scale(scale: v, child: child),
                ),
                child: StrokeText(
                  count == 0 ? l.countdownGo : '$count',
                  key: const Key('run.countdown'),
                  size: count == 0 ? 80 : 96,
                  color: count == 0 ? GameColors.gold : Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── pause ──

class PausePanel extends StatelessWidget {
  const PausePanel({super.key, required this.onResume, required this.onRestart, required this.onQuit});

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _Scrim(
      child: _TitledPanel(
        key: const Key('pause.menu'),
        title: l.pauseTitle,
        tone: GameTone.purple,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GameButton(
              key: const Key('pause.resume'),
              label: l.pauseResume,
              icon: Icons.play_arrow_rounded,
              tone: GameTone.green,
              height: 66,
              expand: true,
              onPressed: onResume,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GameButton(
                    key: const Key('pause.restart'),
                    label: l.pauseRestart,
                    icon: Icons.replay_rounded,
                    tone: GameTone.blue,
                    height: 54,
                    expand: true,
                    onPressed: onRestart,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GameButton(
                    key: const Key('pause.quit'),
                    label: l.homeLabel,
                    icon: Icons.home_rounded,
                    tone: GameTone.purple,
                    height: 54,
                    expand: true,
                    onPressed: onQuit,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const SoundSettings(muteKey: Key('pause.mute')),
          ],
        ),
      ),
    );
  }
}

// ── revive ──

/// After a crash: spend gems to carry on. A ring runs down; when it empties
/// or the player says no, the results show.
class RevivePanel extends StatefulWidget {
  const RevivePanel({
    super.key,
    required this.cost,
    required this.gems,
    required this.coins,
    required this.onRevive,
    required this.onReviveWithCoins,
    required this.onDecline,
  });

  final int cost;
  final int gems;
  final int coins;
  final VoidCallback onRevive;
  final VoidCallback onReviveWithCoins;
  final VoidCallback onDecline;

  static const time = Duration(seconds: 5);

  @override
  State<RevivePanel> createState() => _RevivePanelState();
}

class _RevivePanelState extends State<RevivePanel> with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(vsync: this, duration: RevivePanel.time)
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDecline();
    })
    ..forward();

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _Scrim(
      opacity: 0.6,
      child: _TitledPanel(
        key: const Key('revive.panel'),
        title: l.revive,
        tone: GameTone.blue,
        child: Column(
          children: [
            SizedBox(
              width: 130,
              height: 130,
              child: AnimatedBuilder(
                animation: _t,
                builder: (context, _) => Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: 1 - _t.value,
                        strokeWidth: 10,
                        color: GameColors.gold,
                        backgroundColor: const Color(0x33FFFFFF),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.cost <= widget.gems) ...[
                          const GemIcon(size: 48),
                          StrokeText('${widget.cost}', size: 30, color: const Color(0xFF8BF0FF)),
                        ] else ...[
                          const CoinIcon(size: 48),
                          StrokeText('$reviveCoinCost', size: 30, color: GameColors.gold),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (widget.cost <= widget.gems) ...[
              GameButton(
                key: const Key('revive.yes'),
                label: l.reviveFor(widget.cost),
                leading: const GemIcon(size: 26),
                tone: GameTone.green,
                height: 62,
                onPressed: widget.onRevive,
              ),
              const SizedBox(height: 10),
            ],
            GameButton(
              key: const Key('revive.coins'),
              label: l.reviveForCoins(reviveCoinCost),
              leading: const CoinIcon(size: 26),
              tone: GameTone.orange,
              height: 56,
              onPressed: reviveCoinCost <= widget.coins ? widget.onReviveWithCoins : null,
            ),
            const SizedBox(height: 8),
            TextButton(
              key: const Key('revive.no'),
              onPressed: widget.onDecline,
              child: Text(
                MaterialLocalizations.of(context).cancelButtonLabel,
                style: const TextStyle(color: GameColors.textDim, fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── results ──

/// What the results screen shows.
class RunResult {
  const RunResult({
    required this.stats,
    required this.newBest,
    required this.missions,
    required this.xp,
    required this.levelUpTo,
  });

  final RunStats stats;
  final bool newBest;
  final List<MissionDef> missions;
  final int xp;

  /// The new level, if this run raised it.
  final int? levelUpTo;

  int get score => scoreOf(stats);
}

/// Game over and world cleared: the score counts up, the run's numbers,
/// a new-best badge, missions finished on this run, XP and any level-up,
/// with Retry and Home (or Continue after a cleared world).
class ResultsPanel extends StatelessWidget {
  const ResultsPanel({
    super.key,
    required this.realm,
    required this.result,
    required this.cause,
    required this.onRetry,
    required this.onHome,
  });

  final Realm realm;

  /// Null while the run is still being saved.
  final RunResult? result;

  /// Why the run ended, for a game over (e.g. "Splash! Into the river").
  final String? cause;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  bool get _finished => result?.stats.finished ?? false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final r = result;
    final reduce = reduceMotionOf(context);
    final celebrate = r != null && (r.stats.finished || r.newBest);
    return Stack(
      fit: StackFit.expand,
      children: [
        _Scrim(
          child: _TitledPanel(
            key: Key(_finished ? 'complete.panel' : 'gameover.panel'),
            title: _finished ? l.victoryTitle : l.gameOverTitle,
            tone: _finished ? GameTone.green : GameTone.red,
            child: Column(
              children: [
                if (_finished)
                  Container(
                    height: 110,
                    margin: const EdgeInsets.only(bottom: 10),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: GameColors.gold, width: 3),
                    ),
                    child: RealmPostcard(realm: realm),
                  ),
                if (_finished)
                  Text(
                    l.realmCompleteTitle(realm.name(l)),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                  )
                else if (cause != null)
                  Text(
                    cause!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: GameColors.textDim, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                const SizedBox(height: 6),
                Text(
                  l.scoreLabel.toUpperCase(),
                  style: const TextStyle(color: GameColors.gold, fontWeight: FontWeight.w800, letterSpacing: 2),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: (r?.score ?? 0).toDouble()),
                  duration: Duration(milliseconds: reduce ? 0 : 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => StrokeText('${v.round()}', key: const Key('gameover.score'), size: 50),
                ),
                if (r != null && r.newBest)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.elasticOut,
                    builder: (context, v, child) => Transform.scale(scale: v, child: child),
                    child: Container(
                      key: const Key('gameover.newBest'),
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: GameTone.pink.face),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: StrokeText(l.newBest, size: 18, maxLines: 1, strokeWidth: 3),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatTile(
                      icon: const Icon(Icons.directions_run_rounded, color: GameColors.gold, size: 26),
                      label: l.distanceLabel,
                      value: l.metresValue(r?.stats.metres ?? 0),
                    ),
                    const SizedBox(width: 8),
                    _StatTile(
                      key: const Key('gameover.coins'),
                      icon: const CoinIcon(size: 26),
                      label: l.coinsCollected,
                      value: '${r?.stats.coins ?? 0}',
                    ),
                    const SizedBox(width: 8),
                    _StatTile(icon: const GemIcon(size: 26), label: l.gemsLabel, value: '${r?.stats.gems ?? 0}'),
                  ],
                ),
                if (r != null && r.missions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l.missionsDone,
                      style: const TextStyle(color: GameColors.green, fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
                  for (final m in r.missions)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: MissionRow(def: m, progress: m.goal, compact: true),
                    ),
                ],
                if (r != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StrokeText(l.xpEarned(r.xp), size: 20, color: const Color(0xFF8BF0FF), maxLines: 1),
                      if (r.levelUpTo != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          key: const Key('gameover.levelUp'),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: GameTone.blue.face),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!reduce)
                                SizedBox(width: 30, height: 30, child: Lottie.asset('assets/lottie/level_up.json')),
                              StrokeText(
                                '${l.levelUp} ${l.levelShort(r.levelUpTo!)}',
                                size: 16,
                                maxLines: 1,
                                strokeWidth: 3,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GameButton(
                        key: Key(_finished ? 'complete.home' : 'gameover.home'),
                        label: l.homeLabel,
                        icon: Icons.home_rounded,
                        tone: GameTone.purple,
                        height: 58,
                        expand: true,
                        onPressed: onHome,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: _finished
                          ? GameButton(
                              key: const Key('complete.continue'),
                              label: l.nextWorld,
                              icon: Icons.arrow_forward_rounded,
                              tone: GameTone.orange,
                              height: 58,
                              expand: true,
                              onPressed: onHome,
                            )
                          : GameButton(
                              key: const Key('gameover.retry'),
                              label: l.retry,
                              icon: Icons.replay_rounded,
                              tone: GameTone.orange,
                              height: 58,
                              expand: true,
                              onPressed: onRetry,
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (celebrate && !reduce)
          IgnorePointer(child: Lottie.asset('assets/lottie/confetti.json', repeat: false, fit: BoxFit.cover)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({super.key, required this.icon, required this.label, required this.value});

  final Widget icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0x33000000),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x33FFFFFF), width: 1.5),
        ),
        child: Column(
          children: [
            icon,
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: GameColors.textDim, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── in-run pops ──

/// "Close call!" popping up near the hero after a near miss.
class NearMissPop extends StatelessWidget {
  const NearMissPop({super.key, required this.count});

  final ValueListenable<int> count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return IgnorePointer(
      child: ValueListenableBuilder<int>(
        valueListenable: count,
        builder: (context, n, _) => n == 0
            ? const SizedBox.shrink()
            : Align(
                alignment: const Alignment(0, 0.2),
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(n),
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 900),
                  builder: (context, v, child) => Opacity(
                    opacity: v < 0.7 ? 1 : (1 - (v - 0.7) / 0.3),
                    child: Transform.translate(
                      offset: Offset(0, -40 * v),
                      child: Transform.scale(
                        scale: 0.6 + 0.5 * Curves.elasticOut.transform(math.min(1, v * 2)),
                        child: child,
                      ),
                    ),
                  ),
                  child: Column(
                    key: const Key('run.nearMiss'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StrokeText(l.nearMiss, size: 28, color: const Color(0xFF8BF0FF)),
                      const StrokeText('+25', size: 20, color: GameColors.gold),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

/// Swipe hints for the gentle first-run opening, timed to the tutorial rows.
class TutorialHints extends StatelessWidget {
  const TutorialHints({super.key, required this.hud, required this.sim});

  final ValueListenable<RunHud> hud;
  final RunSimulation sim;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return IgnorePointer(
      child: ValueListenableBuilder<RunHud>(
        valueListenable: hud,
        builder: (context, h, _) {
          final m = h.metres;
          final (String? text, IconData icon) = m < 50
              ? (l.hintLanes, Icons.swap_horiz_rounded)
              : m < 92
              ? (l.hintJump, Icons.keyboard_double_arrow_up_rounded)
              : m < 133
              ? (l.hintSlide, Icons.keyboard_double_arrow_down_rounded)
              : (null, Icons.circle);
          if (text == null) return const SizedBox.shrink();
          return Align(
            alignment: const Alignment(0, 0.15),
            child: Container(
              key: const Key('run.hint'),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xE6120A2E),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: GameColors.gold, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: GameColors.gold, size: 34),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      text,
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
