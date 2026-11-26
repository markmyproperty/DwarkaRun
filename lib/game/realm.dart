import 'dart:ui';

import 'entities.dart';

/// The colours a realm is painted with. All art is drawn in code, so a realm's
/// look is this palette plus its scenery painter.
class RealmPalette {
  const RealmPalette({
    required this.skyTop,
    required this.skyBottom,
    required this.haze,
    required this.ground,
    required this.groundFar,
    required this.pathA,
    required this.pathB,
    required this.pathEdge,
    required this.foliageDark,
    required this.foliageLight,
    required this.stone,
    required this.stoneDark,
  });

  final Color skyTop;
  final Color skyBottom;
  final Color haze;
  final Color ground;
  final Color groundFar;
  final Color pathA;
  final Color pathB;
  final Color pathEdge;
  final Color foliageDark;
  final Color foliageLight;
  final Color stone;
  final Color stoneDark;
}

/// One stage of the yatra. The order of the values is the order of the trip.
enum Realm {
  forest(
    id: 'forest',
    targetMetres: 1500,
    playable: true,
    obstacles: [
      ObstacleKind.fallenPillar,
      ObstacleKind.lowBranch,
      ObstacleKind.stoneWheel,
      ObstacleKind.ropeBarrier,
      ObstacleKind.firePit,
      ObstacleKind.monkey,
    ],
    palette: RealmPalette(
      skyTop: Color(0xFF7FB7C9),
      skyBottom: Color(0xFFF6E3B4),
      haze: Color(0xFFDCE8C8),
      ground: Color(0xFF4F7A3A),
      groundFar: Color(0xFF7FA05A),
      pathA: Color(0xFFC9A878),
      pathB: Color(0xFFB8956A),
      pathEdge: Color(0xFF8C6B47),
      foliageDark: Color(0xFF2F5A2A),
      foliageLight: Color(0xFF5E8C3F),
      stone: Color(0xFFB9AE98),
      stoneDark: Color(0xFF857B69),
    ),
  ),
  river(
    id: 'river',
    targetMetres: 1200,
    playable: false,
    obstacles: [ObstacleKind.fallenPillar],
    palette: RealmPalette(
      skyTop: Color(0xFFF2A65A),
      skyBottom: Color(0xFFFCE3B0),
      haze: Color(0xFFF8D9A8),
      ground: Color(0xFF3F7F8C),
      groundFar: Color(0xFF6FA6AE),
      pathA: Color(0xFF8A6A4A),
      pathB: Color(0xFF7A5B3E),
      pathEdge: Color(0xFF5C4430),
      foliageDark: Color(0xFF2E5C47),
      foliageLight: Color(0xFF5D8C5A),
      stone: Color(0xFFD8B98C),
      stoneDark: Color(0xFFA88A62),
    ),
  ),
  desert(
    id: 'desert',
    targetMetres: 1600,
    playable: false,
    obstacles: [ObstacleKind.fallenPillar],
    palette: RealmPalette(
      skyTop: Color(0xFF6FA8DC),
      skyBottom: Color(0xFFFBE7C0),
      haze: Color(0xFFF5DCB0),
      ground: Color(0xFFE2B66E),
      groundFar: Color(0xFFEFCB8B),
      pathA: Color(0xFFD49A5A),
      pathB: Color(0xFFC88B4C),
      pathEdge: Color(0xFFA06A35),
      foliageDark: Color(0xFF6B7A3A),
      foliageLight: Color(0xFF9AA552),
      stone: Color(0xFFD9935A),
      stoneDark: Color(0xFFA9683A),
    ),
  ),
  himalaya(
    id: 'himalaya',
    targetMetres: 1700,
    playable: false,
    obstacles: [ObstacleKind.fallenPillar],
    palette: RealmPalette(
      skyTop: Color(0xFF5B8FC7),
      skyBottom: Color(0xFFDDEBF5),
      haze: Color(0xFFE8F0F6),
      ground: Color(0xFFF2F5F8),
      groundFar: Color(0xFFDDE6EE),
      pathA: Color(0xFFBFD3E3),
      pathB: Color(0xFFAFC6D9),
      pathEdge: Color(0xFF8AA4BB),
      foliageDark: Color(0xFF2F5249),
      foliageLight: Color(0xFF4F7A6C),
      stone: Color(0xFF9AA3AD),
      stoneDark: Color(0xFF6E7781),
    ),
  ),
  celestial(
    id: 'celestial',
    targetMetres: 1800,
    playable: false,
    obstacles: [ObstacleKind.fallenPillar],
    palette: RealmPalette(
      skyTop: Color(0xFF3A2A6E),
      skyBottom: Color(0xFFF4C98A),
      haze: Color(0xFFF7DDB0),
      ground: Color(0xFFF7E6C4),
      groundFar: Color(0xFFFFF1D6),
      pathA: Color(0xFFF2C94C),
      pathB: Color(0xFFE5B83A),
      pathEdge: Color(0xFFC7952A),
      foliageDark: Color(0xFFB98ED6),
      foliageLight: Color(0xFFDAB8EE),
      stone: Color(0xFFFFF4DC),
      stoneDark: Color(0xFFE6CFA0),
    ),
  );

  const Realm({
    required this.id,
    required this.targetMetres,
    required this.playable,
    required this.obstacles,
    required this.palette,
  });

  /// Stable id, used in saved progress and widget keys.
  final String id;

  /// Distance that completes the realm.
  final int targetMetres;

  /// Whether this build can run the realm yet.
  final bool playable;

  /// Obstacles that appear in this realm.
  final List<ObstacleKind> obstacles;

  final RealmPalette palette;

  /// The realm after this one, or null for the last.
  Realm? get next => index + 1 < Realm.values.length ? Realm.values[index + 1] : null;

  static Realm? byId(String id) {
    for (final r in Realm.values) {
      if (r.id == id) return r;
    }
    return null;
  }
}
