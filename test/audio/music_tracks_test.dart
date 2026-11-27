import 'dart:io';

import 'package:dwarka_run/audio/game_audio.dart';
import 'package:dwarka_run/game/realm.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the first two stages have music, and every track exists', () {
    expect(GameAudio.musicTracks.keys, containsAll([Realm.ayodhya.id, Realm.ganga.id]));
    for (final MapEntry(:key, :value) in GameAudio.musicTracks.entries) {
      expect(Realm.byId(key)?.playable, isTrue, reason: key);
      expect(File('assets/$value').existsSync(), isTrue, reason: value);
    }
  });
}
