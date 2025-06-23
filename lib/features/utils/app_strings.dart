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






  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings)!;
  }

}