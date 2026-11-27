import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../game/dwarka_run_game.dart';
import '../l10n/gen/app_localizations.dart';
import 'pickup_icons.dart';
import 'ui/game_ui.dart';

/// The in-run heads-up display: score, distance, the stage progress bar,
/// coins, pause, the Lotus charm timer and the Garuda feather button. Every
/// control has a stable key for tests.
class RunHudOverlay extends StatelessWidget {
  const RunHudOverlay({
    super.key,
    required this.hud,
    required this.targetMetres,
    required this.onPause,
    required this.onBoost,
    required this.worldName,
  });

  final ValueListenable<RunHud> hud;
  final int targetMetres;
  final VoidCallback onPause;
  final VoidCallback onBoost;
  final String worldName;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: ValueListenableBuilder<RunHud>(
        valueListenable: hud,
        builder: (context, h, _) => Stack(
          children: [
            Positioned(
              left: 12,
              right: 12,
              top: 8,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Score and distance.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          label: '${l.scoreLabel}: ${h.score}',
                          excludeSemantics: true,
                          child: StrokeText(
                            '${h.score}',
                            key: const Key('hud.score'),
                            size: 30,
                            align: TextAlign.left,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _Pill(
                          key: const Key('hud.distance'),
                          semantics: l.hudDistance(h.metres),
                          icon: const Icon(Icons.directions_run_rounded, color: GameColors.gold, size: 18),
                          text: l.metresValue(h.metres),
                        ),
                        const SizedBox(height: 6),
                        _StageProgress(
                          value: h.progress,
                          name: worldName,
                          label: l.distanceToGo((targetMetres - h.metres).clamp(0, targetMetres)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          _CoinCounter(coins: h.coins, semantics: l.hudCoins(h.coins)),
                          const SizedBox(width: 8),
                          RoundGameButton(
                            key: const Key('hud.pause'),
                            icon: Icons.pause_rounded,
                            label: l.hudPause,
                            size: 50,
                            onPressed: onPause,
                          ),
                        ],
                      ),
                      if (h.magnet)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, right: 4),
                          child: Container(
                            key: const Key('hud.magnet'),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xCC120A2E),
                              border: Border.all(color: GameColors.pink, width: 2.5),
                            ),
                            child: const LotusIcon(size: 26),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: 20,
              child: _BoostButton(charges: h.boostCharges, active: h.boosting, onTap: onBoost),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({super.key, required this.semantics, required this.icon, required this.text});

  final String semantics;
  final Widget icon;
  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semantics,
    excludeSemantics: true,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xB3120A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x40FFFFFF), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, height: 1.2),
          ),
        ],
      ),
    ),
  );
}

/// The coin total, which hops each time it goes up.
class _CoinCounter extends StatefulWidget {
  const _CoinCounter({required this.coins, required this.semantics});

  final int coins;
  final String semantics;

  @override
  State<_CoinCounter> createState() => _CoinCounterState();
}

class _CoinCounterState extends State<_CoinCounter> with SingleTickerProviderStateMixin {
  late final AnimationController _bump = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));

  @override
  void didUpdateWidget(covariant _CoinCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.coins > oldWidget.coins) _bump.forward(from: 0);
  }

  @override
  void dispose() {
    _bump.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.semantics,
    excludeSemantics: true,
    child: AnimatedBuilder(
      animation: _bump,
      builder: (context, child) {
        final v = _bump.value;
        return Transform.scale(scale: 1 + 0.18 * (v < 0.5 ? v * 2 : (1 - v) * 2), child: child);
      },
      child: Container(
        key: const Key('hud.coins'),
        height: 40,
        padding: const EdgeInsets.fromLTRB(4, 3, 12, 3),
        decoration: BoxDecoration(
          color: const Color(0xB3120A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x80FFD34A), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CoinIcon(size: 30),
            const SizedBox(width: 6),
            Text(
              '${widget.coins}',
              style: const TextStyle(
                fontFamily: kBodyFont,
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _StageProgress extends StatelessWidget {
  const _StageProgress({required this.value, required this.name, required this.label});

  final double value;
  final String name;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    excludeSemantics: true,
    child: SizedBox(
      width: 170,
      child: Row(
        children: [
          Expanded(child: GameProgressBar(value: value, height: 12)),
          const SizedBox(width: 4),
          const Icon(Icons.flag_rounded, color: GameColors.gold, size: 20),
        ],
      ),
    ),
  );
}

class _BoostButton extends StatelessWidget {
  const _BoostButton({required this.charges, required this.active, required this.onTap});

  final int charges;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ready = charges > 0 && !active;
    return Semantics(
      button: true,
      enabled: ready,
      label: l.hudBoost(charges),
      excludeSemantics: true,
      child: GestureDetector(
        key: const Key('hud.boost'),
        onTap: ready
            ? () {
                tapFeedback(context);
                onTap();
              }
            : null,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: ready ? 1 : 0.9,
          child: Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: ready ? GameTone.blue.face : const [Color(0xCC3A2A8C), Color(0xCC1F1452)],
              ),
              border: Border.all(color: ready ? Colors.white : const Color(0x66FFFFFF), width: 3),
              boxShadow: ready ? const [BoxShadow(color: Color(0x883FB4FF), blurRadius: 16, spreadRadius: 2)] : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                FeatherIcon(size: 42, dim: !ready && !active),
                Positioned(
                  bottom: 8,
                  child: Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Container(
                          width: 9,
                          height: 9,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < charges ? GameColors.gold : const Color(0x55FFFFFF),
                            border: Border.all(color: const Color(0x99000000), width: 1),
                          ),
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
}
