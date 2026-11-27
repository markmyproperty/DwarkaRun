import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../game/dwarka_run_game.dart';
import '../l10n/gen/app_localizations.dart';
import 'dr_theme.dart';
import 'pickup_icons.dart';

/// The in-run heads-up display: coins, distance, progress, pause and boost.
/// Every control has a stable key for tests.
class RunHudOverlay extends StatelessWidget {
  const RunHudOverlay({
    super.key,
    required this.hud,
    required this.targetMetres,
    required this.onPause,
    required this.onBoost,
  });

  final ValueListenable<RunHud> hud;
  final int targetMetres;
  final VoidCallback onPause;
  final VoidCallback onBoost;

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
                  _Chip(
                    key: const Key('hud.coins'),
                    semantics: l.hudCoins(h.coins),
                    icon: const CoinIcon(size: 22),
                    text: '${h.coins}',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Chip(
                          key: const Key('hud.distance'),
                          semantics: l.hudDistance(h.metres),
                          icon: const Icon(Icons.directions_run, color: Colors.white, size: 20),
                          text: l.metresValue(h.metres),
                        ),
                        const SizedBox(height: 6),
                        _Progress(
                          value: h.progress,
                          label: l.distanceToGo((targetMetres - h.metres).clamp(0, targetMetres)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Semantics(
                    button: true,
                    label: l.hudPause,
                    excludeSemantics: true,
                    child: Material(
                      color: const Color(0xCC2B1A4A),
                      shape: const CircleBorder(),
                      child: InkWell(
                        key: const Key('hud.pause'),
                        customBorder: const CircleBorder(),
                        onTap: onPause,
                        child: const SizedBox(
                          width: 52,
                          height: 52,
                          child: Icon(Icons.pause_rounded, color: Colors.white, size: 30),
                        ),
                      ),
                    ),
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

class _Chip extends StatelessWidget {
  const _Chip({super.key, required this.semantics, required this.icon, required this.text});

  final String semantics;
  final Widget icon;
  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semantics,
    excludeSemantics: true,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xCC2B1A4A), borderRadius: BorderRadius.circular(22)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ),
  );
}

class _Progress extends StatelessWidget {
  const _Progress({required this.value, required this.label});

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    excludeSemantics: true,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 8,
        width: 160,
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: const Color(0x662B1A4A),
          valueColor: const AlwaysStoppedAnimation(DrColors.gold),
        ),
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
      child: Material(
        color: ready ? DrColors.teal : const Color(0x992B1A4A),
        shape: const CircleBorder(side: BorderSide(color: Colors.white, width: 3)),
        child: InkWell(
          key: const Key('hud.boost'),
          customBorder: const CircleBorder(),
          onTap: ready ? onTap : null,
          child: SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                FeatherIcon(size: 40, dim: !ready && !active),
                Positioned(
                  bottom: 8,
                  child: Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < charges ? DrColors.gold : const Color(0x55FFFFFF),
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
