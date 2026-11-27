import '../game/run_simulation.dart';

/// Sound effects the game can play.
enum Sfx { coin, gem, jump, slide, crash, boost, monkey, fanfare }

/// Game sound, behind an interface so tests need no audio plugin. The app
/// uses [MusicAudio] (lib/audio/music_audio.dart); tests use [SilentAudio].
abstract class GameAudio {
  /// Background music per stage id, as asset paths under `assets/`.
  static const musicTracks = {
    'ayodhya': 'audio/ayodhya_run.mp3',
    'ganga': 'audio/ganga_run.mp3',
    'pharaoh': 'audio/thar_desert_run.mp3',
    'himalayan': 'audio/himalayan_run.mp3',
  };

  bool get muted;
  set muted(bool value);

  void play(Sfx sfx);

  /// Starts the looping music for a realm (by realm id). Keeps playing,
  /// without restarting, if that realm's track is already on.
  void playMusic(String realmId);
  void stopMusic();

  /// Holds the music while the game is paused, and picks it up again.
  void pauseMusic();
  void resumeMusic();

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

  /// The track that would be heard now, or null.
  String? get music => muted || _paused ? null : _track;
  String? _track;
  bool _paused = false;

  @override
  void playMusic(String realmId) {
    _track = GameAudio.musicTracks[realmId];
    _paused = false;
  }

  @override
  void stopMusic() => _track = null;

  @override
  void pauseMusic() => _paused = true;

  @override
  void resumeMusic() => _paused = false;
}
