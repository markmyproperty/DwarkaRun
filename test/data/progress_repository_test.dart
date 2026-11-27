import 'package:dwarka_run/data/progress_repository.dart';
import 'package:dwarka_run/game/realm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('starts empty, with Ancient Dwarka next', () async {
    final repo = await ProgressRepository.load();
    expect(repo.wallet, 0);
    expect(repo.bestMetres, 0);
    expect(repo.nextRealm, Realm.ayodhya);
    expect(repo.playRealm, Realm.ayodhya);
    expect(repo.tutorialDone, isFalse);
  });

  test('records runs, wallet and best, and keeps them', () async {
    final repo = await ProgressRepository.load();
    expect(await repo.recordRun(metres: 300, coins: 40), isTrue);
    expect(await repo.recordRun(metres: 200, coins: 10), isFalse);
    expect(repo.wallet, 50);
    expect(repo.bestMetres, 300);

    final again = await ProgressRepository.load();
    expect(again.wallet, 50);
    expect(again.bestMetres, 300);
    expect(again.runs, 2);
  });

  test('spending needs enough coins', () async {
    final repo = await ProgressRepository.load();
    await repo.addCoins(30);
    expect(await repo.spend(50), isFalse);
    expect(await repo.spend(20), isTrue);
    expect(repo.wallet, 10);
  });

  test('completing a realm moves the route on and persists', () async {
    final repo = await ProgressRepository.load();
    await repo.completeRealm(Realm.ayodhya);
    expect(repo.isDone(Realm.ayodhya), isTrue);
    expect(repo.nextRealm, Realm.ganga);
    expect(repo.playRealm, Realm.ganga);
    await repo.completeRealm(Realm.ganga);
    expect(repo.nextRealm, Realm.pharaoh);
    expect(repo.playRealm, Realm.pharaoh);
    for (final r in [Realm.pharaoh, Realm.himalayan, Realm.vijayanagar]) {
      await repo.completeRealm(r);
    }
    expect(repo.nextRealm, Realm.dragonValley);
    // Dragon Valley is not playable in this build yet, so Play repeats the
    // last playable stage.
    expect(repo.playRealm, Realm.vijayanagar);
    final again = await ProgressRepository.load();
    expect(again.realmsDone, {'ayodhya', 'ganga', 'pharaoh', 'himalayan', 'vijayanagar'});
  });

  test('the stages follow the final order of the master brief', () {
    expect(Realm.values.map((r) => r.id), [
      'ayodhya',
      'ganga',
      'pharaoh',
      'himalayan',
      'vijayanagar',
      'dragon',
      'lanka',
      'indus',
      'sunken',
      'finale',
    ]);
  });

  test('mute and tutorial settings persist', () async {
    final repo = await ProgressRepository.load();
    await repo.setMuted(true);
    await repo.markTutorialDone();
    final again = await ProgressRepository.load();
    expect(again.muted, isTrue);
    expect(again.tutorialDone, isTrue);
  });
}
