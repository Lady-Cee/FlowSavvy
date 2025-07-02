// // Tinus own
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
    ThemeData get lightMode =>
        ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.pink,
            colorScheme: ColorScheme.light(
                surface: Color(0xFFFFFFFF),
                inverseSurface: Color(0xFFFFE9E4),
                primary: Color(0xFFFF6B81),
                secondary: Color(0xFFC0C0C0),
                inversePrimary: Color(0xFF333333),
                tertiary: Color(0xFFA3A3A3)
            ),
            textTheme: GoogleFonts.nunitoTextTheme(
                ThemeData
                    .light()
                    .textTheme,
            ).apply(
                bodyColor: Color(0xFF262626),
                displayColor: Color(0xFF262626),
            ),
        );
}


//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class AppTheme {
//     // Light Theme
//     ThemeData get lightMode => ThemeData(
//         brightness: Brightness.light,
//         primarySwatch: Colors.pink,
//         colorScheme: const ColorScheme.light(
//             surface: Color(0xFFFFFFFF),
//             inverseSurface: Color(0xFFFFE9E4),
//             primary: Color(0xFFFF6B81),
//             secondary: Color(0xFFC0C0C0),
//             inversePrimary: Color(0xFF333333),
//             tertiary: Color(0xFFA3A3A3),
//         ),
//         scaffoldBackgroundColor: const Color(0xFFFFFFFF),
//         textTheme: GoogleFonts.nunitoTextTheme().apply(
//             bodyColor: Color(0xFF262626),
//             displayColor: Color(0xFF262626),
//         ),
//     );
//
//     // Dark Theme
//     ThemeData get darkMode => ThemeData(
//         brightness: Brightness.dark,
//         primarySwatch: Colors.pink,
//         colorScheme: const ColorScheme.dark(
//             surface: Color(0xFF121212),
//             inverseSurface: Color(0xFF1E1E1E),
//             primary: Color(0xFFFF6B81),
//             secondary: Color(0xFF888888),
//             inversePrimary: Color(0xFFFFFFFF),
//             tertiary: Color(0xFFB0B0B0),
//         ),
//         scaffoldBackgroundColor: const Color(0xFF121212),
//         textTheme: GoogleFonts.nunitoTextTheme().apply(
//             bodyColor: Colors.white,
//             displayColor: Colors.white,
//         ),
//     );
// }
// //


//ends here
/// Dark mode
// ThemeData darkMode = ThemeData(
//     brightness: Brightness.dark,
//     primarySwatch: Colors.yellow,
//     fontFamily: 'Montserrat',
//     colorScheme: ColorScheme.dark(
//         surface: Colors.grey.shade900,
//         primary: Colors.grey.shade800,
//         secondary: Colors.grey.shade700,
//         inversePrimary: Colors.grey.shade300
//     ),
//
//     textTheme: ThemeData.light().textTheme.apply(
//         bodyColor: Color(0xFF262626),
//         displayColor: Color(0xFF262626),
//     ),
// );

//}

