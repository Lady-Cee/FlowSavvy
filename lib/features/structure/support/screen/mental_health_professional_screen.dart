import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
            child:
            ListTile(
              leading: Image.network(professional.imageUrl, width: 60, fit: BoxFit.cover),
              title: Text(professional.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(professional.qualification, style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 4),
                  Text(professional.bio),
                  Text(professional.contactInfo),
                  // Text('Contact: ${admin.contactInfo}'),
                ],
              ),
              trailing: Icon(Icons.arrow_forward),
              onTap: () async {
                final url = Uri.parse(professional.imageUrl);

                if (await launchUrl(url, mode: LaunchMode.inAppWebView)) {
                  // launched
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not launch product link')),
                  );
                }
              },
            ),


          );
        },
      ),
    );
  }
}
