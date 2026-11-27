import 'dart:async';

import 'package:lottie/lottie.dart';
import 'package:material_ui/material_ui.dart';

import '../app_scope.dart';
import '../audio/game_audio.dart';
import '../data/player.dart';
import '../l10n/gen/app_localizations.dart';
import 'dr_theme.dart';
import 'pickup_icons.dart';
import 'story_intro_screen.dart';
import 'realm_postcard.dart';
import '../game/realm.dart';
import 'ui/game_ui.dart';
import 'ui/hero_runner.dart';

// ── reward celebration ──

/// A short burst over everything when the player collects a reward: rays,
/// the amount popping in and the reward chime. Taps or 1.6 s close it.
Future<void> showRewardBurst(BuildContext context, {int coins = 0, int gems = 0, String? title}) {
  final scope = AppScope.read(context);
  scope.audio.play(Sfx.reward);
  final reduce = reduceMotionOf(context);
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: const Color(0x99080418),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (ctx, _, _) => _RewardBurst(coins: coins, gems: gems, title: title, reduce: reduce),
  );
}

class _RewardBurst extends StatefulWidget {
  const _RewardBurst({required this.coins, required this.gems, required this.title, required this.reduce});

  final int coins;
  final int gems;
  final String? title;
  final bool reduce;

  @override
  State<_RewardBurst> createState() => _RewardBurstState();
}

class _RewardBurstState extends State<_RewardBurst> {
  Timer? _close;

  @override
  void initState() {
    super.initState();
    _close = Timer(const Duration(milliseconds: 1700), () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  void dispose() {
    _close?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    key: const Key('reward.burst'),
    onTap: () => Navigator.of(context).maybePop(),
    child: Material(
      type: MaterialType.transparency,
      child: Center(
        child: SizedBox(
          width: 340,
          height: 340,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Lottie.asset('assets/lottie/reward_burst.json', animate: !widget.reduce),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (context, v, child) => Transform.scale(scale: v, child: child),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.title != null) StrokeText(widget.title!, size: 28),
                    const SizedBox(height: 8),
                    if (widget.coins > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CoinIcon(size: 46),
                          const SizedBox(width: 8),
                          StrokeText('+${widget.coins}', size: 44, color: GameColors.gold),
                        ],
                      ),
                    if (widget.gems > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const GemIcon(size: 42),
                          const SizedBox(width: 8),
                          StrokeText('+${widget.gems}', size: 40, color: const Color(0xFF8BF0FF)),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ── daily reward ──

Future<void> showDailySheet(BuildContext context) => showGameSheet<void>(context, builder: (_) => const _DailySheet());

class _DailySheet extends StatelessWidget {
  const _DailySheet();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final progress = AppScope.of(context).progress;
    final now = DateTime.now();
    final today = progress.dailyDay(now);
    final canClaim = progress.canClaimDaily(now);
    return GameSheet(
      title: l.dailyTitle,
      tone: GameTone.pink,
      sheetKey: const Key('sheet.daily'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            canClaim ? l.dailyStreak : l.dailyCome,
            textAlign: TextAlign.center,
            style: const TextStyle(color: GameColors.textDim, fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var d = 0; d < 7; d++)
                _DayTile(
                  day: d,
                  reward: DailyReward.week[d],
                  claimed: d < today || (d == today && !canClaim),
                  current: d == today && canClaim,
                ),
            ],
          ),
          const SizedBox(height: 16),
          GameButton(
            key: const Key('daily.claim'),
            label: l.claim,
            icon: Icons.redeem_rounded,
            tone: GameTone.green,
            onPressed: canClaim
                ? () async {
                    final nav = Navigator.of(context);
                    final host = nav.context;
                    final reward = await progress.claimDaily(DateTime.now());
                    if (reward == null || !host.mounted) return;
                    nav.maybePop();
                    await showRewardBurst(host, coins: reward.coins, gems: reward.gems, title: l.dayN(today + 1));
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

/// The treasure each day of the week pays out, from the worlds' art packs.
const _dayArt = [
  'ayodhya/rewards/coin_stack',
  'ganga/rewards/brass_coin_pot',
  'himalayan/rewards/turquoise_mountain_jewel',
  'himalayan/rewards/copper_coin_box',
  'vijayanagar/rewards/temple_gold_coin_pot',
  'vijayanagar/rewards/carnelian_temple_jewel',
  'ayodhya/rewards/royal_gold_chest',
];

class _DayTile extends StatelessWidget {
  const _DayTile({required this.day, required this.reward, required this.claimed, required this.current});

  final int day;
  final DailyReward reward;
  final bool claimed;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final big = day == 6;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: big ? 150 : 92,
      height: 104,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: current
              ? const [Color(0xFFFFE27A), Color(0xFFFF9A1A)]
              : claimed
              ? const [Color(0xFF3B8E5A), Color(0xFF256B41)]
              : const [Color(0xFF5B45C2), Color(0xFF3A2A8C)],
        ),
        border: Border.all(color: current ? Colors.white : const Color(0x55FFFFFF), width: current ? 3 : 1.5),
        boxShadow: current ? const [BoxShadow(color: Color(0x88FFB020), blurRadius: 16)] : null,
      ),
      child: Stack(
        children: [
          Column(
            children: [
              StrokeText(l.dayN(day + 1), size: 15, maxLines: 1, strokeWidth: 3),
              const Spacer(),
              Image.asset(
                'assets/images/${_dayArt[day % _dayArt.length]}.webp',
                height: big ? 50 : 42,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (reward.coins > 0) const CoinIcon(size: 30),
                    if (reward.gems > 0) const GemIcon(size: 28),
                  ],
                ),
              ),
              const Spacer(),
              StrokeText(
                [if (reward.coins > 0) '${reward.coins}', if (reward.gems > 0) '${reward.gems}♦'].join(' + '),
                size: 16,
                maxLines: 1,
                strokeWidth: 3,
              ),
            ],
          ),
          if (claimed)
            const Align(
              alignment: Alignment.center,
              child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 40),
            ),
        ],
      ),
    );
  }
}

// ── missions ──

Future<void> showMissionsSheet(BuildContext context) =>
    showGameSheet<void>(context, builder: (_) => const _MissionsSheet());

String missionText(AppLocalizations l, MissionDef m) => switch (m.kind) {
  MissionKind.coinsInRun => l.missionCoinsInRun(m.goal),
  MissionKind.metresInRun => l.missionMetresInRun(m.goal),
  MissionKind.jumps => l.missionJumps(m.goal),
  MissionKind.slides => l.missionSlides(m.goal),
  MissionKind.nearMisses => l.missionNearMisses(m.goal),
  MissionKind.gems => l.missionGems(m.goal),
  MissionKind.boosts => l.missionBoosts(m.goal),
  MissionKind.finishStage => l.missionFinish,
  MissionKind.runs => l.missionRuns(m.goal),
  MissionKind.coinsTotal => l.missionCoinsTotal(m.goal),
};

IconData missionIcon(MissionKind k) => switch (k) {
  MissionKind.coinsInRun || MissionKind.coinsTotal => Icons.paid_rounded,
  MissionKind.metresInRun => Icons.directions_run_rounded,
  MissionKind.jumps => Icons.keyboard_double_arrow_up_rounded,
  MissionKind.slides => Icons.keyboard_double_arrow_down_rounded,
  MissionKind.nearMisses => Icons.bolt_rounded,
  MissionKind.gems => Icons.diamond_rounded,
  MissionKind.boosts => Icons.flight_rounded,
  MissionKind.finishStage => Icons.emoji_events_rounded,
  MissionKind.runs => Icons.replay_rounded,
};

class _MissionsSheet extends StatelessWidget {
  const _MissionsSheet();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final progress = AppScope.of(context).progress;
    final slots = progress.missions;
    return GameSheet(
      title: l.missionsTitle,
      tone: GameTone.green,
      sheetKey: const Key('sheet.missions'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l.missionsHint,
            textAlign: TextAlign.center,
            style: const TextStyle(color: GameColors.textDim, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < slots.length; i++) ...[
            MissionRow(
              key: Key('mission.$i'),
              def: slots[i].def,
              progress: slots[i].progress,
              onClaim: slots[i].done
                  ? () async {
                      final def = slots[i].def;
                      final host = Navigator.of(context).context;
                      AppScope.read(context).audio.play(Sfx.mission);
                      await progress.claimMission(i);
                      if (!host.mounted) return;
                      await showRewardBurst(host, coins: def.reward, gems: def.gemReward);
                    }
                  : null,
            ),
            if (i < slots.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

/// One mission: icon, what to do, a progress bar and its reward or a Claim
/// button.
class MissionRow extends StatelessWidget {
  const MissionRow({super.key, required this.def, required this.progress, this.onClaim, this.compact = false});

  final MissionDef def;
  final int progress;
  final VoidCallback? onClaim;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final done = progress >= def.goal;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: done ? const Color(0x553FD46B) : const Color(0x33000000),
        border: Border.all(color: done ? GameColors.green : const Color(0x33FFFFFF), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: done ? GameTone.green.face : GameTone.purple.face,
              ),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(missionIcon(def.kind), color: Colors.white, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  missionText(l, def),
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, height: 1.15),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: GameProgressBar(value: progress / def.goal, height: 10)),
                    const SizedBox(width: 8),
                    Text(
                      '${progress.clamp(0, def.goal)}/${def.goal}',
                      style: const TextStyle(color: GameColors.textDim, fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 10),
            if (done && onClaim != null)
              GameButton(
                key: const Key('mission.claim'),
                label: l.claim,
                tone: GameTone.green,
                height: 42,
                onPressed: onClaim,
              )
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CoinIcon(size: 18),
                      const SizedBox(width: 3),
                      Text(
                        '${def.reward}',
                        style: const TextStyle(color: GameColors.gold, fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                    ],
                  ),
                  if (def.gemReward > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const GemIcon(size: 16),
                        const SizedBox(width: 3),
                        Text(
                          '${def.gemReward}',
                          style: const TextStyle(color: Color(0xFF8BF0FF), fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ],
                    ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}

// ── shop ──

Future<void> showShopSheet(BuildContext context) => showGameSheet<void>(context, builder: (_) => const _ShopSheet());

class _ShopSheet extends StatelessWidget {
  const _ShopSheet();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scope = AppScope.of(context);
    final progress = scope.progress;
    return GameSheet(
      title: l.shopTitle,
      tone: GameTone.gold,
      sheetKey: const Key('sheet.shop'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CurrencyChip(icon: const CoinIcon(size: 34), value: progress.wallet, width: 130),
              const SizedBox(width: 12),
              CurrencyChip(icon: const GemIcon(size: 34), value: progress.gems, width: 90),
            ],
          ),
          const SizedBox(height: 12),
          StrokeText(l.upgradesTitle, size: 18, align: TextAlign.left, maxLines: 1, strokeWidth: 3),
          const SizedBox(height: 8),
          for (final u in Upgrade.values) ...[
            _UpgradeRow(
              upgrade: u,
              level: progress.upgradeLevel(u),
              wallet: progress.wallet,
              onBuy: () async {
                if (await progress.buyUpgrade(u)) scope.audio.play(Sfx.unlock);
              },
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _UpgradeRow extends StatelessWidget {
  const _UpgradeRow({required this.upgrade, required this.level, required this.wallet, required this.onBuy});

  final Upgrade upgrade;
  final int level;
  final int wallet;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cost = upgrade.costFrom(level);
    final name = upgrade == Upgrade.feather ? l.upgradeFeather : l.upgradeLotus;
    return Container(
      key: Key('shop.${upgrade.name}'),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0x33000000),
        border: Border.all(color: const Color(0x33FFFFFF), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [Color(0xFF6A4FD8), Color(0xFF2B1E70)]),
            ),
            child: upgrade == Upgrade.feather ? const FeatherIcon(size: 38) : const LotusIcon(size: 38),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                Text(
                  l.upgradeSeconds(upgrade.seconds(level).toStringAsFixed(1)),
                  style: const TextStyle(color: GameColors.textDim, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    for (var i = 0; i < Upgrade.maxLevel; i++)
                      Container(
                        width: 18,
                        height: 8,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: i < level ? GameColors.gold : const Color(0x33FFFFFF),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (cost == null)
            StrokeText(l.maxed, size: 18, color: GameColors.gold)
          else
            GameButton(
              key: Key('shop.${upgrade.name}.buy'),
              label: '$cost',
              leading: const CoinIcon(size: 20),
              tone: GameTone.green,
              height: 44,
              onPressed: cost <= wallet ? onBuy : null,
            ),
        ],
      ),
    );
  }
}

// ── heroes ──

Future<void> showHeroSheet(BuildContext context) => showGameSheet<void>(context, builder: (_) => const _HeroSheet());

class _HeroSheet extends StatefulWidget {
  const _HeroSheet();

  @override
  State<_HeroSheet> createState() => _HeroSheetState();
}

/// The king's wardrobe: one royal outfit per world. The selected world's
/// outfit runs toward you in the preview; reaching a world unlocks its look.
class _HeroSheetState extends State<_HeroSheet> {
  Realm? _shown;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final progress = AppScope.of(context).progress;
    final shown = _shown ?? progress.selectedRealm;
    return GameSheet(
      title: l.heroTitle,
      tone: GameTone.blue,
      sheetKey: const Key('sheet.hero'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 230,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GameColors.gold, width: 3),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                RealmPostcard(realm: shown, alignmentY: 0.2),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(radius: 0.8, colors: [Color(0x55FFF0B0), Color(0xAA120A2E)]),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, 0.9),
                  child: HeroRunner(key: const Key('hero.preview'), height: 196, fps: 12, outfit: shown, front: true),
                ),
                Positioned(
                  left: 10,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xCC120A2E), borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      shown.name(l),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          StrokeText(l.heroKing, size: 24),
          Text(
            l.heroOutfitsHint,
            textAlign: TextAlign.center,
            style: const TextStyle(color: GameColors.textDim, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: Realm.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final r = Realm.values[i];
                final open = progress.isUnlocked(r);
                final selected = r == shown;
                return Semantics(
                  button: true,
                  selected: selected,
                  label: open ? r.name(l) : '${r.name(l)}: ${l.routeTodo}',
                  excludeSemantics: true,
                  child: GestureDetector(
                    key: Key('hero.outfit.${r.id}'),
                    onTap: () {
                      tapFeedback(context);
                      setState(() => _shown = r);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 66,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: selected ? GameTone.gold.face : const [Color(0xFF4B3C9E), Color(0xFF2B1E70)],
                        ),
                        border: Border.all(color: selected ? Colors.white : const Color(0x44FFFFFF), width: 2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 4, 4, 16),
                            child: ColorFiltered(
                              colorFilter: open
                                  ? const ColorFilter.mode(Color(0x00000000), BlendMode.dst)
                                  : const ColorFilter.mode(Color(0xDD1A1240), BlendMode.srcATop),
                              child: Image.asset(
                                'assets/images/hero/${r.id}/front_01.webp',
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const SizedBox(),
                              ),
                            ),
                          ),
                          if (!open) const Icon(Icons.lock_rounded, color: Color(0xCCFFFFFF), size: 22),
                          Positioned(bottom: 3, child: StrokeText('${i + 1}', size: 13, strokeWidth: 2.5)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── settings ──

Future<void> showSettingsSheet(BuildContext context) =>
    showGameSheet<void>(context, builder: (_) => const _SettingsSheet());

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scope = AppScope.of(context);
    return GameSheet(
      title: l.settingsTitle,
      tone: GameTone.purple,
      sheetKey: const Key('sheet.settings'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SoundSettings(),
          const SizedBox(height: 14),
          GameButton(
            key: const Key('settings.replayIntro'),
            label: l.replayIntro,
            icon: Icons.movie_rounded,
            tone: GameTone.blue,
            expand: true,
            height: 52,
            onPressed: () {
              final nav = Navigator.of(context);
              nav.maybePop();
              nav.push(
                GameRoute<void>(
                  builder: (_) => const StoryIntroScreen(),
                  settings: const RouteSettings(name: '/story'),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Opacity(
            opacity: 0.85,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/brand/mmyp_logo.webp', width: 34, height: 34),
                const SizedBox(width: 8),
                Text(
                  l.creditsLine,
                  style: const TextStyle(color: GameColors.textDim, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          if (scope.progress.muted) const SizedBox.shrink(),
        ],
      ),
    );
  }
}

/// Music and effects volume sliders and the mute switch, used by Settings
/// and the pause screen.
class SoundSettings extends StatelessWidget {
  const SoundSettings({super.key, this.muteKey = const Key('hub.sound')});

  final Key muteKey;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scope = AppScope.of(context);
    final progress = scope.progress;
    final audio = scope.audio;
    Widget slider(String label, IconData icon, double value, ValueChanged<double> onChanged, Key key) => Row(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 8),
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
        Expanded(
          child: Slider(key: key, value: value, onChanged: progress.muted ? null : onChanged),
        ),
      ],
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        slider(l.musicVolume, Icons.music_note_rounded, progress.musicVolume, (v) {
          progress.setMusicVolume(v);
          audio.setMusicVolume(v);
        }, const Key('settings.music')),
        slider(l.sfxVolume, Icons.graphic_eq_rounded, progress.sfxVolume, (v) {
          progress.setSfxVolume(v);
          audio.setSfxVolume(v);
        }, const Key('settings.sfx')),
        SwitchListTile(
          key: muteKey,
          contentPadding: EdgeInsets.zero,
          value: progress.muted,
          activeThumbColor: GameColors.saffron,
          title: Text(
            l.muteAll,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          secondary: Icon(progress.muted ? Icons.volume_off_rounded : Icons.volume_up_rounded, color: Colors.white),
          onChanged: (v) {
            progress.setMuted(v);
            audio.muted = v;
          },
        ),
      ],
    );
  }
}
