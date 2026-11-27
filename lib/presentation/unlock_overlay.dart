import 'dart:math' as math;

import 'package:lottie/lottie.dart';
import 'package:material_ui/material_ui.dart';

import '../app_scope.dart';
import '../audio/game_audio.dart';
import '../game/realm.dart';
import '../l10n/gen/app_localizations.dart';
import 'dr_theme.dart';
import 'realm_postcard.dart';
import 'ui/game_ui.dart';

/// The new-world moment: the world's card flies in behind a lock, the lock
/// shakes and bursts open with a chime, light rays and confetti, then the
/// name lands.
Future<void> showUnlockOverlay(BuildContext context, Realm realm) {
  final scope = AppScope.read(context);
  scope.audio.play(Sfx.stageWhoosh, volume: 0.7);
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: const Color(0xE6080418),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, _, _) => UnlockOverlay(realm: realm),
  );
}

class UnlockOverlay extends StatefulWidget {
  const UnlockOverlay({super.key, required this.realm});

  final Realm realm;

  @override
  State<UnlockOverlay> createState() => _UnlockOverlayState();
}

class _UnlockOverlayState extends State<UnlockOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
  bool _chimed = false;

  static const _open = 0.42;

  @override
  void initState() {
    super.initState();
    _t.addListener(() {
      if (!_chimed && _t.value >= _open) {
        _chimed = true;
        AppScope.read(context).audio.play(Sfx.unlock);
      }
    });
    _t.forward();
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    await AppScope.read(context).progress.markUnlockSeen(widget.realm);
    if (mounted) Navigator.of(context).pop();
  }

  static double _seg(double t, double a, double b, [Curve c = Curves.easeOut]) =>
      c.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final reduce = reduceMotionOf(context);
    return Material(
      key: const Key('unlock.overlay'),
      type: MaterialType.transparency,
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, _) {
          final t = _t.value;
          final cardIn = _seg(t, 0, 0.25, Curves.easeOutBack);
          final shake = t < _open ? math.sin(t * 90) * 0.18 * _seg(t, 0.15, _open) : 0.0;
          final lockGone = _seg(t, _open, _open + 0.15, Curves.easeIn);
          final after = _seg(t, _open, _open + 0.3);
          final nameIn = _seg(t, 0.55, 0.8, Curves.elasticOut);
          return Stack(
            fit: StackFit.expand,
            children: [
              if (after > 0)
                Center(
                  child: Opacity(
                    opacity: after,
                    child: SizedBox(
                      width: 520,
                      height: 520,
                      child: Lottie.asset('assets/lottie/reward_burst.json', animate: !reduce),
                    ),
                  ),
                ),
              if (after > 0 && !reduce)
                Lottie.asset('assets/lottie/confetti.json', repeat: false, fit: BoxFit.cover),
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: _seg(t, 0.5, 0.7),
                      child: RibbonTitle(l.newWorldUnlocked, size: 24),
                    ),
                    const SizedBox(height: 24),
                    Transform.scale(
                      scale: 0.3 + 0.7 * cardIn,
                      child: Opacity(
                        opacity: cardIn.clamp(0.0, 1.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 290,
                              height: 200,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: GameColors.gold, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(255, 200, 60, 0.6 * after),
                                    blurRadius: 40,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  Color.fromRGBO(18, 10, 46, 0.7 * (1 - after)),
                                  BlendMode.srcATop,
                                ),
                                child: RealmPostcard(realm: widget.realm),
                              ),
                            ),
                            if (lockGone < 1)
                              Transform.translate(
                                offset: Offset(0, -60 * lockGone),
                                child: Transform.rotate(
                                  angle: shake,
                                  child: Transform.scale(
                                    scale: 1 + lockGone * 0.8,
                                    child: Opacity(
                                      opacity: 1 - lockGone,
                                      child: Container(
                                        width: 86,
                                        height: 86,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: GameTone.gold.face,
                                          ),
                                          border: Border.all(color: Colors.white, width: 3),
                                        ),
                                        child: Icon(
                                          lockGone > 0 ? Icons.lock_open_rounded : Icons.lock_rounded,
                                          color: Colors.white,
                                          size: 46,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Transform.scale(
                      scale: nameIn,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Text(
                              l.stageNumber(widget.realm.index + 1),
                              style: const TextStyle(color: GameColors.gold, fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            StrokeText(widget.realm.name(l), size: 34),
                            const SizedBox(height: 4),
                            Text(
                              widget.realm.blurb(l),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: GameColors.textDim, fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Opacity(
                      opacity: _seg(t, 0.75, 0.95),
                      child: GameButton(
                        key: const Key('unlock.go'),
                        label: l.letsGo,
                        icon: Icons.play_arrow_rounded,
                        height: 64,
                        onPressed: t >= 0.75 ? _go : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
