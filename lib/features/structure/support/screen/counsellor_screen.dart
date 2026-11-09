import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../providers/counsellor_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
            child:
            ListTile(
              leading: Image.network(
              counsellor.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return const SizedBox(
                  width: 60,
                  height: 60,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  width: 60,
                  height: 60,
                  child: Icon(
                    Icons.person_outline,
                    size: 35,
                    color: Colors.pinkAccent,
                  ),
                );
              },
            ),
              title: Text(counsellor.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(counsellor.expertise, style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 4),
                  Text(counsellor.bio),
                  Text(counsellor.contactInfo),
                  // Text('Contact: ${admin.contactInfo}'),
                ],
              ),
              trailing: Icon(Icons.arrow_forward),
              onTap: () async {
                if (kIsWeb) {
                  // Web only: open WhatsApp in a new tab
                  var digits = counsellor.contactInfo.replaceAll(RegExp(r'[^0-9]'), '');
                  if (digits.startsWith('0')) digits = '234${digits.substring(1)}';

                  await launchUrl(
                    Uri.parse('https://wa.me/$digits'),
                    mode: LaunchMode.externalApplication,
                    webOnlyWindowName: '_blank',
                  );
                  return;
                }

                // Mobile: your original code, unchanged
                final url = Uri.parse(counsellor.imageUrl);

                if (await launchUrl(url, mode: LaunchMode.inAppWebView)) {
                  // launched
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not launch product link')),
                  );
                }
              },
            ),
            // ListTile(
            //   leading: Image.network(counsellor.imageUrl, width: 60, fit: BoxFit.cover),
            //   title: Text(counsellor.name),
            //   subtitle: Text(counsellor.expertise),
            //   trailing: Icon(Icons.arrow_forward),
            //   onTap: () {
            //     // Navigate to counsellor's detail or booking page
            //   },
            // ),
          );
        },
      ),
    );
  }
}
