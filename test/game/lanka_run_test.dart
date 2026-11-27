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

  test('a stage waiting for its art is stepped over: after Vijayanagar the route goes on to Lanka', () async {
    SharedPreferences.setMockInitialValues({
      'dr.realmsDone': ['ayodhya', 'ganga', 'pharaoh', 'himalayan', 'vijayanagar'],
    });
    final repo = await ProgressRepository.load();
    expect(Realm.dragonValley.playable, isFalse);
    expect(repo.nextRealm, Realm.lanka);
    expect(repo.playRealm, Realm.lanka);
    expect(repo.isUnlocked(Realm.lanka), isTrue);
    expect(repo.isUnlocked(Realm.dragonValley), isFalse);
    await repo.completeRealm(Realm.lanka);
    expect(repo.playRealm, Realm.indus);
    await repo.completeRealm(Realm.indus);
    await repo.completeRealm(Realm.sunkenDwarka);
    await repo.completeRealm(Realm.finalLegend);
    expect(repo.yatraComplete, isTrue);
    expect(repo.playRealm, Realm.finalLegend);
  });
}
