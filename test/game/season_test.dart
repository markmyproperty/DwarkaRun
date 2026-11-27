import 'package:dwarka_run/game/realm.dart';
import 'package:dwarka_run/game/season.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Season 1, Jambudvīpa, holds all ten stages in their final order', () {
    expect(Season.values.first, Season.jambudvipa);
    expect(Season.jambudvipa.number, 1);
    expect(Season.jambudvipa.realms, Realm.values);
    expect(Season.jambudvipa.realms, hasLength(10));
    for (final r in Realm.values) {
      expect(Season.of(r), Season.jambudvipa);
    }
  });
}
