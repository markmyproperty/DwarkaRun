import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../l10n/gen/app_localizations.dart';
import 'game_ui.dart';

/// The game's wordmark, built in the app rather than pasted as a picture:
/// a small crown, the title in carved gold with a light sweep running across
/// it, and a crimson ribbon underneath.
class GameTitle extends StatefulWidget {
  const GameTitle({super.key, this.width = 320, this.reduce = false});

  final double width;
  final bool reduce;

  @override
  State<GameTitle> createState() => _GameTitleState();
}

class _GameTitleState extends State<GameTitle> with SingleTickerProviderStateMixin {
  late final AnimationController _shine = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.reduce) {
      _shine.stop();
    } else if (!_shine.isAnimating) {
      _shine.repeat();
    }
  }

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final w = widget.width;
    final main = l.titleMain;
    // Long titles (Hindi) step down so they still fit on one line.
    final mainSize = w * (main.length > 8 ? 0.13 : 0.19);
    final base = TextStyle(
      fontFamily: kDisplayFont,
      fontFamilyFallback: const [kBodyFont],
      fontSize: mainSize,
      height: 1.05,
      letterSpacing: 1.5,
    );
    return Semantics(
      header: true,
      label: l.appTitle,
      excludeSemantics: true,
      child: SizedBox(
        width: w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(size: Size(w * 0.2, w * 0.1), painter: _CrownPainter()),
            AnimatedBuilder(
              animation: _shine,
              builder: (context, _) {
                final s = _shine.value * 2.4 - 0.7;
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Stack(
                    children: [
                      // Deep outline and drop shadow.
                      Text(
                        main,
                        maxLines: 1,
                        style: base.copyWith(
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = mainSize * 0.2
                            ..strokeJoin = StrokeJoin.round
                            ..color = const Color(0xFF3B1300),
                          shadows: [
                            Shadow(color: const Color(0xAA000000), offset: Offset(0, mainSize * 0.1), blurRadius: 6),
                          ],
                        ),
                      ),
                      // Bright inner rim.
                      Text(
                        main,
                        maxLines: 1,
                        style: base.copyWith(
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = mainSize * 0.08
                            ..strokeJoin = StrokeJoin.round
                            ..color = const Color(0xFFFFF1B8),
                        ),
                      ),
                      // Gold face with the moving light sweep.
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (r) => LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: const [Color(0xFFFFF7C9), Color(0xFFFFD44D), Color(0xFFF09A12), Color(0xFFB85C00)],
                          stops: const [0, 0.38, 0.72, 1],
                        ).createShader(r),
                        child: Text(main, maxLines: 1, style: base.copyWith(color: Colors.white)),
                      ),
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (r) => LinearGradient(
                          begin: Alignment(s * 2 - 1.4, -1),
                          end: Alignment(s * 2 - 0.6, 1),
                          colors: const [Color(0x00FFFFFF), Color(0xCCFFFFFF), Color(0x00FFFFFF)],
                          stops: const [0.35, 0.5, 0.65],
                        ).createShader(r),
                        child: Text(main, maxLines: 1, style: base.copyWith(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
            Transform.translate(
              offset: Offset(0, -w * 0.02),
              child: _Ribbon(text: l.titleSub, width: w * 0.86),
            ),
          ],
        ),
      ),
    );
  }
}

/// A crimson banner with folded tails.
class _Ribbon extends StatelessWidget {
  const _Ribbon({required this.text, required this.width});

  final String text;
  final double width;

  @override
  Widget build(BuildContext context) {
    final h = width * 0.15;
    return SizedBox(
      width: width,
      height: h,
      child: CustomPaint(
        painter: _RibbonPainter(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.14),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: StrokeText(
                text,
                size: h * 0.56,
                maxLines: 1,
                letterSpacing: 2.5,
                stroke: const Color(0xFF4A0612),
                strokeWidth: 3,
                color: const Color(0xFFFFF4D6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final tail = w * 0.1;
    final drop = h * 0.28;
    // Tails, tucked behind and lower.
    final tailPaint = Paint()..color = const Color(0xFF7A0F22);
    for (final left in [true, false]) {
      final x0 = left ? 0.0 : w;
      final x1 = left ? tail * 1.4 : w - tail * 1.4;
      final p = Path()
        ..moveTo(x0, drop)
        ..lineTo(x1, drop)
        ..lineTo(x1, h + drop)
        ..lineTo(x0, h + drop)
        ..lineTo(x0 + (left ? tail * 0.5 : -tail * 0.5), drop + h / 2)
        ..close();
      canvas.drawPath(p, tailPaint);
    }
    final body = Rect.fromLTWH(tail, 0, w - tail * 2, h);
    canvas.drawRect(
      body.shift(Offset(0, h * 0.12)),
      Paint()
        ..color = const Color(0x66000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF4D5E), Color(0xFFD01632), Color(0xFF9C0B24)],
        ).createShader(body),
    );
    final edge = Paint()
      ..color = const Color(0xFFFFD34A)
      ..strokeWidth = math.max(1.5, h * 0.06);
    canvas.drawLine(body.topLeft + Offset(0, h * 0.12), body.topRight + Offset(0, h * 0.12), edge);
    canvas.drawLine(body.bottomLeft - Offset(0, h * 0.12), body.bottomRight - Offset(0, h * 0.12), edge);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A small three-point royal crown with jewels.
class _CrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p = Path()
      ..moveTo(w * 0.08, h * 0.92)
      ..lineTo(0, h * 0.25)
      ..lineTo(w * 0.3, h * 0.55)
      ..lineTo(w * 0.5, 0)
      ..lineTo(w * 0.7, h * 0.55)
      ..lineTo(w, h * 0.25)
      ..lineTo(w * 0.92, h * 0.92)
      ..close();
    canvas.drawPath(
      p,
      Paint()
        ..color = const Color(0xFF3B1300)
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.16
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      p,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF3B0), Color(0xFFFFC22E), Color(0xFFD27A00)],
        ).createShader(Offset.zero & size),
    );
    final jewel = Paint()..color = const Color(0xFFE8173A);
    canvas.drawCircle(Offset(w * 0.5, h * 0.66), h * 0.12, jewel);
    canvas.drawCircle(Offset(w * 0.25, h * 0.74), h * 0.08, Paint()..color = const Color(0xFF19B6E8));
    canvas.drawCircle(Offset(w * 0.75, h * 0.74), h * 0.08, Paint()..color = const Color(0xFF19B6E8));
    for (final x in [0.0, 0.5, 1.0]) {
      canvas.drawCircle(Offset(w * x, x == 0.5 ? 0 : h * 0.25), h * 0.09, Paint()..color = const Color(0xFFFFF7D6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
