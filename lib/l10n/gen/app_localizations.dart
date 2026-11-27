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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Dwarka Run'**
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
  /// **'Pharaoh Run'**
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
  /// **'Pyramids, dunes and hidden tombs'**
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
  /// **'Your run ends here'**
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
