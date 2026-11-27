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
  garlandBeam(Clearance.slide, height: 1.1, depth: 0.5);

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
  /// code when null or not loaded yet.
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
