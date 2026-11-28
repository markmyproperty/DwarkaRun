import 'dart:convert';
import 'dart:io';

import 'package:dwarka_run/audio/game_audio.dart';
import 'package:dwarka_run/game/run_simulation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every sound effect has its file', () {
    for (final s in Sfx.values) {
      expect(File('assets/${s.asset}').existsSync(), isTrue, reason: s.asset);
    }
  });

  test('every collectible and action makes a sound', () {
    final audio = SilentAudio();
    for (final e in [
      RunEvent.coin,
      RunEvent.gem,
      RunEvent.feather,
      RunEvent.lotus,
      RunEvent.jump,
      RunEvent.slide,
      RunEvent.crash,
      RunEvent.boostStart,
      RunEvent.nearMiss,
      RunEvent.revive,
      RunEvent.finish,
      RunEvent.footstep,
    ]) {
      audio.played.clear();
      audio.onRunEvent(e);
      expect(audio.played, hasLength(1), reason: e.name);
    }
  });

  test('the Lottie animations are valid JSON with layers', () {
    for (final name in ['reward_burst', 'confetti', 'loader', 'level_up']) {
      final json = jsonDecode(File('assets/lottie/$name.json').readAsStringSync()) as Map<String, Object?>;
      expect(json['layers'], isNotEmpty, reason: name);
      expect(json['op'], greaterThan(0));
    }
  });
}
