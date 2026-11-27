// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'Dwarka Run';

  @override
  String get hubTagline => 'A quest through ten legendary worlds';

  @override
  String get hubNextStop => 'NEXT STOP';

  @override
  String get hubStartYatra => 'Start the adventure';

  @override
  String hubContinueTo(String realm) {
    return 'Continue to $realm';
  }

  @override
  String hubRunAgain(String realm) {
    return 'Play $realm again';
  }

  @override
  String hubPlayLabel(String realm) {
    return 'Play $realm';
  }

  @override
  String hubComingSoon(String realm, String current) {
    return '$realm opens in the next update. Until then, run $current again.';
  }

  @override
  String hubTarget(int metres) {
    return 'Run $metres m to cross the realm';
  }

  @override
  String get walletLabel => 'Wallet';

  @override
  String mudraCount(int count) {
    return '$count mudra';
  }

  @override
  String get bestLabel => 'Best run';

  @override
  String metresValue(int metres) {
    return '$metres m';
  }

  @override
  String get routeTitle => 'Your yatra';

  @override
  String get routeDone => 'Done';

  @override
  String get routeTodo => 'To do';

  @override
  String get routeComingSoon => 'Coming soon';

  @override
  String routeStateLabel(String realm, String state) {
    return '$realm: $state';
  }

  @override
  String get howToTitle => 'How to play';

  @override
  String get howToLanes => 'Swipe left or right to change lanes';

  @override
  String get howToJump => 'Swipe up to jump';

  @override
  String get howToSlide => 'Swipe down to slide';

  @override
  String get howToKeys =>
      'On a keyboard: arrow keys or WASD, and space for a boost';

  @override
  String get howToBoost =>
      'Collect a Garuda feather, then tap it to fly over everything';

  @override
  String get howToLotus => 'A Lotus charm pulls nearby mudra towards you';

  @override
  String get howToMonkey =>
      'Cheeky monkeys snatch a few mudra. Jump over them!';

  @override
  String get soundOn => 'Sound on';

  @override
  String get soundOff => 'Sound off';

  @override
  String get realmAyodhya => 'Ayodhya Run';

  @override
  String get realmGanga => 'Ganga Run';

  @override
  String get realmPharaoh => 'Pharaoh Run';

  @override
  String get realmHimalayan => 'Himalayan Run';

  @override
  String get realmVijayanagar => 'Vijayanagar Run';

  @override
  String get realmDragonValley => 'Dragon Valley';

  @override
  String get realmLanka => 'Lanka Run';

  @override
  String get realmIndus => 'Indus Run';

  @override
  String get realmSunkenDwarka => 'Dwarka: The Sunken Kingdom';

  @override
  String get realmFinalLegend => 'Dwarka Run: The Final Legend';

  @override
  String get realmAyodhyaBlurb =>
      'Temples, royal courtyards and market streets';

  @override
  String get realmGangaBlurb => 'Riverside ghats, boats and floating platforms';

  @override
  String get realmPharaohBlurb => 'Pyramids, dunes and hidden tombs';

  @override
  String get realmHimalayanBlurb =>
      'Snowy passes, rope bridges and monasteries';

  @override
  String get realmVijayanagarBlurb =>
      'Stone chariots, bazaars and boulder hills';

  @override
  String get realmDragonValleyBlurb =>
      'Volcanoes, lava caves and dragon fortresses';

  @override
  String get realmLankaBlurb =>
      'A golden island kingdom of palaces and gardens';

  @override
  String get realmIndusBlurb => 'Brick cities, granaries and water channels';

  @override
  String get realmSunkenDwarkaBlurb => 'Ocean temples and submerged palaces';

  @override
  String get realmFinalLegendBlurb =>
      'The golden city and the final relic chamber';

  @override
  String hudCoins(int count) {
    return 'Mudra: $count';
  }

  @override
  String hudDistance(int metres) {
    return 'Distance: $metres metres';
  }

  @override
  String get hudPause => 'Pause';

  @override
  String hudBoost(int count) {
    return 'Garuda feather boost, $count left';
  }

  @override
  String get pauseTitle => 'Paused';

  @override
  String get pauseResume => 'Resume';

  @override
  String get pauseRestart => 'Restart';

  @override
  String get pauseQuit => 'Quit to hub';

  @override
  String get gameOverTitle => 'Your run ends here';

  @override
  String get scoreLabel => 'Score';

  @override
  String get coinsCollected => 'Mudra collected';

  @override
  String get newBest => 'New best run!';

  @override
  String get retry => 'Retry';

  @override
  String get backToHub => 'Back to hub';

  @override
  String realmCompleteTitle(String realm) {
    return '$realm crossed!';
  }

  @override
  String get realmCompleteBody =>
      'You reached the far side of the realm. Your mudra are safe in your wallet.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get hintLanes => 'Swipe left or right to dodge';

  @override
  String get hintJump => 'Swipe up to jump';

  @override
  String get hintSlide => 'Swipe down to slide';

  @override
  String monkeyStole(int count) {
    return 'A monkey snatched $count mudra!';
  }

  @override
  String get featherGot => 'Garuda feather! Tap the feather to fly';

  @override
  String get lotusGot => 'Lotus charm! Mudra come to you';

  @override
  String distanceToGo(int metres) {
    return '$metres m to go';
  }

  @override
  String get riverStart => 'Open water! Jump the gaps between boats and planks';

  @override
  String get bridgeStart => 'The current is rising! Race across the bridge';

  @override
  String get gameOverSplash => 'Splash! Into the river';

  @override
  String get crevasseStart =>
      'Ice crevasses! Keep to the ice and jump the gaps';

  @override
  String get ropeBridgeStart =>
      'The rope bridge! Run across before the wind rises';

  @override
  String get gameOverCrevasse => 'Whoosh! Down the crevasse';

  @override
  String get moatStart => 'The palace moat! Hop across the golden platforms';

  @override
  String get fortressBridgeStart => 'The fortress bridge! Race to the citadel';

  @override
  String get gameOverMoat => 'Splash! Into the palace moat';
}
