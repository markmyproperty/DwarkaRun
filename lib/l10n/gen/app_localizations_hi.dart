// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'द्वारका रन';

  @override
  String get hubTagline => 'प्राचीन लोकों की एक यात्रा';

  @override
  String get hubNextStop => 'अगला पड़ाव';

  @override
  String get hubStartYatra => 'यात्रा शुरू करें';

  @override
  String hubContinueTo(String realm) {
    return '$realm की ओर बढ़ें';
  }

  @override
  String hubRunAgain(String realm) {
    return '$realm फिर से दौड़ें';
  }

  @override
  String hubPlayLabel(String realm) {
    return '$realm खेलें';
  }

  @override
  String hubComingSoon(String realm, String current) {
    return '$realm अगले अपडेट में खुलेगा। तब तक $current फिर से दौड़ें।';
  }

  @override
  String hubTarget(int metres) {
    return 'लोक पार करने के लिए $metres मीटर दौड़ें';
  }

  @override
  String get walletLabel => 'बटुआ';

  @override
  String mudraCount(int count) {
    return '$count मुद्रा';
  }

  @override
  String get bestLabel => 'सबसे लंबी दौड़';

  @override
  String metresValue(int metres) {
    return '$metres मी';
  }

  @override
  String get routeTitle => 'आपकी यात्रा';

  @override
  String get routeDone => 'पूरा';

  @override
  String get routeTodo => 'बाकी';

  @override
  String get routeComingSoon => 'जल्द आ रहा है';

  @override
  String routeStateLabel(String realm, String state) {
    return '$realm: $state';
  }

  @override
  String get howToTitle => 'कैसे खेलें';

  @override
  String get howToLanes => 'लेन बदलने के लिए बाएँ या दाएँ स्वाइप करें';

  @override
  String get howToJump => 'कूदने के लिए ऊपर स्वाइप करें';

  @override
  String get howToSlide => 'फिसलने के लिए नीचे स्वाइप करें';

  @override
  String get howToKeys =>
      'कीबोर्ड पर: तीर कुंजियाँ या WASD, और बूस्ट के लिए स्पेस';

  @override
  String get howToBoost =>
      'गरुड़ पंख इकट्ठा करें, फिर सब कुछ पार उड़ने के लिए उसे टैप करें';

  @override
  String get howToLotus => 'कमल ताबीज़ पास की मुद्राएँ आपकी ओर खींचता है';

  @override
  String get howToMonkey =>
      'शरारती बंदर कुछ मुद्राएँ छीन लेते हैं। उनके ऊपर से कूदें!';

  @override
  String get soundOn => 'आवाज़ चालू';

  @override
  String get soundOff => 'आवाज़ बंद';

  @override
  String get realmDwarka => 'प्राचीन द्वारका';

  @override
  String get realmForest => 'वन राज्य';

  @override
  String get realmRiver => 'घाटों की नदी';

  @override
  String get realmDesert => 'मरु दुर्ग';

  @override
  String get realmCelestial => 'स्वर्ण नगरी';

  @override
  String get realmDwarkaBlurb =>
      'बलुआ पत्थर की गलियाँ, दुकान-घर और भव्य स्मारक';

  @override
  String get realmForestBlurb => 'बरगद के जंगल और पुराने पत्थर के खंडहर';

  @override
  String get realmRiverBlurb => 'पत्थर की सीढ़ियाँ, नावें और बहते लट्ठे';

  @override
  String get realmDesertBlurb => 'खुले आसमान के नीचे बलुआ पत्थर की प्राचीरें';

  @override
  String get realmCelestialBlurb => 'सोने की एक तैरती नगरी';

  @override
  String hudCoins(int count) {
    return 'मुद्रा: $count';
  }

  @override
  String hudDistance(int metres) {
    return 'दूरी: $metres मीटर';
  }

  @override
  String get hudPause => 'रोकें';

  @override
  String hudBoost(int count) {
    return 'गरुड़ पंख बूस्ट, $count बाकी';
  }

  @override
  String get pauseTitle => 'रुका हुआ';

  @override
  String get pauseResume => 'जारी रखें';

  @override
  String get pauseRestart => 'फिर से शुरू करें';

  @override
  String get pauseQuit => 'मुख्य पृष्ठ पर जाएँ';

  @override
  String get gameOverTitle => 'आपकी दौड़ यहीं थमी';

  @override
  String get scoreLabel => 'स्कोर';

  @override
  String get coinsCollected => 'इकट्ठी मुद्राएँ';

  @override
  String get newBest => 'नई सबसे लंबी दौड़!';

  @override
  String get retry => 'फिर कोशिश करें';

  @override
  String get backToHub => 'मुख्य पृष्ठ पर लौटें';

  @override
  String realmCompleteTitle(String realm) {
    return '$realm पार!';
  }

  @override
  String get realmCompleteBody =>
      'आप लोक के दूसरे छोर तक पहुँच गए। आपकी मुद्राएँ बटुए में सुरक्षित हैं।';

  @override
  String get continueLabel => 'आगे बढ़ें';

  @override
  String get hintLanes => 'बचने के लिए बाएँ या दाएँ स्वाइप करें';

  @override
  String get hintJump => 'कूदने के लिए ऊपर स्वाइप करें';

  @override
  String get hintSlide => 'फिसलने के लिए नीचे स्वाइप करें';

  @override
  String monkeyStole(int count) {
    return 'एक बंदर ने $count मुद्राएँ छीन लीं!';
  }

  @override
  String get featherGot => 'गरुड़ पंख! उड़ने के लिए पंख टैप करें';

  @override
  String get lotusGot => 'कमल ताबीज़! मुद्राएँ आपके पास आती हैं';

  @override
  String distanceToGo(int metres) {
    return '$metres मी बाकी';
  }
}
