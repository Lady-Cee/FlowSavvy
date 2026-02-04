import 'package:flow_savvy/features/structure/educational/screen/educational_resource_screen.dart';
import 'package:flow_savvy/features/structure/home/screen/home_screen.dart';
// import 'package:flow_savvy/features/structure/period/screen/period_log_screen.dart';
import 'package:flow_savvy/features/structure/support/screen/community_support_screen.dart';
//import 'package:flow_savvy/features/structure/symptom/screen/symptom_log_screen.dart';
//import 'package:flow_savvy/features/structure/user/screen/user_profile_screen.dart';
import 'package:flutter/material.dart';

import '../period_matters/period_matters_screen.dart';

class BottomNavigationScreen extends StatefulWidget {
  @override
  _BottomNavigationScreenState createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    PeriodMattersScreen(),
    //SymptomLogScreen(),
    EducationalResourceScreen(),
    //UserProfileScreen(),
    //PeriodLogScreen(),
    CommunitySupportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        type: BottomNavigationBarType.fixed, // Needed for 5 items
        backgroundColor: color.surface, // background color
        selectedItemColor: color.primary, // selected icon & text color
        unselectedItemColor: color.inversePrimary, // unselected icon & text color
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop),
            label: 'PeriodMatters',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.sign_language),
          //   label: 'Symptom Log',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Educational',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.person),
          //   label: 'Profile',
          // ),

          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Support',
          ),
        ],
      ),
    );
  }
}
