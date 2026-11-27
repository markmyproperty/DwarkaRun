import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

/// The art-pack images, decoded once and shared by every run.
///
/// Loading happens in the background at start-up. Until an image is ready,
/// [operator []] returns null and the painter draws its code-drawn fallback,
/// so the game never waits on art and tests run without decoding images.
class ArtLibrary {
  ArtLibrary._();

  static final ArtLibrary instance = ArtLibrary._();

  /// Every image the game uses, by path under `assets/images/` without the
  /// `.webp` extension.
  static const names = [
    'backgrounds/sky_india',
    'backgrounds/skyline_dwarka',
    'backgrounds/temple_hills',
    'buildings/ancient_b01',
    'buildings/ancient_b02',
    'buildings/ancient_b03',
    'buildings/ancient_b04',
    'buildings/ancient_b05',
    'buildings/ancient_b06',
    'monuments/dwarka_temple',
    'monuments/royal_fort',
    'monuments/golden_palace',
    'monuments/temple_tower',
    'monuments/ancient_gateway',
    'monuments/stone_monument',
    'props/ancient_pot',
    'props/stone_debris',
    'props/wooden_crate',
    'props/broken_pillar',
    'props/ancient_torch',
    'props/marigold_pot',
    'props/golden_vase',
    'props/stone_pillar',
    'backgrounds/coastal_background',
    'monuments/sacred_shrine',
    'river/coastal_steps',
    'river/boat_side',
    'river/water_rock',
    'river/sea_pillar',
    'river/water_splash',
    'river/coastal_lamp',
  ];

  final Map<String, ui.Image> _images = {};
  final Map<String, ui.Rect> _src = {};
  Future<void>? _loading;

  bool get loaded => _images.length == names.length;

  ui.Image? operator [](String name) => _images[name];

  /// The whole-image source rectangle, made once per image.
  ui.Rect? src(String name) => _src[name];

  /// Starts loading (once). Images that fail to load are skipped, and the
  /// painter keeps its fallback for them.
  Future<void> load([AssetBundle? bundle]) => _loading ??= _loadAll(bundle ?? rootBundle);

  Future<void> _loadAll(AssetBundle bundle) async {
    for (final name in names) {
      try {
        final data = await bundle.load('assets/images/$name.webp');
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        _images[name] = frame.image;
        _src[name] = ui.Rect.fromLTWH(0, 0, frame.image.width.toDouble(), frame.image.height.toDouble());
      } catch (_) {
        // Keep the code-drawn fallback for this one.
      }
    }
  }
}
