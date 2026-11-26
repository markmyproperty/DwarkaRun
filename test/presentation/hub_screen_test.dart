import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_app.dart';

void main() {
  testWidgets('the hub shows the next stop, route, wallet, best and how-to', (tester) async {
    final s = await TestServices.create({'dr.wallet': 120, 'dr.best': 640});
    await tester.pumpWidget(s.app());
    await tester.pump();

    expect(find.text('Dwarka Run'), findsOneWidget);
    expect(find.byKey(const Key('hub.nextStop')), findsOneWidget);
    expect(find.text('Forest Kingdom'), findsWidgets);
    expect(find.text('Start yatra'), findsOneWidget);
    expect(find.text('120 mudra'), findsOneWidget);
    expect(find.text('640 m'), findsOneWidget);
    for (final id in ['forest', 'river', 'desert', 'himalaya', 'celestial']) {
      expect(find.byKey(Key('play.route.$id.todo')), findsOneWidget, reason: id);
    }
    await tester.scrollUntilVisible(find.byKey(const Key('play.howto')), 200);
    expect(find.byKey(const Key('play.howto')), findsOneWidget);
    expect(s.analytics.names, contains('game_open'));
  });

  testWidgets('a finished realm shows as done on the route', (tester) async {
    final s = await TestServices.create({'dr.realmsDone': ['forest']});
    await tester.pumpWidget(s.app());
    await tester.pump();
    expect(find.byKey(const Key('play.route.forest.done')), findsOneWidget);
    expect(find.byKey(const Key('play.route.river.todo')), findsOneWidget);
    expect(find.text('Run Forest Kingdom again'), findsOneWidget);
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
    expect(find.text('द्वारका रन'), findsOneWidget);
    expect(find.text('यात्रा शुरू करें'), findsOneWidget);
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
