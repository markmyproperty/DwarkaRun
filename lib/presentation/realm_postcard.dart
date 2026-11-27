import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../game/realm.dart';
import '../game/stage_art.dart';

/// A small painted view of a realm for the hub: sky, hills and a path running
/// into the distance, in the realm's colours.
class RealmPostcard extends StatelessWidget {
  const RealmPostcard({super.key, required this.realm, this.alignmentY = 0.2});

  final Realm realm;
  final double alignmentY;

  /// Art-pack backdrops, where a realm has one.
  static const _art = {
    Realm.ayodhya: 'assets/images/backgrounds/ancient_city_background.webp',
    Realm.ganga: 'assets/images/backgrounds/coastal_background.webp',
  };

  @override
  Widget build(BuildContext context) {
    final painted = CustomPaint(painter: _PostcardPainter(realm.palette), size: Size.infinite);
    final stage = StageArt.of(realm);
    final asset = _art[realm] ?? (stage == null ? null : 'assets/images/${stage.postcard}.webp');
    return ExcludeSemantics(
      child: asset == null
          ? painted
          : Image.asset(
              asset,
              fit: BoxFit.cover,
              alignment: Alignment(0, alignmentY),
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, _, _) => painted,
            ),
    );
  }
}

class _PostcardPainter extends CustomPainter {
  _PostcardPainter(this.pal);

  final RealmPalette pal;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final horizon = h * 0.52;
    final p = Paint();
    p.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [pal.skyTop, pal.skyBottom],
    ).createShader(Rect.fromLTWH(0, 0, w, horizon));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, horizon), p);
    p.shader = null;

    p.color = const Color(0xFFFFF3D0);
    canvas.drawCircle(Offset(w * 0.8, h * 0.2), h * 0.09, p);

    final hills = Path()..moveTo(0, horizon);
    for (var i = 0; i <= 10; i++) {
      hills.lineTo(w * i / 10, horizon - h * (0.1 + 0.07 * math.sin(i * 1.9)));
    }
    hills
      ..lineTo(w, horizon)
      ..close();
    p.color = pal.foliageLight;
    canvas.drawPath(hills, p);

    p.color = pal.ground;
    canvas.drawRect(Rect.fromLTWH(0, horizon, w, h - horizon), p);

    final road = Path()
      ..moveTo(w * 0.47, horizon)
      ..lineTo(w * 0.53, horizon)
      ..lineTo(w * 0.8, h)
      ..lineTo(w * 0.2, h)
      ..close();
    p.color = pal.pathA;
    canvas.drawPath(road, p);

    // A pair of trees framing the path.
    for (final (x, s) in [(0.12, 1.0), (0.88, 0.9), (0.3, 0.45), (0.7, 0.4)]) {
      final bx = w * x;
      final by = horizon + (h - horizon) * (s * 0.8);
      p.color = const Color(0xFF6B4A2E);
      canvas.drawRect(Rect.fromLTWH(bx - 5 * s, by - 46 * s, 10 * s, 46 * s), p);
      p.color = pal.foliageDark;
      canvas.drawOval(Rect.fromCenter(center: Offset(bx, by - 54 * s), width: 90 * s, height: 44 * s), p);
      p.color = pal.foliageLight;
      canvas.drawCircle(Offset(bx - 14 * s, by - 62 * s), 18 * s, p);
    }
  }

  @override
  bool shouldRepaint(covariant _PostcardPainter oldDelegate) => oldDelegate.pal != pal;
}
