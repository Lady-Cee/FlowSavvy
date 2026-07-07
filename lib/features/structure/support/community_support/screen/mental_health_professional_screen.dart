import 'package:flow_savvy/features/models/mental_health_professional.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../providers/mental_health_provider.dart';

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
              leading: Image.asset(
                professional.imageUrl,
                width: 60,
                fit: BoxFit.cover,
              ),

              title: Text(professional.name),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,

                children: [
                  Text(
                    professional.expertise,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(professional.bio),
                  Text(professional.email),
                  Text(professional.phoneNumber),
                ],
              ),

              trailing: Icon(Icons.call),

              onTap: () async {
                final Uri phoneUri = Uri(
                  scheme: 'tel',
                  path: professional.phoneNumber,
                );

                if (await canLaunchUrl(phoneUri)) {
                  await launchUrl(phoneUri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not make phone call'),
                    ),
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
