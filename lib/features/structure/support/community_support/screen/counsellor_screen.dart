import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../providers/counsellor_provider.dart';
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
              leading: SizedBox.square(
                dimension: 50,
                child: ClipOval(
                  child: Image.asset(
                    counsellor.imageUrl,
                    key: ValueKey(counsellor.imageUrl),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.pinkAccent,
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 30,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
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
              trailing: kIsWeb
                  ? const Icon(Icons.chat, color: Color(0xFF25D366), size: 30)
                  : const Icon(Icons.arrow_forward),
              onTap: () async {
                if (kIsWeb) {
                  await _openWhatsApp(counsellor.contactPhoneNumber);
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


  Future<void> _openWhatsApp(String contact) async {
    var digits = contact.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('0')) digits = '234${digits.substring(1)}';

    await launchUrl(
      Uri.parse('https://wa.me/$digits'),
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
  }
}
