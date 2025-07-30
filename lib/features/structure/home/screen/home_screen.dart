
import 'package:flow_savvy/features/models/user_profilel.dart';
import 'package:flow_savvy/features/services/firebase_auth_services.dart';
import 'package:flow_savvy/features/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_profile_provider.dart';

class HomeScreen extends StatelessWidget {
// final FireBaseAuthService auth = FireBaseAuthService();

  void logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('rememberMe', false);

    Navigator.pushReplacementNamed(context, '/login');
  }

  final AppStrings appStrings = AppStrings();


  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<UserProfileProvider>(context).userProfile;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Flow Savvy Dashboard'),
        actions: [
          PopupMenuButton<int>(
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.menu),
            ),
            tooltip: 'Menu',
            onSelected: (value) {
              switch (value) {
                case 0:
                  Navigator.pushNamed(context, '/symptomLog');
                  break;
                case 1:
                  Navigator.pushNamed(context, '/educational');
                  break;
                case 2:
                  Navigator.pushNamed(context, '/profile');
                  break;
                case 3:
                  Navigator.pushNamed(context, '/periodLog');
                  break;
                case 4:
                  Navigator.pushNamed(context, '/support');
                  break;
                case 5:
                  Navigator.pushNamed(context, '/menopause');
                  break;
              }
            },
            itemBuilder: (context) {
              final items = <PopupMenuEntry<int>>[
                PopupMenuItem(
                  value: 0,
                  child: Row(
                    children: [
                      Icon(Icons.monitor_heart, color: Colors.pink),
                      SizedBox(width: 10),
                      Text('My Symptom Log'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(Icons.library_books, color: Colors.pink),
                      SizedBox(width: 10),
                      Text('Educational Resource'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.pink),
                      SizedBox(width: 10),
                      Text('My Profile'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 3,
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.pink),
                      SizedBox(width: 10),
                      Text('My Period Log'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 4,
                  child: Row(
                    children: [
                      Icon(Icons.people_rounded, color: Colors.pink),
                      SizedBox(width: 10),
                      Text('Community Support'),
                    ],
                  ),
                ),
              ];

              // Only show Menopause Tips if profile is not null and age >= 40
              if (profile != null && profile.age >= 40) {
                items.add(
                  PopupMenuItem(
                    value: 5,
                    child: Row(
                      children: [
                        Icon(Icons.female, color: Colors.pink),
                        SizedBox(width: 10),
                        Text('Menopause Tips'),
                      ],
                    ),
                  ),
                );
              }

              return items;
            },
          ),
          IconButton(onPressed: () => logout(context), icon: Icon(Icons.exit_to_app), tooltip: 'logout',)

        ],
      ),
      body: Consumer<UserProfileProvider>(
        builder: (context, profileProvider, _) {
          final profile = profileProvider.userProfile;

          if (profile == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    appStrings.defaultText,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: Text('Go to Profile'),
                  ),
                ],
              ),
            );
          }

          final nextPeriod = profile.predictedNextPeriod != null
              ? DateFormat('MMM dd, yyyy').format(profile.predictedNextPeriod!)
              : 'Not available';

          final ovulationDate = profile.predictedOvulation != null
              ? DateFormat('MMM dd, yyyy').format(profile.predictedOvulation!)
              : 'Not available';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${profile.name} 👋',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text('Next Period'),
                    subtitle: Text(nextPeriod),
                    leading: Icon(Icons.calendar_today, color: Colors.pink),
                  ),
                ),
                SizedBox(height: 10),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text('Predicted Ovulation'),
                    subtitle: Text(ovulationDate),
                    leading: Icon(Icons.favorite, color: Colors.redAccent),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Stay hydrated and maintain a healthy routine 🌸',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(height: 30),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildFeatureCard(
                      context,
                      title: 'My Period Log',
                      icon: Icons.calendar_today,
                      routeName: '/periodLog',
                    ),
                    _buildFeatureCard(
                      context,
                      title: 'My Symptom Log',
                      icon: Icons.monitor_heart,
                      routeName: '/symptomLog',
                    ),
                    _buildFeatureCard(
                      context,
                      title: 'Educational Resource',
                      icon: Icons.library_books,
                      routeName: '/educational',
                    ),
                    _buildFeatureCard(
                      context,
                      title: 'My Profile',
                      icon: Icons.person,
                      routeName: '/profile',
                    ),
                    _buildFeatureCard(
                      context,
                      title: 'Community Support',
                      icon: Icons.people_rounded,
                      routeName: '/support',
                    ),
                    // ✅ Show this only if age >= 40
                    if (profile.age >= 40)
                      _buildFeatureCard(
                        context,
                        title: 'Menopause Tips',
                        icon: Icons.female,
                        routeName: '/menopause',
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required String title, required IconData icon, required String routeName}) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, routeName),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.pink),
              SizedBox(height: 10),
              Text(title, style: TextStyle(fontSize: 16), textAlign: TextAlign.center, ),
            ],
          ),
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../providers/auth_provider.dart';
// import '../../../providers/user_profile_provider.dart';
// import '../../../utils/app_strings.dart';
// import '../../educational/screen/educational_resource_screen.dart';
// import '../../menopause/menopause_screen.dart';
// import '../../period/screen/period_log_screen.dart';
// import '../../support/screen/community_support_screen.dart';
// import '../../symptom/screen/symptom_log_screen.dart';
// import '../../user/screen/user_profile_screen.dart';
//
// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   final AppStrings appStrings = AppStrings();
//   int _selectedIndex = 0;
//
//   void _onTabSelected(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   void logout(BuildContext context) async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     await authProvider.logout();
//     final prefs = await SharedPreferences.getInstance();
//     Navigator.pushReplacementNamed(context, '/login');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final profile = Provider.of<UserProfileProvider>(context).userProfile;
//
//     final bool showMenopause = profile != null && profile.age >= 40;
//
//     // final pages = <Widget>[
//     //   _buildPage('My Period Log', Icons.calendar_today),
//     //   _buildPage('My Symptom Log', Icons.monitor_heart),
//     //   _buildPage('Educational Resource', Icons.library_books),
//     //   _buildPage('My Profile', Icons.person),
//     //   _buildPage('Community Support', Icons.people_rounded),
//     //   if (showMenopause) _buildPage('Menopause Tips', Icons.female),
//     // ];
//     final pages = <Widget>[
//       PeriodLogScreen(),
//       SymptomLogScreen(),
//       EducationalResourceScreen(),
//       UserProfileScreen(),
//       CommunitySupportScreen(),
//       if (showMenopause) MenopauseScreen(),
//     ];
//
//
//     final tabs = <BottomNavigationBarItem>[
//       BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Period Log'),
//       BottomNavigationBarItem(icon: Icon(Icons.monitor_heart), label: 'Symptoms'),
//       BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Resources'),
//       BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//       BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'Support'),
//       if (showMenopause)
//         BottomNavigationBarItem(icon: Icon(Icons.female), label: 'Menopause'),
//     ];
//
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text('Flow Savvy Dashboard'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.exit_to_app),
//             tooltip: 'Logout',
//             onPressed: () => logout(context),
//           )
//         ],
//       ),
//       body: Consumer<UserProfileProvider>(
//         builder: (context, profileProvider, _) {
//           final profile = profileProvider.userProfile;
//
//           if (profile == null) {
//             return Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     appStrings.defaultText,
//                     style: TextStyle(fontSize: 16),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.pushNamed(context, '/profile');
//                     },
//                     child: Text('Go to Profile'),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           return pages[_selectedIndex];
//         },
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onTabSelected,
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Colors.pink,
//         unselectedItemColor: Colors.grey,
//         items: tabs,
//       ),
//     );
//   }
//   //
//   // Widget _buildPage(String title, IconData icon) {
//   //   return Center(
//   //     child: Column(
//   //       mainAxisSize: MainAxisSize.min,
//   //       children: [
//   //         Icon(icon, size: 60, color: Colors.pink),
//   //         SizedBox(height: 16),
//   //         Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//   //         SizedBox(height: 8),
//   //         Text('This is the $title screen', textAlign: TextAlign.center),
//   //       ],
//   //     ),
//   //   );
//   // }
// }
//
//
//

