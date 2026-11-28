import 'package:dwarka_run/data/progress_repository.dart';
import 'package:dwarka_run/game/realm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Lanka Run is a palace-moat stage with a fortress-bridge finale', () {
    expect(Realm.lanka.playable, isTrue);
    expect(Realm.lanka.hasMoat, isTrue);
    expect(Realm.lanka.hasCrevasse, isFalse);
    expect(Realm.lanka.bridgeStart, greaterThan(Realm.lanka.waterStart));
  });

  test('every stage is built, so after Vijayanagar the route goes on to Dragon Valley and on to the end', () async {
    SharedPreferences.setMockInitialValues({
      'dr.realmsDone': ['ayodhya', 'ganga', 'pharaoh', 'himalayan', 'vijayanagar'],
    });
    final repo = await ProgressRepository.load();
    expect(Realm.values.every((r) => r.playable), isTrue);
    for (final r in [Realm.dragonValley, Realm.lanka, Realm.indus, Realm.sunkenDwarka]) {
      expect(repo.playRealm, r);
      expect(repo.isUnlocked(r), isTrue);
      await repo.completeRealm(r);
    }
    expect(repo.playRealm, Realm.finalLegend);
    await repo.completeRealm(Realm.finalLegend);
    expect(repo.yatraComplete, isTrue);
  });
}
