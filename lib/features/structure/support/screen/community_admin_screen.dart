import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
              subtitle: Text(admin.role),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to admin's detail or contact page
              },
            ),
          );
        },
      ),
    );
  }
}
