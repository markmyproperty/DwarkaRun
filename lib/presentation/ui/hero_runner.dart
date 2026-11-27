import 'package:material_ui/material_ui.dart';

import '../dr_theme.dart';

/// The hero's rendered run cycle as a widget, for menus and the story intro.
class HeroRunner extends StatefulWidget {
  const HeroRunner({super.key, this.height = 260, this.fps = 14, this.shadow = true});

  final double height;
  final double fps;
  final bool shadow;

  static List<String> get frames => [
    for (var i = 1; i <= 16; i++) 'assets/images/hero/run_${i.toString().padLeft(2, '0')}.webp',
  ];

  /// Loads every frame so the cycle never flickers on its first pass.
  static Future<void> precache(BuildContext context) =>
      Future.wait([for (final f in frames) precacheImage(AssetImage(f), context)]).catchError((_) => <void>[]);

  @override
  State<HeroRunner> createState() => _HeroRunnerState();
}

class _HeroRunnerState extends State<HeroRunner> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 1));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    HeroRunner.precache(context);
    _c.duration = Duration(milliseconds: (16 / widget.fps * 1000).round());
    if (reduceMotionOf(context)) {
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
    final h = widget.height;
    final w = h * 144 / 416;
    return ExcludeSemantics(
      child: SizedBox(
        width: w * 1.6,
        height: h * 1.04,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final frame = (_c.value * 16).floor() % 16;
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                if (widget.shadow)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: w * 1.1,
                      height: h * 0.07,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(h),
                        gradient: const RadialGradient(colors: [Color(0x88000000), Color(0x00000000)]),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: h * 0.025,
                  child: Image.asset(
                    HeroRunner.frames[frame],
                    height: h,
                    width: w,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (_, _, _) => SizedBox(width: w, height: h),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
