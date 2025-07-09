import 'package:flutter/widgets.dart';
import 'package:flutter_localization/flutter_localization.dart';

class AppStrings {
  static late Map<String, String> _localizedStrings;

  static Future<void> load(Locale locale) async {
    final translations = {
      'en': {
        // Home
        'defaultText': 'Please complete your profile to get predictions.',


        // strings for onboarding pages
        'onboardingHeaderTitle1': 'Take Charge of Your Cycle',
        'onboardingHeaderSubTitle1': 'Track your period, log symptoms, and learn \nabout your body—all in one safe, supportive \nspace',
        'onboardingHeaderTitle2': 'Know What to Expect',
        'onboardingHeaderSubTitle2': 'Log how you feel daily--track your mood, cramps, \ncravings, and more.',
        'onboardingHeaderTitle3': 'You’re Not Alone',
        'onboardingHeaderSubTitle3': 'Get trusted answers, connect with others, and \nlearn at your pace',
        'onboardingHeaderTitle4': 'Join a community that cares',
        'onboardingHeaderSubTitle4': 'Trust us to keep you informed, and \nconnected all at once.',


        // for login and sign up
        'loginHeaderText': 'Welcome Back',
        'loginSubtitleText': 'Log in to continue your journey',

        // for sample UI

      },
      'yo': {
        // Home
        'defaultText': 'Yoruba',

        // for sign in
        'homeAppBarText': 'Aplicación de películas',


        // for sample UI

      },
      'ha': {
        // Home
        'defaultText': 'Hausa',

        // for sign in
        'homeAppBarText': 'Application de films',



        // for sample UI

      },  'ig': {
        // Home
        'defaultText': 'Igbo',

        // for sign in
        'homeAppBarText': 'Application de films',



        // for sample UI

      },
    };

    _localizedStrings = translations[locale.languageCode] ??
        translations['en']!; // Default to English
  }

  // home
  String get defaultText => _localizedStrings['defaultText']!;

  // for onboarding pages
  String get onboardingHeaderTitle1 => _localizedStrings['onboardingHeaderTitle1']!;
  String get onboardingHeaderSubTitle1 => _localizedStrings['onboardingHeaderSubTitle1']!;
  String get onboardingHeaderTitle2 => _localizedStrings['onboardingHeaderTitle2']!;
  String get onboardingHeaderSubTitle2 => _localizedStrings['onboardingHeaderSubTitle2']!;
  String get onboardingHeaderTitle3 => _localizedStrings['onboardingHeaderTitle3']!;
  String get onboardingHeaderSubTitle3 => _localizedStrings['onboardingHeaderSubTitle3']!;
  String get onboardingHeaderTitle4 => _localizedStrings['onboardingHeaderTitle4']!;
  String get onboardingHeaderSubTitle4 => _localizedStrings['onboardingHeaderSubTitle4']!;


  // for login and sign up
  String get loginHeaderText => _localizedStrings['loginHeaderText']!;
  String get loginSubtitleText => _localizedStrings['loginSubtitleText']!;




  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings)!;
  }

}