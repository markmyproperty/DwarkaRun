import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../game/dwarka_run_game.dart';
import '../game/realm.dart';
import '../game/run_simulation.dart';
import '../l10n/gen/app_localizations.dart';
import 'dr_theme.dart';
import 'pickup_icons.dart';

/// Dimmed backdrop with a centred card.
class _PanelFrame extends StatelessWidget {
  const _PanelFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0x992B1A4A),
    child: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
              decoration: drCard(),
              child: Material(type: MaterialType.transparency, child: child),
            ),
          ),
        ),
      ),
    ),
  );
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: DrColors.indigo),
    ),
  );
}

class PausePanel extends StatelessWidget {
  const PausePanel({
    super.key,
    required this.muted,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
    required this.onToggleMute,
  });

  final bool muted;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;
  final VoidCallback onToggleMute;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _PanelFrame(
      child: Column(
        key: const Key('pause.menu'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Title(l.pauseTitle),
          const SizedBox(height: 20),
          DrButton(
            key: const Key('pause.resume'),
            label: l.pauseResume,
            icon: Icons.play_arrow_rounded,
            onPressed: onResume,
          ),
          const SizedBox(height: 12),
          DrButton(
            key: const Key('pause.restart'),
            label: l.pauseRestart,
            icon: Icons.replay_rounded,
            primary: false,
            onPressed: onRestart,
          ),
          const SizedBox(height: 12),
          DrButton(
            key: const Key('pause.quit'),
            label: l.pauseQuit,
            icon: Icons.home_rounded,
            primary: false,
            onPressed: onQuit,
          ),
          const SizedBox(height: 8),
          Semantics(
            toggled: !muted,
            label: muted ? l.soundOff : l.soundOn,
            excludeSemantics: true,
            child: SwitchListTile(
              key: const Key('pause.mute'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: Text(muted ? l.soundOff : l.soundOn, style: const TextStyle(fontWeight: FontWeight.w600)),
              secondary: Icon(muted ? Icons.volume_off_rounded : Icons.volume_up_rounded, color: DrColors.indigo),
              value: !muted,
              onChanged: (_) => onToggleMute(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({super.key, required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final Widget? icon;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: $value',
    excludeSemantics: true,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: DrColors.sand, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: DrColors.inkMuted, fontSize: 13)),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 6)],
              Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: DrColors.ink),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class GameOverPanel extends StatelessWidget {
  const GameOverPanel({
    super.key,
    required this.score,
    required this.coins,
    required this.newBest,
    required this.onRetry,
    required this.onBack,
    this.splash = false,
    this.gapStyle = GapStyle.river,
  });

  final int score;
  final int coins;
  final bool newBest;

  /// The run ended in the river.
  final bool splash;

  /// What the hero fell into, when [splash] is set.
  final GapStyle gapStyle;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _PanelFrame(
      child: Column(
        key: const Key('gameover.panel'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Title(
            splash
                ? switch (gapStyle) {
                    GapStyle.river => l.gameOverSplash,
                    GapStyle.crevasse => l.gameOverCrevasse,
                    GapStyle.moat => l.gameOverMoat,
                  }
                : l.gameOverTitle,
          ),
          if (newBest) ...[
            const SizedBox(height: 8),
            Text(
              l.newBest,
              key: const Key('gameover.best'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: DrColors.saffron, fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _Stat(key: const Key('gameover.score'), label: l.scoreLabel, value: l.metresValue(score)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Stat(
                  key: const Key('gameover.coins'),
                  label: l.coinsCollected,
                  value: '$coins',
                  icon: const CoinIcon(size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DrButton(key: const Key('gameover.retry'), label: l.retry, icon: Icons.replay_rounded, onPressed: onRetry),
          const SizedBox(height: 12),
          DrButton(
            key: const Key('gameover.back'),
            label: l.backToHub,
            icon: Icons.home_rounded,
            primary: false,
            onPressed: onBack,
          ),
        ],
      ),
    );
  }
}

class RealmCompletePanel extends StatelessWidget {
  const RealmCompletePanel({
    super.key,
    required this.title,
    required this.coins,
    required this.metres,
    required this.onContinue,
  });

  final String title;
  final int coins;
  final int metres;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _PanelFrame(
      child: Column(
        key: const Key('complete.panel'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.flag_rounded, size: 44, color: DrColors.saffron),
          const SizedBox(height: 8),
          _Title(title),
          const SizedBox(height: 8),
          Text(
            l.realmCompleteBody,
            textAlign: TextAlign.center,
            style: const TextStyle(color: DrColors.inkMuted),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Stat(label: l.scoreLabel, value: l.metresValue(metres)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Stat(label: l.coinsCollected, value: '$coins', icon: const CoinIcon(size: 20)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DrButton(
            key: const Key('complete.continue'),
            label: l.continueLabel,
            icon: Icons.arrow_forward_rounded,
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}

/// Swipe hints for the gentle first-run opening, timed to the tutorial rows.
class TutorialHints extends StatelessWidget {
  const TutorialHints({super.key, required this.hud, required this.sim});

  final ValueListenable<RunHud> hud;
  final RunSimulation sim;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return IgnorePointer(
      child: ValueListenableBuilder<RunHud>(
        valueListenable: hud,
        builder: (context, h, _) {
          final m = h.metres;
          final (String? text, IconData icon) = m < 50
              ? (l.hintLanes, Icons.swap_horiz_rounded)
              : m < 92
              ? (l.hintJump, Icons.keyboard_double_arrow_up_rounded)
              : m < 133
              ? (l.hintSlide, Icons.keyboard_double_arrow_down_rounded)
              : (null, Icons.circle);
          if (text == null) return const SizedBox.shrink();
          return Align(
            alignment: const Alignment(0, 0.15),
            child: Container(
              key: const Key('run.hint'),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(color: const Color(0xD9FFF4E0), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: DrColors.indigo, size: 30),
                  const SizedBox(width: 10),
                  Text(
                    text,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: DrColors.indigo),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
