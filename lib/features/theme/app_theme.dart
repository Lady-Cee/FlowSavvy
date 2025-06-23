import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
    ThemeData get lightMode => ThemeData(
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
            ThemeData.light().textTheme,
        ).apply(
            bodyColor: Color(0xFF262626),
            displayColor: Color(0xFF262626),
        ),
    );

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

}

