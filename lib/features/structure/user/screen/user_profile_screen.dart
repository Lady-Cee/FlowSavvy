import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/user_profilel.dart'; // Your UserProfileModel import
import '../../../providers/user_profile_provider.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _cycleLengthController = TextEditingController();
  final _lastPeriodController = TextEditingController();
  DateTime? _lastPeriodDate;
  DateTime? _predictedNextPeriod;
  DateTime? _predictedOvulation;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    await provider.loadUserProfile();
    final profile = provider.userProfile;

    if (profile != null) {
      setState(() {
        _nameController.text = profile.name;
        _ageController.text = profile.age.toString();
        _cycleLengthController.text = profile.cycleLength.toString();
        _lastPeriodDate = profile.lastPeriodDate;
        _lastPeriodController.text = DateFormat('yyyy-MM-dd').format(profile.lastPeriodDate);
        _predictedNextPeriod = profile.predictedNextPeriod;
        _predictedOvulation = profile.predictedOvulation;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _lastPeriodDate = picked;
        _lastPeriodController.text = DateFormat('yyyy-MM-dd').format(picked);
        _updatePrediction();
      });
    }
  }

  void _updatePrediction() {
    final cycleLength = int.tryParse(_cycleLengthController.text);
    if (_lastPeriodDate != null && cycleLength != null) {
      setState(() {
        _predictedNextPeriod = _lastPeriodDate!.add(Duration(days: cycleLength));
        _predictedOvulation = _predictedNextPeriod!.subtract(Duration(days: 14));
      });
    }
  }

  void _saveProfile() {
    final name = _nameController.text;
    final age = int.tryParse(_ageController.text);
    final cycleLength = int.tryParse(_cycleLengthController.text);

    if (name.isNotEmpty && age != null && cycleLength != null && _lastPeriodDate != null) {
      // Call the saveUserProfile method with individual parameters
      Provider.of<UserProfileProvider>(context, listen: false).saveUserProfile(
        name,
        age,
        cycleLength,
        _lastPeriodDate!,
      );

      Navigator.pushNamed(context, '/home');
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Error"),
          content: Text("Please enter valid information"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Enter your details to help us predict your next period and ovulation day"),
              SizedBox(height: 20),

              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Age",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              TextField(
                controller: _cycleLengthController,
                keyboardType: TextInputType.number,
                onChanged: (_) => _updatePrediction(),
                decoration: InputDecoration(
                  labelText: "Average Cycle Length (days)",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              TextField(
                controller: _lastPeriodController,
                decoration: InputDecoration(
                  labelText: "Last Period Start Date",
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 20),

              if (_predictedNextPeriod != null)
                Text(
                  "Your next period is expected on: ${DateFormat('MMMM d, yyyy').format(_predictedNextPeriod!)}",
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.purple),
                ),
              if (_predictedOvulation != null)
                Text(
                  "Estimated ovulation day: ${DateFormat('MMMM d, yyyy').format(_predictedOvulation!)}",
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
                ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveProfile,
                child: Text("Save Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


