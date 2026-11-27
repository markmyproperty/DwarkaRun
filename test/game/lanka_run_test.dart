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

  test('a stage waiting for its art holds the route: Lanka is not skipped to', () async {
    SharedPreferences.setMockInitialValues({
      'dr.realmsDone': ['ayodhya', 'ganga', 'pharaoh', 'himalayan', 'vijayanagar'],
    });
    final repo = await ProgressRepository.load();
    expect(repo.nextRealm, Realm.dragonValley);
    expect(repo.playRealm, Realm.vijayanagar);
  });
}
