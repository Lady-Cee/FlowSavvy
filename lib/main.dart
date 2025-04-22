
import 'package:firebase_core/firebase_core.dart';
import 'package:flow_savvy/features/providers/period_log_provider.dart';
import 'package:flow_savvy/features/structure/educational/screen/educational_resource_screen.dart';
import 'package:flow_savvy/features/structure/gemini/gemini_search_screen.dart';
import 'package:flow_savvy/features/structure/home/screen/home_screen.dart';
import 'package:flow_savvy/features/structure/period/screen/period_log_screen.dart';
import 'package:flow_savvy/features/structure/symptom/screen/symptom_log_screen.dart';
import 'package:flow_savvy/features/structure/user/screen/user_profile_screen.dart';

import 'package:flutter/material.dart';import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';

import 'features/providers/gemini_provider.dart';
import 'features/providers/symptom_log_provider.dart';
import 'features/providers/user_profile_provider.dart';
import 'features/structure/splash/splash_screen.dart';
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
  print("Gemini Key: ${dotenv.env['GEMINI_API_KEY']}");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Gemini.init(apiKey: dotenv.env['GEMINI_API_KEY']!);
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
       // ChangeNotifierProvider(create: (_) => EducationalResourceProvider()),
        //ChangeNotifierProvider(create: (_) => sourceProvider()),
    ],
      child: MaterialApp(
        title: 'Menstrual Health Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
          debugShowCheckedModeBanner: false,
        home: SplashScreen(),
        routes: {
          '/home': (_) => HomeScreen(),
          '/periodLog': (_) => PeriodLogScreen(),
          '/symptomLog': (_) => SymptomLogScreen(),
          '/educational': (_) => EducationalResourceScreen(),
          '/profile': (_) => UserProfileScreen(),
          '/search': (_) => GeminiSearchScreen(),
        },
      ),
    );
  }
}
