import 'package:material_ui/material_ui.dart';

import '../app_scope.dart';
import '../game/realm.dart';
import '../game/season.dart';
import '../l10n/gen/app_localizations.dart';
import 'dr_theme.dart';
import 'realm_postcard.dart';
import 'ui/game_ui.dart';

/// The world map: a carousel of the season's ten worlds, each with its art,
/// story line, distance and state, and the route underneath. Picking an
/// open world returns it to the caller, which starts a run there.
class WorldsScreen extends StatefulWidget {
  const WorldsScreen({super.key});

  @override
  State<WorldsScreen> createState() => _WorldsScreenState();
}

class _WorldsScreenState extends State<WorldsScreen> {
  late final PageController _pages;
  late int _page;

  @override
  void initState() {
    super.initState();
    _page = 0;
    _pages = PageController(viewportFraction: 0.84);
  }

  bool _placed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_placed) {
      _placed = true;
      _page = AppScope.read(context).progress.selectedRealm.index;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pages.hasClients) _pages.jumpToPage(_page);
      });
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _goTo(int i) {
    tapFeedback(context);
    _pages.animateToPage(i, duration: const Duration(milliseconds: 420), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final progress = AppScope.of(context).progress;
    final season = Season.jambudvipa;
    final realms = season.realms;
    return Scaffold(
      backgroundColor: GameColors.night,
      body: GameBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Row(
                  children: [
                    RoundGameButton(
                      key: const Key('worlds.back'),
                      icon: Icons.arrow_back_rounded,
                      label: MaterialLocalizations.of(context).backButtonTooltip,
                      size: 46,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Center(child: RibbonTitle(l.selectWorld, size: 22))),
                    const SizedBox(width: 54),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${l.seasonLabel(season.number)} · ${l.seasonJambudvipa}',
                style: const TextStyle(color: GameColors.gold, fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: PageView.builder(
                  controller: _pages,
                  itemCount: realms.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) => AnimatedScale(
                    duration: const Duration(milliseconds: 250),
                    scale: i == _page ? 1 : 0.92,
                    child: _WorldCard(realm: realms[i]),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 64,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: realms.length,
                  itemBuilder: (context, i) {
                    final r = realms[i];
                    final done = progress.isDone(r);
                    return Row(
                      children: [
                        if (i > 0)
                          Container(
                            width: 14,
                            height: 4,
                            color: progress.isDone(realms[i - 1]) ? GameColors.green : const Color(0x44FFFFFF),
                          ),
                        Semantics(
                          button: true,
                          label: '${r.name(l)}: ${done ? l.routeDone : l.routeTodo}',
                          excludeSemantics: true,
                          child: GestureDetector(
                            key: Key('play.route.${r.id}.${done ? 'done' : 'todo'}'),
                            onTap: () => _goTo(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: i == _page ? 46 : 38,
                              height: i == _page ? 46 : 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: done
                                      ? GameTone.green.face
                                      : progress.isUnlocked(r)
                                      ? GameTone.orange.face
                                      : GameTone.grey.face,
                                ),
                                border: Border.all(color: i == _page ? Colors.white : const Color(0x88FFFFFF), width: 2.5),
                              ),
                              child: done
                                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                                  : StrokeText('${i + 1}', size: 17, strokeWidth: 3),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorldCard extends StatelessWidget {
  const _WorldCard({required this.realm});

  final Realm realm;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final progress = AppScope.of(context).progress;
    final done = progress.isDone(realm);
    final open = progress.isUnlocked(realm);
    final current = open && !done && realm == progress.playRealm;
    final String status;
    final Color statusColor;
    if (done) {
      status = l.worldCleared;
      statusColor = GameColors.green;
    } else if (current) {
      status = l.worldCurrent;
      statusColor = GameColors.saffron;
    } else if (!realm.playable) {
      status = l.worldArtSoon;
      statusColor = const Color(0xFF7E7896);
    } else {
      final before = Realm.values[(realm.index - 1).clamp(0, Realm.values.length - 1)];
      status = l.worldLockedHint(before.name(l));
      statusColor = const Color(0xFF7E7896);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Container(
        key: Key('worlds.card.${realm.id}'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: current ? GameColors.gold : const Color(0x66FFFFFF), width: current ? 3 : 2),
          boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 20, offset: Offset(0, 10))],
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [GameColors.panelTop, GameColors.panelBottom],
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 11,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColorFiltered(
                    colorFilter: open
                        ? const ColorFilter.mode(Color(0x00000000), BlendMode.dst)
                        : const ColorFilter.matrix([
                            0.3, 0.4, 0.1, 0, 0, //
                            0.3, 0.4, 0.1, 0, 0,
                            0.3, 0.4, 0.1, 0, 0,
                            0, 0, 0, 1, 0,
                          ]),
                    child: RealmPostcard(realm: realm),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00000000), Color(0x00000000), Color(0xCC2B1E70)],
                        stops: [0, 0.6, 1],
                      ),
                    ),
                  ),
                  if (!open)
                    Center(
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xAA120A2E),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Icon(
                          realm.playable ? Icons.lock_rounded : Icons.hourglass_top_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xCC120A2E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l.stageNumber(realm.index + 1),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: StrokeText(realm.name(l), size: 26, maxLines: 1),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      realm.blurb(l),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: GameColors.textDim, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.directions_run_rounded, color: GameColors.gold, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          l.metresValue(realm.targetMetres),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              status,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Center(
                      child: GameButton(
                        key: Key('worlds.play.${realm.id}'),
                        label: l.worldPlay,
                        icon: Icons.play_arrow_rounded,
                        height: 52,
                        tone: done ? GameTone.blue : GameTone.orange,
                        onPressed: open ? () => Navigator.of(context).pop(realm) : null,
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
