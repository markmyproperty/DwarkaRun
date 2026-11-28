import 'package:material_ui/material_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;

import 'analytics/game_analytics.dart';
import 'app_scope.dart';
import 'audio/game_audio.dart';
import 'data/progress_repository.dart';
import 'l10n/gen/app_localizations.dart';
import 'presentation/dr_theme.dart';
import 'presentation/launch_screen.dart';
import 'update/update_checker.dart';
import 'update/update_gate.dart';

/// Strings for the game and for the material and cupertino widgets.
const appLocalizationsDelegates = <LocalizationsDelegate<Object>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// The Odyssey of the Ages app. Services are passed in so tests can use fakes.
class DwarkaRunApp extends StatelessWidget {
  const DwarkaRunApp({super.key, required this.progress, required this.analytics, required this.audio, this.locale, this.updateChecker = const NoUpdateChecker()});

  final ProgressRepository progress;
  final GameAnalytics analytics;
  final GameAudio audio;
  final Locale? locale;

  /// Blocks play until the player updates when the store has a newer version.
  final UpdateChecker updateChecker;

  @override
  Widget build(BuildContext context) {
    audio
      ..muted = progress.muted
      ..setMusicVolume(progress.musicVolume)
      ..setSfxVolume(progress.sfxVolume);
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
        localizationsDelegates: appLocalizationsDelegates,
        builder: (context, child) => UpdateGate(checker: updateChecker, child: child ?? const SizedBox.shrink()),
        home: const LaunchScreen(),
      ),
    );
  }
}
