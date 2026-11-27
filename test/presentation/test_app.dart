import 'package:dwarka_run/analytics/game_analytics.dart';
import 'package:dwarka_run/app.dart';
import 'package:dwarka_run/app_scope.dart';
import 'package:dwarka_run/audio/game_audio.dart';
import 'package:dwarka_run/data/progress_repository.dart';
import 'package:dwarka_run/l10n/gen/app_localizations.dart';
import 'package:dwarka_run/presentation/dr_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestServices {
  TestServices(this.progress);

  final ProgressRepository progress;
  final RecordingAnalytics analytics = RecordingAnalytics();
  final SilentAudio audio = SilentAudio();

  static Future<TestServices> create([Map<String, Object> prefs = const {}]) async {
    SharedPreferences.setMockInitialValues(prefs);
    return TestServices(await ProgressRepository.load());
  }

  Widget app({bool reduceMotion = false, Locale? locale}) => MediaQuery(
    data: MediaQueryData(size: const Size(400, 800), disableAnimations: reduceMotion),
    child: DwarkaRunApp(progress: progress, analytics: analytics, audio: audio, locale: locale),
  );

  /// Wraps [child] in everything a screen needs, without the hub.
  Widget wrap(Widget child, {bool reduceMotion = false}) => MediaQuery(
    data: MediaQueryData(size: const Size(400, 800), disableAnimations: reduceMotion),
    child: AppScope(
      progress: progress,
      analytics: analytics,
      audio: audio,
      child: MaterialApp(
        theme: buildDrTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
}
