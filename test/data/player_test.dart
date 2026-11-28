import 'package:dwarka_run/audio/game_audio.dart';
import 'package:dwarka_run/data/player.dart';
import 'package:dwarka_run/data/progress_repository.dart';
import 'package:dwarka_run/game/realm.dart';
import 'package:dwarka_run/game/run_simulation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

RunStats run({int metres = 0, int coins = 0, int jumps = 0, bool finished = false}) => (
  realm: 'ayodhya',
  metres: metres,
  coins: coins,
  gems: 0,
  jumps: jumps,
  slides: 0,
  nearMisses: 0,
  boosts: 0,
  finished: finished,
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('levels climb with XP', () {
    expect(Levels.levelFor(0), 1);
    expect(Levels.levelFor(149), 1);
    expect(Levels.levelFor(150), 2);
    expect(Levels.levelFor(450), 3);
    expect(Levels.progress(75), closeTo(0.5, 1e-9));
    expect(Levels.xpFor(run(metres: 1000)), 100);
  });

  test('missions count runs, finish, pay out and deal the next one', () async {
    final repo = await ProgressRepository.load();
    expect(repo.missions.map((m) => m.index), [0, 1, 2]);
    // Mission 0 is "50 coins in one run": two smaller runs do not add up.
    expect(await repo.applyRunToMissions(run(coins: 30, jumps: 12)), isEmpty);
    expect(await repo.applyRunToMissions(run(coins: 30, jumps: 12)), [missionPool[1]]);
    expect(repo.missions[0].progress, 30);
    expect(repo.missions[1].done, isTrue, reason: '20 jumps in total');
    expect(repo.missionsToClaim, 1);

    expect(await repo.claimMission(0), isFalse, reason: 'not finished');
    expect(await repo.claimMission(1), isTrue);
    expect(repo.wallet, missionPool[1].reward);
    expect(repo.xp, missionPool[1].xp());
    expect(repo.missions[1].index, 3);
    expect(repo.missions[1].progress, 0);
  });

  test('missions repeat with bigger goals after the pool runs out', () {
    final first = missionAt(0);
    final again = missionAt(missionPool.length);
    expect(again.kind, first.kind);
    expect(again.goal, first.goal * 2);
  });

  test('the daily reward follows a seven-day streak and resets after a missed day', () async {
    final repo = await ProgressRepository.load();
    final d1 = DateTime(2026, 11, 1, 9);
    expect(repo.canClaimDaily(d1), isTrue);
    expect((await repo.claimDaily(d1))!.coins, DailyReward.week[0].coins);
    expect(await repo.claimDaily(d1.add(const Duration(hours: 5))), isNull);
    final d2 = d1.add(const Duration(days: 1));
    expect(repo.dailyDay(d2), 1);
    await repo.claimDaily(d2);
    final d3 = d2.add(const Duration(days: 1));
    expect((await repo.claimDaily(d3))!.gems, 1);
    expect(repo.gems, 1);
    // Skip a day: back to day 1.
    expect(repo.dailyDay(d3.add(const Duration(days: 2))), 0);
  });

  test('upgrades cost mudra and lengthen the power-ups', () async {
    SharedPreferences.setMockInitialValues({'dr.wallet': 1000});
    final repo = await ProgressRepository.load();
    expect(await repo.buyUpgrade(Upgrade.lotus), isTrue);
    expect(await repo.buyUpgrade(Upgrade.lotus), isTrue);
    expect(await repo.buyUpgrade(Upgrade.lotus), isFalse, reason: 'cannot afford 1400');
    expect(repo.upgradeLevel(Upgrade.lotus), 2);
    expect(repo.wallet, 0);
    expect(Upgrade.lotus.seconds(2), greaterThan(Upgrade.lotus.seconds(0)));
  });

  test('worlds open as the route reaches them, and the unlock shows once', () async {
    SharedPreferences.setMockInitialValues({
      'dr.realmsDone': ['ayodhya'],
    });
    final repo = await ProgressRepository.load();
    expect(repo.isUnlocked(Realm.ganga), isTrue);
    expect(repo.isUnlocked(Realm.pharaoh), isFalse);
    expect(repo.pendingUnlock, Realm.ganga);
    await repo.markUnlockSeen(Realm.ganga);
    expect(repo.pendingUnlock, isNull);
    expect(repo.selectedRealm, Realm.ganga);
    await repo.selectRealm(Realm.pharaoh);
    expect(repo.selectedRealm, Realm.ganga, reason: 'a locked world cannot be picked');
  });

  test('revives cost 1, 2, then 4 gems', () {
    expect([reviveCost(0), reviveCost(1), reviveCost(2)], [1, 2, 4]);
  });

  test('a coin line climbs a short scale and close pickups fold into one sound', () {
    final audio = SilentAudio();
    // SilentAudio's clock moves 1 s per call; drive it by hand instead.
    var now = 0;
    final a = _ClockAudio(() => now);
    for (var i = 0; i < 7; i++) {
      now += 100;
      a.onRunEvent(RunEvent.coin);
    }
    expect(a.played, [Sfx.coin1, Sfx.coin2, Sfx.coin3, Sfx.coin4, Sfx.coin5, Sfx.coin5, Sfx.coin5]);
    a.played.clear();
    now += 20;
    a.onRunEvent(RunEvent.coin);
    expect(a.played, isEmpty, reason: 'within 55 ms of the last coin');
    now += 2000;
    a.onRunEvent(RunEvent.coin);
    expect(a.played, [Sfx.coin1], reason: 'a pause starts the scale again');
    audio.muted = true;
    audio.onRunEvent(RunEvent.jump);
    expect(audio.played, isEmpty, reason: 'mute silences effects');
  });
}

class _ClockAudio extends SilentAudio {
  _ClockAudio(this.clock);

  final int Function() clock;

  @override
  int nowMs() => clock();
}
