import 'package:dwarka_run/audio/game_audio.dart';
import 'package:dwarka_run/game/realm.dart';
import 'package:dwarka_run/presentation/run_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'test_app.dart';

int hudCoins(WidgetTester tester) {
  final text = tester.widget<Text>(
    find.descendant(of: find.byKey(const Key('hud.coins')), matching: find.byType(Text)),
  );
  return int.parse(text.data!);
}

String hudDistance(WidgetTester tester) =>
    tester.widget<Text>(find.descendant(of: find.byKey(const Key('hud.distance')), matching: find.byType(Text))).data!;

/// Pumps frames until [finder] shows, or fails after [seconds].
Future<void> pumpUntil(WidgetTester tester, Finder finder, {double seconds = 90}) async {
  for (var t = 0.0; t < seconds; t += 0.05) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for $finder');
}

void main() {
  testWidgets('a seeded run shows the HUD, a crash gives game over, and Retry restarts', (tester) async {
    final s = await TestServices.create({'dr.tutorialDone': true});
    await tester.pumpWidget(s.wrap(const RunScreen(realm: Realm.ayodhya, seed: 3, intro: false)));
    await tester.pump();

    for (final key in ['hud.coins', 'hud.distance', 'hud.pause', 'hud.boost']) {
      expect(find.byKey(Key(key)), findsOneWidget, reason: key);
    }
    expect(hudCoins(tester), 0);

    // Nobody steers, so the hero runs into something.
    await pumpUntil(tester, find.byKey(const Key('gameover.panel')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('gameover.score')), findsOneWidget);
    expect(s.audio.played, contains(Sfx.gameOver));
    expect(find.byKey(const Key('gameover.coins')), findsOneWidget);
    expect(s.analytics.names, containsAllInOrder(['run_start', 'run_end']));
    expect(s.analytics.events.last.params['reason'], 'crash');
    expect(s.progress.runs, 1);

    await tester.tap(find.byKey(const Key('gameover.retry')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.byKey(const Key('gameover.panel')), findsNothing);
    expect(hudCoins(tester), 0);
    expect(hudDistance(tester), '0 m');
    expect(s.analytics.names.where((n) => n == 'run_start').length, 2);

    // The new run moves on.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(hudDistance(tester), isNot('0 m'));
  });

  testWidgets('the pause menu resumes, mutes and quits', (tester) async {
    final s = await TestServices.create({'dr.tutorialDone': true});
    await tester.pumpWidget(s.wrap(const RunScreen(realm: Realm.ayodhya, seed: 11, intro: false)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(s.audio.music, 'audio/ayodhya_run.mp3');

    await tester.tap(find.byKey(const Key('hud.pause')));
    await tester.pump();
    expect(find.byKey(const Key('pause.menu')), findsOneWidget);
    expect(s.audio.music, isNull, reason: 'music holds while paused');
    final pausedAt = hudDistance(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(hudDistance(tester), pausedAt);

    await tester.tap(find.byKey(const Key('pause.mute')));
    await tester.pump();
    expect(s.progress.muted, isTrue);
    expect(s.audio.muted, isTrue);

    await tester.tap(find.byKey(const Key('pause.resume')));
    await tester.pump();
    expect(find.byKey(const Key('pause.menu')), findsNothing);
    expect(s.audio.music, isNull, reason: 'still muted');
    s.audio.muted = false;
    expect(s.audio.music, 'audio/ayodhya_run.mp3');

    await tester.tap(find.byKey(const Key('hud.pause')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('pause.quit')));
    await tester.pumpAndSettle();
    expect(s.analytics.events.last.params['reason'], 'quit');
    expect(s.audio.music, isNull, reason: 'quitting stops the music');
  });

  testWidgets('reaching the target completes the realm and saves it', (tester) async {
    final s = await TestServices.create({'dr.tutorialDone': true});
    await tester.pumpWidget(s.wrap(const RunScreen(realm: Realm.ayodhya, seed: 5, targetMetres: 30, intro: false)));
    await tester.pump();
    // Hold a boost so nothing can stop the hero.
    final state = tester.state(find.byType(RunScreen));
    // ignore: avoid_dynamic_calls
    final sim = (state as dynamic).debugSim;
    for (var i = 0; i < 100 && find.byKey(const Key('complete.panel')).evaluate().isEmpty; i++) {
      sim.boostLeft = 1.0;
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('complete.panel')), findsOneWidget);
    expect(s.progress.isDone(Realm.ayodhya), isTrue);
    expect(s.progress.xp, greaterThan(0));
    expect(s.audio.played, contains(Sfx.fanfare));
    expect(s.analytics.names, contains('realm_complete'));
  });

  testWidgets('the first run opens gently with swipe hints', (tester) async {
    final s = await TestServices.create();
    await tester.pumpWidget(s.wrap(const RunScreen(realm: Realm.ayodhya, seed: 2, intro: false)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('run.hint')), findsOneWidget);
  });

  testWidgets('swipes and keys steer the hero', (tester) async {
    final s = await TestServices.create({'dr.tutorialDone': true});
    await tester.pumpWidget(s.wrap(const RunScreen(realm: Realm.ayodhya, seed: 2, intro: false)));
    await tester.pump(const Duration(milliseconds: 50));
    final state = tester.state(find.byType(RunScreen));
    // ignore: avoid_dynamic_calls
    final sim = (state as dynamic).debugSim;

    await tester.drag(find.byType(RunScreen), const Offset(-120, 0));
    await tester.pump();
    expect(sim.lane, -1);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(sim.lane, 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
    await tester.pump();
    expect(sim.lane, 1);

    await tester.drag(find.byType(RunScreen), const Offset(0, -120));
    await tester.pump();
    expect(sim.y, greaterThan(0));
  });

  testWidgets('a run opens with the stage banner and a 3-2-1 countdown, holding still until GO', (tester) async {
    final s = await TestServices.create({'dr.tutorialDone': true});
    await tester.pumpWidget(s.wrap(const RunScreen(realm: Realm.ganga, seed: 4)));
    await tester.pump();
    expect(find.byKey(const Key('run.intro')), findsOneWidget);
    expect(find.text('Ganga Run'), findsWidgets);
    final state = tester.state(find.byType(RunScreen));
    // ignore: avoid_dynamic_calls
    final sim = (state as dynamic).debugSim;
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(sim.distance, 0, reason: 'nothing moves during the intro');
    expect(s.audio.played, contains(Sfx.tick));
    // Swipes are ignored until GO.
    await tester.drag(find.byType(RunScreen), const Offset(-120, 0));
    expect(sim.lane, 0);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(s.audio.played, contains(Sfx.go));
    expect(find.byKey(const Key('run.intro')), findsNothing);
    expect(sim.distance, greaterThan(0));
  });

  testWidgets('with gems, a crash offers a revive that carries the run on', (tester) async {
    final s = await TestServices.create({'dr.tutorialDone': true, 'dr.gems': 2});
    await tester.pumpWidget(s.wrap(const RunScreen(realm: Realm.ayodhya, seed: 3, intro: false)));
    await tester.pump();
    await pumpUntil(tester, find.byKey(const Key('revive.panel')));
    final state = tester.state(find.byType(RunScreen));
    // ignore: avoid_dynamic_calls
    final sim = (state as dynamic).debugSim;
    final at = sim.distance;
    await tester.tap(find.byKey(const Key('revive.yes')));
    await tester.pump();
    expect(s.progress.gems, 1);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('revive.panel')), findsNothing);
    expect(sim.distance, greaterThan(at));
    expect(s.audio.played, contains(Sfx.revive));
  });

  testWidgets('declining the revive shows the results', (tester) async {
    final s = await TestServices.create({'dr.tutorialDone': true, 'dr.gems': 1});
    await tester.pumpWidget(s.wrap(const RunScreen(realm: Realm.ayodhya, seed: 3, intro: false)));
    await tester.pump();
    await pumpUntil(tester, find.byKey(const Key('revive.panel')));
    await tester.tap(find.byKey(const Key('revive.no')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('gameover.panel')), findsOneWidget);
    expect(s.progress.gems, 1);
  });

  testWidgets('with no gems, 100 coins buy a revive', (tester) async {
    final s = await TestServices.create({'dr.tutorialDone': true, 'dr.wallet': 150});
    await tester.pumpWidget(s.wrap(const RunScreen(realm: Realm.ayodhya, seed: 3, intro: false)));
    await tester.pump();
    await pumpUntil(tester, find.byKey(const Key('revive.panel')));
    await tester.tap(find.byKey(const Key('revive.coins')));
    await tester.pump();
    expect(s.progress.wallet, 50);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('revive.panel')), findsNothing);
  });
}
