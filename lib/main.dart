import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'analytics/game_analytics.dart';
import 'app.dart';
import 'audio/game_audio.dart';
import 'data/progress_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final progress = await ProgressRepository.load();
  runApp(DwarkaRunApp(
    progress: progress,
    analytics: NoopAnalytics(),
    audio: SilentAudio(),
  ));
}
