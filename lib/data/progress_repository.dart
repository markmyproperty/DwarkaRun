import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/realm.dart';

/// The player's saved progress: wallet, best run, finished realms and
/// settings. Stored on the device with `shared_preferences`; v1 has no
/// backend.
class ProgressRepository extends ChangeNotifier {
  ProgressRepository(this._prefs);

  static Future<ProgressRepository> load() async => ProgressRepository(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  static const _kWallet = 'dr.wallet';
  static const _kBest = 'dr.best';
  static const _kRealms = 'dr.realmsDone';
  static const _kMuted = 'dr.muted';
  static const _kTutorial = 'dr.tutorialDone';
  static const _kRuns = 'dr.runs';

  int get wallet => _prefs.getInt(_kWallet) ?? 0;
  int get bestMetres => _prefs.getInt(_kBest) ?? 0;
  int get runs => _prefs.getInt(_kRuns) ?? 0;
  bool get muted => _prefs.getBool(_kMuted) ?? false;
  bool get tutorialDone => _prefs.getBool(_kTutorial) ?? false;

  Set<String> get realmsDone => (_prefs.getStringList(_kRealms) ?? const []).toSet();

  bool isDone(Realm r) => realmsDone.contains(r.id);

  /// The first realm on the route not finished yet, or null when the whole
  /// yatra is complete.
  Realm? get nextRealm {
    final done = realmsDone;
    for (final r in Realm.values) {
      if (!done.contains(r.id)) return r;
    }
    return null;
  }

  /// The realm the Play button starts: the next one if this build can run
  /// it, otherwise the latest playable realm before it. The route is never
  /// skipped, so a stage still waiting for its art holds the player back.
  Realm get playRealm {
    final next = nextRealm;
    if (next != null && next.playable) return next;
    final upTo = next?.index ?? Realm.values.length;
    return Realm.values.take(upTo).lastWhere((r) => r.playable, orElse: () => Realm.values.first);
  }

  bool get yatraComplete => nextRealm == null;

  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    await _prefs.setInt(_kWallet, wallet + amount);
    notifyListeners();
  }

  /// Spends [amount] if the wallet holds it. Returns whether it did.
  Future<bool> spend(int amount) async {
    if (amount < 0 || amount > wallet) return false;
    await _prefs.setInt(_kWallet, wallet - amount);
    notifyListeners();
    return true;
  }

  /// Records a finished run. Returns true if it is a new best.
  Future<bool> recordRun({required int metres, required int coins}) async {
    await _prefs.setInt(_kRuns, runs + 1);
    if (coins > 0) await _prefs.setInt(_kWallet, wallet + coins);
    final best = metres > bestMetres;
    if (best) await _prefs.setInt(_kBest, metres);
    notifyListeners();
    return best;
  }

  Future<void> completeRealm(Realm r) async {
    final done = realmsDone..add(r.id);
    await _prefs.setStringList(_kRealms, [
      for (final realm in Realm.values)
        if (done.contains(realm.id)) realm.id,
    ]);
    notifyListeners();
  }

  Future<void> setMuted(bool value) async {
    await _prefs.setBool(_kMuted, value);
    notifyListeners();
  }

  Future<void> markTutorialDone() async {
    if (tutorialDone) return;
    await _prefs.setBool(_kTutorial, true);
    notifyListeners();
  }
}
