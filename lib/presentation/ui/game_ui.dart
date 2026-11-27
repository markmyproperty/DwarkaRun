import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../app_scope.dart';
import '../../audio/game_audio.dart';
import '../dr_theme.dart';

/// The game's colourful menu style: deep royal night panels, saffron and
/// gold highlights, chunky glossy buttons with a pressable 3D lip, and
/// outlined display type.
class GameColors {
  static const night = Color(0xFF120A2E);
  static const deep = Color(0xFF1F1452);
  static const royal = Color(0xFF33228A);
  static const panelTop = Color(0xFF4A36A8);
  static const panelBottom = Color(0xFF2B1E70);
  static const violet = Color(0xFF7A52F0);
  static const saffron = Color(0xFFFFA31A);
  static const gold = Color(0xFFFFD34A);
  static const teal = Color(0xFF19D3B8);
  static const sky = Color(0xFF3FB4FF);
  static const pink = Color(0xFFFF5C93);
  static const green = Color(0xFF3FD46B);
  static const red = Color(0xFFFF4D5E);
  static const text = Colors.white;
  static const textDim = Color(0xFFCFC6F5);
  static const outline = Color(0xFF1A0F3D);
}

/// Display face for titles and buttons; Baloo 2 for everything else (it also
/// covers Devanagari).
const kDisplayFont = 'Lilita';
const kBodyFont = 'Baloo';

/// Colour sets for [GameButton] and [RoundGameButton].
enum GameTone {
  orange([Color(0xFFFFD45A), Color(0xFFFF8A00)], Color(0xFFC25400), Color(0xFF7A3000)),
  green([Color(0xFF9BF57A), Color(0xFF2DBE4E)], Color(0xFF178A36), Color(0xFF0D5A22)),
  blue([Color(0xFF7FDBFF), Color(0xFF1E8BEA)], Color(0xFF135FA8), Color(0xFF0B3C70)),
  purple([Color(0xFFB99BFF), Color(0xFF6B42DE)], Color(0xFF43259A), Color(0xFF2A1466)),
  pink([Color(0xFFFFA6CF), Color(0xFFF0428A)], Color(0xFFA81E5C), Color(0xFF66103A)),
  red([Color(0xFFFF9A9A), Color(0xFFE5384C)], Color(0xFFA11F31), Color(0xFF66101E)),
  gold([Color(0xFFFFF0A0), Color(0xFFF2B21E)], Color(0xFFB07806), Color(0xFF6E4A00)),
  grey([Color(0xFFB9B4C9), Color(0xFF7E7896)], Color(0xFF575170), Color(0xFF332F45));

  const GameTone(this.face, this.lip, this.border);

  final List<Color> face;
  final Color lip;
  final Color border;
}

/// Plays the button click and a light haptic tick.
void tapFeedback(BuildContext context) {
  AppScope.read(context).audio.play(Sfx.click);
  HapticFeedback.selectionClick();
}

/// Text with a dark outline and drop shadow, the way game titles read over
/// busy art.
class StrokeText extends StatelessWidget {
  const StrokeText(
    this.text, {
    super.key,
    this.size = 24,
    this.color = Colors.white,
    this.stroke = GameColors.outline,
    this.strokeWidth,
    this.font = kDisplayFont,
    this.align = TextAlign.center,
    this.maxLines = 2,
    this.letterSpacing = 0.5,
  });

  final String text;
  final double size;
  final Color color;
  final Color stroke;
  final double? strokeWidth;
  final String font;
  final TextAlign align;
  final int maxLines;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontFamily: font,
      fontSize: size,
      height: 1.1,
      letterSpacing: letterSpacing,
      fontWeight: font == kBodyFont ? FontWeight.w800 : FontWeight.w400,
    );
    final sw = strokeWidth ?? math.max(2.5, size * 0.16);
    return Stack(
      children: [
        Text(
          text,
          textAlign: align,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: base.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = sw
              ..strokeJoin = StrokeJoin.round
              ..color = stroke,
            shadows: [Shadow(color: const Color(0x66000000), offset: Offset(0, size * 0.08), blurRadius: 2)],
          ),
        ),
        Text(
          text,
          textAlign: align,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: base.copyWith(color: color),
        ),
      ],
    );
  }
}

/// A chunky, glossy game button. It sinks onto its lip while pressed, clicks
/// and gives a haptic tick.
class GameButton extends StatefulWidget {
  const GameButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.leading,
    this.tone = GameTone.orange,
    this.height = 58,
    this.fontSize,
    this.expand = false,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? leading;
  final GameTone tone;
  final double height;
  final double? fontSize;
  final bool expand;
  final String? semanticLabel;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final tone = enabled ? widget.tone : GameTone.grey;
    final h = widget.height;
    final depth = h * 0.11;
    final radius = BorderRadius.circular(h * 0.34);
    final fs = widget.fontSize ?? h * 0.38;
    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.leading != null) ...[widget.leading!, SizedBox(width: h * 0.14)],
        if (widget.icon != null) ...[
          Icon(widget.icon, color: Colors.white, size: fs * 1.25, shadows: const [Shadow(color: Color(0x88000000), offset: Offset(0, 2))]),
          SizedBox(width: h * 0.14),
        ],
        Flexible(
          child: StrokeText(widget.label, size: fs, stroke: tone.border, maxLines: 1),
        ),
      ],
    );
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel ?? widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTap: enabled
            ? () {
                tapFeedback(context);
                widget.onPressed!();
              }
            : null,
        child: AnimatedScale(
          scale: _down ? 0.97 : 1,
          duration: const Duration(milliseconds: 90),
          child: SizedBox(
            height: h,
            width: widget.expand ? double.infinity : null,
            child: Stack(
              children: [
                // The lip under the face.
                Positioned.fill(
                  top: depth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: tone.lip,
                      borderRadius: radius,
                      border: Border.all(color: tone.border, width: 2),
                      boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 10, offset: Offset(0, 6))],
                    ),
                  ),
                ),
                AnimatedPadding(
                  duration: const Duration(milliseconds: 70),
                  padding: EdgeInsets.only(top: _down ? depth * 0.75 : 0, bottom: _down ? depth * 0.25 : depth),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      border: Border.all(color: tone.border, width: 2),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: tone.face,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Gloss across the top half.
                        Positioned(
                          left: h * 0.18,
                          right: h * 0.18,
                          top: h * 0.07,
                          height: h * 0.26,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(h),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0x88FFFFFF), Color(0x10FFFFFF)],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: h - depth,
                          child: Center(
                            widthFactor: 1,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: h * 0.36),
                              child: content,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A round 3D icon button with an optional caption and a red badge.
class RoundGameButton extends StatefulWidget {
  const RoundGameButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.label,
    this.caption,
    this.tone = GameTone.purple,
    this.size = 56,
    this.badge = 0,
    this.dot = false,
    this.child,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String label;
  final String? caption;
  final GameTone tone;
  final double size;
  final int badge;
  final bool dot;
  final Widget? child;

  @override
  State<RoundGameButton> createState() => _RoundGameButtonState();
}

class _RoundGameButtonState extends State<RoundGameButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final depth = s * 0.08;
    final tone = widget.tone;
    final face = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: tone.border, width: 2),
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: tone.face),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: s * 0.08,
            left: s * 0.2,
            right: s * 0.2,
            height: s * 0.24,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(s),
                color: const Color(0x55FFFFFF),
              ),
            ),
          ),
          widget.child ??
              Icon(
                widget.icon,
                color: Colors.white,
                size: s * 0.5,
                shadows: const [Shadow(color: Color(0x99000000), offset: Offset(0, 2), blurRadius: 1)],
              ),
        ],
      ),
    );
    final button = SizedBox(
      width: s,
      height: s,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            top: depth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tone.lip,
                border: Border.all(color: tone.border, width: 2),
                boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 8, offset: Offset(0, 4))],
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 70),
            left: 0,
            right: 0,
            top: _down ? depth * 0.8 : 0,
            bottom: _down ? 0 : depth,
            child: face,
          ),
          if (widget.badge > 0 || widget.dot)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: GameColors.red,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: widget.badge > 0
                    ? Text(
                        '${widget.badge}',
                        style: const TextStyle(
                          fontFamily: kBodyFont,
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onPressed == null
            ? null
            : () {
                tapFeedback(context);
                widget.onPressed!();
              },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            button,
            if (widget.caption != null) ...[
              const SizedBox(height: 4),
              StrokeText(widget.caption!, size: 13, maxLines: 1, strokeWidth: 3),
            ],
          ],
        ),
      ),
    );
  }
}

/// A rounded panel in the menu style.
class GamePanel extends StatelessWidget {
  const GamePanel({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.tint});

  final Widget child;
  final EdgeInsets padding;
  final List<Color>? tint;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: tint ?? const [GameColors.panelTop, GameColors.panelBottom],
      ),
      border: Border.all(color: const Color(0x55FFFFFF), width: 2),
      boxShadow: const [BoxShadow(color: Color(0x88000000), blurRadius: 24, offset: Offset(0, 10))],
    ),
    child: child,
  );
}

/// A ribbon banner with a title, across the top of a panel or screen.
class RibbonTitle extends StatelessWidget {
  const RibbonTitle(this.text, {super.key, this.tone = GameTone.orange, this.size = 26});

  final String text;
  final GameTone tone;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _RibbonPainter(tone),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: size * 1.6, vertical: size * 0.38),
      child: StrokeText(text, size: size, stroke: tone.border, maxLines: 1),
    ),
  );
}

class _RibbonPainter extends CustomPainter {
  _RibbonPainter(this.tone);

  final GameTone tone;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final tail = h * 0.55;
    final p = Paint()..isAntiAlias = true;
    // Folded tails.
    for (final side in const [-1.0, 1.0]) {
      final x0 = side < 0 ? 0.0 : w;
      final path = Path()
        ..moveTo(x0 + side * -tail * 0.2, h * 0.25)
        ..lineTo(x0 + side * tail * 0.6, h * 0.25)
        ..lineTo(x0 + side * tail * 0.25, h * 0.7)
        ..lineTo(x0 + side * tail * 0.6, h * 1.12)
        ..lineTo(x0 + side * -tail * 0.2, h * 1.12)
        ..close();
      canvas.drawPath(path, p..color = tone.lip);
      canvas.drawPath(
        path,
        Paint()
          ..isAntiAlias = true
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = tone.border,
      );
    }
    final body = RRect.fromRectAndRadius(Rect.fromLTWH(tail * 0.2, 0, w - tail * 0.4, h), Radius.circular(h * 0.2));
    canvas.drawRRect(
      body,
      p
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: tone.face,
        ).createShader(Offset.zero & size),
    );
    p.shader = null;
    canvas.drawRRect(
      body,
      Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = tone.border,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(tail * 0.4, h * 0.1, w - tail * 0.8, h * 0.3), Radius.circular(h)),
      p..color = const Color(0x44FFFFFF),
    );
  }

  @override
  bool shouldRepaint(covariant _RibbonPainter oldDelegate) => oldDelegate.tone != tone;
}

/// A balance pill: icon, an animated number and an optional "+" action.
class CurrencyChip extends StatelessWidget {
  const CurrencyChip({super.key, required this.icon, required this.value, this.onAdd, this.width = 118});

  final Widget icon;
  final int value;
  final VoidCallback? onAdd;
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: 40,
    child: Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.centerLeft,
      children: [
        Positioned.fill(
          left: 14,
          child: Container(
            padding: const EdgeInsets.only(left: 22, right: 8),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: const Color(0xB3120A2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x40FFFFFF), width: 1.5),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: value.toDouble()),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _group(v.round()),
                  style: const TextStyle(
                    fontFamily: kBodyFont,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 34, height: 34, child: icon),
        if (onAdd != null)
          Positioned(
            right: -6,
            child: GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: GameColors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    ),
  );

  static String _group(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }
}

/// Deep night backdrop for menu screens, with soft light beams and drifting
/// sparkles. Pass [art] to blur a world behind it.
class GameBackdrop extends StatefulWidget {
  const GameBackdrop({super.key, required this.child, this.art});

  final Widget child;
  final String? art;

  @override
  State<GameBackdrop> createState() => _GameBackdropState();
}

class _GameBackdropState extends State<GameBackdrop> with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(seconds: 24));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotionOf(context)) {
      _t.stop();
    } else if (!_t.isAnimating) {
      _t.repeat();
    }
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.5),
            radius: 1.3,
            colors: [Color(0xFF4B2FA6), GameColors.deep, GameColors.night],
            stops: [0, 0.55, 1],
          ),
        ),
      ),
      if (widget.art != null)
        Opacity(
          opacity: 0.35,
          child: Image.asset(widget.art!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox()),
        ),
      if (widget.art != null)
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x99120A2E), Color(0xDD120A2E)],
            ),
          ),
        ),
      RepaintBoundary(
        child: AnimatedBuilder(
          animation: _t,
          builder: (context, _) => CustomPaint(painter: SparklePainter(_t.value)),
        ),
      ),
      widget.child,
    ],
  );
}

/// Slow light beams and twinkling motes, reused on several screens.
class SparklePainter extends CustomPainter {
  SparklePainter(this.t, {this.count = 36, this.beams = true});

  final double t;
  final int count;
  final bool beams;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = true;
    if (beams) {
      final c = Offset(size.width / 2, -size.height * 0.1);
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(t * math.pi * 2 / 6);
      for (var i = 0; i < 9; i++) {
        canvas.rotate(math.pi * 2 / 9);
        final beam = Path()
          ..moveTo(0, 0)
          ..lineTo(-size.height * 0.09, size.height * 1.4)
          ..lineTo(size.height * 0.09, size.height * 1.4)
          ..close();
        canvas.drawPath(beam, p..color = const Color(0x0CFFFFFF));
      }
      canvas.restore();
    }
    for (var i = 0; i < count; i++) {
      final seed = i * 7919 % 1000 / 1000;
      final x = (seed * 0.97 + i * 0.137) % 1 * size.width;
      final speed = 0.3 + (i % 5) * 0.12;
      final y = (1 - ((t * speed * 3 + seed) % 1)) * size.height;
      final tw = 0.5 + 0.5 * math.sin((t * 40 + i) * 1.3);
      final r = 1.0 + (i % 3) * 0.9;
      p.color = Color.fromRGBO(255, 230, 160, 0.15 + 0.5 * tw);
      canvas.drawCircle(Offset(x, y), r, p);
    }
  }

  @override
  bool shouldRepaint(covariant SparklePainter oldDelegate) => oldDelegate.t != t;
}

/// A fade-and-rise page transition with a whoosh.
class GameRoute<T> extends PageRouteBuilder<T> {
  GameRoute({required WidgetBuilder builder, super.settings})
    : super(
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (context, _, _) => builder(context),
        transitionsBuilder: (context, a, _, child) {
          final curved = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(scale: Tween(begin: 1.06, end: 1.0).animate(curved), child: child),
          );
        },
      );
}

/// A modal sheet in the menu style, sliding up over a dimmed screen.
Future<T?> showGameSheet<T>(BuildContext context, {required WidgetBuilder builder}) {
  AppScope.read(context).audio.play(Sfx.whoosh, volume: 0.7);
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: const Color(0xB3080418),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (context, _, _) => builder(context),
    transitionBuilder: (context, a, _, child) {
      final curved = CurvedAnimation(parent: a, curve: Curves.easeOutBack, reverseCurve: Curves.easeInCubic);
      return FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.25), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// The frame for a sheet: ribbon title, close button and scrolling content.
class GameSheet extends StatelessWidget {
  const GameSheet({super.key, required this.title, required this.child, this.tone = GameTone.orange, this.sheetKey});

  final String title;
  final Widget child;
  final GameTone tone;
  final Key? sheetKey;

  @override
  Widget build(BuildContext context) {
    final l = MaterialLocalizations.of(context);
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Material(
              type: MaterialType.transparency,
              child: Stack(
                key: sheetKey,
                clipBehavior: Clip.none,
                children: [
                  GamePanel(
                    padding: const EdgeInsets.fromLTRB(16, 44, 16, 18),
                    child: child,
                  ),
                  Positioned(
                    top: -22,
                    left: 0,
                    right: 0,
                    child: Center(child: RibbonTitle(title, tone: tone)),
                  ),
                  Positioned(
                    top: -12,
                    right: -8,
                    child: RoundGameButton(
                      key: const Key('sheet.close'),
                      icon: Icons.close_rounded,
                      label: l.closeButtonLabel,
                      tone: GameTone.red,
                      size: 42,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A thin, rounded bar with a glossy fill.
class GameProgressBar extends StatelessWidget {
  const GameProgressBar({super.key, required this.value, this.height = 12, this.colors});

  final double value;
  final double height;
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: BoxDecoration(
      color: const Color(0xFF140B36),
      borderRadius: BorderRadius.circular(height),
      border: Border.all(color: const Color(0x66FFFFFF), width: 1.2),
    ),
    padding: const EdgeInsets.all(1.5),
    child: Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors ?? const [Color(0xFFFFE27A), Color(0xFFFF9A1A)],
            ),
          ),
        ),
      ),
    ),
  );
}
