// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dwarka Run';

  @override
  String get hubTagline => 'A yatra through ancient realms';

  @override
  String get hubNextStop => 'NEXT STOP';

  @override
  String get hubStartYatra => 'Start yatra';

  @override
  String hubContinueTo(String realm) {
    return 'Continue to $realm';
  }

  @override
  String hubRunAgain(String realm) {
    return 'Run $realm again';
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
  String get realmDwarka => 'Ancient Dwarka';

  @override
  String get realmForest => 'Forest Kingdom';

  @override
  String get realmRiver => 'River of Ghats';

  @override
  String get realmDesert => 'Desert Fort';

  @override
  String get realmCelestial => 'Celestial City';

  @override
  String get realmDwarkaBlurb =>
      'Sandstone streets, shop-houses and grand monuments';

  @override
  String get realmForestBlurb => 'Banyan forests and old stone ruins';

  @override
  String get realmRiverBlurb => 'Stone steps, boats and drifting logs';

  @override
  String get realmDesertBlurb => 'Sandstone ramparts under a wide sky';

  @override
  String get realmCelestialBlurb => 'A floating city of gold';

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
}
