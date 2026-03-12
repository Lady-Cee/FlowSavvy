// import 'package:flow_savvy/features/structure/period_matters/pad_request_form/pad_request_form.dart';
// import 'package:flow_savvy/features/structure/period_matters/period/screen/period_log_screen.dart';
// import 'package:flow_savvy/features/structure/period_matters/symptom/screen/symptom_log_screen.dart';
// import 'package:flow_savvy/features/structure/period_matters/user/screen/user_profile_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class PeriodMattersScreen extends StatefulWidget {
//   const PeriodMattersScreen({super.key});
//
//   @override
//   State<PeriodMattersScreen> createState() => _PeriodMattersScreenState();
// }
//
// class _PeriodMattersScreenState extends State<PeriodMattersScreen> {
//   int selectedIndex = -1;
//
//   // Function to open URL in external browser
//   Future<void> _openUrl(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Could not open the form'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
//
//   final List<Map<String, dynamic>> resources = [
//     {
//       'title': 'Track Period',
//       'icon': Icons.calendar_today,
//       'screen': PeriodLogScreen(),
//     },
//     {'title': 'Symptom Log',
//       'icon': Icons.medical_services_outlined,
//       'screen': SymptomLogScreen(),
//     },
//     {'title': 'Profile',
//       'icon': Icons.person,
//       'screen': UserProfileScreen(),
//     },
//     {
//       'title': 'Pad Request Form',
//       'icon': Icons.assignment_outlined,
//       'screen': null,
//       'isNavigate': false,
//       'url': 'https://forms.gle/nZYx7X6gjNgrgm1X6', // Replace with your actual form URL
//     },
//
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Everything About Period'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             const Text(
//               'Log your period, track the symptoms and your profile. '
//                   'This section provides you with platform to record your menses start and end date, record the symptoms for each month and view your profile.',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//             ),
//             const SizedBox(height: 30),
//             Expanded(
//               child: GridView.builder(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   mainAxisSpacing: 16,
//                   crossAxisSpacing: 16,
//                   childAspectRatio: 1.1,
//                 ),
//                 itemCount: resources.length,
//                 itemBuilder: (context, index) {
//                   final resource = resources[index];
//                   final isPeriodBot = resource['title'] == 'Ask PeriodBot';
//
//                   return InkWell(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => resource['screen']),
//                       );
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: isPeriodBot ? Colors.purple.shade50 : Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: Colors.pink,
//                           width: 2,
//                         ),
//                         // boxShadow: isPeriodBot
//                         //     ? [BoxShadow(color: Colors.purple.shade100, blurRadius: 6, offset: Offset(0, 2))]
//                         //     : [],
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             resource['icon'],
//                             size: 40,
//                             color: Colors.pinkAccent,
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             resource['title'],
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: isPeriodBot ? 17 : 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//
//               ),
//             ),
//
//           ],
//
//         ),
//
//       ),
//     );
//   }
// }


import 'package:flow_savvy/features/structure/period_matters/period/screen/period_log_screen.dart';
import 'package:flow_savvy/features/structure/period_matters/symptom/screen/symptom_log_screen.dart';
import 'package:flow_savvy/features/structure/period_matters/user/screen/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PeriodMattersScreen extends StatefulWidget {
  const PeriodMattersScreen({super.key});

  @override
  State<PeriodMattersScreen> createState() => _PeriodMattersScreenState();
}

class _PeriodMattersScreenState extends State<PeriodMattersScreen> {
  int selectedIndex = -1;

  // Function to open URL - FIXED VERSION
  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      // Try different launch modes
      bool launched = false;

      // Try external application first
      try {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        print('External app launch failed: $e');
      }

      // If external didn't work, try platform default
      if (!launched) {
        try {
          launched = await launchUrl(uri);
        } catch (e) {
          print('Platform default launch failed: $e');
        }
      }

      // If still not launched, try in-app browser
      if (!launched) {
        try {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.inAppWebView,
          );
        } catch (e) {
          print('In-app web view launch failed: $e');
        }
      }

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open the form. Please check your internet connection.'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Copy Link',
              textColor: Colors.white,
              onPressed: () {
                // You can add clipboard functionality here if needed
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Error launching URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Define resource items with proper typing
  List<Map<String, dynamic>> get resources => [
    {
      'title': 'Track Period',
      'icon': Icons.calendar_today,
      'type': 'navigate',
      'screen': PeriodLogScreen(),
    },
    {
      'title': 'Symptom Log',
      'icon': Icons.medical_services_outlined,
      'type': 'navigate',
      'screen': SymptomLogScreen(),
    },
    {
      'title': 'Profile',
      'icon': Icons.person,
      'type': 'navigate',
      'screen': UserProfileScreen(),
    },
    {
      'title': 'Pad Request Form',
      'icon': Icons.assignment_outlined,
      'type': 'url',
      'url': 'https://forms.gle/nZYx7X6gjNgrgm1X6', // Pad request form url
    },
  ];

  void _handleTap(Map<String, dynamic> resource) {
    if (resource['type'] == 'navigate' && resource['screen'] != null) {
      // Navigate to screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => resource['screen']),
      );
    } else if (resource['type'] == 'url' && resource['url'] != null) {
      // Open URL in browser
      _openUrl(resource['url']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Everything About Period'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Log your period, track the symptoms and your profile. '
                  'This section provides you with platform to record your menses start and end date, record the symptoms for each month and view your profile.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: resources.length,
                itemBuilder: (context, index) {
                  final resource = resources[index];
                  final isPeriodBot = resource['title'] == 'Ask PeriodBot';

                  return InkWell(
                    onTap: () => _handleTap(resource),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isPeriodBot ? Colors.purple.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.pink,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            resource['icon'],
                            size: 40,
                            color: Colors.pinkAccent,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            resource['title'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isPeriodBot ? 17 : 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}