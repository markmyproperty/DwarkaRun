import 'package:material_ui/material_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;

import 'analytics/game_analytics.dart';
import 'app_scope.dart';
import 'audio/game_audio.dart';
import 'data/progress_repository.dart';
import 'l10n/gen/app_localizations.dart';
import 'presentation/dr_theme.dart';
import 'presentation/hub_screen.dart';

/// The Dwarka Run app. Services are passed in so tests can use fakes.
class DwarkaRunApp extends StatelessWidget {
  const DwarkaRunApp({
    super.key,
    required this.progress,
    required this.analytics,
    required this.audio,
    this.locale,
  });

  final ProgressRepository progress;
  final GameAnalytics analytics;
  final GameAudio audio;
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    audio.muted = progress.muted;
    return AppScope(
      progress: progress,
      analytics: analytics,
      audio: audio,
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        theme: buildDrTheme(),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const HubScreen(),
      ),
    );
  }
}
