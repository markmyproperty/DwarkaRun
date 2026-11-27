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

/// One stage of the adventure. The order of the values is the final stage
/// order from the master brief; do not reorder.
enum Realm {
  ayodhya(
    id: 'ayodhya',
    targetMetres: 1500,
    playable: true,
    obstacles: [
      ObstacleKind.clayPot,
      ObstacleKind.garlandBeam,
      ObstacleKind.woodenCrate,
      ObstacleKind.stoneDebris,
      ObstacleKind.brokenPillar,
      ObstacleKind.marketCart,
      ObstacleKind.monkey,
    ],
    palette: RealmPalette(
      skyTop: Color(0xFF9FD3F2),
      skyBottom: Color(0xFFFCE7C8),
      haze: Color(0xFFFFEBD2),
      ground: Color(0xFFE6C79E),
      groundFar: Color(0xFFF1DDBE),
      pathA: Color(0xFFE9CFA6),
      pathB: Color(0xFFE0C194),
      pathEdge: Color(0xFFB9A78E),
      foliageDark: Color(0xFF5C9F99),
      foliageLight: Color(0xFFBDE8D9),
      stone: Color(0xFFE9CFA6),
      stoneDark: Color(0xFFB9A78E),
    ),
  ),
  ganga(
    id: 'ganga',
    targetMetres: 1500,
    playable: false,
    obstacles: [ObstacleKind.fallenPillar, ObstacleKind.lowBranch, ObstacleKind.marketCart],
    palette: RealmPalette(
      skyTop: Color(0xFFF2A65A),
      skyBottom: Color(0xFFFCE3B0),
      haze: Color(0xFFF8D9A8),
      ground: Color(0xFF3F7F8C),
      groundFar: Color(0xFF6FA6AE),
      pathA: Color(0xFFD8B98C),
      pathB: Color(0xFFC9A97A),
      pathEdge: Color(0xFFA88A62),
      foliageDark: Color(0xFF2E5C47),
      foliageLight: Color(0xFF5D8C5A),
      stone: Color(0xFFD8B98C),
      stoneDark: Color(0xFFA88A62),
    ),
  ),
  pharaoh(
    id: 'pharaoh',
    targetMetres: 1600,
    playable: false,
    obstacles: [ObstacleKind.fallenPillar, ObstacleKind.lowBranch, ObstacleKind.marketCart],
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
  himalayan(
    id: 'himalayan',
    targetMetres: 1600,
    playable: false,
    obstacles: [ObstacleKind.fallenPillar, ObstacleKind.lowBranch, ObstacleKind.marketCart],
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
  vijayanagar(
    id: 'vijayanagar',
    targetMetres: 1700,
    playable: false,
    obstacles: [ObstacleKind.fallenPillar, ObstacleKind.lowBranch, ObstacleKind.marketCart],
    palette: RealmPalette(
      skyTop: Color(0xFF8EC5E8),
      skyBottom: Color(0xFFFBE3C4),
      haze: Color(0xFFF6DDBE),
      ground: Color(0xFFC9A27A),
      groundFar: Color(0xFFD9B892),
      pathA: Color(0xFFC2A07E),
      pathB: Color(0xFFB39070),
      pathEdge: Color(0xFF8C6B4F),
      foliageDark: Color(0xFF5E7A3A),
      foliageLight: Color(0xFF8FA65A),
      stone: Color(0xFFB59C80),
      stoneDark: Color(0xFF86705A),
    ),
  ),
  dragonValley(
    id: 'dragon',
    targetMetres: 1700,
    playable: false,
    obstacles: [ObstacleKind.fallenPillar, ObstacleKind.lowBranch, ObstacleKind.marketCart],
    palette: RealmPalette(
      skyTop: Color(0xFF3A1F3D),
      skyBottom: Color(0xFFE8865A),
      haze: Color(0xFFF0A070),
      ground: Color(0xFF4A2E2E),
      groundFar: Color(0xFF6B3F35),
      pathA: Color(0xFF6E5A52),
      pathB: Color(0xFF5E4C45),
      pathEdge: Color(0xFF3E302B),
      foliageDark: Color(0xFF2E3A2A),
      foliageLight: Color(0xFF4F5E3A),
      stone: Color(0xFF7A6A62),
      stoneDark: Color(0xFF4E423D),
    ),
  ),
  lanka(
    id: 'lanka',
    targetMetres: 1800,
    playable: false,
    obstacles: [ObstacleKind.fallenPillar, ObstacleKind.lowBranch, ObstacleKind.marketCart],
    palette: RealmPalette(
      skyTop: Color(0xFF6FC1E0),
      skyBottom: Color(0xFFFCE7B0),
      haze: Color(0xFFFBE2B8),
      ground: Color(0xFF6FAF6A),
      groundFar: Color(0xFF8CC47E),
      pathA: Color(0xFFF2C94C),
      pathB: Color(0xFFE5B83A),
      pathEdge: Color(0xFFC7952A),
      foliageDark: Color(0xFF2F7A4A),
      foliageLight: Color(0xFF5BAF6A),
      stone: Color(0xFFF7E3A8),
      stoneDark: Color(0xFFD9AE58),
    ),
  ),
  indus(
    id: 'indus',
    targetMetres: 1800,
    playable: false,
    obstacles: [ObstacleKind.fallenPillar, ObstacleKind.lowBranch, ObstacleKind.marketCart],
    palette: RealmPalette(
      skyTop: Color(0xFFA8C8DC),
      skyBottom: Color(0xFFF3E2C8),
      haze: Color(0xFFEEDCC2),
      ground: Color(0xFFC9935F),
      groundFar: Color(0xFFD8A877),
      pathA: Color(0xFFB8784A),
      pathB: Color(0xFFA86C42),
      pathEdge: Color(0xFF7E5032),
      foliageDark: Color(0xFF6B7A3A),
      foliageLight: Color(0xFF9AA552),
      stone: Color(0xFFC08458),
      stoneDark: Color(0xFF8E5E3C),
    ),
  ),
  sunkenDwarka(
    id: 'sunken',
    targetMetres: 1900,
    playable: false,
    obstacles: [ObstacleKind.fallenPillar, ObstacleKind.lowBranch, ObstacleKind.marketCart],
    palette: RealmPalette(
      skyTop: Color(0xFF0F4C6E),
      skyBottom: Color(0xFF3FA3B8),
      haze: Color(0xFF6FC0CC),
      ground: Color(0xFF1E6F7A),
      groundFar: Color(0xFF2E8C93),
      pathA: Color(0xFFD9C08A),
      pathB: Color(0xFFCBB07A),
      pathEdge: Color(0xFF9C8455),
      foliageDark: Color(0xFF1F5E5A),
      foliageLight: Color(0xFF5C9F99),
      stone: Color(0xFFE3C98F),
      stoneDark: Color(0xFFB39A62),
    ),
  ),
  finalLegend(
    id: 'finale',
    targetMetres: 2000,
    playable: false,
    obstacles: [ObstacleKind.fallenPillar, ObstacleKind.lowBranch, ObstacleKind.marketCart],
    palette: RealmPalette(
      skyTop: Color(0xFF2A2468),
      skyBottom: Color(0xFFF4C98A),
      haze: Color(0xFFF7DDB0),
      ground: Color(0xFFD9AE58),
      groundFar: Color(0xFFF2D58F),
      pathA: Color(0xFFF2C94C),
      pathB: Color(0xFFE5B83A),
      pathEdge: Color(0xFFC7952A),
      foliageDark: Color(0xFF5C9F99),
      foliageLight: Color(0xFF87C7D8),
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
