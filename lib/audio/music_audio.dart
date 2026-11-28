import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'game_audio.dart';

/// The app's sound: each stage's looping music on one player, and short
/// effects from small pools of preloaded players so they start at once and
/// can overlap.
class MusicAudio extends GameAudio {
  MusicAudio({AudioPlayer? player}) : _player = player ?? AudioPlayer(playerId: 'music') {
    // Every player mixes with the others instead of taking audio focus, so
    // a coin or jump sound never pauses the music. The music player and the
    // effect pools get the setting directly as well as through the global
    // default, because the global default can arrive after they are made.
    _guard(AudioPlayer.global.setAudioContext(_mix));
    _guard(_player.setAudioContext(_mix));
    _guard(_player.setReleaseMode(ReleaseMode.loop));
    _guard(_player.setVolume(musicVolume));
    // If the loop ever ends, start it again.
    _player.onPlayerComplete.listen((_) => _sync());
  }

  static final AudioContext _mix = AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build();

  final AudioPlayer _player;
  final Map<Sfx, Future<AudioPool>> _pools = {};
  String? _track;
  bool _paused = false;
  bool _muted = false;

  /// Loads every effect ahead of time, so the first coin is not late.
  void preload() {
    for (final s in Sfx.values) {
      _pool(s);
    }
  }

  Future<AudioPool> _pool(Sfx s) => _pools.putIfAbsent(
    s,
    () => AudioPool.create(source: AssetSource(s.asset), maxPlayers: s.voices, minPlayers: 1, audioContext: _mix),
  );

  @override
  bool get muted => _muted;

  @override
  set muted(bool value) {
    if (value == _muted) return;
    _muted = value;
    _sync();
  }

  @override
  void playNow(Sfx sfx, double volume) {
    _guard(_pool(sfx).then((p) => p.start(volume: (volume * sfxVolume).clamp(0.0, 1.0))));
  }

  @override
  void setMusicVolume(double v) {
    super.setMusicVolume(v);
    _guard(_player.setVolume(musicVolume));
    _sync();
  }

  @override
  void playMusic(String trackId) {
    final track = GameAudio.musicTracks[trackId];
    _paused = false;
    if (track == _track) {
      _sync();
      return;
    }
    _track = track;
    _guard(_player.stop());
    if (track != null && _audible) _guard(_player.play(AssetSource(track), volume: musicVolume));
  }

  @override
  void stopMusic() {
    _track = null;
    _guard(_player.stop());
  }

  @override
  void pauseMusic() {
    _paused = true;
    _sync();
  }

  @override
  void resumeMusic() {
    _paused = false;
    _sync();
  }

  @override
  void keepMusicAlive(String trackId) {
    if (_track == null) {
      playMusic(trackId);
    } else {
      _sync();
    }
  }

  bool get _audible => !_muted && musicVolume > 0;

  /// Plays or holds the current track to match the mute and pause state.
  void _sync() {
    final track = _track;
    if (track == null) return;
    if (!_audible || _paused) {
      if (_player.state == PlayerState.playing) _guard(_player.pause());
    } else if (_player.state == PlayerState.paused) {
      _guard(_player.resume());
    } else if (_player.state != PlayerState.playing) {
      _guard(_player.play(AssetSource(track), volume: musicVolume));
    }
  }

  /// Audio is never worth crashing a run over.
  void _guard(Future<Object?> f) => unawaited(f.then<void>((_) {}, onError: (Object e) => debugPrint('audio: $e')));
}
