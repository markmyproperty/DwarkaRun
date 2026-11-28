import 'dart:io';

import 'package:dwarka_run/game/entities.dart';
import 'package:dwarka_run/game/realm.dart';
import 'package:dwarka_run/game/stage_art.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const packStages = [
    Realm.pharaoh,
    Realm.himalayan,
    Realm.vijayanagar,
    Realm.dragonValley,
    Realm.lanka,
    Realm.indus,
    Realm.sunkenDwarka,
    Realm.finalLegend,
  ];

  test('stages 3 to 10 are playable and dressed from their own art packs', () {
    for (final realm in packStages) {
      expect(realm.playable, isTrue, reason: realm.id);
      final art = StageArt.of(realm);
      expect(art, isNotNull, reason: realm.id);
      for (final name in art!.names(realm)) {
        expect(File('assets/images/$name.webp').existsSync(), isTrue, reason: name);
      }
      expect(File('assets/images/${art.postcard}.webp').existsSync(), isTrue);
    }
  });

  test('each new stage has something to jump, slide under and dodge', () {
    for (final realm in packStages) {
      final kinds = realm.obstacles.map((o) => o.clearance).toSet();
      expect(kinds, containsAll([Clearance.jump, Clearance.slide, Clearance.lane]), reason: realm.id);
    }
  });

  test('monuments and temples are never obstacles', () {
    for (final realm in Realm.values) {
      for (final o in realm.obstacles) {
        final sprite = o.sprite;
        if (sprite == null) continue;
        expect(sprite.contains('/monuments/'), isFalse, reason: '$o uses $sprite');
        expect(sprite, isNot(contains('guardian')), reason: 'guardians wait for the chase');
      }
    }
  });

  test('only the Himalayan run has ice crevasses', () {
    expect(Realm.values.where((r) => r.hasCrevasse), [Realm.himalayan]);
    expect(Realm.himalayan.bridgeStart, greaterThan(Realm.himalayan.waterStart));
  });
}
