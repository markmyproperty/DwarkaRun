import 'realm.dart';

/// One art-pack image placed in the world: its path under `assets/images/`
/// (no extension) and its width in metres.
class Piece {
  const Piece(this.name, this.width);

  final String name;
  final double width;
}

/// How an art-pack stage is dressed: sky, horizon bands, the houses along
/// the path, monuments set well back, wild scenery and kerb props.
///
/// Temples, shrines and monuments only ever appear as a backdrop, never on
/// the path and never as something to hit.
class StageArt {
  const StageArt({
    required this.sky,
    required this.farBand,
    required this.nearBand,
    required this.postcard,
    required this.buildings,
    required this.monuments,
    required this.wild,
    required this.kerb,
    this.buildingWidth = 7.0,
    this.buildingChance = 0.62,
    this.gapWild = const [],
    this.extra = const [],
  });

  final String sky;

  /// Bottom-aligned strips along the horizon, far and near.
  final String farBand;
  final String nearBand;

  /// Backdrop shown on the hub card.
  final String postcard;

  final List<String> buildings;
  final double buildingWidth;

  /// How often a side of the path gets a house (0..1).
  final double buildingChance;

  final List<Piece> monuments;

  /// Trees, rocks and dunes, between the houses and the monuments.
  final List<Piece> wild;

  /// Small decorations right beside the path.
  final List<Piece> kerb;

  /// Scenery beside a crevasse or river stretch, where there are no houses.
  final List<Piece> gapWild;

  /// Other images the stage uses (obstacle sprites are added automatically).
  final List<String> extra;

  /// Every image this stage needs, for loading.
  Set<String> names(Realm realm) => {
    sky,
    farBand,
    nearBand,
    ...buildings,
    for (final p in monuments) p.name,
    for (final p in wild) p.name,
    for (final p in kerb) p.name,
    for (final p in gapWild) p.name,
    ...extra,
    if (realm == Realm.lanka) 'lanka/props/golden_column',
    for (final o in realm.obstacles)
      if (o.sprite != null) o.sprite!,
  };

  static StageArt? of(Realm realm) => _byRealm[realm];

  static const _byRealm = {
    Realm.sunkenDwarka: StageArt(
      sky: 'sunken/backgrounds/sky_sunken',
      farBand: 'sunken/backgrounds/reef_ridge',
      nearBand: 'sunken/backgrounds/skyline_sunken',
      postcard: 'sunken/backgrounds/sunken_city_background',
      buildings: [
        'sunken/buildings/sunken_b01',
        'sunken/buildings/sunken_b02',
        'sunken/buildings/sunken_b03',
        'sunken/buildings/sunken_b04',
        'sunken/buildings/sunken_b05',
        'sunken/buildings/sunken_b06',
      ],
      monuments: [
        Piece('sunken/monuments/submerged_palace', 24),
        Piece('sunken/monuments/coral_tower', 8),
        Piece('sunken/monuments/reef_citadel', 22),
        Piece('sunken/monuments/sunken_palace_gate', 12),
        Piece('sunken/monuments/sunken_pavilion', 18),
        Piece('sunken/monuments/submerged_courtyard', 22),
        Piece('sunken/monuments/sea_cave_hall', 20),
        Piece('sunken/monuments/ocean_tunnel', 14),
      ],
      wild: [
        Piece('sunken/env/coral_cluster', 5),
        Piece('sunken/env/kelp', 2.6),
        Piece('sunken/env/sea_fan', 4),
        Piece('sunken/env/seafloor_rocks', 6),
        Piece('sunken/env/anemone', 2),
        Piece('sunken/env/shell_bed', 5),
      ],
      kerb: [
        Piece('sunken/env/bubble_vent', 1.2),
        Piece('sunken/props/kelp_curtain', 1.0),
        Piece('sunken/env/anemone', 1.3),
      ],
      gapWild: [
        Piece('sunken/env/coral_cluster', 6),
        Piece('sunken/monuments/whirlpool_basin', 12),
        Piece('sunken/env/kelp', 3),
        Piece('sunken/monuments/coral_bridge', 18),
        Piece('sunken/env/sea_fan', 4.5),
      ],
    ),
    Realm.finalLegend: StageArt(
      sky: 'finale/backgrounds/sky_final',
      farBand: 'finale/backgrounds/coastal_ridge',
      nearBand: 'finale/backgrounds/skyline_final',
      postcard: 'finale/backgrounds/golden_city_background',
      buildings: [
        'finale/buildings/golden_b01',
        'finale/buildings/golden_b02',
        'finale/buildings/golden_b03',
        'finale/buildings/golden_b04',
        'finale/buildings/golden_b05',
        'finale/buildings/golden_b06',
      ],
      monuments: [
        Piece('finale/monuments/golden_city_palace', 26),
        Piece('finale/monuments/golden_spire_tower', 7),
        Piece('finale/monuments/golden_city_gate', 14),
        Piece('finale/monuments/waterfront_terrace', 22),
        Piece('finale/monuments/sun_court', 20),
        Piece('finale/monuments/treasury_vault', 14),
        Piece('finale/monuments/final_relic_chamber', 16),
      ],
      wild: [
        Piece('finale/env/gold_garden', 5),
        Piece('finale/env/palace_tree', 3.6),
        Piece('finale/env/gold_planter', 2.6),
        Piece('finale/env/palace_tree', 4.4),
      ],
      kerb: [
        Piece('finale/props/golden_lantern', 0.9),
        Piece('finale/props/ceremonial_urn', 0.9),
        Piece('finale/env/gold_planter', 1.2),
      ],
      gapWild: [
        Piece('finale/monuments/underwater_palace', 24),
        Piece('finale/env/coral_garden', 5),
        Piece('finale/monuments/giant_submerged_gateway', 16),
        Piece('finale/env/seafloor_rocks', 6),
        Piece('finale/monuments/underwater_colonnade', 22),
        Piece('finale/env/kelp', 3),
      ],
    ),
    Realm.lanka: StageArt(
      sky: 'lanka/backgrounds/sky_lanka',
      farBand: 'lanka/backgrounds/tropical_hills',
      nearBand: 'lanka/backgrounds/skyline_lanka',
      postcard: 'lanka/backgrounds/palace_valley_background',
      buildings: [
        'lanka/buildings/lanka_b01',
        'lanka/buildings/lanka_b02',
        'lanka/buildings/lanka_b03',
        'lanka/buildings/lanka_b04',
        'lanka/buildings/lanka_b05',
        'lanka/buildings/lanka_b06',
      ],
      monuments: [
        Piece('lanka/monuments/golden_palace', 24),
        Piece('lanka/monuments/golden_tower', 7),
        Piece('lanka/monuments/island_citadel', 22),
        Piece('lanka/monuments/royal_pavilion', 20),
        Piece('lanka/monuments/grand_palace_gate', 12),
        Piece('lanka/monuments/garden_terrace', 18),
        Piece('lanka/monuments/palace_courtyard', 22),
        Piece('lanka/monuments/palace_stairs', 14),
      ],
      wild: [
        Piece('lanka/env/palm_cluster', 4.5),
        Piece('lanka/env/tropical_foliage', 3.6),
        Piece('lanka/env/flowering_shrubs', 5),
        Piece('lanka/env/garden_hedge', 6),
        Piece('lanka/env/palace_fountain', 4.5),
        Piece('lanka/env/palm_cluster', 5.5),
      ],
      kerb: [
        Piece('lanka/props/flaming_brazier', 1.1),
        Piece('lanka/props/golden_column', 0.8),
        Piece('lanka/env/grass_scrub', 1.4),
      ],
      gapWild: [
        Piece('lanka/env/coastal_rocks', 6),
        Piece('lanka/monuments/water_palace', 22),
        Piece('lanka/env/palm_cluster', 4.5),
        Piece('lanka/monuments/fortress_bridge', 20),
        Piece('lanka/env/coastal_rocks', 4),
      ],
    ),
    Realm.pharaoh: StageArt(
      sky: 'pharaoh/backgrounds/sky_egypt',
      farBand: 'pharaoh/backgrounds/desert_hills',
      nearBand: 'pharaoh/backgrounds/skyline_egypt',
      postcard: 'pharaoh/backgrounds/pyramid_valley_background',
      buildings: [
        'pharaoh/buildings/egypt_b01',
        'pharaoh/buildings/egypt_b02',
        'pharaoh/buildings/egypt_b03',
        'pharaoh/buildings/egypt_b04',
        'pharaoh/buildings/egypt_b05',
        'pharaoh/buildings/egypt_b06',
      ],
      buildingChance: 0.5,
      monuments: [
        Piece('pharaoh/monuments/great_pyramid', 34),
        Piece('pharaoh/monuments/sphinx_monument', 18),
        Piece('pharaoh/monuments/temple_pylon', 22),
        Piece('pharaoh/monuments/temple_obelisk', 3.6),
        Piece('pharaoh/monuments/stepped_pyramid', 26),
        Piece('pharaoh/monuments/sandstone_temple', 22),
        Piece('pharaoh/monuments/pharaoh_tomb', 16),
        Piece('pharaoh/monuments/valley_temple', 32),
        Piece('pharaoh/monuments/treasure_chamber', 15),
        Piece('pharaoh/monuments/hieroglyph_corridor', 10),
      ],
      wild: [
        Piece('pharaoh/env/palm_cluster', 4.5),
        Piece('pharaoh/env/sand_dune', 9),
        Piece('pharaoh/env/desert_rock', 3.2),
        Piece('pharaoh/env/papyrus_clump', 2.6),
        Piece('pharaoh/env/oasis_pool', 9),
        Piece('pharaoh/env/dune_crest', 6),
      ],
      kerb: [
        Piece('pharaoh/props/oil_lamp', 0.7),
        Piece('pharaoh/props/alabaster_vase', 0.8),
        Piece('pharaoh/props/lotus_column', 1.0),
        Piece('pharaoh/env/desert_pillar', 1.0),
      ],
    ),
    Realm.himalayan: StageArt(
      sky: 'himalayan/backgrounds/sky_himalaya',
      farBand: 'himalayan/backgrounds/mountain_ridge',
      nearBand: 'himalayan/backgrounds/skyline_himalaya',
      postcard: 'himalayan/backgrounds/valley_background',
      buildings: [
        'himalayan/buildings/himalaya_b01',
        'himalayan/buildings/himalaya_b02',
        'himalayan/buildings/himalaya_b03',
        'himalayan/buildings/himalaya_b04',
        'himalayan/buildings/himalaya_b05',
        'himalayan/buildings/himalaya_b06',
      ],
      monuments: [
        Piece('himalayan/monuments/mountain_monastery', 15),
        Piece('himalayan/monuments/village_gate', 10),
        Piece('himalayan/monuments/hilltop_gompa', 15),
        Piece('himalayan/monuments/mountain_watchtower', 7),
        Piece('himalayan/monuments/prayer_hall', 24),
        Piece('himalayan/monuments/snow_stupa', 9),
        Piece('himalayan/monuments/cliff_monastery', 14),
        Piece('himalayan/monuments/waterfall_shrine', 10),
        Piece('himalayan/monuments/high_pass_gate', 14),
      ],
      wild: [
        Piece('himalayan/env/pine_cluster', 4.5),
        Piece('himalayan/env/snow_bank', 7),
        Piece('himalayan/env/ice_rock', 3),
        Piece('himalayan/props/ice_crystal', 1.8),
        Piece('himalayan/env/pine_cluster', 5.5),
      ],
      kerb: [
        Piece('himalayan/props/mountain_lantern', 1.1),
        Piece('himalayan/props/prayer_flag_pole', 0.8),
        Piece('himalayan/props/stone_cairn', 1.0),
      ],
      gapWild: [
        Piece('himalayan/env/snow_cliff', 11),
        Piece('himalayan/env/ice_rock', 3.5),
        Piece('himalayan/env/icicle_cluster', 2.6),
        Piece('himalayan/monuments/ice_cave_entrance', 14),
        Piece('himalayan/env/mountain_waterfall', 4),
        Piece('himalayan/env/pine_cluster', 5),
      ],
    ),
    Realm.vijayanagar: StageArt(
      sky: 'vijayanagar/backgrounds/sky_vijayanagar',
      farBand: 'vijayanagar/backgrounds/granite_hills',
      nearBand: 'vijayanagar/backgrounds/skyline_hampi',
      postcard: 'vijayanagar/backgrounds/temple_valley_background',
      buildings: [
        'vijayanagar/buildings/vijayanagar_b01',
        'vijayanagar/buildings/vijayanagar_b02',
        'vijayanagar/buildings/vijayanagar_b03',
        'vijayanagar/buildings/vijayanagar_b04',
        'vijayanagar/buildings/vijayanagar_b05',
        'vijayanagar/buildings/vijayanagar_b06',
      ],
      monuments: [
        Piece('vijayanagar/monuments/temple_gopuram', 11),
        Piece('vijayanagar/monuments/royal_palace', 24),
        Piece('vijayanagar/monuments/stone_chariot', 10),
        Piece('vijayanagar/monuments/lotus_mahal', 20),
        Piece('vijayanagar/monuments/pillared_mandapa', 20),
        Piece('vijayanagar/monuments/elephant_stables', 28),
        Piece('vijayanagar/monuments/stepped_tank', 16),
        Piece('vijayanagar/monuments/boulder_shrine', 16),
        Piece('vijayanagar/monuments/stone_gateway', 12),
        Piece('vijayanagar/monuments/market_colonnade', 26),
      ],
      wild: [
        Piece('vijayanagar/env/granite_boulder_cluster', 8),
        Piece('vijayanagar/env/tree_cluster', 4.5),
        Piece('vijayanagar/env/rocky_outcrop', 8),
        Piece('vijayanagar/env/grass_scrub', 2.2),
        Piece('vijayanagar/env/fallen_boulder', 5),
        Piece('vijayanagar/env/courtyard_fountain', 4.5),
      ],
      kerb: [
        Piece('vijayanagar/props/lamp_column', 0.9),
        Piece('vijayanagar/props/stone_column', 0.8),
        Piece('vijayanagar/env/grass_scrub', 1.4),
      ],
    ),
  };
}
