import 'dart:math' as math;

import 'package:lottie/lottie.dart';
import 'package:material_ui/material_ui.dart';

import '../app_scope.dart';
import '../audio/game_audio.dart';
import 'dr_theme.dart';
import 'home_screen.dart';
import 'story_intro_screen.dart';
import 'ui/game_ui.dart';

/// The opening: the MMYP Technologies logo on its own branded card, then a
/// cut into the game world as the Odyssey of the Ages title lands. About
/// four seconds; a tap skips ahead. The first launch goes on to the story
/// introduction, later launches straight to the home screen.
class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  static const total = Duration(milliseconds: 4600);

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(vsync: this, duration: LaunchScreen.total);
  bool _left = false;
  bool _titleSound = false;

  // Phases, as fractions of [LaunchScreen.total].
  static const _brandIn = (0.02, 0.22);
  static const _sweep = (0.24, 0.42);
  static const _brandOut = (0.5, 0.6);
  static const _titleIn = (0.6, 0.74);

  @override
  void initState() {
    super.initState();
    _t.addListener(_onTick);
    _t.addStatusListener((s) {
      if (s == AnimationStatus.completed) _leave();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppScope.read(context).audio.play(Sfx.logoSting);
      _t.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/brand/mmyp_logo.webp'), context);
    precacheImage(const AssetImage('assets/images/brand/logo.webp'), context);
    precacheImage(const AssetImage('assets/images/backgrounds/ancient_city_background.webp'), context);
  }

  void _onTick() {
    if (!_titleSound && _t.value >= _titleIn.$1) {
      _titleSound = true;
      AppScope.read(context).audio.play(Sfx.stageWhoosh, volume: 0.8);
    }
  }

  /// A tap jumps from the company card to the title, and from the title on.
  void _skip() {
    if (_t.value < _brandOut.$1) {
      _t.value = _brandOut.$2;
      _t.forward();
    } else {
      _leave();
    }
  }

  void _leave() {
    if (_left || !mounted) return;
    _left = true;
    final progress = AppScope.read(context).progress;
    Navigator.of(context).pushReplacement(
      GameRoute<void>(
        builder: (_) => progress.introSeen ? const HomeScreen() : const StoryIntroScreen(firstRun: true),
        settings: RouteSettings(name: progress.introSeen ? '/home' : '/story'),
      ),
    );
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  static double _seg(double t, (double, double) span, [Curve curve = Curves.easeOut]) =>
      curve.transform(((t - span.$1) / (span.$2 - span.$1)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final reduce = reduceMotionOf(context);
    return Scaffold(
      backgroundColor: GameColors.night,
      body: GestureDetector(
        key: const Key('launch.skip'),
        behavior: HitTestBehavior.opaque,
        onTap: _skip,
        child: AnimatedBuilder(
          animation: _t,
          builder: (context, _) {
            final t = _t.value;
            final brandIn = _seg(t, _brandIn, Curves.easeOutBack);
            final brandOut = _seg(t, _brandOut, Curves.easeInCubic);
            final titleIn = _seg(t, _titleIn, Curves.elasticOut);
            final worldIn = _seg(t, (_brandOut.$1, _titleIn.$2));
            return Stack(
              fit: StackFit.expand,
              children: [
                // ── the game world and title ──
                if (worldIn > 0) ...[
                  Opacity(
                    opacity: worldIn,
                    child: Transform.scale(
                      scale: 1.18 - 0.12 * _seg(t, (_brandOut.$1, 1.0)),
                      child: Image.asset(
                        'assets/images/backgrounds/ancient_city_background.webp',
                        fit: BoxFit.cover,
                        alignment: Alignment(-0.2 + 0.4 * _seg(t, (_brandOut.$1, 1.0)), 0),
                        errorBuilder: (_, _, _) => const SizedBox(),
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: worldIn,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          radius: 1.0,
                          colors: [Color(0x33120A2E), Color(0xDD120A2E)],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Opacity(
                      opacity: _seg(t, _titleIn),
                      child: SizedBox(
                        width: 420,
                        height: 420,
                        child: Lottie.asset('assets/lottie/reward_burst.json', animate: !reduce, repeat: true),
                      ),
                    ),
                  ),
                  Center(
                    child: Transform.scale(
                      scale: 0.3 + 0.7 * titleIn,
                      child: Opacity(
                        opacity: _seg(t, _titleIn).clamp(0.0, 1.0),
                        child: Image.asset(
                          'assets/images/brand/logo.webp',
                          key: const Key('launch.title'),
                          width: 250,
                          height: 250,
                          errorBuilder: (_, _, _) => const SizedBox(width: 250, height: 250),
                        ),
                      ),
                    ),
                  ),
                ],
                // ── MMYP Technologies card ──
                if (brandOut < 1)
                  Opacity(
                    opacity: 1 - brandOut,
                    child: _BrandCard(t: t, logoIn: brandIn, sweep: _seg(t, _sweep, Curves.easeInOut), reduce: reduce),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The company logo on a clean, softly lit card with drifting violet motes
/// and a light sweep across the mark.
class _BrandCard extends StatelessWidget {
  const _BrandCard({required this.t, required this.logoIn, required this.sweep, required this.reduce});

  final double t;
  final double logoIn;
  final double sweep;
  final bool reduce;

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      'assets/images/brand/mmyp_logo.webp',
      key: const Key('launch.mmyp'),
      width: 260,
      height: 260,
      semanticLabel: 'MMYP Technologies',
      errorBuilder: (_, _, _) => const SizedBox(width: 260, height: 260),
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 0.9,
              colors: [Color(0xFFFFFFFF), Color(0xFFF6F3FD), Color(0xFFDCD3F5)],
              stops: [0, 0.45, 1],
            ),
          ),
        ),
        if (!reduce) CustomPaint(painter: _MotePainter(t)),
        Center(
          child: Opacity(
            opacity: logoIn.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 0.82 + 0.18 * logoIn,
              child: ShaderMask(
                blendMode: BlendMode.srcATop,
                shaderCallback: (rect) => LinearGradient(
                  begin: Alignment(-1.0 + sweep * 3.2 - 0.6, -0.4),
                  end: Alignment(-1.0 + sweep * 3.2 + 0.6, 0.4),
                  colors: const [Color(0x00FFFFFF), Color(0x99FFFFFF), Color(0x00FFFFFF)],
                  stops: const [0.3, 0.5, 0.7],
                ).createShader(rect),
                child: logo,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MotePainter extends CustomPainter {
  _MotePainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final p = Paint()..isAntiAlias = true;
    for (var i = 0; i < 28; i++) {
      final a = i * 2.399 + t * (0.6 + (i % 4) * 0.15);
      final d = 120 + (i * 37 % 160) + t * 60;
      final o = c + Offset(math.cos(a) * d, math.sin(a) * d * 0.8);
      final fade = (1 - (t * 1.6 - (i % 5) * 0.08)).clamp(0.0, 1.0) * math.min(1, t * 8);
      p.color = Color.fromRGBO(106, 63, 216, 0.35 * fade);
      canvas.drawCircle(o, 2.0 + (i % 3), p);
    }
  }

  @override
  bool shouldRepaint(covariant _MotePainter oldDelegate) => oldDelegate.t != t;
}
