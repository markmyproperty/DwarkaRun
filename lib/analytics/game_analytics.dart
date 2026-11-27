/// Analytics events the game reports. The game only talks to this interface,
/// so a real backend can be plugged in later without touching gameplay.
abstract class GameAnalytics {
  void log(String name, [Map<String, Object> params = const {}]);

  void gameOpen() => log('game_open');

  void runStart({required String realm, required int seed}) =>
      log('run_start', {'realm': realm, 'seed': seed});

  void runEnd({
    required String realm,
    required String reason,
    required int metres,
    required int coins,
  }) =>
      log('run_end', {'realm': realm, 'reason': reason, 'metres': metres, 'coins': coins});

  void realmComplete({required String realm, required int coins}) =>
      log('realm_complete', {'realm': realm, 'coins': coins});

  void siteBought({required String site, required int price}) =>
      log('site_bought', {'site': site, 'price': price});

  void shareClicked() => log('share_clicked');
}

/// Drops every event. The default in v1, which has no backend.
class NoopAnalytics extends GameAnalytics {
  @override
  void log(String name, [Map<String, Object> params = const {}]) {}
}

/// Keeps every event in memory, for tests and debugging.
class RecordingAnalytics extends GameAnalytics {
  final List<({String name, Map<String, Object> params})> events = [];

  @override
  void log(String name, [Map<String, Object> params = const {}]) {
    events.add((name: name, params: Map.unmodifiable(params)));
  }

  List<String> get names => [for (final e in events) e.name];
}
