import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('hi'),
    Locale('mr'),
    Locale('ta'),
  ];

  /// No description provided for @titleMain.
  ///
  /// In en, this message translates to:
  /// **'ODYSSEY'**
  String get titleMain;

  /// No description provided for @titleSub.
  ///
  /// In en, this message translates to:
  /// **'OF THE AGES'**
  String get titleSub;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Odyssey of the Ages'**
  String get appTitle;

  /// No description provided for @hubTagline.
  ///
  /// In en, this message translates to:
  /// **'A quest through ten legendary worlds'**
  String get hubTagline;

  /// No description provided for @hubNextStop.
  ///
  /// In en, this message translates to:
  /// **'NEXT STOP'**
  String get hubNextStop;

  /// No description provided for @hubStartYatra.
  ///
  /// In en, this message translates to:
  /// **'Start the adventure'**
  String get hubStartYatra;

  /// No description provided for @hubContinueTo.
  ///
  /// In en, this message translates to:
  /// **'Continue to {realm}'**
  String hubContinueTo(String realm);

  /// No description provided for @hubRunAgain.
  ///
  /// In en, this message translates to:
  /// **'Play {realm} again'**
  String hubRunAgain(String realm);

  /// No description provided for @hubPlayLabel.
  ///
  /// In en, this message translates to:
  /// **'Play {realm}'**
  String hubPlayLabel(String realm);

  /// No description provided for @hubComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{realm} opens in the next update. Until then, run {current} again.'**
  String hubComingSoon(String realm, String current);

  /// No description provided for @hubTarget.
  ///
  /// In en, this message translates to:
  /// **'Run {metres} m to cross the realm'**
  String hubTarget(int metres);

  /// No description provided for @walletLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletLabel;

  /// No description provided for @mudraCount.
  ///
  /// In en, this message translates to:
  /// **'{count} mudra'**
  String mudraCount(int count);

  /// No description provided for @bestLabel.
  ///
  /// In en, this message translates to:
  /// **'Best run'**
  String get bestLabel;

  /// No description provided for @metresValue.
  ///
  /// In en, this message translates to:
  /// **'{metres} m'**
  String metresValue(int metres);

  /// No description provided for @routeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your yatra'**
  String get routeTitle;

  /// No description provided for @routeDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get routeDone;

  /// No description provided for @routeTodo.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get routeTodo;

  /// No description provided for @routeComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get routeComingSoon;

  /// No description provided for @routeStateLabel.
  ///
  /// In en, this message translates to:
  /// **'{realm}: {state}'**
  String routeStateLabel(String realm, String state);

  /// No description provided for @howToTitle.
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get howToTitle;

  /// No description provided for @howToLanes.
  ///
  /// In en, this message translates to:
  /// **'Swipe left or right to change lanes'**
  String get howToLanes;

  /// No description provided for @howToJump.
  ///
  /// In en, this message translates to:
  /// **'Swipe up to jump'**
  String get howToJump;

  /// No description provided for @howToSlide.
  ///
  /// In en, this message translates to:
  /// **'Swipe down to slide'**
  String get howToSlide;

  /// No description provided for @howToKeys.
  ///
  /// In en, this message translates to:
  /// **'On a keyboard: arrow keys or WASD, and space for a boost'**
  String get howToKeys;

  /// No description provided for @howToBoost.
  ///
  /// In en, this message translates to:
  /// **'Collect a Garuda feather, then tap it to fly over everything'**
  String get howToBoost;

  /// No description provided for @howToLotus.
  ///
  /// In en, this message translates to:
  /// **'A Lotus charm pulls nearby mudra towards you'**
  String get howToLotus;

  /// No description provided for @howToMonkey.
  ///
  /// In en, this message translates to:
  /// **'Cheeky monkeys snatch a few mudra. Jump over them!'**
  String get howToMonkey;

  /// No description provided for @soundOn.
  ///
  /// In en, this message translates to:
  /// **'Sound on'**
  String get soundOn;

  /// No description provided for @soundOff.
  ///
  /// In en, this message translates to:
  /// **'Sound off'**
  String get soundOff;

  /// No description provided for @realmAyodhya.
  ///
  /// In en, this message translates to:
  /// **'Ayodhya Run'**
  String get realmAyodhya;

  /// No description provided for @realmGanga.
  ///
  /// In en, this message translates to:
  /// **'Ganga Run'**
  String get realmGanga;

  /// No description provided for @realmPharaoh.
  ///
  /// In en, this message translates to:
  /// **'Thar Desert Run'**
  String get realmPharaoh;

  /// No description provided for @realmHimalayan.
  ///
  /// In en, this message translates to:
  /// **'Himalayan Run'**
  String get realmHimalayan;

  /// No description provided for @realmVijayanagar.
  ///
  /// In en, this message translates to:
  /// **'Vijayanagar Run'**
  String get realmVijayanagar;

  /// No description provided for @realmDragonValley.
  ///
  /// In en, this message translates to:
  /// **'Dragon Valley'**
  String get realmDragonValley;

  /// No description provided for @realmLanka.
  ///
  /// In en, this message translates to:
  /// **'Lanka Run'**
  String get realmLanka;

  /// No description provided for @realmIndus.
  ///
  /// In en, this message translates to:
  /// **'Indus Run'**
  String get realmIndus;

  /// No description provided for @realmSunkenDwarka.
  ///
  /// In en, this message translates to:
  /// **'Dwarka: The Sunken Kingdom'**
  String get realmSunkenDwarka;

  /// No description provided for @realmFinalLegend.
  ///
  /// In en, this message translates to:
  /// **'Dwarka Run: The Final Legend'**
  String get realmFinalLegend;

  /// No description provided for @realmAyodhyaBlurb.
  ///
  /// In en, this message translates to:
  /// **'Temples, royal courtyards and market streets'**
  String get realmAyodhyaBlurb;

  /// No description provided for @realmGangaBlurb.
  ///
  /// In en, this message translates to:
  /// **'Riverside ghats, boats and floating platforms'**
  String get realmGangaBlurb;

  /// No description provided for @realmPharaohBlurb.
  ///
  /// In en, this message translates to:
  /// **'Golden dunes, sandstone streets and hidden treasure'**
  String get realmPharaohBlurb;

  /// No description provided for @realmHimalayanBlurb.
  ///
  /// In en, this message translates to:
  /// **'Snowy passes, rope bridges and monasteries'**
  String get realmHimalayanBlurb;

  /// No description provided for @realmVijayanagarBlurb.
  ///
  /// In en, this message translates to:
  /// **'Stone chariots, bazaars and boulder hills'**
  String get realmVijayanagarBlurb;

  /// No description provided for @realmDragonValleyBlurb.
  ///
  /// In en, this message translates to:
  /// **'Volcanoes, lava caves and dragon fortresses'**
  String get realmDragonValleyBlurb;

  /// No description provided for @realmLankaBlurb.
  ///
  /// In en, this message translates to:
  /// **'A golden island kingdom of palaces and gardens'**
  String get realmLankaBlurb;

  /// No description provided for @realmIndusBlurb.
  ///
  /// In en, this message translates to:
  /// **'Brick cities, granaries and water channels'**
  String get realmIndusBlurb;

  /// No description provided for @realmSunkenDwarkaBlurb.
  ///
  /// In en, this message translates to:
  /// **'Ocean temples and submerged palaces'**
  String get realmSunkenDwarkaBlurb;

  /// No description provided for @realmFinalLegendBlurb.
  ///
  /// In en, this message translates to:
  /// **'The golden city and the final relic chamber'**
  String get realmFinalLegendBlurb;

  /// No description provided for @hudCoins.
  ///
  /// In en, this message translates to:
  /// **'Mudra: {count}'**
  String hudCoins(int count);

  /// No description provided for @hudDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance: {metres} metres'**
  String hudDistance(int metres);

  /// No description provided for @hudPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get hudPause;

  /// No description provided for @hudBoost.
  ///
  /// In en, this message translates to:
  /// **'Garuda feather boost, {count} left'**
  String hudBoost(int count);

  /// No description provided for @pauseTitle.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pauseTitle;

  /// No description provided for @pauseResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get pauseResume;

  /// No description provided for @pauseRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get pauseRestart;

  /// No description provided for @pauseQuit.
  ///
  /// In en, this message translates to:
  /// **'Quit to hub'**
  String get pauseQuit;

  /// No description provided for @gameOverTitle.
  ///
  /// In en, this message translates to:
  /// **'Run over!'**
  String get gameOverTitle;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get scoreLabel;

  /// No description provided for @coinsCollected.
  ///
  /// In en, this message translates to:
  /// **'Mudra collected'**
  String get coinsCollected;

  /// No description provided for @newBest.
  ///
  /// In en, this message translates to:
  /// **'New best run!'**
  String get newBest;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @backToHub.
  ///
  /// In en, this message translates to:
  /// **'Back to hub'**
  String get backToHub;

  /// No description provided for @realmCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'{realm} crossed!'**
  String realmCompleteTitle(String realm);

  /// No description provided for @realmCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'You reached the far side of the realm. Your mudra are safe in your wallet.'**
  String get realmCompleteBody;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @hintLanes.
  ///
  /// In en, this message translates to:
  /// **'Swipe left or right to dodge'**
  String get hintLanes;

  /// No description provided for @hintJump.
  ///
  /// In en, this message translates to:
  /// **'Swipe up to jump'**
  String get hintJump;

  /// No description provided for @hintSlide.
  ///
  /// In en, this message translates to:
  /// **'Swipe down to slide'**
  String get hintSlide;

  /// No description provided for @monkeyStole.
  ///
  /// In en, this message translates to:
  /// **'A monkey snatched {count} mudra!'**
  String monkeyStole(int count);

  /// No description provided for @featherGot.
  ///
  /// In en, this message translates to:
  /// **'Garuda feather! Tap the feather to fly'**
  String get featherGot;

  /// No description provided for @lotusGot.
  ///
  /// In en, this message translates to:
  /// **'Lotus charm! Mudra come to you'**
  String get lotusGot;

  /// No description provided for @distanceToGo.
  ///
  /// In en, this message translates to:
  /// **'{metres} m to go'**
  String distanceToGo(int metres);

  /// No description provided for @riverStart.
  ///
  /// In en, this message translates to:
  /// **'Open water! Jump the gaps between boats and planks'**
  String get riverStart;

  /// No description provided for @bridgeStart.
  ///
  /// In en, this message translates to:
  /// **'The current is rising! Race across the bridge'**
  String get bridgeStart;

  /// No description provided for @gameOverSplash.
  ///
  /// In en, this message translates to:
  /// **'Splash! Into the river'**
  String get gameOverSplash;

  /// No description provided for @crevasseStart.
  ///
  /// In en, this message translates to:
  /// **'Ice crevasses! Keep to the ice and jump the gaps'**
  String get crevasseStart;

  /// No description provided for @ropeBridgeStart.
  ///
  /// In en, this message translates to:
  /// **'The rope bridge! Run across before the wind rises'**
  String get ropeBridgeStart;

  /// No description provided for @gameOverCrevasse.
  ///
  /// In en, this message translates to:
  /// **'Whoosh! Down the crevasse'**
  String get gameOverCrevasse;

  /// No description provided for @moatStart.
  ///
  /// In en, this message translates to:
  /// **'The palace moat! Hop across the golden platforms'**
  String get moatStart;

  /// No description provided for @fortressBridgeStart.
  ///
  /// In en, this message translates to:
  /// **'The fortress bridge! Race to the citadel'**
  String get fortressBridgeStart;

  /// No description provided for @gameOverMoat.
  ///
  /// In en, this message translates to:
  /// **'Splash! Into the palace moat'**
  String get gameOverMoat;

  /// No description provided for @seasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Season {number}'**
  String seasonLabel(int number);

  /// No description provided for @seasonJambudvipa.
  ///
  /// In en, this message translates to:
  /// **'Jambudvīpa'**
  String get seasonJambudvipa;

  /// No description provided for @seasonJambudvipaBlurb.
  ///
  /// In en, this message translates to:
  /// **'Ten legendary worlds, from Ayodhya to the sunken city of Dwarka'**
  String get seasonJambudvipaBlurb;

  /// No description provided for @trenchStart.
  ///
  /// In en, this message translates to:
  /// **'The sea trench! Keep to the coral ledges'**
  String get trenchStart;

  /// No description provided for @coralBridgeStart.
  ///
  /// In en, this message translates to:
  /// **'The coral bridge! Race for the palace'**
  String get coralBridgeStart;

  /// No description provided for @gameOverTrench.
  ///
  /// In en, this message translates to:
  /// **'Whoosh! Down into the trench'**
  String get gameOverTrench;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get play;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @beginOdyssey.
  ///
  /// In en, this message translates to:
  /// **'Begin the odyssey'**
  String get beginOdyssey;

  /// No description provided for @presents.
  ///
  /// In en, this message translates to:
  /// **'presents'**
  String get presents;

  /// No description provided for @intro1.
  ///
  /// In en, this message translates to:
  /// **'Long ago, every age of the world was bound by one thread of golden light.'**
  String get intro1;

  /// No description provided for @intro2.
  ///
  /// In en, this message translates to:
  /// **'Then the thread broke, and its relics scattered across Jambudvīpa.'**
  String get intro2;

  /// No description provided for @intro3.
  ///
  /// In en, this message translates to:
  /// **'Along sacred rivers, through burning deserts and over frozen peaks…'**
  String get intro3;

  /// No description provided for @intro4.
  ///
  /// In en, this message translates to:
  /// **'…into golden palaces and kingdoms the world forgot.'**
  String get intro4;

  /// No description provided for @intro5.
  ///
  /// In en, this message translates to:
  /// **'Beneath the waves, the legendary city of Dwarka still waits.'**
  String get intro5;

  /// No description provided for @intro6.
  ///
  /// In en, this message translates to:
  /// **'One runner. Ten worlds. Your odyssey begins now.'**
  String get intro6;

  /// No description provided for @levelShort.
  ///
  /// In en, this message translates to:
  /// **'Lv {level}'**
  String levelShort(int level);

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelLabel(int level);

  /// No description provided for @worldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Worlds'**
  String get worldsTitle;

  /// No description provided for @missionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Missions'**
  String get missionsTitle;

  /// No description provided for @dailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily reward'**
  String get dailyTitle;

  /// No description provided for @shopTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopTitle;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'Heroes'**
  String get heroTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @claim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get claim;

  /// No description provided for @dayN.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String dayN(int day);

  /// No description provided for @dailyCome.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow for the next reward'**
  String get dailyCome;

  /// No description provided for @dailyStreak.
  ///
  /// In en, this message translates to:
  /// **'Log in every day for bigger rewards'**
  String get dailyStreak;

  /// No description provided for @missionCoinsInRun.
  ///
  /// In en, this message translates to:
  /// **'Collect {goal} mudra in one run'**
  String missionCoinsInRun(int goal);

  /// No description provided for @missionMetresInRun.
  ///
  /// In en, this message translates to:
  /// **'Run {goal} m in one run'**
  String missionMetresInRun(int goal);

  /// No description provided for @missionJumps.
  ///
  /// In en, this message translates to:
  /// **'Jump {goal} times'**
  String missionJumps(int goal);

  /// No description provided for @missionSlides.
  ///
  /// In en, this message translates to:
  /// **'Slide {goal} times'**
  String missionSlides(int goal);

  /// No description provided for @missionNearMisses.
  ///
  /// In en, this message translates to:
  /// **'Make {goal} close calls'**
  String missionNearMisses(int goal);

  /// No description provided for @missionGems.
  ///
  /// In en, this message translates to:
  /// **'Collect {goal} gems'**
  String missionGems(int goal);

  /// No description provided for @missionBoosts.
  ///
  /// In en, this message translates to:
  /// **'Fly with {goal} Garuda feathers'**
  String missionBoosts(int goal);

  /// No description provided for @missionFinish.
  ///
  /// In en, this message translates to:
  /// **'Cross a world'**
  String get missionFinish;

  /// No description provided for @missionRuns.
  ///
  /// In en, this message translates to:
  /// **'Play {goal} runs'**
  String missionRuns(int goal);

  /// No description provided for @missionCoinsTotal.
  ///
  /// In en, this message translates to:
  /// **'Collect {goal} mudra in total'**
  String missionCoinsTotal(int goal);

  /// No description provided for @missionsHint.
  ///
  /// In en, this message translates to:
  /// **'Finish missions to earn mudra, gems and XP'**
  String get missionsHint;

  /// No description provided for @upgradeFeather.
  ///
  /// In en, this message translates to:
  /// **'Garuda feather flight'**
  String get upgradeFeather;

  /// No description provided for @upgradeLotus.
  ///
  /// In en, this message translates to:
  /// **'Lotus charm'**
  String get upgradeLotus;

  /// No description provided for @upgradeSeconds.
  ///
  /// In en, this message translates to:
  /// **'Lasts {seconds} s'**
  String upgradeSeconds(String seconds);

  /// No description provided for @upgradesTitle.
  ///
  /// In en, this message translates to:
  /// **'Power-up upgrades'**
  String get upgradesTitle;

  /// No description provided for @maxed.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get maxed;

  /// No description provided for @heroOutfitsHint.
  ///
  /// In en, this message translates to:
  /// **'Each world dresses the king in its own royal outfit. Reach a world to unlock its look.'**
  String get heroOutfitsHint;

  /// No description provided for @heroKing.
  ///
  /// In en, this message translates to:
  /// **'The Wandering King'**
  String get heroKing;

  /// No description provided for @heroKingBlurb.
  ///
  /// In en, this message translates to:
  /// **'A young king on a yatra through the ages.'**
  String get heroKingBlurb;

  /// No description provided for @heroSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get heroSelected;

  /// No description provided for @heroComingSoon.
  ///
  /// In en, this message translates to:
  /// **'More heroes are on the way'**
  String get heroComingSoon;

  /// No description provided for @musicVolume.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get musicVolume;

  /// No description provided for @sfxVolume.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get sfxVolume;

  /// No description provided for @muteAll.
  ///
  /// In en, this message translates to:
  /// **'Mute all sound'**
  String get muteAll;

  /// No description provided for @replayIntro.
  ///
  /// In en, this message translates to:
  /// **'Replay the story'**
  String get replayIntro;

  /// No description provided for @creditsLine.
  ///
  /// In en, this message translates to:
  /// **'A game by MMYP Technologies'**
  String get creditsLine;

  /// No description provided for @worldCleared.
  ///
  /// In en, this message translates to:
  /// **'Cleared'**
  String get worldCleared;

  /// No description provided for @worldCurrent.
  ///
  /// In en, this message translates to:
  /// **'You are here'**
  String get worldCurrent;

  /// No description provided for @worldLockedHint.
  ///
  /// In en, this message translates to:
  /// **'Cross {world} to unlock'**
  String worldLockedHint(String world);

  /// No description provided for @worldArtSoon.
  ///
  /// In en, this message translates to:
  /// **'Arriving soon'**
  String get worldArtSoon;

  /// No description provided for @worldPlay.
  ///
  /// In en, this message translates to:
  /// **'Play this world'**
  String get worldPlay;

  /// No description provided for @stageNumber.
  ///
  /// In en, this message translates to:
  /// **'Stage {number}'**
  String stageNumber(int number);

  /// No description provided for @newWorldUnlocked.
  ///
  /// In en, this message translates to:
  /// **'New world unlocked!'**
  String get newWorldUnlocked;

  /// No description provided for @letsGo.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go!'**
  String get letsGo;

  /// No description provided for @countdownGo.
  ///
  /// In en, this message translates to:
  /// **'GO!'**
  String get countdownGo;

  /// No description provided for @nearMiss.
  ///
  /// In en, this message translates to:
  /// **'Close call!'**
  String get nearMiss;

  /// No description provided for @distanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distanceLabel;

  /// No description provided for @gemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Gems'**
  String get gemsLabel;

  /// No description provided for @missionsDone.
  ///
  /// In en, this message translates to:
  /// **'Missions completed'**
  String get missionsDone;

  /// No description provided for @revive.
  ///
  /// In en, this message translates to:
  /// **'Revive'**
  String get revive;

  /// No description provided for @reviveForCoins.
  ///
  /// In en, this message translates to:
  /// **'Revive for {count} coins'**
  String reviveForCoins(int count);

  /// No description provided for @reviveFor.
  ///
  /// In en, this message translates to:
  /// **'Revive for {count, plural, =1{1 gem} other{{count} gems}}'**
  String reviveFor(int count);

  /// No description provided for @homeLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeLabel;

  /// No description provided for @victoryTitle.
  ///
  /// In en, this message translates to:
  /// **'World cleared!'**
  String get victoryTitle;

  /// No description provided for @nextWorld.
  ///
  /// In en, this message translates to:
  /// **'Next world'**
  String get nextWorld;

  /// No description provided for @levelUp.
  ///
  /// In en, this message translates to:
  /// **'Level up!'**
  String get levelUp;

  /// No description provided for @xpEarned.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String xpEarned(int xp);

  /// No description provided for @selectWorld.
  ///
  /// In en, this message translates to:
  /// **'Choose a world'**
  String get selectWorld;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en', 'hi', 'mr', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
