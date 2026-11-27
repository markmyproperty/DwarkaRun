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

/// What the gaps in a gapped stretch are: a river, an ice crevasse, a
/// palace moat or a deep sea trench.
enum GapStyle { river, crevasse, moat, trench }

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
    playable: true,
    waterFrom: 0.38,
    bridgeFrom: 0.8,
    obstacles: [
      ObstacleKind.stoneSteps,
      ObstacleKind.hangingLanterns,
      ObstacleKind.woodenCrate,
      ObstacleKind.clayPot,
      ObstacleKind.brokenPillar,
      ObstacleKind.monkey,
    ],
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
    playable: true,
    obstacles: [
      ObstacleKind.stoneBlocks,
      ObstacleKind.bladeGate,
      ObstacleKind.brokenColumn,
      ObstacleKind.spikeTrap,
      ObstacleKind.sandBoulder,
      ObstacleKind.sandPit,
      ObstacleKind.collapsingTiles,
    ],
    palette: RealmPalette(
      skyTop: Color(0xFF8CC4EA),
      skyBottom: Color(0xFFFCE3BE),
      haze: Color(0xFFFBE3C0),
      ground: Color(0xFFF0CF9A),
      groundFar: Color(0xFFF6DDB4),
      pathA: Color(0xFFE9CFA6),
      pathB: Color(0xFFE0C094),
      pathEdge: Color(0xFFC79A5E),
      foliageDark: Color(0xFF5C9F99),
      foliageLight: Color(0xFFBDE8D9),
      stone: Color(0xFFE9CFA6),
      stoneDark: Color(0xFFC8A472),
    ),
  ),
  himalayan(
    id: 'himalayan',
    targetMetres: 1600,
    playable: true,
    waterFrom: 0.42,
    bridgeFrom: 0.84,
    gapStyle: GapStyle.crevasse,
    obstacles: [
      ObstacleKind.snowMound,
      ObstacleKind.icicles,
      ObstacleKind.snowCrate,
      ObstacleKind.crackedIce,
      ObstacleKind.fallenRocks,
      ObstacleKind.snowBoulder,
    ],
    palette: RealmPalette(
      skyTop: Color(0xFF8FC3EA),
      skyBottom: Color(0xFFE4EFF7),
      haze: Color(0xFFEAF2F8),
      ground: Color(0xFFF7FAFC),
      groundFar: Color(0xFFE3EBF2),
      pathA: Color(0xFFE6ECF3),
      pathB: Color(0xFFD9E2EC),
      pathEdge: Color(0xFFB9A78E),
      foliageDark: Color(0xFF2F5249),
      foliageLight: Color(0xFF4F7A6C),
      stone: Color(0xFFB9A78E),
      stoneDark: Color(0xFF8C7C66),
    ),
  ),
  vijayanagar(
    id: 'vijayanagar',
    targetMetres: 1700,
    playable: true,
    obstacles: [
      ObstacleKind.bazaarPot,
      ObstacleKind.mandapaBeam,
      ObstacleKind.leaningPillar,
      ObstacleKind.graniteRubble,
      ObstacleKind.oxCart,
      ObstacleKind.fallenLintel,
      ObstacleKind.graniteBoulder,
      ObstacleKind.monkey,
    ],
    palette: RealmPalette(
      skyTop: Color(0xFF9FCFEA),
      skyBottom: Color(0xFFFBE0C0),
      haze: Color(0xFFF6DDBE),
      ground: Color(0xFFD9BE94),
      groundFar: Color(0xFFE6CFAA),
      pathA: Color(0xFFD8C7AE),
      pathB: Color(0xFFCDBB9F),
      pathEdge: Color(0xFFA8957A),
      foliageDark: Color(0xFF5C7A3A),
      foliageLight: Color(0xFF8FA65A),
      stone: Color(0xFFD8C7AE),
      stoneDark: Color(0xFFA8957A),
    ),
  ),
  dragonValley(
    id: 'dragon',
    targetMetres: 1700,
    playable: true,
    obstacles: [
      ObstacleKind.stoneDebris,
      ObstacleKind.lowBranch,
      ObstacleKind.fallenPillar,
      ObstacleKind.brokenPillar,
      ObstacleKind.woodenCrate,
      ObstacleKind.graniteBoulder,
    ],
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
    targetMetres: 1700,
    playable: true,
    waterFrom: 0.45,
    bridgeFrom: 0.84,
    gapStyle: GapStyle.moat,
    obstacles: [
      ObstacleKind.goldenBlock,
      ObstacleKind.flamingArrows,
      ObstacleKind.gardenPot,
      ObstacleKind.bladeTrap,
      ObstacleKind.turretPillar,
      ObstacleKind.closingGate,
    ],
    palette: RealmPalette(
      skyTop: Color(0xFF9FD3F0),
      skyBottom: Color(0xFFFCE7C4),
      haze: Color(0xFFFBE6C8),
      ground: Color(0xFF9CCB8E),
      groundFar: Color(0xFFB8DBA8),
      pathA: Color(0xFFF2DDB4),
      pathB: Color(0xFFE9CFA0),
      pathEdge: Color(0xFFD9AE58),
      foliageDark: Color(0xFF3F8A6A),
      foliageLight: Color(0xFF8FCFA0),
      stone: Color(0xFFF2DDB4),
      stoneDark: Color(0xFFD9AE58),
    ),
  ),
  indus(
    id: 'indus',
    targetMetres: 1800,
    playable: true,
    obstacles: [
      ObstacleKind.clayPot,
      ObstacleKind.lowBranch,
      ObstacleKind.woodenCrate,
      ObstacleKind.stoneDebris,
      ObstacleKind.marketCart,
    ],
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
    targetMetres: 1800,
    playable: true,
    waterFrom: 0.48,
    bridgeFrom: 0.85,
    gapStyle: GapStyle.trench,
    obstacles: [
      ObstacleKind.seaUrchin,
      ObstacleKind.jellyfish,
      ObstacleKind.coralBlock,
      ObstacleKind.reefRubble,
      ObstacleKind.coralColumn,
      ObstacleKind.seaGate,
      ObstacleKind.whirlpool,
    ],
    palette: RealmPalette(
      skyTop: Color(0xFF4FA6B5),
      skyBottom: Color(0xFFBFE6E3),
      haze: Color(0xFFA8DCDC),
      ground: Color(0xFFE9D7B0),
      groundFar: Color(0xFFD3E6D8),
      pathA: Color(0xFFEAD8B2),
      pathB: Color(0xFFE0CBA2),
      pathEdge: Color(0xFFD9AE58),
      foliageDark: Color(0xFF3E8C84),
      foliageLight: Color(0xFF8FD0C4),
      stone: Color(0xFFEAD8B2),
      stoneDark: Color(0xFFC8B088),
    ),
  ),
  finalLegend(
    id: 'finale',
    targetMetres: 1800,
    playable: true,
    waterFrom: 0.45,
    bridgeFrom: 0.84,
    gapStyle: GapStyle.moat,
    obstacles: [
      ObstacleKind.goldenCube,
      ObstacleKind.lanternBeam,
      ObstacleKind.goldenColumn,
      ObstacleKind.seaUrchin,
      ObstacleKind.fallingMasonry,
      ObstacleKind.goldGate,
    ],
    palette: RealmPalette(
      skyTop: Color(0xFF8CC9E0),
      skyBottom: Color(0xFFFCE6B8),
      haze: Color(0xFFFBE7C4),
      ground: Color(0xFFF2DFB4),
      groundFar: Color(0xFFF6E8C8),
      pathA: Color(0xFFF7F4EE),
      pathB: Color(0xFFEDE4D2),
      pathEdge: Color(0xFFD9AE58),
      foliageDark: Color(0xFF3E8C84),
      foliageLight: Color(0xFF8FD0C4),
      stone: Color(0xFFF7F4EE),
      stoneDark: Color(0xFFD9AE58),
    ),
  );

  const Realm({
    required this.id,
    required this.targetMetres,
    required this.playable,
    required this.obstacles,
    required this.palette,
    this.waterFrom,
    this.bridgeFrom,
    this.gapStyle = GapStyle.river,
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

  /// For river stages: where the open water starts and where the bridge
  /// finale starts, as fractions of [targetMetres]. Null on dry land.
  final double? waterFrom;
  final double? bridgeFrom;

  /// What falls away under the gaps.
  final GapStyle gapStyle;

  /// Whether the stage has a gapped stretch (river or crevasse).
  bool get hasRiver => waterFrom != null;

  bool get hasCrevasse => hasRiver && gapStyle == GapStyle.crevasse;

  bool get hasMoat => hasRiver && gapStyle == GapStyle.moat;

  bool get hasTrench => hasRiver && gapStyle == GapStyle.trench;

  /// Metres at which open water starts (infinity on dry land).
  double get waterStart => waterFrom == null ? double.infinity : (waterFrom! * targetMetres).roundToDouble();

  /// Metres at which the bridge finale starts (infinity when there is none).
  double get bridgeStart => bridgeFrom == null ? double.infinity : (bridgeFrom! * targetMetres).roundToDouble();

  /// The realm after this one, or null for the last.
  Realm? get next => index + 1 < Realm.values.length ? Realm.values[index + 1] : null;

  static Realm? byId(String id) {
    for (final r in Realm.values) {
      if (r.id == id) return r;
    }
    return null;
  }
}
