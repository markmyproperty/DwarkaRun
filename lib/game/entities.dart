/// How the hero gets past an obstacle.
enum Clearance {
  /// Jump over it.
  jump,

  /// Slide under it.
  slide,

  /// Change lane. Blocks the whole lane.
  lane,

  /// Not a crash: a playful monkey that snatches a few coins.
  steal,
}

/// Original, themed obstacles. None of them depict a deity or carry a
/// religious symbol.
enum ObstacleKind {
  fallenPillar(Clearance.jump, height: 0.8, depth: 1.0),
  lowBranch(Clearance.slide, height: 1.1, depth: 0.8),
  stoneWheel(Clearance.lane, height: 2.0, depth: 0.8, speed: 5),
  ropeBarrier(Clearance.jump, height: 0.9, depth: 0.4),
  firePit(Clearance.jump, height: 0.5, depth: 1.4),
  marketCart(Clearance.lane, height: 2.1, depth: 2.2),
  monkey(Clearance.steal, height: 0.9, depth: 0.6),

  // Ancient Dwarka street obstacles, drawn from the art pack.
  clayPot(Clearance.jump, height: 0.9, depth: 0.9, sprite: 'props/ancient_pot', spriteWidth: 1.4),
  stoneDebris(Clearance.jump, height: 0.7, depth: 1.2, sprite: 'props/stone_debris', spriteWidth: 2.0),
  woodenCrate(Clearance.lane, height: 1.6, depth: 1.4, sprite: 'props/wooden_crate', spriteWidth: 2.0),
  brokenPillar(Clearance.lane, height: 2.6, depth: 1.0, sprite: 'props/broken_pillar', spriteWidth: 1.9),
  garlandBeam(Clearance.slide, height: 1.1, depth: 0.5),

  // Ganga Run.
  stoneSteps(Clearance.jump, height: 0.65, depth: 1.6),
  hangingLanterns(Clearance.slide, height: 1.1, depth: 0.5),

  // Thar Desert Run (stage 3; internal id "pharaoh", art from the Egyptian desert pack for now).
  sandBoulder(
    Clearance.lane,
    height: 2.0,
    depth: 1.0,
    speed: 5,
    sprite: 'pharaoh/props/rolling_boulder',
    spriteWidth: 2.1,
  ),
  brokenColumn(Clearance.lane, height: 2.4, depth: 1.0, sprite: 'pharaoh/props/broken_column', spriteWidth: 2.0),
  stoneBlocks(Clearance.jump, height: 0.7, depth: 1.0, sprite: 'pharaoh/props/stone_block', spriteWidth: 2.0),
  spikeTrap(Clearance.jump, height: 0.65, depth: 1.2, sprite: 'pharaoh/props/spike_trap', spriteWidth: 1.8),
  sandPit(Clearance.jump, height: 0.3, depth: 1.6, sprite: 'pharaoh/props/sand_pit', spriteWidth: 2.2),
  collapsingTiles(Clearance.jump, height: 0.3, depth: 1.6, sprite: 'pharaoh/props/collapsing_tiles', spriteWidth: 2.2),
  bladeGate(Clearance.slide, height: 1.1, depth: 0.6, sprite: 'pharaoh/props/swinging_blades'),

  // Himalayan Run.
  snowBoulder(
    Clearance.lane,
    height: 2.0,
    depth: 1.0,
    speed: 5,
    sprite: 'himalayan/props/snow_boulder',
    spriteWidth: 2.0,
  ),
  fallenRocks(Clearance.lane, height: 1.8, depth: 1.2, sprite: 'himalayan/props/falling_rock', spriteWidth: 2.2),
  snowCrate(Clearance.lane, height: 1.6, depth: 1.4, sprite: 'himalayan/props/wooden_crate_snow', spriteWidth: 2.0),
  snowMound(Clearance.jump, height: 0.6, depth: 1.0, sprite: 'himalayan/props/snow_gap_mound', spriteWidth: 2.3),
  crackedIce(Clearance.jump, height: 0.5, depth: 1.4, sprite: 'himalayan/props/breaking_ice', spriteWidth: 2.3),
  icicles(Clearance.slide, height: 1.1, depth: 0.5, sprite: 'himalayan/props/falling_icicle'),

  // Vijayanagar Run.
  graniteBoulder(
    Clearance.lane,
    height: 2.0,
    depth: 1.0,
    speed: 5,
    sprite: 'vijayanagar/props/rolling_boulder',
    spriteWidth: 2.1,
  ),
  leaningPillar(
    Clearance.lane,
    height: 2.8,
    depth: 1.0,
    sprite: 'vijayanagar/props/collapsing_pillar',
    spriteWidth: 1.7,
  ),
  fallenLintel(Clearance.lane, height: 2.2, depth: 1.4, sprite: 'vijayanagar/props/falling_lintel', spriteWidth: 2.8),
  oxCart(Clearance.lane, height: 1.6, depth: 2.0, sprite: 'vijayanagar/props/wooden_cart', spriteWidth: 2.6),
  bazaarPot(Clearance.jump, height: 0.9, depth: 0.9, sprite: 'vijayanagar/props/bazaar_pot', spriteWidth: 1.3),
  graniteRubble(Clearance.jump, height: 0.7, depth: 1.2, sprite: 'props/stone_debris', spriteWidth: 2.0),
  mandapaBeam(Clearance.slide, height: 1.1, depth: 0.5, sprite: 'vijayanagar/props/stone_column'),

  // Lanka Run: a golden palace-fortress. No sacred figures anywhere.
  goldenBlock(Clearance.jump, height: 0.6, depth: 1.0, sprite: 'lanka/props/golden_block', spriteWidth: 2.2),
  gardenPot(Clearance.jump, height: 0.9, depth: 0.9, sprite: 'lanka/props/garden_pot', spriteWidth: 1.4),
  flamingArrows(Clearance.slide, height: 1.1, depth: 0.5, sprite: 'lanka/props/flaming_arrows'),
  bladeTrap(Clearance.lane, height: 2.0, depth: 1.2, sprite: 'lanka/props/rotating_blades', spriteWidth: 2.3),
  turretPillar(
    Clearance.lane,
    height: 2.8,
    depth: 1.0,
    sprite: 'lanka/props/collapsing_palace_pillar',
    spriteWidth: 1.6,
  ),
  closingGate(Clearance.lane, height: 2.6, depth: 0.8, sprite: 'lanka/props/closing_golden_gate', spriteWidth: 2.5);

  const ObstacleKind(
    this.clearance, {
    required this.height,
    required this.depth,
    this.speed = 0,
    this.sprite,
    this.spriteWidth = 2.0,
  });

  final Clearance clearance;

  /// For jump obstacles: the hero's feet must be above this (metres).
  /// For slide obstacles: the underside of the obstacle.
  final double height;

  /// Length along the track (metres).
  final double depth;

  /// Extra speed towards the hero (metres per second), for rolling things.
  final double speed;

  /// Art-pack image (path under assets/images, without extension). Drawn in
  /// code when null or not loaded yet. Slide obstacles use it as a part
  /// (blades, icicles, posts) of a frame drawn over the lane.
  final String? sprite;

  /// Width of the sprite on the path (metres).
  final double spriteWidth;
}

/// A pooled obstacle. Instances are reused; [active] says if it is in play.
class Obstacle {
  bool active = false;
  ObstacleKind kind = ObstacleKind.fallenPillar;

  /// Lane: -1 left, 0 centre, 1 right.
  int lane = 0;

  /// Distance along the track (metres).
  double z = 0;

  /// Set once the hero has hit or been robbed by it, so it only counts once.
  bool spent = false;

  /// Per-obstacle variety for the painter (0..1).
  double variant = 0;

  void spawn(ObstacleKind k, int l, double atZ, double v) {
    active = true;
    kind = k;
    lane = l;
    z = atZ;
    spent = false;
    variant = v;
  }
}

enum PickupKind {
  /// Gold coin (mudra).
  coin,

  /// Rare gem, worth [gemValue] mudra.
  gem,

  /// Garuda feather: one boost charge (a short, invincible flight).
  feather,

  /// Lotus charm: a coin magnet for a few seconds.
  lotus,
}

const int gemValue = 20;

/// A pooled pickup.
class Pickup {
  bool active = false;
  PickupKind kind = PickupKind.coin;
  double x = 0;
  double y = 0.6;
  double z = 0;

  void spawn(PickupKind k, double atX, double atY, double atZ) {
    active = true;
    kind = k;
    x = atX;
    y = atY;
    z = atZ;
  }
}

/// What a river surface is made of. They all carry the hero the same way.
enum PlatformKind { plank, boat, bridge }

/// A pooled stretch of walkable surface over water, in one lane.
class Platform {
  bool active = false;
  PlatformKind kind = PlatformKind.plank;
  int lane = 0;

  /// Near and far ends along the track (metres).
  double z0 = 0;
  double z1 = 0;

  /// Per-platform variety for the painter (0..1).
  double variant = 0;

  void spawn(PlatformKind k, int l, double from, double to, double v) {
    active = true;
    kind = k;
    lane = l;
    z0 = from;
    z1 = to;
    variant = v;
  }

  bool covers(double z, [double tolerance = 0]) => active && z >= z0 - tolerance && z <= z1 + tolerance;
}
