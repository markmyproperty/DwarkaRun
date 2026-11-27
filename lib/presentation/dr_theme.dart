import 'package:material_ui/material_ui.dart';

import '../game/realm.dart';
import '../l10n/gen/app_localizations.dart';

/// The menus' Ukiyo-e woodblock look: washi paper, Prussian-blue ink,
/// vermilion seals, ochre and sumi-black outlines. The stages keep their own
/// art; only the hub, panels and buttons wear this style.
class DrColors {
  static const indigo = Color(0xFF1E3A5F); // Prussian blue (bero-ai)
  static const indigoSoft = Color(0xFF2F5680);
  static const saffron = Color(0xFFC8402F); // vermilion
  static const teal = Color(0xFF3F7F78);
  static const gold = Color(0xFFD9A441); // ochre
  static const cream = Color(0xFFF7EEDC); // washi paper
  static const sand = Color(0xFFEDE0C4);
  static const ink = Color(0xFF1C1A17); // sumi
  static const inkMuted = Color(0xFF5E5547);
  static const done = Color(0xFF4F7A4A);
}

ThemeData buildDrTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: DrColors.indigo,
    primary: DrColors.indigo,
    secondary: DrColors.saffron,
    surface: DrColors.cream,
  );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: DrColors.sand,
    useMaterial3: true,
    fontFamily: 'serif',
    textTheme: Typography.blackMountainView.apply(
      bodyColor: DrColors.ink,
      displayColor: DrColors.ink,
      fontFamily: 'serif',
    ),
  );
}

/// Shared card: a paper panel with a sumi outline and a flat, offset
/// "print" shadow instead of a soft blur.
BoxDecoration drCard({Color color = DrColors.cream}) => BoxDecoration(
  color: color,
  borderRadius: BorderRadius.circular(8),
  border: Border.all(color: DrColors.ink, width: 1.6),
  boxShadow: const [BoxShadow(color: Color(0x401E3A5F), offset: Offset(4, 4))],
);

/// Washi paper with a vermilion sun and bands of seigaiha waves, behind the
/// hub. Drawn in code, so there is nothing to load.
class WoodblockBackground extends StatelessWidget {
  const WoodblockBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _WoodblockPainter(), child: child);
}

class _WoodblockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = true;
    canvas.drawRect(Offset.zero & size, p..color = DrColors.sand);
    // Faint paper fibres.
    p
      ..color = const Color(0x14806A40)
      ..strokeWidth = 1;
    for (var i = 0; i < 90; i++) {
      final y = (i * 97.0) % size.height;
      final x = (i * 211.0) % size.width;
      canvas.drawLine(Offset(x, y), Offset(x + 18 + (i % 5) * 6, y + (i % 3) - 1), p);
    }
    // The rising sun.
    final sun = Offset(size.width * 0.86, 120);
    canvas.drawCircle(sun, 74, p..color = const Color(0x22C8402F));
    canvas.drawCircle(sun, 52, p..color = const Color(0x55C8402F));
    // Seigaiha waves along the bottom.
    const r = 26.0;
    final stroke = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final fill = Paint()..isAntiAlias = true;
    var row = 0;
    for (var y = size.height - 40; y < size.height + r; y += r * 0.55, row++) {
      final shift = row.isOdd ? r : 0.0;
      for (var x = -r + shift; x < size.width + r; x += r * 2) {
        final c = Offset(x, y);
        fill.color = row.isEven ? const Color(0xFF2F5680) : const Color(0xFF1E3A5F);
        canvas.drawCircle(c, r, fill);
        stroke.color = const Color(0xCCF7EEDC);
        for (final k in const [0.78, 0.56, 0.34]) {
          canvas.drawCircle(c, r * k, stroke);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Whether the player asked for less motion (system setting).
bool reduceMotionOf(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

extension RealmText on Realm {
  String name(AppLocalizations l) => switch (this) {
    Realm.ayodhya => l.realmAyodhya,
    Realm.ganga => l.realmGanga,
    Realm.pharaoh => l.realmPharaoh,
    Realm.himalayan => l.realmHimalayan,
    Realm.vijayanagar => l.realmVijayanagar,
    Realm.dragonValley => l.realmDragonValley,
    Realm.lanka => l.realmLanka,
    Realm.indus => l.realmIndus,
    Realm.sunkenDwarka => l.realmSunkenDwarka,
    Realm.finalLegend => l.realmFinalLegend,
  };

  String blurb(AppLocalizations l) => switch (this) {
    Realm.ayodhya => l.realmAyodhyaBlurb,
    Realm.ganga => l.realmGangaBlurb,
    Realm.pharaoh => l.realmPharaohBlurb,
    Realm.himalayan => l.realmHimalayanBlurb,
    Realm.vijayanagar => l.realmVijayanagarBlurb,
    Realm.dragonValley => l.realmDragonValleyBlurb,
    Realm.lanka => l.realmLankaBlurb,
    Realm.indus => l.realmIndusBlurb,
    Realm.sunkenDwarka => l.realmSunkenDwarkaBlurb,
    Realm.finalLegend => l.realmFinalLegendBlurb,
  };
}

/// A big, rounded primary button with a semantic label and a 56 px target.
class DrButton extends StatelessWidget {
  const DrButton({super.key, required this.label, required this.onPressed, this.icon, this.primary = true});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final bg = primary ? DrColors.indigo : DrColors.cream;
    final fg = primary ? Colors.white : DrColors.indigo;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: SizedBox(
        height: 56,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            minimumSize: const Size(120, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: DrColors.ink, width: 2),
            ),
            textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 22), const SizedBox(width: 8)],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
    );
  }
}
