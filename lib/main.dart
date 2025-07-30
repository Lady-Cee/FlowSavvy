
import 'package:firebase_core/firebase_core.dart';
import 'package:flow_savvy/features/account/login/login_screen.dart';
import 'package:flow_savvy/features/account/password/forgot_password_screen.dart';
import 'package:flow_savvy/features/account/signup/signup_screen.dart';
import 'package:flow_savvy/features/providers/period_log_provider.dart';
import 'package:flow_savvy/features/providers/product_provider.dart';
import 'package:flow_savvy/features/providers/profile_complete_provider.dart';
import 'package:flow_savvy/features/structure/educational/screen/educational_resource_screen.dart';
import 'package:flow_savvy/features/structure/gemini/gemini_search_screen.dart';
import 'package:flow_savvy/features/structure/home/screen/home_screen.dart';
import 'package:flow_savvy/features/structure/home/screen/test_screen.dart';
import 'package:flow_savvy/features/structure/menopause/menopause_screen.dart';
import 'package:flow_savvy/features/structure/onboarding/onboarding_screens.dart';
import 'package:flow_savvy/features/structure/period/screen/period_log_screen.dart';
import 'package:flow_savvy/features/structure/support/screen/community_support_screen.dart';
import 'package:flow_savvy/features/structure/symptom/screen/symptom_log_screen.dart';
import 'package:flow_savvy/features/structure/user/screen/user_profile_screen.dart';
import 'package:flow_savvy/features/theme/app_theme.dart';

import 'package:flutter/material.dart';import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';

import 'features/models/profile_complete_model.dart';
import 'features/providers/auth_provider.dart';
import 'features/providers/community_admin_provider.dart';
import 'features/providers/community_support_provider.dart';
import 'features/providers/counsellor_provider.dart';
import 'features/providers/doctor_provider.dart';
import 'features/providers/gemini_provider.dart';
import 'features/providers/is_login_state_provider.dart';
import 'features/providers/menopause_provider.dart';
import 'features/providers/mental_health_provider.dart';
import 'features/providers/symptom_log_provider.dart';
import 'features/providers/user_profile_provider.dart';
import 'features/services/firebase_auth_services.dart';
import 'features/services/splash_service.dart';
import 'features/structure/home/screen/profile_complete_screen.dart';
import 'features/structure/product/screen/product_screen.dart';
import 'features/structure/splash/splash_screen.dart';
import 'features/structure/support/screen/community_admin_screen.dart';
import 'features/structure/support/screen/counsellor_screen.dart';
import 'features/structure/support/screen/doctor_screen.dart';
import 'features/structure/support/screen/mental_health_professional_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/utils/app_strings.dart';
import 'features/structure/home/screen/login_signup_screen.dart';
import 'firebase_options.dart';
// import 'package:provider/provider.dart';
// import 'features/providers/educational_resource_provider.dart';
// import 'features/providers/symptom_log_provider.dart';
// import 'features/providers/user_profile_provider.dart';
// import 'features/structure/splash/splash_screen.dart';
// import 'firebase_options.dart';
// import 'structure/user_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  Gemini.init(apiKey: dotenv.env['GEMINI_API_KEY']!);
  print("Gemini Key: ${dotenv.env['GEMINI_API_KEY']}");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => SymptomLogProvider()),
        ChangeNotifierProvider(create: (_) => PeriodLogProvider()),
        ChangeNotifierProvider(create: (_) => GeminiProvider()),
        ChangeNotifierProvider(create: (_) => CommunitySupportProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CommunityAdminProvider()),
        ChangeNotifierProvider(create: (_) => CounsellorProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
        ChangeNotifierProvider(create: (_) => MentalHealthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileCompleteProvider()),
        ChangeNotifierProvider(create: (_) => MenopauseProvider()),
        Provider<FireBaseAuthService>(create: (_) => FireBaseAuthService(),),
        ChangeNotifierProvider<AuthProvider>( create: (context) => AuthProvider(context.read<FireBaseAuthService>()),),
        Provider<AppTheme>(create:(_) => AppTheme() ),
        Provider<SplashService>(create: (_) => SplashService()),
        ChangeNotifierProvider(create: (_) => IsLoginStateProvider()),
       // ChangeNotifierProvider(create: (_) => EducationalResourceProvider()),

    ],
      child: MaterialApp(
        title: 'Menstrual Health Tracker',
        theme: AppTheme().lightMode,
        // theme: AppTheme().lightMode,
        // darkTheme: AppTheme().darkMode,
        // themeMode: ThemeMode.system, // Automatically switch based on system preference
          debugShowCheckedModeBanner: false,
        locale: Locale('en'),
        supportedLocales: const [
          Locale('en'),
          // Locale('yo'),
          // Locale('ha'),
          // Locale('ig'),
        ],
        localizationsDelegates: [
          StringsDelegate(), // Renamed for clarity
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          if (supportedLocales.contains(locale)) {
            return locale;
          }
          // If not supported, fallback to English
          return const Locale('en');
        },
       // home: SplashScreen(),
        // home: TestScreen(),
        home: LoginSignUpScreen(),
        routes: {
          '/test': (_) => TestScreen(),
          '/home': (_) => HomeScreen(),
          '/onboarding': (_) => OnboardingScreen(),
          '/periodLog': (_) => PeriodLogScreen(),
          '/symptomLog': (_) => SymptomLogScreen(),
          '/educational': (_) => EducationalResourceScreen(),
          '/profile': (_) => UserProfileScreen(),
          '/search': (_) => GeminiSearchScreen(),
          '/support' : (_) => CommunitySupportScreen(),
          '/product' : (_) => ProductScreen(),
          '/counsellor' : (_) => CounsellorScreen(),
          '/doctor' : (_) => DoctorScreen(),
          '/mentalHealthProfessional' : (_) => MentalHealthProfessionalScreen(),
          '/communityAdmin' : (_) => CommunityAdminScreen(),
          '/login' : (_) => LoginScreen(),
          '/signup' : (_) => SignupScreen(),
          '/forgotPassword' : (_) => ForgotPasswordScreen(),
          '/menopause' : (_) => MenopauseScreen(),
          '/profileCompleteScreen' : (_) => ProfileCompleteScreen(),
          '/loginSignUpScreen' : (_) => LoginSignUpScreen(),

        },
      ),
    );
  }
}

class StringsDelegate extends LocalizationsDelegate<AppStrings> {
  @override
  bool isSupported(Locale locale) =>
      ['en', 'yo', 'ha', 'ig'].contains(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) async {
    if (!isSupported(locale)) {
      locale = const Locale('en'); // Default to English
    }
    await AppStrings.load(locale);
    return AppStrings();
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppStrings> old) => false;
}
