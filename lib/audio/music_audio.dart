import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'game_audio.dart';

/// The app's sound: each stage's looping music on one player, and short
/// effects from small pools of preloaded players so they start at once and
/// can overlap.
class MusicAudio extends GameAudio {
  MusicAudio({AudioPlayer? player}) : _player = player ?? AudioPlayer(playerId: 'music') {
    // Effects mix with the music instead of taking audio focus from it.
    _guard(
      AudioPlayer.global.setAudioContext(AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build()),
    );
    _guard(_player.setReleaseMode(ReleaseMode.loop));
    _guard(_player.setVolume(musicVolume));
  }

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

  Future<AudioPool> _pool(Sfx s) =>
      _pools.putIfAbsent(s, () => AudioPool.createFromAsset(path: s.asset, maxPlayers: s.voices, minPlayers: 1));

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

  bool get _audible => !_muted && musicVolume > 0;

  /// Plays or holds the current track to match the mute and pause state.
  void _sync() {
    final track = _track;
    if (track == null) return;
    if (!_audible || _paused) {
      _guard(_player.pause());
    } else if (_player.state == PlayerState.paused) {
      _guard(_player.resume());
    } else if (_player.state != PlayerState.playing) {
      _guard(_player.play(AssetSource(track), volume: musicVolume));
    }
  }

  /// Audio is never worth crashing a run over.
  void _guard(Future<Object?> f) => unawaited(f.then<void>((_) {}, onError: (Object e) => debugPrint('audio: $e')));
}
