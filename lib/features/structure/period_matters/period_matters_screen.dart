import 'package:flow_savvy/features/structure/period_matters/period/screen/period_log_screen.dart';
import 'package:flow_savvy/features/structure/period_matters/symptom/screen/symptom_log_screen.dart';
import 'package:flow_savvy/features/structure/period_matters/user/screen/user_profile_screen.dart';
import 'package:flutter/material.dart';

class PeriodMattersScreen extends StatefulWidget {
  const PeriodMattersScreen({super.key});

  @override
  State<PeriodMattersScreen> createState() => _PeriodMattersScreenState();
}

class _PeriodMattersScreenState extends State<PeriodMattersScreen> {
  int selectedIndex = -1;

  final List<Map<String, dynamic>> resources = [
    {
      'title': 'Track Period',
      'icon': Icons.calendar_today,
      'screen': PeriodLogScreen(),
    },
    {'title': 'Symptom Log',
      'icon': Icons.medical_services_outlined,
      'screen': SymptomLogScreen(),
    },
    {'title': 'Profile',
      'icon': Icons.person,
      'screen': UserProfileScreen(),
    },

  ];
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => resource['screen']),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isPeriodBot ? Colors.purple.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.pink,
                          width: 2,
                        ),
                        // boxShadow: isPeriodBot
                        //     ? [BoxShadow(color: Colors.purple.shade100, blurRadius: 6, offset: Offset(0, 2))]
                        //     : [],
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
