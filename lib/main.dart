import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'analytics/game_analytics.dart';
import 'app.dart';
import 'audio/music_audio.dart';
import 'data/progress_repository.dart';
import 'game/art_library.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Art loads in the background; the game draws stand-ins until it is ready.
  ArtLibrary.instance.load();
  final progress = await ProgressRepository.load();
  runApp(DwarkaRunApp(progress: progress, analytics: NoopAnalytics(), audio: MusicAudio()));
}
