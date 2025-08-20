import 'package:flow_savvy/features/structure/educational/screen/faq_screen.dart';
import 'package:flow_savvy/features/structure/educational/screen/roles_screen.dart';
import 'package:flow_savvy/features/structure/gemini/gemini_search_screen.dart';
import 'package:flutter/material.dart';

import 'essential_info_screen.dart';
import 'hygiene__tips_screen.dart';
import 'myths_screen.dart';

class EducationalResourceScreen extends StatefulWidget {
  @override
  _EducationalResourceScreenState createState() => _EducationalResourceScreenState();
}

class _EducationalResourceScreenState extends State<EducationalResourceScreen> {
  int selectedIndex = -1;

  final List<Map<String, dynamic>> resources = [
    {
      'title': 'Myths vs Facts',
      'icon': Icons.question_answer,
      'screen': MythsScreen(),
    },
    {'title': 'Essential Information',
      'icon': Icons.info,
      'screen': EssentialInfoScreen(),
    },
    {'title': 'Hygiene Tips',
      'icon': Icons.clean_hands,
      'screen': HygieneTipsScreen(),
    },
    {'title': 'Our Roles',
      'icon': Icons.group,
      'screen': RolesScreen(),
    },
    {'title': 'FAQs',
      'icon': Icons.help,
      'screen': FaqScreen(),
    },
    {
      'title': 'Ask PeriodBot',
      'icon': Icons.smart_toy,
      'screen': GeminiSearchScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Educational Resources'),
        centerTitle: true,
       ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Learn, understand, and share knowledge about menstruation. '
                  'This section provides facts, hygiene tips, roles we can all play, and answers to frequently asked questions.',
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
                          color: isPeriodBot ? Colors.deepPurple : Colors.pink,
                          width: 2,
                        ),
                        boxShadow: isPeriodBot
                            ? [BoxShadow(color: Colors.purple.shade100, blurRadius: 6, offset: Offset(0, 2))]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            resource['icon'],
                            size: isPeriodBot ? 48 : 40,
                            color: isPeriodBot ? Colors.deepPurple : Colors.pinkAccent,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            resource['title'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isPeriodBot ? 17 : 16,
                              fontWeight: FontWeight.bold,
                              color: isPeriodBot ? Colors.deepPurple : Colors.black,
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
