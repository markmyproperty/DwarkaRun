import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../game/realm.dart';

/// Each world's touch of atmosphere for the menus: what drifts down the
/// screen (petals, snow, sand) and the garland hung across the top.
class WorldAmbience {
  const WorldAmbience({this.falling, this.garland});

  final String? falling;
  final String? garland;

  static WorldAmbience of(Realm realm) => switch (realm) {
    Realm.ayodhya => const WorldAmbience(
      falling: 'ayodhya/vfx/marigold_petal_fall',
      garland: 'ayodhya/decorations/festive_toran',
    ),
    Realm.ganga => const WorldAmbience(
      falling: 'ayodhya/vfx/floating_lotus_petals',
      garland: 'ganga/decorations/string_of_marigold_on_rope',
    ),
    Realm.pharaoh => const WorldAmbience(falling: 'pharaoh/vfx/desert_dust_motes'),
    Realm.himalayan => const WorldAmbience(
      falling: 'himalayan/vfx/falling_snow',
      garland: 'himalayan/decorations/coloured_cloth_bunting',
    ),
    Realm.vijayanagar => const WorldAmbience(
      falling: 'vijayanagar/vfx/falling_plumeria_petals',
      garland: 'vijayanagar/decorations/jasmine_garland_swag',
    ),
    Realm.dragonValley => const WorldAmbience(falling: 'dragon/vfx/falling_cinder_flakes'),
    Realm.lanka => const WorldAmbience(
      falling: 'lanka/vfx/falling_frangipani_petals',
      garland: 'lanka/decorations/floral_swag_garland',
    ),
    _ => const WorldAmbience(falling: 'ayodhya/vfx/gold_sparkle'),
  };
}

/// Sprites from the world's art drifting slowly down and across the screen.
class FallingAmbience extends StatefulWidget {
  const FallingAmbience({super.key, required this.realm, this.count = 7, this.reduce = false});

  final Realm realm;
  final int count;
  final bool reduce;

  @override
  State<FallingAmbience> createState() => _FallingAmbienceState();
}

class _FallingAmbienceState extends State<FallingAmbience> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 18));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.reduce) {
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
    final name = WorldAmbience.of(widget.realm).falling;
    if (name == null || widget.reduce) return const SizedBox.shrink();
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, box) => AnimatedBuilder(
          animation: _c,
          builder: (context, _) =>
              Stack(children: [for (var i = 0; i < widget.count; i++) _flake(box, name, i, _c.value)]),
        ),
      ),
    );
  }

  Widget _flake(BoxConstraints box, String name, int i, double t) {
    final seed = math.sin(i * 91.7) * 0.5 + 0.5;
    final speed = 0.7 + (i % 3) * 0.25;
    final p = (t * speed + i / widget.count) % 1.0;
    final size = 46.0 + seed * 40;
    final x = seed * box.maxWidth + math.sin((t * 6 + i) * math.pi) * 24 - size / 2;
    final y = -size + p * (box.maxHeight + size * 2);
    final fade = math.sin(p * math.pi).clamp(0.0, 1.0);
    return Positioned(
      left: x,
      top: y,
      child: Opacity(
        opacity: 0.75 * fade,
        child: Transform.rotate(
          angle: (t * 2 + seed) * math.pi * (i.isEven ? 1 : -1),
          child: Image.asset(
            'assets/images/$name.webp',
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

/// The world's garland, hung in a gentle swag across the width.
class WorldGarland extends StatelessWidget {
  const WorldGarland({super.key, required this.realm, this.height = 44});

  final Realm realm;
  final double height;

  @override
  Widget build(BuildContext context) {
    final name = WorldAmbience.of(realm).garland;
    if (name == null) return SizedBox(height: height * 0.4);
    return IgnorePointer(
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            for (var i = 0; i < 2; i++)
              Expanded(
                child: Image.asset(
                  'assets/images/$name.webp',
                  fit: BoxFit.fill,
                  height: height,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
