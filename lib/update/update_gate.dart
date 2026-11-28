import 'package:material_ui/material_ui.dart';

import '../l10n/gen/app_localizations.dart';
import '../presentation/ui/game_ui.dart';
import 'update_checker.dart';

/// Wraps the whole app. When the store has a newer version, it covers the
/// game with an "Update required" screen that cannot be dismissed, and opens
/// the store's updater. It checks at launch and every time the game comes
/// back to the foreground, so a player who backs out of the update is
/// stopped again.
class UpdateGate extends StatefulWidget {
  const UpdateGate({super.key, required this.checker, required this.child});

  final UpdateChecker checker;
  final Widget child;

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> with WidgetsBindingObserver {
  bool _required = false;
  bool _checking = false;
  bool _startedOnce = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    if (_checking) return;
    _checking = true;
    try {
      final required = await widget.checker.updateRequired();
      if (!mounted) return;
      setState(() => _required = required);
      // Open the updater straight away the first time; after that the
      // player taps the button.
      if (required && !_startedOnce) {
        _startedOnce = true;
        await widget.checker.startUpdate();
      }
    } finally {
      _checking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // The game keeps its state underneath but cannot be touched.
        IgnorePointer(ignoring: _required, child: widget.child),
        if (_required) _UpdateRequiredScreen(onUpdate: widget.checker.startUpdate),
      ],
    );
  }
}

class _UpdateRequiredScreen extends StatelessWidget {
  const _UpdateRequiredScreen({required this.onUpdate});

  final Future<void> Function() onUpdate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      child: Material(
        key: const Key('update-required'),
        color: const Color(0xEE1A0F2E),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GamePanel(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/brand/logo.webp', width: 120, height: 120),
                    const SizedBox(height: 16),
                    RibbonTitle(l.updateRequiredTitle),
                    const SizedBox(height: 16),
                    Text(
                      l.updateRequiredBody,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.35, fontFamily: 'Baloo', fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 20),
                    GameButton(
                      label: l.updateNow,
                      icon: Icons.system_update_alt_rounded,
                      tone: GameTone.green,
                      expand: true,
                      onPressed: () => onUpdate(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
