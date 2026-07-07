import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../providers/counsellor_provider.dart';

//import '../../../providers/counsellor_provider.dart';

class CounsellorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counsellors = Provider.of<CounsellorProvider>(context).counsellors;

    return Scaffold(
      appBar: AppBar(title: Text('Consult a Counsellor')),
      body: ListView.builder(
        itemCount: counsellors.length,
        itemBuilder: (ctx, i) {
          final counsellor = counsellors[i];

          return Card(
            margin: EdgeInsets.all(10),

            child: ListTile(
              leading: Image.asset(
                counsellor.imageUrl,
                width: 60,
                fit: BoxFit.cover,
              ),

              title: Text(counsellor.name),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,

                children: [
                  Text(
                    counsellor.expertise,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(counsellor.bio),
                  Text(counsellor.email),
                  Text(counsellor.phoneNumber),
                ],
              ),

              trailing: Icon(Icons.call),

              onTap: () async {
                final Uri phoneUri = Uri(
                  scheme: 'tel',
                  path: counsellor.phoneNumber,
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
