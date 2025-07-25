import 'package:flutter/widgets.dart';
import 'package:flutter_localization/flutter_localization.dart';

class AppStrings {
  static late Map<String, String> _localizedStrings;

  static Future<void> load(Locale locale) async {
    final translations = {
      'en': {
        // core strings



        // Home
        'defaultText': 'Please complete your profile to get predictions.',
        'flowSavvyDashBoardText1': 'Flow Savvy Dashboard',
        'homeStayHydratedText': 'Stay hydrated and maintain a healthy routine 🌸',


        // strings for onboarding pages
        'onboardingHeaderTitle1': 'Take Charge of Your Cycle',
        'onboardingHeaderSubTitle1': 'Track your period, log symptoms, and learn \nabout your body—all in one safe, supportive \nspace',
        'onboardingHeaderTitle2': 'Know What to Expect',
        'onboardingHeaderSubTitle2': 'Log how you feel daily--track your mood, cramps, \ncravings, and more.',
        'onboardingHeaderTitle3': 'You’re Not Alone',
        'onboardingHeaderSubTitle3': 'Get trusted answers, connect with others, and \nlearn at your pace',
        'onboardingHeaderTitle4': 'Join a community that cares',
        'onboardingHeaderSubTitle4': 'Trust us to keep you informed, and \nconnected all at once.',
        'loginHeaderText': 'welcome Back.',
        'loginSubtitleText': 'Log in to continue your journey.',
        'signupHeaderText': 'Create an Account.',
        'signupSubtitleText': 'Join the PeriodReal community.',




        // strings for profile page
        'completeYourProfileText': 'Complete Your Profile',
        'completeProfileSubTitleText': 'Tell us more about you so we can personalise your experience',
        'completeProfileNameText': 'Name',
        'completeProfileAgeText': 'Age',
        'completeProfileAverageCycleText': 'Average Cycle Length (days) if not sure use 28days',
        'completeProfileLastPeriodText': 'Last Period Start Date',
        'completeProfileNextPeriodIsText': 'Your next period is expected on: ',
        'completeProfileEstimatedOvulationText': 'Estimated ovulation day: ',
        'saveProfileBtnText': 'Save Profile',
        'completeProfileWeValueText': 'We value your privacy. Your information stay secure with us',


        // for login and sign up
        // 'loginHeaderText': 'Welcome Back',
        // 'loginSubtitleText': 'Log in to continue your journey',

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
  String get flowSavvyDashBoardText1 => _localizedStrings['flowSavvyDashBoardText1']!;
  String get homeStayHydratedText => _localizedStrings['homeStayHydratedText']!;

  // for onboarding pages
  String get onboardingHeaderTitle1 => _localizedStrings['onboardingHeaderTitle1']!;
  String get onboardingHeaderSubTitle1 => _localizedStrings['onboardingHeaderSubTitle1']!;
  String get onboardingHeaderTitle2 => _localizedStrings['onboardingHeaderTitle2']!;
  String get onboardingHeaderSubTitle2 => _localizedStrings['onboardingHeaderSubTitle2']!;
  String get onboardingHeaderTitle3 => _localizedStrings['onboardingHeaderTitle3']!;
  String get onboardingHeaderSubTitle3 => _localizedStrings['onboardingHeaderSubTitle3']!;
  String get onboardingHeaderTitle4 => _localizedStrings['onboardingHeaderTitle4']!;
  String get onboardingHeaderSubTitle4 => _localizedStrings['onboardingHeaderSubTitle4']!;
  String get loginHeaderText => _localizedStrings['loginHeaderText']!;
  String get loginSubtitleText => _localizedStrings['loginSubtitleText']!;
  String get signupHeaderText => _localizedStrings['signupHeaderText']!;
  String get signupSubtitleText => _localizedStrings['signupSubtitleText']!;


  // for profile screen
  String get completeYourProfileText => _localizedStrings['completeYourProfileText']!;
  String get completeProfileSubTitleText => _localizedStrings['completeProfileSubTitleText']!;
  String get completeProfileNameText => _localizedStrings['completeProfileNameText']!;
  String get completeProfileAgeText => _localizedStrings['completeProfileAgeText']!;
  String get completeProfileAverageCycleText => _localizedStrings['completeProfileAverageCycleText']!;
  String get completeProfileLastPeriodText => _localizedStrings['completeProfileLastPeriodText']!;
  String get completeProfileNextPeriodIsText => _localizedStrings['completeProfileNextPeriodIsText']!;
  String get completeProfileEstimatedOvulationText => _localizedStrings['completeProfileEstimatedOvulationText']!;
  String get saveProfileBtnText => _localizedStrings['saveProfileBtnText']!;
  String get completeProfileWeValueText => _localizedStrings['completeProfileWeValueText']!;


  // for login and sign up
  // String get loginHeaderText => _localizedStrings['loginHeaderText']!;
  // String get loginSubtitleText => _localizedStrings['loginSubtitleText']!;




  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings)!;
  }

}