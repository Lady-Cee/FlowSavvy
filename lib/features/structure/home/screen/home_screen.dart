import 'package:flow_savvy/features/models/user_profilel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_profile_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              }
            },
            itemBuilder: (context) => [
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
            ],
          ),
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
                    'Please complete your profile to get predictions.',
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

