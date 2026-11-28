import 'package:dwarka_run/update/update_checker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../presentation/launch_test.dart' show pumpFor;
import '../presentation/test_app.dart';

class FakeChecker implements UpdateChecker {
  FakeChecker(this.required);

  bool required;
  int starts = 0;

  @override
  Future<bool> updateRequired() async => required;

  @override
  Future<void> startUpdate() async => starts++;
}

void main() {
  group('isNewerVersion', () {
    test('compares numerically, part by part', () {
      expect(isNewerVersion('1.0.1', '1.0.0'), isTrue);
      expect(isNewerVersion('1.10.0', '1.9.9'), isTrue);
      expect(isNewerVersion('2.0', '1.9.9'), isTrue);
      expect(isNewerVersion('1.0.0', '1.0.0'), isFalse);
      expect(isNewerVersion('1.0', '1.0.0'), isFalse);
      expect(isNewerVersion('1.0.0', '1.0.1'), isFalse, reason: 'a build under review is newer than the store');
      expect(isNewerVersion('1.0.0+5', '1.0.0'), isFalse);
    });
  });

  group('parseLookup', () {
    test('reads version and store page', () {
      final r = parseLookup('{"resultCount":1,"results":[{"version":"1.2.0","trackViewUrl":"https://apps.apple.com/app/id1"}]}');
      expect(r?.version, '1.2.0');
      expect(r?.page.toString(), 'https://apps.apple.com/app/id1');
    });
    test('no app in the store yet', () {
      expect(parseLookup('{"resultCount":0,"results":[]}'), isNull);
    });
  });

  testWidgets('a newer store version blocks the game and opens the updater', (tester) async {
    final s = await TestServices.create({'dr.introSeen': true});
    final checker = FakeChecker(true);
    await tester.pumpWidget(s.app(updateChecker: checker));
    await pumpFor(tester, const Duration(milliseconds: 300));
    expect(find.byKey(const Key('update-required')), findsOneWidget);
    expect(find.text('Update required'), findsWidgets);
    expect(checker.starts, 1, reason: 'the updater opens by itself once');

    await tester.tap(find.text('Update now').last);
    await tester.pump();
    expect(checker.starts, 2);

    // Coming back without updating keeps the block.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await pumpFor(tester, const Duration(milliseconds: 300));
    expect(find.byKey(const Key('update-required')), findsOneWidget);
    await pumpFor(tester, const Duration(seconds: 6));
  });

  testWidgets('up to date: no block', (tester) async {
    final s = await TestServices.create({'dr.introSeen': true});
    await tester.pumpWidget(s.app(updateChecker: FakeChecker(false)));
    await pumpFor(tester, const Duration(seconds: 6));
    expect(find.byKey(const Key('update-required')), findsNothing);
    expect(find.byKey(const Key('hub.play')), findsOneWidget);
  });
}
