import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/doctor_provider.dart';

class DoctorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final doctors = Provider.of<DoctorProvider>(context).doctors;

    return Scaffold(
      appBar: AppBar(title: Text('Consult a Doctor')),
      body: ListView.builder(
        itemCount: doctors.length,
        itemBuilder: (ctx, i) {
          final doctor = doctors[i];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Image.network(doctor.imageUrl, width: 60, fit: BoxFit.cover),
              title: Text(doctor.name),
              subtitle: Text(doctor.specialization),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to doctor's detail or booking page
              },
            ),
          );
        },
      ),
    );
  }
}
