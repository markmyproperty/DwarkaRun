import 'realm.dart';

/// Top-down running-track tiles for a stage, under `assets/images/tracks/`.
///
/// Every stage has a path, a kerb and a verge. Some also have a deck for
/// bridges, a lip for the edge where the path drops into water or a chasm,
/// and an inlay medallion set into the paving now and then.
///
/// Scale: the 1024 px path tile is 7.4 m across (the full path width) with
/// lane joints at x = 360 and 664; the kerb is the verge-side band on the
/// left, so the right kerb is its mirror.
abstract final class TrackTiles {
  static const double pathTileMetres = 7.4;

  static const _withDeck = {Realm.ganga, Realm.himalayan, Realm.dragonValley, Realm.finalLegend};
  static const _withLip = {
    Realm.ganga,
    Realm.himalayan,
    Realm.dragonValley,
    Realm.lanka,
    Realm.sunkenDwarka,
    Realm.finalLegend,
  };
  static const _withInlay = {
    Realm.ayodhya,
    Realm.pharaoh,
    Realm.vijayanagar,
    Realm.lanka,
    Realm.indus,
    Realm.sunkenDwarka,
    Realm.finalLegend,
  };

  static String path(Realm r) => 'tracks/${r.id}/path';
  static String kerb(Realm r) => 'tracks/${r.id}/kerb';
  static String verge(Realm r) => 'tracks/${r.id}/verge';
  static String? deck(Realm r) => _withDeck.contains(r) ? 'tracks/${r.id}/deck' : null;
  static String? lip(Realm r) => _withLip.contains(r) ? 'tracks/${r.id}/lip' : null;
  static String? inlay(Realm r) => _withInlay.contains(r) ? 'tracks/${r.id}/inlay' : null;

  static List<String> names(Realm r) => [path(r), kerb(r), verge(r), ?deck(r), ?lip(r), ?inlay(r)];
}
