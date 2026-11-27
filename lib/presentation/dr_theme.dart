import 'package:material_ui/material_ui.dart';

import '../game/realm.dart';
import '../l10n/gen/app_localizations.dart';

/// Dwarka Run's own look: deep indigo, saffron, peacock teal and warm cream.
class DrColors {
  static const indigo = Color(0xFF2B1A4A);
  static const indigoSoft = Color(0xFF4A3478);
  static const saffron = Color(0xFFF29E38);
  static const teal = Color(0xFF1F8A8A);
  static const gold = Color(0xFFF5C542);
  static const cream = Color(0xFFFFF4E0);
  static const sand = Color(0xFFF6E7CC);
  static const ink = Color(0xFF2A1E3A);
  static const inkMuted = Color(0xFF6E6380);
  static const done = Color(0xFF2E8B57);
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
    textTheme: Typography.blackMountainView.apply(bodyColor: DrColors.ink, displayColor: DrColors.ink),
  );
}

/// Shared card decoration.
BoxDecoration drCard({Color color = DrColors.cream}) => BoxDecoration(
  color: color,
  borderRadius: BorderRadius.circular(20),
  boxShadow: const [BoxShadow(color: Color(0x222B1A4A), blurRadius: 16, offset: Offset(0, 6))],
);

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
              borderRadius: BorderRadius.circular(28),
              side: primary ? BorderSide.none : const BorderSide(color: DrColors.indigo, width: 2),
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
