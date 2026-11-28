import 'package:dwarka_run/audio/game_audio.dart';
import 'package:dwarka_run/data/player.dart';
import 'package:dwarka_run/game/realm.dart';
import 'package:dwarka_run/presentation/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_app.dart';

/// The day number for today, so the daily reward counts as collected.
int today() => DailyReward.dayNumber(DateTime.now());

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('home shows the logo, balances, level, world, PLAY and the menu buttons', (tester) async {
    final s = await TestServices.create({'dr.wallet': 120, 'dr.gems': 3, 'dr.best': 640});
    await tester.pumpWidget(s.wrap(const HomeScreen()));
    await tester.pump();

    for (final key in [
      'hub.logo',
      'hub.wallet',
      'hub.gems',
      'hub.level',
      'hub.settings',
      'hub.daily',
      'hub.missions',
      'hub.shop',
      'hub.hero',
      'hub.worlds',
      'hub.play',
      'hub.season',
    ]) {
      expect(find.byKey(Key(key)), findsOneWidget, reason: key);
    }
    expect(find.text('Ayodhya Run'), findsWidgets);
    expect(find.text('120'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    expect(s.analytics.names, contains('game_open'));
    expect(s.audio.music, 'audio/ayodhya_run.mp3', reason: 'home plays the selected world');
  });

  testWidgets('the world arrows move between open worlds only', (tester) async {
    final s = await TestServices.create({
      'dr.realmsDone': ['ayodhya'],
      'dr.unlockSeen': 'ganga',
    });
    await tester.pumpWidget(s.wrap(const HomeScreen()));
    await tester.pump();
    expect(s.progress.selectedRealm, Realm.ganga);
    await tester.tap(find.byKey(const Key('hub.world.prev')));
    await tester.pump();
    expect(s.progress.selectedRealm, Realm.ayodhya);
    expect(s.audio.music, 'audio/ayodhya_run.mp3');
    await tester.tap(find.byKey(const Key('hub.world.next')));
    await tester.pump();
    expect(s.progress.selectedRealm, Realm.ganga);
    await tester.tap(find.byKey(const Key('hub.world.next')));
    await tester.pump();
    expect(s.progress.selectedRealm, Realm.ganga, reason: 'Thar is still locked');
  });

  testWidgets('a newly reached world plays its unlock sequence once', (tester) async {
    final s = await TestServices.create({
      'dr.realmsDone': ['ayodhya'],
    });
    await tester.pumpWidget(s.wrap(const HomeScreen()));
    await settle(tester);
    expect(find.byKey(const Key('unlock.overlay')), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.tap(find.byKey(const Key('unlock.go')));
    await settle(tester);
    expect(find.byKey(const Key('unlock.overlay')), findsNothing);
    expect(s.progress.pendingUnlock, isNull);
    expect(s.audio.played, contains(Sfx.unlock));
  });

  testWidgets('the Play button pulses, and Reduce motion keeps it still', (tester) async {
    final s = await TestServices.create();
    await tester.pumpWidget(s.wrap(const HomeScreen()));
    await tester.pump();
    expect(find.byKey(const Key('hub.play.pulse')), findsOneWidget);

    final still = await TestServices.create();
    await tester.pumpWidget(still.wrap(const HomeScreen(), reduceMotion: true));
    await tester.pump();
    expect(find.byKey(const Key('hub.play.pulse')), findsNothing);
    expect(find.byKey(const Key('hub.play')), findsOneWidget);
  });

  testWidgets('settings change the volumes and mute, and are saved', (tester) async {
    final s = await TestServices.create();
    await tester.pumpWidget(s.wrap(const HomeScreen()));
    await tester.pump();
    await tester.tap(find.byKey(const Key('hub.settings')));
    await settle(tester);
    expect(find.byKey(const Key('sheet.settings')), findsOneWidget);
    expect(s.audio.played, contains(Sfx.click));

    await tester.drag(find.byKey(const Key('settings.music')), const Offset(-400, 0));
    await tester.pump();
    expect(s.progress.musicVolume, lessThan(0.1));
    expect(s.audio.musicVolume, lessThan(0.1));

    await tester.tap(find.byKey(const Key('hub.sound')));
    await tester.pump();
    expect(s.progress.muted, isTrue);
    expect(s.audio.muted, isTrue);
  });

  testWidgets('the daily reward can be collected once a day', (tester) async {
    final s = await TestServices.create();
    await tester.pumpWidget(s.wrap(const HomeScreen()));
    await tester.pump();
    await tester.tap(find.byKey(const Key('hub.daily')));
    await settle(tester);
    expect(find.byKey(const Key('sheet.daily')), findsOneWidget);
    await tester.tap(find.byKey(const Key('daily.claim')));
    await settle(tester);
    expect(s.progress.wallet, DailyReward.week.first.coins);
    expect(s.progress.canClaimDaily(DateTime.now()), isFalse);
    expect(s.audio.played, contains(Sfx.reward));
    await tester.pump(const Duration(seconds: 2));
    await settle(tester);
  });

  testWidgets('a finished mission can be claimed for its reward', (tester) async {
    final s = await TestServices.create({
      'dr.missions': ['0:50', '1:3', '2:0'],
      'dr.dailyLast': today(),
    });
    await tester.pumpWidget(s.wrap(const HomeScreen()));
    await tester.pump();
    await tester.tap(find.byKey(const Key('hub.missions')));
    await settle(tester);
    expect(find.byKey(const Key('sheet.missions')), findsOneWidget);
    expect(find.text('Collect 50 mudra in one run'), findsOneWidget);
    await tester.tap(find.byKey(const Key('mission.claim')));
    await settle(tester);
    expect(s.progress.wallet, missionPool.first.reward);
    expect(s.progress.missions.first.index, 3, reason: 'the next mission takes the slot');
    await tester.pump(const Duration(seconds: 2));
    await settle(tester);
  });

  testWidgets('the shop sells upgrades for mudra', (tester) async {
    final s = await TestServices.create({'dr.wallet': 1000});
    await tester.pumpWidget(s.wrap(const HomeScreen()));
    await tester.pump();
    await tester.tap(find.byKey(const Key('hub.shop')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('shop.feather.buy')));
    await tester.pump();
    expect(s.progress.upgradeLevel(Upgrade.feather), 1);
    expect(s.progress.wallet, 700);
  });

  testWidgets('the world map shows every stage and opens a run in an open world', (tester) async {
    final s = await TestServices.create({'dr.tutorialDone': true});
    await tester.pumpWidget(s.wrap(const HomeScreen()));
    await tester.pump();
    await tester.tap(find.byKey(const Key('hub.worlds')));
    await settle(tester);
    for (final r in Realm.values) {
      final key = Key('play.route.${r.id}.todo');
      await tester.dragUntilVisible(find.byKey(key), find.byType(ListView), const Offset(-60, 0));
      expect(find.byKey(key), findsOneWidget, reason: r.id);
    }
    expect(find.byKey(const Key('worlds.card.ayodhya')), findsOneWidget);
    await tester.tap(find.byKey(const Key('worlds.play.ayodhya')));
    await settle(tester);
    expect(find.byKey(const Key('hud.coins')), findsOneWidget);
    expect(s.analytics.names, contains('run_start'));
  });

  testWidgets('the home screen speaks Hindi', (tester) async {
    final s = await TestServices.create();
    await tester.pumpWidget(s.wrap(const HomeScreen(), locale: const Locale('hi')));
    await tester.pump();
    expect(find.text('खेलें'), findsWidgets);
  });
}
