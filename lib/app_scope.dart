import 'package:flutter/widgets.dart';

import 'analytics/game_analytics.dart';
import 'audio/game_audio.dart';
import 'data/progress_repository.dart';

/// Hands the app's services to every screen. Tests build it with fakes.
class AppScope extends InheritedNotifier<ProgressRepository> {
  const AppScope({
    super.key,
    required this.progress,
    required this.analytics,
    required this.audio,
    required super.child,
  }) : super(notifier: progress);

  final ProgressRepository progress;
  final GameAnalytics analytics;
  final GameAudio audio;

  /// Rebuilds the caller when progress changes.
  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope above this widget');
    return scope!;
  }

  /// Reads the scope without listening for changes.
  static AppScope read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope above this widget');
    return scope!;
  }
}
