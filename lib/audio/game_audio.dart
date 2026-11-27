import '../game/run_simulation.dart';

/// Sound effects the game can play. Each has a WAV under `assets/audio/sfx/`.
enum Sfx {
  coin1('coin_1'),
  coin2('coin_2'),
  coin3('coin_3'),
  coin4('coin_4'),
  coin5('coin_5'),
  gem('gem'),
  powerup('powerup'),
  jump('jump'),
  slide('slide'),
  step1('step_1'),
  step2('step_2'),
  crash('crash'),
  splash('splash'),
  nearMiss('near_miss'),
  boost('boost'),
  magnet('magnet'),
  shield('shield'),
  monkey('monkey'),
  fanfare('fanfare'),
  reward('reward'),
  mission('mission'),
  unlock('unlock'),
  gameOver('game_over'),
  revive('revive'),
  click('click'),
  whoosh('whoosh'),
  stageWhoosh('stage_whoosh'),
  tick('tick'),
  go('go'),
  logoSting('logo_sting');

  const Sfx(this.file);

  final String file;

  String get asset => 'audio/sfx/$file.wav';

  /// Sounds that can fire many times a second get more voices.
  int get voices => switch (this) {
    coin1 || coin2 || coin3 || coin4 || coin5 => 3,
    step1 || step2 || click => 2,
    _ => 2,
  };

  static const coins = [coin1, coin2, coin3, coin4, coin5];
}

/// Game sound, behind an interface so tests need no audio plugin. The app
/// uses [MusicAudio] (lib/audio/music_audio.dart); tests use [SilentAudio].
abstract class GameAudio {
  /// Background music per stage id, as asset paths under `assets/`.
  static const musicTracks = {
    'ayodhya': 'audio/ayodhya_run.mp3',
    'ganga': 'audio/ganga_run.mp3',
    'pharaoh': 'audio/thar_desert_run.mp3',
    'himalayan': 'audio/himalayan_run.mp3',
    'vijayanagar': 'audio/vijayanagar_run.mp3',
    'dragon': 'audio/dragon_valley_run.mp3',
    'lanka': 'audio/lanka_run.mp3',
    'indus': 'audio/indus_run.mp3',
    'sunken': 'audio/sunken_kingdom_run.mp3',
    'finale': 'audio/final_legend_run.mp3',
  };

  bool get muted;
  set muted(bool value);

  /// Music and sound-effect volumes, 0 to 1.
  double musicVolume = 0.7;
  double sfxVolume = 0.9;

  /// Plays one sound now, at [volume] times the effects volume.
  void playNow(Sfx sfx, double volume);

  // Coin chain: quick pickups climb a short scale, and pickups closer
  // together than [_coinGapMs] are folded into one so a coin line never
  // turns into a buzz.
  static const _coinGapMs = 55;
  static const _chainMs = 420;
  int _lastCoinMs = -100000;
  int _chain = 0;
  bool _leftFoot = false;

  /// Milliseconds since some fixed point. Overridden by tests.
  int nowMs() => DateTime.now().millisecondsSinceEpoch;

  void play(Sfx sfx, {double volume = 1}) {
    if (muted || sfxVolume <= 0) return;
    if (Sfx.coins.contains(sfx)) {
      final now = nowMs();
      final gap = now - _lastCoinMs;
      if (gap < _coinGapMs) return;
      _chain = gap < _chainMs ? (_chain + 1).clamp(0, Sfx.coins.length - 1) : 0;
      _lastCoinMs = now;
      playNow(Sfx.coins[_chain], volume * 0.8);
      return;
    }
    playNow(sfx, volume);
  }

  /// Starts the looping music for [trackId] (a stage id). Keeps playing,
  /// without restarting, if that track is already on. A stage with no track
  /// is silent.
  void playMusic(String trackId);
  void stopMusic();

  /// Holds the music while the game is paused, and picks it up again.
  void pauseMusic();
  void resumeMusic();

  /// Applies a new music volume to the playing track.
  void setMusicVolume(double v) => musicVolume = v.clamp(0.0, 1.0);
  void setSfxVolume(double v) => sfxVolume = v.clamp(0.0, 1.0);

  /// Maps a run event to its sound.
  void onRunEvent(RunEvent e) {
    final sfx = switch (e) {
      RunEvent.coin => Sfx.coin1,
      RunEvent.gem => Sfx.gem,
      RunEvent.feather => Sfx.powerup,
      RunEvent.lotus => Sfx.magnet,
      RunEvent.jump => Sfx.jump,
      RunEvent.slide => Sfx.slide,
      RunEvent.crash => Sfx.crash,
      RunEvent.boostStart => Sfx.boost,
      RunEvent.monkeySteal => Sfx.monkey,
      RunEvent.finish => Sfx.fanfare,
      RunEvent.splash => Sfx.splash,
      RunEvent.nearMiss => Sfx.nearMiss,
      RunEvent.revive => Sfx.revive,
      RunEvent.footstep => (_leftFoot = !_leftFoot) ? Sfx.step1 : Sfx.step2,
      RunEvent.laneChange || RunEvent.riverStart || RunEvent.bridgeStart => null,
    };
    if (sfx != null) play(sfx, volume: e == RunEvent.footstep ? 0.35 : 1);
  }
}

/// Plays nothing, but remembers what it was asked to play.
class SilentAudio extends GameAudio {
  @override
  bool muted = false;

  final List<Sfx> played = [];

  int clockMs = 0;

  @override
  int nowMs() => clockMs += 1000;

  @override
  void playNow(Sfx sfx, double volume) => played.add(sfx);

  /// The track that would be heard now, or null.
  String? get music => muted || _paused ? null : _track;
  String? _track;
  bool _paused = false;

  @override
  void playMusic(String trackId) {
    _track = GameAudio.musicTracks[trackId];
    _paused = false;
  }

  @override
  void stopMusic() => _track = null;

  @override
  void pauseMusic() => _paused = true;

  @override
  void resumeMusic() => _paused = false;
}
