import 'dart:io';

import 'package:dwarka_run/audio/game_audio.dart';
import 'package:dwarka_run/game/realm.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every playable stage has a music track that exists', () {
    for (final r in Realm.values.where((r) => r.playable)) {
      final track = GameAudio.musicTracks[r.id];
      expect(track, isNotNull, reason: r.id);
      expect(File('assets/$track').existsSync(), isTrue, reason: track);
    }
  });
}
