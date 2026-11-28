import 'dart:io';

import 'package:dwarka_run/audio/game_audio.dart';
import 'package:dwarka_run/game/realm.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every stage has music, and every track exists', () {
    expect(GameAudio.musicTracks.keys, containsAll(Realm.values.map((r) => r.id)));
    for (final MapEntry(:key, :value) in GameAudio.musicTracks.entries) {
      expect(Realm.byId(key), isNotNull, reason: key);
      expect(File('assets/$value').existsSync(), isTrue, reason: value);
    }
  });
}
