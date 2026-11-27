import 'realm.dart';

/// A season of Odyssey of the Ages: a run of stages in one legendary land.
/// Season 1, Jambudvīpa, holds the ten stages of the master brief in their
/// final order. Later seasons add their own stages.
enum Season {
  jambudvipa(id: 'jambudvipa', number: 1);

  const Season({required this.id, required this.number});

  final String id;
  final int number;

  /// The stages of this season, in order.
  List<Realm> get realms => switch (this) {
    Season.jambudvipa => Realm.values,
  };

  static Season of(Realm realm) => Season.values.firstWhere((s) => s.realms.contains(realm));
}
