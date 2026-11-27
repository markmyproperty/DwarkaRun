// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'युगों की यात्रा';

  @override
  String get hubTagline => 'दस महान लोकों की खोज-यात्रा';

  @override
  String get hubNextStop => 'अगला पड़ाव';

  @override
  String get hubStartYatra => 'साहसिक यात्रा शुरू करें';

  @override
  String hubContinueTo(String realm) {
    return '$realm की ओर बढ़ें';
  }

  @override
  String hubRunAgain(String realm) {
    return '$realm फिर से खेलें';
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
  String get howToKeys => 'कीबोर्ड पर: तीर कुंजियाँ या WASD, और बूस्ट के लिए स्पेस';

  @override
  String get howToBoost => 'गरुड़ पंख इकट्ठा करें, फिर सब कुछ पार उड़ने के लिए उसे टैप करें';

  @override
  String get howToLotus => 'कमल ताबीज़ पास की मुद्राएँ आपकी ओर खींचता है';

  @override
  String get howToMonkey => 'शरारती बंदर कुछ मुद्राएँ छीन लेते हैं। उनके ऊपर से कूदें!';

  @override
  String get soundOn => 'आवाज़ चालू';

  @override
  String get soundOff => 'आवाज़ बंद';

  @override
  String get realmAyodhya => 'अयोध्या रन';

  @override
  String get realmGanga => 'गंगा रन';

  @override
  String get realmPharaoh => 'थार रेगिस्तान रन';

  @override
  String get realmHimalayan => 'हिमालयन रन';

  @override
  String get realmVijayanagar => 'विजयनगर रन';

  @override
  String get realmDragonValley => 'ड्रैगन वैली';

  @override
  String get realmLanka => 'लंका रन';

  @override
  String get realmIndus => 'सिंधु रन';

  @override
  String get realmSunkenDwarka => 'द्वारका: डूबा हुआ साम्राज्य';

  @override
  String get realmFinalLegend => 'द्वारका रन: अंतिम गाथा';

  @override
  String get realmAyodhyaBlurb => 'मंदिर, राजसी आँगन और बाज़ार की गलियाँ';

  @override
  String get realmGangaBlurb => 'नदी किनारे घाट, नावें और तैरते मंच';

  @override
  String get realmPharaohBlurb => 'सुनहरे टीले, बलुआ पत्थर की गलियाँ और छिपा ख़ज़ाना';

  @override
  String get realmHimalayanBlurb => 'बर्फ़ीले दर्रे, रस्सी के पुल और मठ';

  @override
  String get realmVijayanagarBlurb => 'पत्थर के रथ, बाज़ार और शिलाओं वाली पहाड़ियाँ';

  @override
  String get realmDragonValleyBlurb => 'ज्वालामुखी, लावा गुफाएँ और ड्रैगन के किले';

  @override
  String get realmLankaBlurb => 'महलों और बागों वाला एक स्वर्णिम द्वीप राज्य';

  @override
  String get realmIndusBlurb => 'ईंटों के नगर, अन्नागार और जल नालियाँ';

  @override
  String get realmSunkenDwarkaBlurb => 'समुद्री मंदिर और जलमग्न महल';

  @override
  String get realmFinalLegendBlurb => 'स्वर्ण नगरी और अंतिम अवशेष कक्ष';

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
  String get realmCompleteBody => 'आप लोक के दूसरे छोर तक पहुँच गए। आपकी मुद्राएँ बटुए में सुरक्षित हैं।';

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

  @override
  String get riverStart => 'खुला पानी! नावों और तख्तों के बीच की दूरी कूदकर पार करें';

  @override
  String get bridgeStart => 'धारा तेज़ हो रही है! पुल पर दौड़ लगाएँ';

  @override
  String get gameOverSplash => 'छपाक! नदी में गिर गए';

  @override
  String get crevasseStart => 'बर्फ़ की दरारें! बर्फ़ पर रहो और दरारें कूदो';

  @override
  String get ropeBridgeStart => 'रस्सी का पुल! हवा तेज़ होने से पहले पार करो';

  @override
  String get gameOverCrevasse => 'अरे! दरार में फिसल गए';

  @override
  String get moatStart => 'महल की खाई! सुनहरे चबूतरों पर कूदते चलो';

  @override
  String get fortressBridgeStart => 'क़िले का पुल! गढ़ तक दौड़ो';

  @override
  String get gameOverMoat => 'छपाक! महल की खाई में गिर गए';

  @override
  String seasonLabel(int number) {
    return 'सीज़न $number';
  }

  @override
  String get seasonJambudvipa => 'जम्बूद्वीप';

  @override
  String get seasonJambudvipaBlurb => 'अयोध्या से डूबी द्वारका तक, दस महान लोक';

  @override
  String get trenchStart => 'समुद्री खाई! मूँगे की कगारों पर रहो';

  @override
  String get coralBridgeStart => 'मूँगे का पुल! महल की ओर दौड़ो';

  @override
  String get gameOverTrench => 'अरे! गहरी खाई में गिर गए';
}
