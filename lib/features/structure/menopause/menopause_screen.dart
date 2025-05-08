import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/menopause_provider.dart';

class MenopauseScreen extends StatelessWidget {
  const MenopauseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menopauseTips = Provider.of<MenopauseProvider>(context).tips;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menopause Tips'),
        backgroundColor: Colors.pink.shade100,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction
            const Text(
              'What is Menopause?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Menopause is the natural end of a woman\'s menstrual cycle, typically occurring between ages 45 and 55. '
                  'It may bring symptoms like hot flashes, mood swings, and sleep issues due to hormonal changes.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Tips from provider
            const Text(
              'Common Symptoms & Tips',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menopauseTips.length,
              itemBuilder: (context, index) {
                final tip = menopauseTips[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: Text(
                      tip.icon,
                      style: const TextStyle(fontSize: 30),
                    ),
                    title: Text(
                      tip.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(tip.description),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
            const Text(
              'Nutrition & Lifestyle Tips',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const BulletPoint(text: 'Foods that help with hormone balance (e.g., soy, flaxseed, whole grains)'),
            const BulletPoint(text: 'Calcium and Vitamin D-rich foods for bone health'),
            const BulletPoint(text: 'Exercise regularly – walking, yoga, strength training'),
            const BulletPoint(text: 'Practice stress management – mindfulness, deep breathing, or yoga'),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/support',
                    //arguments: {'showExpertMenu': true},
                  );
                },
                icon: const Icon(Icons.medical_services),
                label: const Text('Talk to an Expert'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade400,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;
  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 18)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}


