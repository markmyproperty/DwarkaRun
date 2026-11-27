import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../app_scope.dart';
import '../game/art_library.dart';
import '../game/realm.dart';
import '../game/season.dart';
import '../l10n/gen/app_localizations.dart';
import 'dr_theme.dart';
import 'menu_sheets.dart';
import 'pickup_icons.dart';
import 'realm_postcard.dart';
import 'run_screen.dart';
import 'ui/game_title.dart';
import 'ui/game_ui.dart';
import 'ui/world_ambience.dart';
import 'ui/hero_runner.dart';
import 'unlock_overlay.dart';
import 'worlds_screen.dart';

/// The home screen: the selected world fills the screen behind the hero,
/// with the title, balances and level on top, the world picker and a big
/// PLAY button below, and missions, daily reward, shop, heroes and settings
/// one tap away.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _autoDailyShown = false;
  bool _overlayOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final scope = AppScope.read(context);
      scope.analytics.gameOpen();
      scope.audio.playMusic(scope.progress.selectedRealm.id);
      _afterReturn();
    });
  }

  /// Things to show when the player lands on the home screen: a newly
  /// reached world first, then the day's reward for returning players.
  Future<void> _afterReturn() async {
    if (!mounted || _overlayOpen) return;
    final progress = AppScope.read(context).progress;
    final unlocked = progress.pendingUnlock;
    if (unlocked != null) {
      _overlayOpen = true;
      await showUnlockOverlay(context, unlocked);
      _overlayOpen = false;
      if (mounted) AppScope.read(context).audio.playMusic(progress.selectedRealm.id);
      return;
    }
    if (!_autoDailyShown && progress.runs > 0 && progress.canClaimDaily(DateTime.now())) {
      _autoDailyShown = true;
      _overlayOpen = true;
      await showDailySheet(context);
      _overlayOpen = false;
    }
  }

  Future<void> _play(Realm realm) async {
    final scope = AppScope.read(context);
    await Navigator.of(context).push(
      GameRoute<void>(
        builder: (_) => RunScreen(realm: realm),
        settings: const RouteSettings(name: '/run'),
      ),
    );
    if (!mounted) return;
    scope.audio.playMusic(scope.progress.selectedRealm.id);
    _afterReturn();
  }

  void _select(Realm r) {
    final scope = AppScope.read(context);
    scope.progress.selectRealm(r);
    scope.audio.playMusic(r.id);
  }

  Future<void> _openWorlds() async {
    final picked = await Navigator.of(context).push<Realm>(
      GameRoute<Realm>(
        builder: (_) => const WorldsScreen(),
        settings: const RouteSettings(name: '/worlds'),
      ),
    );
    if (!mounted) return;
    if (picked != null) {
      _select(picked);
      _play(picked);
    } else {
      AppScope.read(context).audio.playMusic(AppScope.read(context).progress.selectedRealm.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scope = AppScope.of(context);
    final progress = scope.progress;
    final realm = progress.selectedRealm;
    final unlocked = [
      for (final r in Realm.values)
        if (progress.isUnlocked(r)) r,
    ];
    final i = unlocked.indexOf(realm);
    final reduce = reduceMotionOf(context);
    // Get the selected world's art pack ready while the player is here.
    ArtLibrary.instance.loadStage(realm);
    final now = DateTime.now();
    final mq = MediaQuery.sizeOf(context);
    final compact = mq.height < 700;

    return Scaffold(
      backgroundColor: GameColors.night,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _WorldBackdrop(realm: realm, reduce: reduce),
          FallingAmbience(key: ValueKey('ambience.${realm.id}'), realm: realm, reduce: reduce),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xCC120A2E), Color(0x00120A2E), Color(0x00120A2E), Color(0xEE120A2E)],
                stops: [0, 0.28, 0.55, 0.86],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                  child: Column(
                    children: [
                      // ── top bar ──
                      Row(
                        children: [
                          _LevelBadge(level: progress.level, progress: progress.levelProgress),
                          const Spacer(),
                          CurrencyChip(
                            key: const Key('hub.wallet'),
                            icon: const CoinIcon(size: 34),
                            value: progress.wallet,
                            width: 112,
                            onAdd: () => showShopSheet(context),
                          ),
                          const SizedBox(width: 12),
                          CurrencyChip(
                            key: const Key('hub.gems'),
                            icon: const GemIcon(size: 34),
                            value: progress.gems,
                            width: 82,
                          ),
                          const SizedBox(width: 8),
                          RoundGameButton(
                            key: const Key('hub.settings'),
                            icon: Icons.settings_rounded,
                            label: l.settingsTitle,
                            size: 42,
                            onPressed: () => showSettingsSheet(context),
                          ),
                        ],
                      ),
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          WorldGarland(key: ValueKey('garland.${realm.id}'), realm: realm, height: compact ? 30 : 40),
                          Padding(
                            padding: EdgeInsets.only(top: compact ? 6 : 14),
                            child: _FloatingLogo(width: compact ? 230 : 290, reduce: reduce),
                          ),
                        ],
                      ),
                      // ── hero and side buttons ──
                      Expanded(
                        child: Stack(
                          children: [
                            Align(
                              alignment: const Alignment(0, 0.95),
                              child: _HeroStage(height: compact ? 180 : 240, reduce: reduce, outfit: realm),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RoundGameButton(
                                    key: const Key('hub.daily'),
                                    icon: Icons.card_giftcard_rounded,
                                    label: l.dailyTitle,
                                    caption: l.dailyTitle.split(' ').first,
                                    tone: GameTone.pink,
                                    dot: progress.canClaimDaily(now),
                                    onPressed: () => showDailySheet(context),
                                  ),
                                  const SizedBox(height: 14),
                                  RoundGameButton(
                                    key: const Key('hub.missions'),
                                    icon: Icons.flag_rounded,
                                    label: l.missionsTitle,
                                    caption: l.missionsTitle,
                                    tone: GameTone.green,
                                    badge: progress.missionsToClaim,
                                    onPressed: () => showMissionsSheet(context),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RoundGameButton(
                                    key: const Key('hub.shop'),
                                    icon: Icons.storefront_rounded,
                                    label: l.shopTitle,
                                    caption: l.shopTitle,
                                    tone: GameTone.gold,
                                    onPressed: () => showShopSheet(context),
                                  ),
                                  const SizedBox(height: 14),
                                  RoundGameButton(
                                    key: const Key('hub.hero'),
                                    icon: Icons.person_rounded,
                                    label: l.heroTitle,
                                    caption: l.heroTitle,
                                    tone: GameTone.blue,
                                    onPressed: () => showHeroSheet(context),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ── world picker ──
                      _WorldPicker(
                        realm: realm,
                        onPrev: i > 0 ? () => _select(unlocked[i - 1]) : null,
                        onNext: i >= 0 && i < unlocked.length - 1 ? () => _select(unlocked[i + 1]) : null,
                        onOpen: _openWorlds,
                      ),
                      const SizedBox(height: 12),
                      _PlayButton(reduce: reduce, label: l.play, onPressed: () => _play(realm)),
                      const SizedBox(height: 10),
                      _SeasonStrip(done: progress.realmsDone.length),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The selected world's art, drifting slowly from side to side.
class _WorldBackdrop extends StatefulWidget {
  const _WorldBackdrop({required this.realm, required this.reduce});

  final Realm realm;
  final bool reduce;

  @override
  State<_WorldBackdrop> createState() => _WorldBackdropState();
}

class _WorldBackdropState extends State<_WorldBackdrop> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 40));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.reduce) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _WorldBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reduce) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 700),
    child: AnimatedBuilder(
      key: ValueKey(widget.realm),
      animation: _c,
      builder: (context, child) => FractionalTranslation(
        translation: Offset((Curves.easeInOutSine.transform(_c.value) - 0.5) * 0.12, 0),
        child: Transform.scale(scale: 1.15, child: child),
      ),
      child: RealmPostcard(realm: widget.realm, alignmentY: 0.1),
    ),
  );
}

/// The title wordmark, bobbing gently.
class _FloatingLogo extends StatefulWidget {
  const _FloatingLogo({required this.width, required this.reduce});

  final double width;
  final bool reduce;

  @override
  State<_FloatingLogo> createState() => _FloatingLogoState();
}

class _FloatingLogoState extends State<_FloatingLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 3));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.reduce) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (context, child) =>
        Transform.translate(offset: Offset(0, -3 + 6 * Curves.easeInOutSine.transform(_c.value)), child: child),
    child: GameTitle(key: const Key('hub.logo'), width: widget.width, reduce: widget.reduce),
  );
}

/// The hero on a carved stone dais, with slowly turning rays of sunlight
/// behind him and drifting golden motes.
class _HeroStage extends StatefulWidget {
  const _HeroStage({required this.height, required this.reduce, required this.outfit});

  final double height;
  final bool reduce;
  final Realm outfit;

  @override
  State<_HeroStage> createState() => _HeroStageState();
}

class _HeroStageState extends State<_HeroStage> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 24));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.reduce) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height;
    return SizedBox(
      key: const Key('hub.heroStage'),
      height: height * 1.15,
      width: height * 1.4,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) => CustomPaint(painter: _RaysPainter(_c.value)),
            ),
          ),
          Positioned(
            bottom: 0,
            child: CustomPaint(size: Size(height * 0.95, height * 0.2), painter: _DaisPainter()),
          ),
          Positioned(
            bottom: height * 0.1,
            child: HeroRunner(height: height, fps: 12, outfit: widget.outfit, front: true),
          ),
        ],
      ),
    );
  }
}

class _RaysPainter extends CustomPainter {
  _RaysPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.5);
    final r = size.width * 0.62;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x88FFF0B0), Color(0x33FFB23A), Color(0x00FFB23A)],
          stops: [0, 0.45, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(t * 2 * math.pi);
    const n = 14;
    final ray = Paint()
      ..shader = const RadialGradient(colors: [Color(0x55FFF6D0), Color(0x00FFF6D0)])
          .createShader(Rect.fromCircle(center: Offset.zero, radius: r));
    for (var i = 0; i < n; i++) {
      final a = i * 2 * math.pi / n;
      final p = Path()
        ..moveTo(0, 0)
        ..lineTo(math.cos(a - 0.08) * r, math.sin(a - 0.08) * r)
        ..lineTo(math.cos(a + 0.08) * r, math.sin(a + 0.08) * r)
        ..close();
      canvas.drawPath(p, ray);
    }
    canvas.restore();
    // Motes rising around the hero.
    final mote = Paint();
    for (var i = 0; i < 18; i++) {
      final seed = i * 97.31;
      final x = (math.sin(seed) * 0.5 + 0.5) * size.width;
      final speed = 0.6 + (i % 5) * 0.15;
      final y = size.height * (1 - ((t * 6 * speed + i / 18) % 1));
      final fade = math.sin(((t * 6 * speed + i / 18) % 1) * math.pi);
      mote.color = Color.fromRGBO(255, 226, 140, 0.8 * fade);
      canvas.drawCircle(Offset(x + math.sin(t * 20 + i) * 6, y), 1.5 + (i % 3), mote);
    }
  }

  @override
  bool shouldRepaint(covariant _RaysPainter old) => old.t != t;
}

/// A round sandstone dais with a gold rim.
class _DaisPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final top = Rect.fromLTWH(0, 0, w, h * 0.62);
    final side = Rect.fromLTWH(0, h * 0.31, w, h * 0.62);
    canvas.drawOval(
      side.shift(Offset(0, h * 0.12)),
      Paint()
        ..color = const Color(0x88000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawOval(
      side,
      Paint()
        ..shader = const LinearGradient(colors: [Color(0xFF6B3A1A), Color(0xFFB0703A), Color(0xFF6B3A1A)])
            .createShader(side),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.31, w, h * 0.31),
      Paint()
        ..shader = const LinearGradient(colors: [Color(0xFF6B3A1A), Color(0xFFB0703A), Color(0xFF6B3A1A)])
            .createShader(side),
    );
    canvas.drawOval(
      top,
      Paint()
        ..shader = const RadialGradient(colors: [Color(0xFFFFE7B0), Color(0xFFE2B070), Color(0xFFB57C40)])
            .createShader(top),
    );
    canvas.drawOval(
      top.deflate(1.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFFFFC94A),
    );
    canvas.drawOval(
      top.deflate(w * 0.12),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0x88A8662A),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level, required this.progress});

  final int level;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      label: l.levelLabel(level),
      excludeSemantics: true,
      child: SizedBox(
        key: const Key('hub.level'),
        width: 104,
        height: 48,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Positioned(
              left: 30,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 4, 8, 5),
                decoration: BoxDecoration(
                  color: const Color(0xB3120A2E),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0x40FFFFFF), width: 1.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.levelShort(level),
                      style: const TextStyle(
                        fontFamily: kBodyFont,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    GameProgressBar(value: progress, height: 7, colors: const [Color(0xFF8BF0FF), Color(0xFF3FB4FF)]),
                  ],
                ),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF7FDBFF), Color(0xFF1E6FD8)],
                ),
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: StrokeText('$level', size: 20, stroke: const Color(0xFF0B3C70)),
            ),
          ],
        ),
      ),
    );
  }
}

/// The selected world's name between two arrows; tapping it opens the
/// world map.
class _WorldPicker extends StatelessWidget {
  const _WorldPicker({required this.realm, required this.onPrev, required this.onNext, required this.onOpen});

  final Realm realm;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final loc = MaterialLocalizations.of(context);
    return Row(
      children: [
        Opacity(
          opacity: onPrev == null ? 0.35 : 1,
          child: RoundGameButton(
            key: const Key('hub.world.prev'),
            icon: Icons.chevron_left_rounded,
            label: loc.previousPageTooltip,
            size: 44,
            tone: GameTone.purple,
            onPressed: onPrev,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Semantics(
            button: true,
            label: '${l.worldsTitle}: ${realm.name(l)}',
            excludeSemantics: true,
            child: GestureDetector(
              key: const Key('hub.worlds'),
              onTap: () {
                tapFeedback(context);
                onOpen();
              },
              child: Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xCC1F1452),
                  border: Border.all(color: const Color(0x80FFD34A), width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.public_rounded, color: GameColors.gold, size: 26),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l.stageNumber(realm.index + 1)} · ${l.worldsTitle}',
                            style: const TextStyle(
                              color: GameColors.gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: StrokeText(
                              realm.name(l),
                              key: const Key('hub.world.name'),
                              size: 21,
                              maxLines: 1,
                              strokeWidth: 3.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.map_rounded, color: Colors.white70, size: 22),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Opacity(
          opacity: onNext == null ? 0.35 : 1,
          child: RoundGameButton(
            key: const Key('hub.world.next'),
            icon: Icons.chevron_right_rounded,
            label: loc.nextPageTooltip,
            size: 44,
            tone: GameTone.purple,
            onPressed: onNext,
          ),
        ),
      ],
    );
  }
}

/// The big PLAY button, breathing gently with a light sweep, unless the
/// player asked for less motion.
class _PlayButton extends StatefulWidget {
  const _PlayButton({required this.reduce, required this.label, required this.onPressed});

  final bool reduce;
  final String label;
  final VoidCallback onPressed;

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.reduce) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: 270,
      child: GameButton(
        key: const Key('hub.play'),
        label: widget.label,
        icon: Icons.play_arrow_rounded,
        height: 76,
        fontSize: 34,
        expand: true,
        onPressed: widget.onPressed,
      ),
    );
    if (widget.reduce) return button;
    return AnimatedBuilder(
      key: const Key('hub.play.pulse'),
      animation: _c,
      builder: (context, child) {
        final v = _c.value;
        final pulse = 1 + 0.035 * math.sin(v * math.pi * 2);
        return Stack(
          alignment: Alignment.center,
          children: [
            // Glow.
            Container(
              width: 300,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(255, 170, 30, 0.35 + 0.25 * math.sin(v * math.pi * 2).abs()),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            Transform.scale(scale: pulse, child: child),
          ],
        );
      },
      child: button,
    );
  }
}

class _SeasonStrip extends StatelessWidget {
  const _SeasonStrip({required this.done});

  final int done;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final season = Season.jambudvipa;
    final total = season.realms.length;
    return Semantics(
      key: const Key('hub.season'),
      label: '${l.seasonLabel(season.number)} · ${l.seasonJambudvipa}: $done / $total',
      excludeSemantics: true,
      child: Row(
        children: [
          Text(
            '${l.seasonLabel(season.number)} · ${l.seasonJambudvipa}',
            style: const TextStyle(color: GameColors.textDim, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 10),
          Expanded(child: GameProgressBar(value: done / total, height: 10)),
          const SizedBox(width: 10),
          Text(
            '$done/$total',
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
