// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Odyssey of the Ages';

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
  String get realmPharaoh => 'Thar Desert Run';

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
  String get realmPharaohBlurb =>
      'Golden dunes, sandstone streets and hidden treasure';

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
  String get gameOverTitle => 'Run over!';

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

  @override
  String seasonLabel(int number) {
    return 'Season $number';
  }

  @override
  String get seasonJambudvipa => 'Jambudvīpa';

  @override
  String get seasonJambudvipaBlurb =>
      'Ten legendary worlds, from Ayodhya to the sunken city of Dwarka';

  @override
  String get trenchStart => 'The sea trench! Keep to the coral ledges';

  @override
  String get coralBridgeStart => 'The coral bridge! Race for the palace';

  @override
  String get gameOverTrench => 'Whoosh! Down into the trench';

  @override
  String get play => 'PLAY';

  @override
  String get skip => 'Skip';

  @override
  String get beginOdyssey => 'Begin the odyssey';

  @override
  String get presents => 'presents';

  @override
  String get intro1 =>
      'Long ago, every age of the world was bound by one thread of golden light.';

  @override
  String get intro2 =>
      'Then the thread broke, and its relics scattered across Jambudvīpa.';

  @override
  String get intro3 =>
      'Along sacred rivers, through burning deserts and over frozen peaks…';

  @override
  String get intro4 => '…into golden palaces and kingdoms the world forgot.';

  @override
  String get intro5 =>
      'Beneath the waves, the legendary city of Dwarka still waits.';

  @override
  String get intro6 => 'One runner. Ten worlds. Your odyssey begins now.';

  @override
  String levelShort(int level) {
    return 'Lv $level';
  }

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String get worldsTitle => 'Worlds';

  @override
  String get missionsTitle => 'Missions';

  @override
  String get dailyTitle => 'Daily reward';

  @override
  String get shopTitle => 'Shop';

  @override
  String get heroTitle => 'Heroes';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get claim => 'Claim';

  @override
  String dayN(int day) {
    return 'Day $day';
  }

  @override
  String get dailyCome => 'Come back tomorrow for the next reward';

  @override
  String get dailyStreak => 'Log in every day for bigger rewards';

  @override
  String missionCoinsInRun(int goal) {
    return 'Collect $goal mudra in one run';
  }

  @override
  String missionMetresInRun(int goal) {
    return 'Run $goal m in one run';
  }

  @override
  String missionJumps(int goal) {
    return 'Jump $goal times';
  }

  @override
  String missionSlides(int goal) {
    return 'Slide $goal times';
  }

  @override
  String missionNearMisses(int goal) {
    return 'Make $goal close calls';
  }

  @override
  String missionGems(int goal) {
    return 'Collect $goal gems';
  }

  @override
  String missionBoosts(int goal) {
    return 'Fly with $goal Garuda feathers';
  }

  @override
  String get missionFinish => 'Cross a world';

  @override
  String missionRuns(int goal) {
    return 'Play $goal runs';
  }

  @override
  String missionCoinsTotal(int goal) {
    return 'Collect $goal mudra in total';
  }

  @override
  String get missionsHint => 'Finish missions to earn mudra, gems and XP';

  @override
  String get upgradeFeather => 'Garuda feather flight';

  @override
  String get upgradeLotus => 'Lotus charm';

  @override
  String upgradeSeconds(String seconds) {
    return 'Lasts $seconds s';
  }

  @override
  String get upgradesTitle => 'Power-up upgrades';

  @override
  String get maxed => 'Max';

  @override
  String get heroKing => 'The Wandering King';

  @override
  String get heroKingBlurb => 'A young king on a yatra through the ages.';

  @override
  String get heroSelected => 'Selected';

  @override
  String get heroComingSoon => 'More heroes are on the way';

  @override
  String get musicVolume => 'Music';

  @override
  String get sfxVolume => 'Sound effects';

  @override
  String get muteAll => 'Mute all sound';

  @override
  String get replayIntro => 'Replay the story';

  @override
  String get creditsLine => 'A game by MMYP Technologies';

  @override
  String get worldCleared => 'Cleared';

  @override
  String get worldCurrent => 'You are here';

  @override
  String worldLockedHint(String world) {
    return 'Cross $world to unlock';
  }

  @override
  String get worldArtSoon => 'Arriving soon';

  @override
  String get worldPlay => 'Play this world';

  @override
  String stageNumber(int number) {
    return 'Stage $number';
  }

  @override
  String get newWorldUnlocked => 'New world unlocked!';

  @override
  String get letsGo => 'Let\'s go!';

  @override
  String get countdownGo => 'GO!';

  @override
  String get nearMiss => 'Close call!';

  @override
  String get distanceLabel => 'Distance';

  @override
  String get gemsLabel => 'Gems';

  @override
  String get missionsDone => 'Missions completed';

  @override
  String get revive => 'Revive';

  @override
  String reviveFor(int count) {
    return 'Revive for $count gems';
  }

  @override
  String get homeLabel => 'Home';

  @override
  String get victoryTitle => 'World cleared!';

  @override
  String get nextWorld => 'Next world';

  @override
  String get levelUp => 'Level up!';

  @override
  String xpEarned(int xp) {
    return '+$xp XP';
  }

  @override
  String get selectWorld => 'Choose a world';

  @override
  String get loading => 'Loading…';
}
