import 'package:flow_savvy/features/models/user_profilel.dart';
import 'package:flow_savvy/features/services/firebase_auth_services.dart';
import 'package:flow_savvy/features/utils/app_strings.dart';
import 'package:flow_savvy/features/utils/app_text_styles.dart';
import 'package:flow_savvy/features/widgets/long_custom_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../utils/get_date_formatter.dart';

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
    final bool hasProfile = profile != null;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: !hasProfile
            ? Text(
                appStrings.flowSavvyDashBoardText1,
                style: AppTextStyles.largeTextSemiBold(context),
              )
            : Text(
                'Welcome, ${profile.name} 👋',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
        centerTitle: !hasProfile ? true : false,
        actions: [
          // PopupMenuButton<int>(
          //   icon: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Icon(Icons.menu),
          //   ),
          //   tooltip: 'Menu',
          //   onSelected: (value) {
          //     switch (value) {
          //       case 0:
          //         Navigator.pushNamed(context, '/symptomLog');
          //         break;
          //       case 1:
          //         Navigator.pushNamed(context, '/educational');
          //         break;
          //       case 2:
          //         Navigator.pushNamed(context, '/profile');
          //         break;
          //       case 3:
          //         Navigator.pushNamed(context, '/periodLog');
          //         break;
          //       case 4:
          //         Navigator.pushNamed(context, '/support');
          //         break;
          //       case 5:
          //         Navigator.pushNamed(context, '/menopause');
          //         break;
          //     }
          //   },
          //   itemBuilder: (context) {
          //     final items = <PopupMenuEntry<int>>[
          //       PopupMenuItem(
          //         value: 0,
          //         child: Row(
          //           children: [
          //             Icon(Icons.monitor_heart, color: Colors.pink),
          //             SizedBox(width: 10),
          //             Text('My Symptom Log'),
          //           ],
          //         ),
          //       ),
          //       PopupMenuItem(
          //         value: 1,
          //         child: Row(
          //           children: [
          //             Icon(Icons.library_books, color: Colors.pink),
          //             SizedBox(width: 10),
          //             Text('Educational Resource'),
          //           ],
          //         ),
          //       ),
          //       PopupMenuItem(
          //         value: 2,
          //         child: Row(
          //           children: [
          //             Icon(Icons.person, color: Colors.pink),
          //             SizedBox(width: 10),
          //             Text('My Profile'),
          //           ],
          //         ),
          //       ),
          //       PopupMenuItem(
          //         value: 3,
          //         child: Row(
          //           children: [
          //             Icon(Icons.calendar_today, color: Colors.pink),
          //             SizedBox(width: 10),
          //             Text('My Period Log'),
          //           ],
          //         ),
          //       ),
          //       PopupMenuItem(
          //         value: 4,
          //         child: Row(
          //           children: [
          //             Icon(Icons.people_rounded, color: Colors.pink),
          //             SizedBox(width: 10),
          //             Text('Community Support'),
          //           ],
          //         ),
          //       ),
          //     ];
          //
          //     // Only show Menopause Tips if profile is not null and age >= 40
          //     if (profile != null && profile.age >= 40) {
          //       items.add(
          //         PopupMenuItem(
          //           value: 5,
          //           child: Row(
          //             children: [
          //               Icon(Icons.female, color: Colors.pink),
          //               SizedBox(width: 10),
          //               Text('Menopause Tips'),
          //             ],
          //           ),
          //         ),
          //       );
          //     }
          //
          //     return items;
          //   },
          // ),
          !hasProfile ? IconButton(
            onPressed: () => logout(context),
            icon: Icon(Icons.exit_to_app),
            tooltip: 'logout',
          ) : Padding(
            padding: const EdgeInsets.only(right: 24),
            child: CircleAvatar(
              child: IconButton(onPressed: (){}, icon: Icon(Icons.person)),
            ),
          )

          // PopupMenuButton<int>(
          //   icon: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Icon(Icons.menu),
          //   ),
          //   tooltip: 'Menu',
          //   onSelected: (value) {
          //     switch (value) {
          //       case 0:
          //         Navigator.pushNamed(context, '/symptomLog');
          //         break;
          //       case 1:
          //         Navigator.pushNamed(context, '/educational');
          //         break;
          //       case 2:
          //         Navigator.pushNamed(context, '/profile');
          //         break;
          //       case 3:
          //         Navigator.pushNamed(context, '/periodLog');
          //         break;
          //       case 4:
          //         Navigator.pushNamed(context, '/support');
          //         break;
          //       case 5:
          //         Navigator.pushNamed(context, '/menopause');
          //         break;
          //     }
          //   },
          //   itemBuilder: (context) => [
          //     PopupMenuItem(
          //       value: 0,
          //       child: Row(
          //         children: [
          //           Icon(Icons.monitor_heart, color: Colors.pink),
          //           SizedBox(width: 10),
          //           Text('My Symptom Log'),
          //         ],
          //       ),
          //     ),
          //     PopupMenuItem(
          //       value: 1,
          //       child: Row(
          //         children: [
          //           Icon(Icons.library_books, color: Colors.pink),
          //           SizedBox(width: 10),
          //           Text('Educational Resource'),
          //         ],
          //       ),
          //     ),
          //     PopupMenuItem(
          //       value: 2,
          //       child: Row(
          //         children: [
          //           Icon(Icons.person, color: Colors.pink),
          //           SizedBox(width: 10),
          //           Text('My Profile'),
          //         ],
          //       ),
          //     ),
          //     PopupMenuItem(
          //       value: 3,
          //       child: Row(
          //         children: [
          //           Icon(Icons.calendar_today, color: Colors.pink),
          //           SizedBox(width: 10),
          //           Text('My Period Log'),
          //         ],
          //       ),
          //     ),
          //     PopupMenuItem(
          //       value: 4,
          //       child: Row(
          //         children: [
          //           Icon(Icons.people_rounded, color: Colors.pink),
          //           SizedBox(width: 10),
          //           Text('Community Support'),
          //         ],
          //       ),
          //     ),
          //    // if (profile.age >= 40)
          //     PopupMenuItem(
          //       value: 5,
          //       child: Row(
          //         children: [
          //           Icon(Icons.female, color: Colors.pink),
          //           SizedBox(width: 10),
          //           Text('Menopause Tips'),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
      body: Consumer<UserProfileProvider>(
        builder: (context, profileProvider, _) {
          final profile = profileProvider.userProfile;
          final color = Theme.of(context).colorScheme;

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
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: LongCustomButton(
                          onTap: () => Navigator.pushNamed(context, '/profile'),
                          title: 'Go to Profile')),
                ],
              ),
            );
          }

          final predictedNextPeriod = profile.predictedNextPeriod;
          final today = DateTime.now();


          final formattedNextPeriod = (predictedNextPeriod != null)
              ? DateFormat('MMM dd').format(predictedNextPeriod!)
              : 'Not available';

          String getPeriodStatus(DateTime predictedDate) {
            final daysLate = today.difference(predictedDate).inDays;

            if (daysLate == 0) {
              return 'due today';
            } else if (daysLate > 0) {
              return '$daysLate days late';
            } else {
              return 'in ${daysLate.abs()} days';
            }
          }

          final periodStatus = (predictedNextPeriod != null)
              ? getPeriodStatus(predictedNextPeriod!)
              : '';



          // final DateTime? predictedOvulation = profile.predictedOvulation;

          // final ovulationDate = profile.predictedOvulation != null
          //     ? DateFormat('MMM dd, yyyy').format(profile.predictedOvulation!)
          //     : 'Not available';


          final lastPeriodDate = profile.lastPeriodDate;
          final cycleLength = profile.cycleLength;
          final predictedOvulation = lastPeriodDate.add(Duration(days: 14));
          // final today = DateTime.now();

          String getOvulationCountdown(DateTime date) {
            final difference = date.difference(today).inDays;

            if (difference > 0) {
              return 'Ovulation in $difference days';
            } else if (difference == 0) {
              return 'Ovulation is today!';
            } else {
              return 'Ovulation was ${difference.abs()} days ago';
            }
          }

          String getCycleDayText(DateTime lastPeriod, int cycleLen) {
            final dayOfCycle = today.difference(lastPeriod).inDays + 1;
            return 'Day $dayOfCycle of $cycleLen-day cycle';
          }


          final int? daysUntilNextPeriod = (predictedNextPeriod != null)
              ? predictedNextPeriod.difference(today).inDays
              : null;


          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getFormattedDate(),
                  style: AppTextStyles.semiBold(context),
                ),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      getCycleDayText(lastPeriodDate, cycleLength),
                      style: AppTextStyles.smallTextRegular(context),
                    ),
                    trailing: FittedBox(
                      child: Row(
                        spacing: 8,
                        children: [
                          Icon(Icons.favorite, color: color.primary, size: 10,),
                          Text(
                            getOvulationCountdown(predictedOvulation),
                            style: AppTextStyles.smallTextRegular(context).copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Image with Dynamic Text Overlay
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Circle
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade400, width: 4),
                        ),
                      ),

                      // Inner Circle
                      Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade400, width: 2),
                        ),
                      ),

                      // Center Content
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Period in:',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$daysUntilNextPeriod',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Last Period on ${DateFormat('MMMM d yyyy').format(lastPeriodDate)}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      'Next Period',
                      style: AppTextStyles.smallTextRegular(context),
                    ),
                    trailing: FittedBox(
                      child: Row(
                        spacing: 8,
                        children: [
                          Icon(Icons.calendar_today, color: color.primary, size: 10,),
                          Text(
                            '$formattedNextPeriod • $periodStatus',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Stay hydrated and maintain a healthy routine 🌸',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

}
