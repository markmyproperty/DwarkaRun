import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'game_audio.dart';

/// Plays each stage's background music on a loop with `audioplayers`.
/// Sound effects are not recorded yet, so [play] does nothing for now.
class MusicAudio extends GameAudio {
  MusicAudio({AudioPlayer? player}) : _player = player ?? AudioPlayer(playerId: 'music') {
    _player.setReleaseMode(ReleaseMode.loop);
    _player.setVolume(volume);
  }

  static const double volume = 0.6;

  final AudioPlayer _player;
  String? _track;
  bool _paused = false;
  bool _muted = false;

  @override
  bool get muted => _muted;

  @override
  set muted(bool value) {
    if (value == _muted) return;
    _muted = value;
    _sync();
  }

  @override
  void play(Sfx sfx) {}

  @override
  void playMusic(String realmId) {
    final track = GameAudio.musicTracks[realmId];
    _paused = false;
    if (track == _track) {
      _sync();
      return;
    }
    _track = track;
    _guard(_player.stop());
    if (track != null && !_muted) _guard(_player.play(AssetSource(track)));
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

  /// Plays or holds the current track to match the mute and pause state.
  void _sync() {
    final track = _track;
    if (track == null) return;
    if (_muted || _paused) {
      _guard(_player.pause());
    } else if (_player.state == PlayerState.paused) {
      _guard(_player.resume());
    } else if (_player.state != PlayerState.playing) {
      _guard(_player.play(AssetSource(track)));
    }
  }

  /// Audio is never worth crashing a run over.
  void _guard(Future<void> f) => f.catchError((Object e) => debugPrint('music: $e'));
}
