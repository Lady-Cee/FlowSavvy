import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/counsellor_provider.dart';

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
              leading: Image.network(counsellor.imageUrl, width: 60, fit: BoxFit.cover),
              title: Text(counsellor.name),
              subtitle: Text(counsellor.expertise),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to counsellor's detail or booking page
              },
            ),
          );
        },
      ),
    );
  }
}
