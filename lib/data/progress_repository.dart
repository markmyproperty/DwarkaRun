import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/realm.dart';
import 'player.dart';

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
  static const _kMusicVol = 'dr.musicVolume';
  static const _kSfxVol = 'dr.sfxVolume';
  static const _kIntro = 'dr.introSeen';
  static const _kGems = 'dr.gems';
  static const _kXp = 'dr.xp';
  static const _kMissions = 'dr.missions';
  static const _kMissionNext = 'dr.missionNext';
  static const _kDailyLast = 'dr.dailyLast';
  static const _kDailyStreak = 'dr.dailyStreak';
  static const _kSelected = 'dr.selectedRealm';
  static const _kUnlockSeen = 'dr.unlockSeen';
  static String _kUpgrade(Upgrade u) => 'dr.upgrade.${u.name}';

  int get wallet => _prefs.getInt(_kWallet) ?? 0;
  int get bestMetres => _prefs.getInt(_kBest) ?? 0;
  int get runs => _prefs.getInt(_kRuns) ?? 0;
  bool get muted => _prefs.getBool(_kMuted) ?? false;
  bool get tutorialDone => _prefs.getBool(_kTutorial) ?? false;
  double get musicVolume => _prefs.getDouble(_kMusicVol) ?? 0.7;
  double get sfxVolume => _prefs.getDouble(_kSfxVol) ?? 0.9;

  /// Whether the story introduction has played once. It only plays by itself
  /// on the very first launch; Settings can replay it.
  bool get introSeen => _prefs.getBool(_kIntro) ?? false;

  int get gems => _prefs.getInt(_kGems) ?? 0;
  int get xp => _prefs.getInt(_kXp) ?? 0;
  int get level => Levels.levelFor(xp);
  double get levelProgress => Levels.progress(xp);

  int upgradeLevel(Upgrade u) => _prefs.getInt(_kUpgrade(u)) ?? 0;

  /// The three current missions.
  List<MissionSlot> get missions {
    final raw = _prefs.getStringList(_kMissions);
    if (raw == null || raw.length != 3) return [MissionSlot(0, 0), MissionSlot(1, 0), MissionSlot(2, 0)];
    return raw.map(MissionSlot.decode).toList();
  }

  int get _missionNext => _prefs.getInt(_kMissionNext) ?? 3;

  /// Missions finished and waiting for their reward to be collected.
  int get missionsToClaim => missions.where((m) => m.done).length;

  Future<void> _saveMissions(List<MissionSlot> slots) =>
      _prefs.setStringList(_kMissions, [for (final m in slots) m.encode()]);

  /// Counts a run towards the missions. Returns the missions it finished.
  Future<List<MissionDef>> applyRunToMissions(RunStats run) async {
    final slots = missions;
    final finished = <MissionDef>[];
    for (final m in slots) {
      if (m.done) continue;
      final v = m.def.measure(run);
      m.progress = m.def.perRun ? (v > m.progress ? v : m.progress) : m.progress + v;
      if (m.done) {
        m.progress = m.def.goal;
        finished.add(m.def);
      }
    }
    await _saveMissions(slots);
    notifyListeners();
    return finished;
  }

  /// Collects a finished mission's reward and deals the next mission into
  /// its slot.
  Future<bool> claimMission(int slot) async {
    final slots = missions;
    if (slot < 0 || slot >= slots.length || !slots[slot].done) return false;
    final def = slots[slot].def;
    final next = _missionNext;
    slots[slot] = MissionSlot(next, 0);
    await _prefs.setInt(_kMissionNext, next + 1);
    await _saveMissions(slots);
    await _prefs.setInt(_kWallet, wallet + def.reward);
    if (def.gemReward > 0) await _prefs.setInt(_kGems, gems + def.gemReward);
    await _prefs.setInt(_kXp, xp + def.xp());
    notifyListeners();
    return true;
  }

  // ── daily reward ──
  int get _dailyLast => _prefs.getInt(_kDailyLast) ?? -1;

  /// Which day of the week's calendar (0..6) is up next.
  int dailyDay(DateTime now) {
    final today = DailyReward.dayNumber(now);
    final streak = _prefs.getInt(_kDailyStreak) ?? 0;
    final last = _dailyLast;
    if (last == today) return (streak - 1) % 7;
    if (last == today - 1) return streak % 7;
    return 0;
  }

  bool canClaimDaily(DateTime now) => _dailyLast != DailyReward.dayNumber(now);

  /// Collects today's reward. Returns it, or null if already collected.
  Future<DailyReward?> claimDaily(DateTime now) async {
    if (!canClaimDaily(now)) return null;
    final day = dailyDay(now);
    final reward = DailyReward.week[day];
    await _prefs.setInt(_kDailyLast, DailyReward.dayNumber(now));
    await _prefs.setInt(_kDailyStreak, day + 1);
    await _prefs.setInt(_kWallet, wallet + reward.coins);
    if (reward.gems > 0) await _prefs.setInt(_kGems, gems + reward.gems);
    notifyListeners();
    return reward;
  }

  // ── shop ──
  Future<bool> buyUpgrade(Upgrade u) async {
    final level = upgradeLevel(u);
    final cost = u.costFrom(level);
    if (cost == null || cost > wallet) return false;
    await _prefs.setInt(_kWallet, wallet - cost);
    await _prefs.setInt(_kUpgrade(u), level + 1);
    notifyListeners();
    return true;
  }

  Future<bool> spendGems(int amount) async {
    if (amount < 0 || amount > gems) return false;
    await _prefs.setInt(_kGems, gems - amount);
    notifyListeners();
    return true;
  }

  // ── worlds ──
  /// Whether [r] can be picked on the world map: finished, or the one the
  /// route has reached, and built in this version.
  bool isUnlocked(Realm r) => r.playable && (isDone(r) || r == playRealm || r.index <= playRealm.index);

  /// The world picked on the home screen; defaults to where the route is.
  Realm get selectedRealm {
    final id = _prefs.getString(_kSelected);
    final r = id == null ? null : Realm.byId(id);
    return r != null && isUnlocked(r) ? r : playRealm;
  }

  Future<void> selectRealm(Realm r) async {
    if (!isUnlocked(r)) return;
    await _prefs.setString(_kSelected, r.id);
    notifyListeners();
  }

  /// The newest world the player has reached but not yet seen unlocked.
  Realm? get pendingUnlock {
    final r = playRealm;
    if (r == Realm.values.first || isDone(r)) return null;
    return _prefs.getString(_kUnlockSeen) == r.id ? null : r;
  }

  Future<void> markUnlockSeen(Realm r) async {
    await _prefs.setString(_kUnlockSeen, r.id);
    // Moving on: the home screen follows the route to the new world.
    await _prefs.setString(_kSelected, r.id);
    notifyListeners();
  }

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
  Future<bool> recordRun({required int metres, required int coins, int gems = 0, int xp = 0}) async {
    await _prefs.setInt(_kRuns, runs + 1);
    if (coins > 0) await _prefs.setInt(_kWallet, wallet + coins);
    if (gems > 0) await _prefs.setInt(_kGems, this.gems + gems);
    if (xp > 0) await _prefs.setInt(_kXp, this.xp + xp);
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

  Future<void> setMusicVolume(double v) async {
    await _prefs.setDouble(_kMusicVol, v.clamp(0.0, 1.0));
    notifyListeners();
  }

  Future<void> setSfxVolume(double v) async {
    await _prefs.setDouble(_kSfxVol, v.clamp(0.0, 1.0));
    notifyListeners();
  }

  Future<void> markIntroSeen() async {
    if (introSeen) return;
    await _prefs.setBool(_kIntro, true);
    notifyListeners();
  }

  Future<void> markTutorialDone() async {
    if (tutorialDone) return;
    await _prefs.setBool(_kTutorial, true);
    notifyListeners();
  }
}
