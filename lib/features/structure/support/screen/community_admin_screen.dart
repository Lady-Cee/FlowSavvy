import 'package:flow_savvy/features/models/community_admin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../providers/community_admin_provider.dart';

class CommunityAdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final admins = Provider.of<CommunityAdminProvider>(context).admins;

    return Scaffold(
      appBar: AppBar(title: Text('Consult a Community Admin')),
      body: ListView.builder(
        itemCount: admins.length,
        itemBuilder: (ctx, i) {
          final admin = admins[i];
          return Card(
            margin: EdgeInsets.all(10),
             child: ListTile(
               leading: Image.network(admin.imageUrl, width: 60, fit: BoxFit.cover),
               title: Text(admin.name),
               subtitle: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(admin.role, style: TextStyle(fontWeight: FontWeight.w500)),
                   SizedBox(height: 4),
                   Text(admin.bio),
                   Text(admin.contactInfo),
                  // Text('Contact: ${admin.contactInfo}'),
                 ],
               ),
               trailing: Icon(Icons.arrow_forward),
               onTap: () async {
                 final url = Uri.parse(admin.imageUrl);

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
            //   leading: Image.network(admin.imageUrl, width: 60, fit: BoxFit.cover),
            //   title: Text(admin.name),
            //   subtitle: Text(admin.role),
            //   trailing: Icon(Icons.arrow_forward),
            //     onTap: () async {
            //       final url = Uri.parse(admin.imageUrl);
            //
            //       if (await launchUrl(url, mode: LaunchMode.inAppWebView)) {
            //         // print("Launched in in-app view");
            //       } else {
            //         ScaffoldMessenger.of(context).showSnackBar(
            //           SnackBar(content: Text('Could not launch product link')),
            //         );
            //       }
            //     }
            // ),
          );
        },
      ),
    );
  }
}
