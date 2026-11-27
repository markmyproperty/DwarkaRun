import 'dart:async';

import 'package:lottie/lottie.dart';
import 'package:material_ui/material_ui.dart';

import '../app_scope.dart';
import '../audio/game_audio.dart';
import '../l10n/gen/app_localizations.dart';
import 'dr_theme.dart';
import 'home_screen.dart';
import 'ui/game_ui.dart';
import 'ui/hero_runner.dart';

/// One shot of the story: a world, a slow camera move across it, and the
/// caption that goes with it.
class _Shot {
  const _Shot(this.art, this.caption, {this.from = const Alignment(-0.6, 0), this.to = const Alignment(0.6, 0)});

  final String art;
  final String Function(AppLocalizations l) caption;
  final Alignment from;
  final Alignment to;
}

final _shots = <_Shot>[
  _Shot('assets/images/backgrounds/ancient_city_background.webp', (l) => l.intro1),
  _Shot('assets/images/backgrounds/coastal_background.webp', (l) => l.intro2, from: Alignment(0.6, 0), to: Alignment(-0.4, 0)),
  _Shot('assets/images/pharaoh/backgrounds/pyramid_valley_background.webp', (l) => l.intro3),
  _Shot('assets/images/himalayan/backgrounds/valley_background.webp', (l) => l.intro3, from: Alignment(0.4, 0), to: Alignment(-0.4, 0)),
  _Shot('assets/images/lanka/backgrounds/palace_valley_background.webp', (l) => l.intro4),
  _Shot('assets/images/vijayanagar/backgrounds/temple_valley_background.webp', (l) => l.intro4, from: Alignment(0.5, 0), to: Alignment(-0.3, 0)),
  _Shot('assets/images/sunken/backgrounds/sunken_city_background.webp', (l) => l.intro5),
  _Shot('assets/images/finale/backgrounds/golden_city_background.webp', (l) => l.intro6, from: Alignment(0.3, 0), to: Alignment(-0.3, 0)),
];

/// The story introduction: a cinematic montage across the worlds with
/// captions, ending on the hero and the title. It plays by itself only on the
/// first launch; Settings can replay it.
class StoryIntroScreen extends StatefulWidget {
  const StoryIntroScreen({super.key, this.firstRun = false});

  /// On the first launch the intro goes on to the home screen; a replay just
  /// closes.
  final bool firstRun;

  static const shotTime = Duration(milliseconds: 3600);

  @override
  State<StoryIntroScreen> createState() => _StoryIntroScreenState();
}

class _StoryIntroScreenState extends State<StoryIntroScreen> {
  int _shot = 0;
  Timer? _timer;
  bool _done = false;

  bool get _last => _shot == _shots.length - 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppScope.read(context).audio.playMusic('ayodhya');
      _schedule();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final s in _shots) {
      precacheImage(AssetImage(s.art), context).catchError((_) {});
    }
    HeroRunner.precache(context);
  }

  void _schedule() {
    _timer?.cancel();
    if (_last) return;
    _timer = Timer(StoryIntroScreen.shotTime, () {
      if (!mounted) return;
      setState(() => _shot++);
      final audio = AppScope.read(context).audio;
      audio.play(_last ? Sfx.stageWhoosh : Sfx.whoosh, volume: 0.5);
      _schedule();
    });
  }

  Future<void> _finish() async {
    if (_done) return;
    _done = true;
    _timer?.cancel();
    final scope = AppScope.read(context);
    await scope.progress.markIntroSeen();
    if (!mounted) return;
    final nav = Navigator.of(context);
    if (widget.firstRun) {
      nav.pushReplacement(GameRoute<void>(builder: (_) => const HomeScreen(), settings: const RouteSettings(name: '/home')));
    } else {
      nav.pop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final shot = _shots[_shot];
    final caption = shot.caption(l);
    final reduce = reduceMotionOf(context);
    final pad = MediaQuery.paddingOf(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finish();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 900),
              child: _KenBurns(key: ValueKey(_shot), shot: shot, reduce: reduce, hold: _last),
            ),
            // Vignette and letterbox bars.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(radius: 1.1, colors: [Color(0x00000000), Color(0xAA000000)]),
              ),
            ),
            const Align(alignment: Alignment.topCenter, child: _Letterbox()),
            const Align(alignment: Alignment.bottomCenter, child: _Letterbox()),
            if (_last) ...[
              Align(
                alignment: const Alignment(0, -0.55),
                child: SizedBox(
                  width: 360,
                  height: 360,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Lottie.asset('assets/lottie/reward_burst.json', animate: !reduce),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.elasticOut,
                        builder: (context, v, child) => Transform.scale(scale: v, child: child),
                        child: Image.asset('assets/images/brand/logo.webp', width: 210, height: 210),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0, 0.42),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: -1, end: 0),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, child) =>
                      FractionalTranslation(translation: Offset(v * 2.5, 0), child: child),
                  child: const HeroRunner(height: 230),
                ),
              ),
            ],
            // Caption.
            Positioned(
              left: 24,
              right: 24,
              bottom: pad.bottom + (_last ? 150 : 96),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(a),
                    child: child,
                  ),
                ),
                child: Semantics(
                  key: ValueKey(caption),
                  liveRegion: true,
                  child: StrokeText(caption, size: 24, maxLines: 4, strokeWidth: 4),
                ),
              ),
            ),
            if (_last)
              Positioned(
                left: 32,
                right: 32,
                bottom: pad.bottom + 48,
                child: Center(
                  child: GameButton(
                    key: const Key('story.begin'),
                    label: l.beginOdyssey,
                    icon: Icons.play_arrow_rounded,
                    height: 64,
                    onPressed: _finish,
                  ),
                ),
              ),
            if (!_last)
              Positioned(
                top: pad.top + 14,
                right: 14,
                child: GameButton(
                  key: const Key('story.skip'),
                  label: l.skip,
                  icon: Icons.fast_forward_rounded,
                  tone: GameTone.purple,
                  height: 42,
                  onPressed: _finish,
                ),
              ),
            // Shot progress dots.
            Positioned(
              top: pad.top + 26,
              left: 18,
              child: Row(
                children: [
                  for (var i = 0; i < _shots.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 5),
                      width: i == _shot ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: i <= _shot ? GameColors.gold : const Color(0x55FFFFFF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Letterbox extends StatelessWidget {
  const _Letterbox();

  @override
  Widget build(BuildContext context) =>
      FractionallySizedBox(heightFactor: 0.07, widthFactor: 1, child: const ColoredBox(color: Colors.black));
}

/// A slow pan and push-in across one world's art.
class _KenBurns extends StatefulWidget {
  const _KenBurns({super.key, required this.shot, required this.reduce, required this.hold});

  final _Shot shot;
  final bool reduce;
  final bool hold;

  @override
  State<_KenBurns> createState() => _KenBurnsState();
}

class _KenBurnsState extends State<_KenBurns> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: StoryIntroScreen.shotTime + const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    if (!widget.reduce) _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (context, _) {
      final v = Curves.easeInOutSine.transform(_c.value);
      return Transform.scale(
        scale: 1.0 + 0.12 * v,
        child: Image.asset(
          widget.shot.art,
          fit: BoxFit.cover,
          alignment: Alignment.lerp(widget.shot.from, widget.shot.to, v)!,
          errorBuilder: (_, _, _) => const ColoredBox(color: GameColors.night),
        ),
      );
    },
  );
}
