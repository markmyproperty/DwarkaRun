import 'package:dwarka_run/audio/game_audio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_app.dart';

Future<void> pumpFor(WidgetTester tester, Duration d) async {
  for (var t = Duration.zero; t < d; t += const Duration(milliseconds: 100)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('first launch: MMYP logo, title, then the story, which then goes home', (tester) async {
    final s = await TestServices.create();
    await tester.pumpWidget(s.app());
    await tester.pump();
    expect(find.byKey(const Key('launch.mmyp')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 50));
    expect(s.audio.played, contains(Sfx.logoSting));

    await pumpFor(tester, const Duration(milliseconds: 3200));
    expect(find.byKey(const Key('launch.title')), findsOneWidget);

    await pumpFor(tester, const Duration(milliseconds: 2200));
    expect(find.byKey(const Key('story.skip')), findsOneWidget, reason: 'the story plays on first launch');
    expect(s.progress.introSeen, isFalse);

    // The montage moves on by itself.
    await pumpFor(tester, const Duration(seconds: 8));
    expect(s.audio.played, contains(Sfx.whoosh));

    await tester.tap(find.byKey(const Key('story.skip')));
    await pumpFor(tester, const Duration(milliseconds: 800));
    expect(s.progress.introSeen, isTrue);
    expect(find.byKey(const Key('hub.play')), findsOneWidget);
  });

  testWidgets('later launches skip the story, and a tap skips the logo', (tester) async {
    final s = await TestServices.create({'dr.introSeen': true});
    await tester.pumpWidget(s.app());
    await tester.pump();
    await tester.tap(find.byKey(const Key('launch.skip')));
    await pumpFor(tester, const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('launch.skip')));
    await pumpFor(tester, const Duration(milliseconds: 800));
    expect(find.byKey(const Key('story.skip')), findsNothing);
    expect(find.byKey(const Key('hub.play')), findsOneWidget);
  });

  testWidgets('Settings can replay the story, which then closes back to home', (tester) async {
    final s = await TestServices.create({'dr.introSeen': true});
    await tester.pumpWidget(s.app());
    await pumpFor(tester, const Duration(milliseconds: 5400));
    expect(find.byKey(const Key('hub.play')), findsOneWidget);
    await tester.tap(find.byKey(const Key('hub.settings')));
    await pumpFor(tester, const Duration(milliseconds: 600));
    await tester.tap(find.byKey(const Key('settings.replayIntro')));
    await pumpFor(tester, const Duration(milliseconds: 800));
    expect(find.byKey(const Key('story.skip')), findsOneWidget);
    await tester.tap(find.byKey(const Key('story.skip')));
    await pumpFor(tester, const Duration(milliseconds: 800));
    expect(find.byKey(const Key('story.skip')), findsNothing);
    expect(find.byKey(const Key('hub.play')), findsOneWidget);
  });

  testWidgets('the story ends on the title and a Begin button', (tester) async {
    final s = await TestServices.create({'dr.introSeen': true});
    await tester.pumpWidget(s.app());
    await pumpFor(tester, const Duration(milliseconds: 5400));
    await tester.tap(find.byKey(const Key('hub.settings')));
    await pumpFor(tester, const Duration(milliseconds: 600));
    await tester.tap(find.byKey(const Key('settings.replayIntro')));
    await pumpFor(tester, const Duration(seconds: 30));
    expect(find.byKey(const Key('story.begin')), findsOneWidget);
    await tester.tap(find.byKey(const Key('story.begin')));
    await pumpFor(tester, const Duration(milliseconds: 800));
    expect(find.byKey(const Key('hub.play')), findsOneWidget);
  });
}
