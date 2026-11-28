import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// The mudra coin as a UI icon: a glossy gold disc with a raised rim and a
/// square hole.
class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: const _CoinPainter());
}

class _CoinPainter extends CustomPainter {
  const _CoinPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: c, radius: r);
    final p = Paint()..isAntiAlias = true;
    // Shadow edge, rim and face.
    canvas.drawCircle(c.translate(0, r * 0.08), r, p..color = const Color(0xFF8A5A06));
    p.shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFF1A6), Color(0xFFF5B81E), Color(0xFFC98A0C)],
    ).createShader(rect);
    canvas.drawCircle(c, r, p);
    p.shader = const LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: [Color(0xFFFFE27A), Color(0xFFE9A313)],
    ).createShader(rect);
    canvas.drawCircle(c, r * 0.74, p);
    p.shader = null;
    final hole = Rect.fromCenter(center: c, width: r * 0.48, height: r * 0.48);
    canvas.drawRRect(RRect.fromRectAndRadius(hole, Radius.circular(r * 0.06)), p..color = const Color(0xFF9A6408));
    // Shine.
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 0.86),
      math.pi * 1.1,
      math.pi * 0.5,
      false,
      Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = r * 0.12
        ..color = const Color(0xCCFFFFFF),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A cut gem: the rare collectible and the premium currency.
class GemIcon extends StatelessWidget {
  const GemIcon({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: const _GemPainter());
}

class _GemPainter extends CustomPainter {
  const _GemPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final top = h * 0.12, girdle = h * 0.38, bottom = h * 0.95;
    Offset o(double x, double y) => Offset(w * x, y);
    final p = Paint()..isAntiAlias = true;
    void facet(List<Offset> pts, Color c) {
      canvas.drawPath(Path()..addPolygon(pts, true), p..color = c);
    }

    // Crown.
    facet([o(0.28, top), o(0.72, top), o(0.95, girdle), o(0.05, girdle)], const Color(0xFF7FF3FF));
    facet([o(0.28, top), o(0.5, top), o(0.38, girdle), o(0.05, girdle)], const Color(0xFFB8FBFF));
    facet([o(0.5, top), o(0.72, top), o(0.95, girdle), o(0.62, girdle)], const Color(0xFF4FD5F0));
    // Pavilion.
    facet([o(0.05, girdle), o(0.38, girdle), o(0.5, bottom)], const Color(0xFF2FB2E8));
    facet([o(0.38, girdle), o(0.62, girdle), o(0.5, bottom)], const Color(0xFF1E8FD8));
    facet([o(0.62, girdle), o(0.95, girdle), o(0.5, bottom)], const Color(0xFF1569B8));
    // Outline and glint.
    canvas.drawPath(
      Path()..addPolygon([o(0.28, top), o(0.72, top), o(0.95, girdle), o(0.5, bottom), o(0.05, girdle)], true),
      Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = math.max(1, w * 0.06)
        ..color = const Color(0xFF0C3D7A),
    );
    canvas.drawCircle(o(0.33, h * 0.22), w * 0.06, p..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The Garuda feather as a UI icon.
class FeatherIcon extends StatelessWidget {
  const FeatherIcon({super.key, this.size = 24, this.dim = false});

  final double size;
  final bool dim;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _FeatherPainter(dim));
}

class _FeatherPainter extends CustomPainter {
  _FeatherPainter(this.dim);

  final bool dim;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.save();
    canvas.translate(w / 2, h / 2);
    canvas.rotate(math.pi / 5);
    final path = Path()
      ..moveTo(0, h * 0.45)
      ..quadraticBezierTo(-w * 0.34, 0, 0, -h * 0.47)
      ..quadraticBezierTo(w * 0.34, 0, 0, h * 0.45)
      ..close();
    final rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    canvas.drawPath(
      path,
      Paint()
        ..isAntiAlias = true
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dim
              ? const [Color(0xFFBFC8C8), Color(0xFF7E8C8C)]
              : const [Color(0xFF6FF0D8), Color(0xFFF5C542), Color(0xFFE87A1E)],
        ).createShader(rect),
    );
    final vane = Paint()
      ..isAntiAlias = true
      ..color = const Color(0x552B1A4A)
      ..strokeWidth = math.max(1, w * 0.03);
    for (var i = 1; i < 6; i++) {
      final y = -h * 0.35 + i * h * 0.12;
      canvas.drawLine(Offset(0, y), Offset(-w * 0.2, y - h * 0.08), vane);
      canvas.drawLine(Offset(0, y), Offset(w * 0.2, y - h * 0.08), vane);
    }
    canvas.drawLine(
      Offset(0, h * 0.48),
      Offset(0, -h * 0.38),
      Paint()
        ..isAntiAlias = true
        ..color = const Color(0xFF2B1A4A)
        ..strokeWidth = math.max(1.5, w * 0.06),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FeatherPainter oldDelegate) => oldDelegate.dim != dim;
}

/// The Lotus charm as a UI icon.
class LotusIcon extends StatelessWidget {
  const LotusIcon({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: const _LotusPainter());
}

class _LotusPainter extends CustomPainter {
  const _LotusPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final base = Offset(w / 2, h * 0.8);
    final p = Paint()..isAntiAlias = true;
    for (final (angle, len, color) in const [
      (-1.1, 0.42, Color(0xFFE95C9B)),
      (1.1, 0.42, Color(0xFFE95C9B)),
      (-0.55, 0.55, Color(0xFFF27DB2)),
      (0.55, 0.55, Color(0xFFF27DB2)),
      (0.0, 0.66, Color(0xFFFFA8CF)),
    ]) {
      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.rotate(angle);
      final l = h * len;
      final petal = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(-w * 0.16, -l * 0.5, 0, -l)
        ..quadraticBezierTo(w * 0.16, -l * 0.5, 0, 0)
        ..close();
      canvas.drawPath(petal, p..color = color);
      canvas.restore();
    }
    canvas.drawOval(
      Rect.fromCenter(center: base.translate(0, h * 0.04), width: w * 0.7, height: h * 0.14),
      p..color = const Color(0xFF3FAE6A),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
