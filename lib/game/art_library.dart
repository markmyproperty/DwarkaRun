import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import 'realm.dart';
import 'stage_art.dart';

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
  static final names = [
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
    'monuments/ancient_stepwell',
    'monuments/royal_treasure_temple',
    'monuments/lost_temple_ruins',
    'props/stone_arch',
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
    for (var i = 1; i <= 16; i++) 'hero/run_${i.toString().padLeft(2, '0')}',
  ];

  final Map<String, ui.Image> _images = {};
  final Map<String, ui.Rect> _src = {};
  final Map<String, Future<void>> _pending = {};
  Future<void>? _loading;
  AssetBundle? _bundle;

  bool get loaded => names.every(_images.containsKey);

  /// Whether every image of [realm]'s art pack is ready.
  bool stageLoaded(Realm realm) => StageArt.of(realm)?.names(realm).every(_images.containsKey) ?? loaded;

  ui.Image? operator [](String name) => _images[name];

  /// The whole-image source rectangle, made once per image.
  ui.Rect? src(String name) => _src[name];

  /// Starts loading (once). Images that fail to load are skipped, and the
  /// painter keeps its fallback for them.
  Future<void> load([AssetBundle? bundle]) {
    _bundle ??= bundle;
    return _loading ??= _loadAll(names);
  }

  /// Loads the art pack of a later stage (stage 3 onwards) and lets go
  /// of other stages' packs, so only one stage's images are held at a time.
  Future<void> loadStage(Realm realm, [AssetBundle? bundle]) {
    if (_loading == null) return Future.value(); // Art is off (tests).
    _bundle ??= bundle;
    final stage = StageArt.of(realm);
    if (stage == null) return load();
    final want = stage.names(realm);
    for (final name in _images.keys.toList()) {
      if (_isStageImage(name) && !want.contains(name)) {
        _images.remove(name)?.dispose();
        _src.remove(name);
      }
    }
    return _loadAll(want);
  }

  static bool _isStageImage(String name) => name.split('/').length > 2;

  Future<void> _loadAll(Iterable<String> list) async {
    for (final name in list) {
      if (_images.containsKey(name)) continue;
      await (_pending[name] ??= _loadOne(name));
    }
  }

  Future<void> _loadOne(String name) async {
    try {
      final data = await (_bundle ?? rootBundle).load('assets/images/$name.webp');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      _images[name] = frame.image;
      _src[name] = ui.Rect.fromLTWH(0, 0, frame.image.width.toDouble(), frame.image.height.toDouble());
    } catch (_) {
      // Keep the code-drawn fallback for this one.
    } finally {
      _pending.remove(name);
    }
  }
}
