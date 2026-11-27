import '../game/run_simulation.dart';

/// Sound effects the game can play.
enum Sfx { coin, gem, jump, slide, crash, boost, monkey, fanfare }

/// Game sound, behind an interface so tests and silent builds need no audio
/// plugin. Real sound files arrive in a later stage; until then the game
/// uses [SilentAudio], and the mute setting is already wired through.
abstract class GameAudio {
  bool get muted;
  set muted(bool value);

  void play(Sfx sfx);

  /// Starts the music for a realm (by realm id).
  void playMusic(String realmId);
  void stopMusic();

  /// Maps a run event to its sound.
  void onRunEvent(RunEvent e) {
    final sfx = switch (e) {
      RunEvent.coin => Sfx.coin,
      RunEvent.gem => Sfx.gem,
      RunEvent.feather || RunEvent.lotus => Sfx.gem,
      RunEvent.jump => Sfx.jump,
      RunEvent.slide => Sfx.slide,
      RunEvent.crash => Sfx.crash,
      RunEvent.boostStart => Sfx.boost,
      RunEvent.monkeySteal => Sfx.monkey,
      RunEvent.finish => Sfx.fanfare,
      RunEvent.splash => Sfx.crash,
      RunEvent.laneChange || RunEvent.riverStart || RunEvent.bridgeStart => null,
    };
    if (sfx != null) play(sfx);
  }
}

/// Plays nothing, but remembers what it was asked to play.
class SilentAudio extends GameAudio {
  @override
  bool muted = false;

  final List<Sfx> played = [];

  @override
  void play(Sfx sfx) {
    if (!muted) played.add(sfx);
  }

  @override
  void playMusic(String realmId) {}

  @override
  void stopMusic() {}
}
