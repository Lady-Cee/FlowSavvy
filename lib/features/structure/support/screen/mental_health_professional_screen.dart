import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/mental_health_provider.dart';

class MentalHealthProfessionalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final professionals = Provider.of<MentalHealthProvider>(context).professionals;

    return Scaffold(
      appBar: AppBar(title: Text('Consult a Mental Health Professional')),
      body: ListView.builder(
        itemCount: professionals.length,
        itemBuilder: (ctx, i) {
          final professional = professionals[i];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Image.network(professional.imageUrl, width: 60, fit: BoxFit.cover),
              title: Text(professional.name),
              subtitle: Text(professional.qualification),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to professional's detail or booking page
              },
            ),
          );
        },
      ),
    );
  }
}
