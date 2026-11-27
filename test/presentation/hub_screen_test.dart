import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_app.dart';

void main() {
  testWidgets('the hub shows the next stop, route, wallet, best and how-to', (tester) async {
    final s = await TestServices.create({'dr.wallet': 120, 'dr.best': 640});
    await tester.pumpWidget(s.app());
    await tester.pump();

    expect(find.text('Odyssey of the Ages'), findsOneWidget);
    expect(find.byKey(const Key('hub.logo')), findsOneWidget);
    expect(find.byKey(const Key('hub.nextStop')), findsOneWidget);
    expect(find.text('Ayodhya Run'), findsWidgets);
    expect(find.text('Start the adventure'), findsOneWidget);
    expect(find.text('120 mudra'), findsOneWidget);
    expect(find.text('640 m'), findsOneWidget);
    for (final id in [
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
    ]) {
      await tester.scrollUntilVisible(find.byKey(Key('play.route.$id.todo')), 120);
      expect(find.byKey(Key('play.route.$id.todo')), findsOneWidget, reason: id);
    }
    await tester.scrollUntilVisible(find.byKey(const Key('play.howto')), 200);
    expect(find.byKey(const Key('play.howto')), findsOneWidget);
    expect(s.analytics.names, contains('game_open'));
  });

  testWidgets('a finished stage shows as done, and Play repeats it until the next one opens', (tester) async {
    final s = await TestServices.create({
      'dr.realmsDone': ['ayodhya'],
    });
    await tester.pumpWidget(s.app());
    await tester.pump();
    expect(find.text('Ganga Run'), findsWidgets);
    expect(find.text('Continue to Ganga Run'), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const Key('play.route.ayodhya.done')), 200);
    expect(find.byKey(const Key('play.route.ayodhya.done')), findsOneWidget);
    expect(find.byKey(const Key('play.route.ganga.todo')), findsOneWidget);
  });

  testWidgets('past the playable stages, Play repeats the last one', (tester) async {
    final s = await TestServices.create({
      'dr.realmsDone': ['ayodhya', 'ganga', 'pharaoh', 'himalayan', 'vijayanagar'],
    });
    await tester.pumpWidget(s.app());
    await tester.pump();
    expect(find.text('Dragon Valley'), findsWidgets);
    expect(find.text('Play Vijayanagar Run again'), findsOneWidget);
  });

  testWidgets('the Play button pulses', (tester) async {
    final s = await TestServices.create();
    await tester.pumpWidget(s.app());
    await tester.pump();
    expect(find.byKey(const Key('hub.play.pulse')), findsOneWidget);
    expect(find.byKey(const Key('hub.play')), findsOneWidget);
  });

  testWidgets('Reduce motion turns the pulse off', (tester) async {
    final s = await TestServices.create();
    await tester.pumpWidget(s.app(reduceMotion: true));
    await tester.pump();
    expect(find.byKey(const Key('hub.play.pulse')), findsNothing);
    expect(find.byKey(const Key('hub.play')), findsOneWidget);
    // Nothing is animating, so the hub settles straight away.
    await tester.pumpAndSettle();
  });

  testWidgets('the sound toggle saves the setting', (tester) async {
    final s = await TestServices.create();
    await tester.pumpWidget(s.app());
    await tester.pump();
    await tester.tap(find.byKey(const Key('hub.sound')));
    await tester.pump();
    expect(s.progress.muted, isTrue);
    expect(s.audio.muted, isTrue);
  });

  testWidgets('the hub speaks Hindi', (tester) async {
    final s = await TestServices.create();
    await tester.pumpWidget(s.app(locale: const Locale('hi')));
    await tester.pump();
    expect(find.text('युगों की यात्रा'), findsOneWidget);
    expect(find.text('साहसिक यात्रा शुरू करें'), findsOneWidget);
  });

  testWidgets('Play opens a run', (tester) async {
    final s = await TestServices.create({'dr.tutorialDone': true});
    await tester.pumpWidget(s.app(reduceMotion: true));
    await tester.pump();
    await tester.tap(find.byKey(const Key('hub.play')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('hud.coins')), findsOneWidget);
    expect(s.analytics.names, contains('run_start'));
  });
}
