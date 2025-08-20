import 'package:flutter/material.dart';

class HygieneTipsScreen extends StatelessWidget {
   HygieneTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hygiene Tips')),
      body: ListView.builder(
        itemCount: hygieneTips.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, i) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.clean_hands, color: Colors.blueAccent),
            title: Text(hygieneTips[i]),
          ),
        ),
      ),
    );
  }
  final List<String> hygieneTips = [
   'Change sanitary products every 4–6 hours.',
   'Wash the genital area with warm water and mild soap.',
   'Avoid using scented products that can cause irritation.',
   'Always wash your hands before and after changing sanitary products.',
   'Dispose of used sanitary products properly—wrap them and place in a bin.',
   'Wear breathable cotton underwear to help prevent infections.',
   'Take a shower daily to maintain overall cleanliness.',
   'Avoid douching as it can disrupt the vagina’s natural balance.',
   'Do not flush sanitary products; use designated disposal bins.',
   'Keep your pubic area clean and dry to reduce moisture build-up.',
   'Change underwear daily and keep an extra pair during your period.',
   'Trim pubic hair regularly to maintain hygiene (optional but helpful).',
   'Use unscented, pH-balanced wipes if necessary while outside.',
   'Properly clean reusable menstrual products (like cups or cloth pads) after each use.',
 ];
}
