/// Player progression rules: levels, missions, daily rewards and upgrades.
/// Plain Dart, so tests can check them without Flutter.
library;

/// What one run achieved, for missions, XP and the game-over screen.
typedef RunStats = ({
  String realm,
  int metres,
  int coins,
  int gems,
  int jumps,
  int slides,
  int nearMisses,
  int boosts,
  bool finished,
});

/// Score shown at the end of a run.
int scoreOf(RunStats r) => r.metres + r.coins * 5 + r.gems * 50 + r.nearMisses * 25 + (r.finished ? 500 : 0);

/// Levels: level 1 at 0 XP, then each level needs 150 XP more than the last.
class Levels {
  static int xpToReach(int level) => level <= 1 ? 0 : 75 * (level - 1) * level;

  static int levelFor(int xp) {
    var level = 1;
    while (xpToReach(level + 1) <= xp) {
      level++;
    }
    return level;
  }

  /// 0..1 progress from the current level to the next.
  static double progress(int xp) {
    final l = levelFor(xp);
    final from = xpToReach(l), to = xpToReach(l + 1);
    return (xp - from) / (to - from);
  }

  /// XP a run earns.
  static int xpFor(RunStats r) => (scoreOf(r) / 10).round();
}

enum MissionKind { coinsInRun, metresInRun, jumps, slides, nearMisses, gems, boosts, finishStage, runs, coinsTotal }

class MissionDef {
  const MissionDef(this.kind, this.goal, this.reward, {this.gemReward = 0});

  final MissionKind kind;
  final int goal;
  final int reward;
  final int gemReward;

  /// Progress this run adds. "In a run" missions report their best single run.
  int measure(RunStats r) => switch (kind) {
    MissionKind.coinsInRun => r.coins,
    MissionKind.metresInRun => r.metres,
    MissionKind.jumps => r.jumps,
    MissionKind.slides => r.slides,
    MissionKind.nearMisses => r.nearMisses,
    MissionKind.gems => r.gems,
    MissionKind.boosts => r.boosts,
    MissionKind.finishStage => r.finished ? 1 : 0,
    MissionKind.runs => 1,
    MissionKind.coinsTotal => r.coins,
  };

  bool get perRun => kind == MissionKind.coinsInRun || kind == MissionKind.metresInRun;

  int xp() => 40 + reward ~/ 5;
}

/// Missions come up in this order, three at a time; after the list ends it
/// starts again with doubled goals and rewards.
const missionPool = [
  MissionDef(MissionKind.coinsInRun, 50, 100),
  MissionDef(MissionKind.jumps, 20, 100),
  MissionDef(MissionKind.metresInRun, 500, 150),
  MissionDef(MissionKind.slides, 15, 120),
  MissionDef(MissionKind.nearMisses, 5, 150),
  MissionDef(MissionKind.runs, 5, 120),
  MissionDef(MissionKind.gems, 3, 150, gemReward: 1),
  MissionDef(MissionKind.coinsInRun, 120, 200),
  MissionDef(MissionKind.boosts, 3, 200),
  MissionDef(MissionKind.finishStage, 1, 300, gemReward: 1),
  MissionDef(MissionKind.metresInRun, 1000, 250),
  MissionDef(MissionKind.coinsTotal, 600, 300),
  MissionDef(MissionKind.nearMisses, 15, 300, gemReward: 1),
  MissionDef(MissionKind.jumps, 80, 250),
  MissionDef(MissionKind.coinsInRun, 200, 350, gemReward: 1),
];

/// The mission at position [n] in the endless sequence.
MissionDef missionAt(int n) {
  final base = missionPool[n % missionPool.length];
  final round = n ~/ missionPool.length;
  if (round == 0) return base;
  final f = 1 << round.clamp(0, 4);
  return MissionDef(base.kind, base.goal * f, base.reward * f, gemReward: base.gemReward * f);
}

/// A mission in one of the three slots.
class MissionSlot {
  MissionSlot(this.index, this.progress);

  final int index;
  int progress;

  MissionDef get def => missionAt(index);
  bool get done => progress >= def.goal;

  String encode() => '$index:$progress';

  static MissionSlot decode(String s) {
    final parts = s.split(':');
    return MissionSlot(int.tryParse(parts.first) ?? 0, int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0);
  }
}

/// Seven-day login calendar. Day 7 is the big one; then it starts over.
class DailyReward {
  const DailyReward(this.coins, [this.gems = 0]);

  final int coins;
  final int gems;

  static const week = [
    DailyReward(100),
    DailyReward(150),
    DailyReward(0, 1),
    DailyReward(250),
    DailyReward(400),
    DailyReward(0, 2),
    DailyReward(1000, 3),
  ];

  /// Days since 2000-01-01, in local time.
  static int dayNumber(DateTime t) => DateTime.utc(t.year, t.month, t.day).difference(DateTime.utc(2000)).inDays;
}

/// Shop upgrades for the two power-ups.
enum Upgrade {
  feather,
  lotus;

  static const maxLevel = 5;
  static const _costs = [300, 700, 1400, 2600, 4500];

  /// Price of the next level, or null at the top.
  int? costFrom(int level) => level >= maxLevel ? null : _costs[level];

  /// Seconds the power-up lasts at [level].
  double seconds(int level) => switch (this) {
    Upgrade.feather => 3.2 + 0.6 * level,
    Upgrade.lotus => 8.0 + 2.0 * level,
  };
}

/// Gems a revive costs: 1, then 2, then 4 within one run.
int reviveCost(int revivesSoFar) => 1 << revivesSoFar;

/// Coins a revive costs instead of gems: always 100.
const reviveCoinCost = 100;

/// Revives allowed in one run.
const maxRevives = 3;
