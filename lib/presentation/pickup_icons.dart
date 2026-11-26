import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// The mudra coin as a UI icon: gold disc with a square hole.
class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _CoinPainter());
}

class _CoinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final p = Paint()..color = const Color(0xFFB07A12);
    canvas.drawCircle(c, r, p);
    p.color = const Color(0xFFF5C542);
    canvas.drawCircle(c, r * 0.82, p);
    p.color = const Color(0xFFB07A12);
    canvas.drawRect(Rect.fromCenter(center: c, width: r * 0.5, height: r * 0.5), p);
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
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _FeatherPainter(dim));
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
      ..quadraticBezierTo(-w * 0.32, 0, 0, -h * 0.45)
      ..quadraticBezierTo(w * 0.32, 0, 0, h * 0.45)
      ..close();
    canvas.drawPath(path, Paint()..color = dim ? const Color(0xFF9AA9A9) : const Color(0xFFF5C542));
    canvas.drawLine(
      Offset(0, h * 0.45),
      Offset(0, -h * 0.35),
      Paint()
        ..color = const Color(0xFF2B1A4A)
        ..strokeWidth = 2,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FeatherPainter oldDelegate) => oldDelegate.dim != dim;
}
