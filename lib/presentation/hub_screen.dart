import 'package:material_ui/material_ui.dart';

import '../app_scope.dart';
import '../game/art_library.dart';
import '../game/realm.dart';
import '../game/season.dart';
import '../l10n/gen/app_localizations.dart';
import 'dr_theme.dart';
import 'pickup_icons.dart';
import 'realm_postcard.dart';
import 'run_screen.dart';

/// The hub: title, the next stop with a Play button, wallet, best run, the
/// yatra route and how to play.
class HubScreen extends StatefulWidget {
  const HubScreen({super.key});

  @override
  State<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends State<HubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppScope.read(context).analytics.gameOpen();
    });
  }

  void _play(Realm realm) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RunScreen(realm: realm),
        settings: const RouteSettings(name: '/run'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scope = AppScope.of(context);
    final progress = scope.progress;
    final next = progress.nextRealm;
    final playRealm = progress.playRealm;
    // Get the next stage's art pack ready while the player is on the hub.
    ArtLibrary.instance.loadStage(playRealm);

    final String playLabel;
    if (next == null || !next.playable) {
      playLabel = l.hubRunAgain(playRealm.name(l));
    } else if (progress.realmsDone.isEmpty) {
      playLabel = l.hubStartYatra;
    } else {
      playLabel = l.hubContinueTo(next.name(l));
    }
    final shown = next ?? playRealm;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                _Header(
                  muted: progress.muted,
                  onToggleSound: () {
                    final muted = !progress.muted;
                    progress.setMuted(muted);
                    scope.audio.muted = muted;
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        key: const Key('hub.wallet'),
                        label: l.walletLabel,
                        value: l.mudraCount(progress.wallet),
                        icon: const CoinIcon(size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        key: const Key('hub.best'),
                        label: l.bestLabel,
                        value: l.metresValue(progress.bestMetres),
                        icon: const Icon(Icons.emoji_events_rounded, color: DrColors.saffron),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _NextStopCard(
                  realm: shown,
                  playRealm: playRealm,
                  playLabel: playLabel,
                  comingSoon: next != null && !next.playable,
                  onPlay: () => _play(playRealm),
                ),
                const SizedBox(height: 14),
                _RouteCard(done: progress.realmsDone),
                const SizedBox(height: 14),
                const _HowToCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.muted, required this.onToggleSound});

  final bool muted;
  final VoidCallback onToggleSound;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        ExcludeSemantics(
          child: Image.asset(
            'assets/images/brand/logo.webp',
            key: const Key('hub.logo'),
            width: 64,
            height: 64,
            errorBuilder: (_, _, _) => const SizedBox(width: 64, height: 64),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l.appTitle,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: DrColors.indigo,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(l.hubTagline, style: const TextStyle(color: DrColors.inkMuted, fontSize: 15)),
            ],
          ),
        ),
        Semantics(
          button: true,
          toggled: !muted,
          label: muted ? l.soundOff : l.soundOn,
          excludeSemantics: true,
          child: IconButton.filledTonal(
            key: const Key('hub.sound'),
            iconSize: 28,
            constraints: const BoxConstraints(minWidth: 52, minHeight: 52),
            onPressed: onToggleSound,
            icon: Icon(muted ? Icons.volume_off_rounded : Icons.volume_up_rounded),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({super.key, required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final Widget icon;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: $value',
    excludeSemantics: true,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: drCard(),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: DrColors.inkMuted, fontSize: 13)),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _NextStopCard extends StatelessWidget {
  const _NextStopCard({
    required this.realm,
    required this.playRealm,
    required this.playLabel,
    required this.comingSoon,
    required this.onPlay,
  });

  final Realm realm;
  final Realm playRealm;
  final String playLabel;
  final bool comingSoon;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      key: const Key('hub.nextStop'),
      decoration: drCard(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 170, child: RealmPostcard(realm: realm)),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.hubNextStop,
                  style: const TextStyle(
                    color: DrColors.saffron,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(realm.name(l), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                Text(realm.blurb(l), style: const TextStyle(color: DrColors.inkMuted)),
                const SizedBox(height: 6),
                Text(
                  comingSoon ? l.hubComingSoon(realm.name(l), playRealm.name(l)) : l.hubTarget(realm.targetMetres),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Center(
                  child: PulsingPlayButton(label: playLabel, onPressed: onPlay),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The Play button. It breathes gently to invite a tap, except when the
/// player has asked for reduced motion.
class PulsingPlayButton extends StatefulWidget {
  const PulsingPlayButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<PulsingPlayButton> createState() => _PulsingPlayButtonState();
}

class _PulsingPlayButtonState extends State<PulsingPlayButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotionOf(context)) {
      _pulse
        ..stop()
        ..value = 0;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final button = DrButton(
      key: const Key('hub.play'),
      label: widget.label,
      icon: Icons.play_arrow_rounded,
      onPressed: widget.onPressed,
    );
    if (reduceMotionOf(context)) return button;
    return ScaleTransition(
      key: const Key('hub.play.pulse'),
      scale: Tween(begin: 1.0, end: 1.06).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
      child: button,
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.done});

  final Set<String> done;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: drCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l.seasonLabel(Season.jambudvipa.number)} · ${l.seasonJambudvipa}',
            key: const Key('hub.season'),
            style: const TextStyle(
              color: DrColors.saffron,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Semantics(
            header: true,
            child: Text(l.routeTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 2),
          Text(l.seasonJambudvipaBlurb, style: const TextStyle(color: DrColors.inkMuted, fontSize: 13)),
          const SizedBox(height: 10),
          for (final (i, realm) in Season.jambudvipa.realms.indexed)
            _RouteStop(realm: realm, done: done.contains(realm.id), last: i == Season.jambudvipa.realms.length - 1),
        ],
      ),
    );
  }
}

class _RouteStop extends StatelessWidget {
  const _RouteStop({required this.realm, required this.done, required this.last});

  final Realm realm;
  final bool done;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = done ? l.routeDone : (realm.playable ? l.routeTodo : l.routeComingSoon);
    return Semantics(
      key: Key('play.route.${realm.id}.${done ? 'done' : 'todo'}'),
      label: l.routeStateLabel(realm.name(l), state),
      excludeSemantics: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 34,
              child: Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? DrColors.done : DrColors.cream,
                      border: Border.all(color: done ? DrColors.done : realm.palette.pathEdge, width: 3),
                    ),
                    child: done
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                        : Center(
                            child: Text(
                              '${realm.index + 1}',
                              style: TextStyle(fontWeight: FontWeight.w800, color: realm.palette.pathEdge),
                            ),
                          ),
                  ),
                  if (!last)
                    Expanded(child: Container(width: 3, color: done ? DrColors.done : const Color(0x332B1A4A))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: last ? 0 : 14, top: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(realm.name(l), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: done ? const Color(0x222E8B57) : const Color(0x142B1A4A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        state,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: done ? DrColors.done : DrColors.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HowToCard extends StatelessWidget {
  const _HowToCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget row(IconData icon, String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: DrColors.teal, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
    return Container(
      key: const Key('play.howto'),
      padding: const EdgeInsets.all(18),
      decoration: drCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(l.howToTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 8),
          row(Icons.swap_horiz_rounded, l.howToLanes),
          row(Icons.keyboard_double_arrow_up_rounded, l.howToJump),
          row(Icons.keyboard_double_arrow_down_rounded, l.howToSlide),
          row(Icons.keyboard_rounded, l.howToKeys),
          row(Icons.flight_rounded, l.howToBoost),
          row(Icons.local_florist_rounded, l.howToLotus),
          row(Icons.pets_rounded, l.howToMonkey),
        ],
      ),
    );
  }
}
