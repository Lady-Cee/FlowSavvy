import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/app_text_styles.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/long_custom_button.dart';

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
  int? _cycleDay;
  int? _daysToNextPeriod;

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
      final cycleLength = profile.cycleLength;
      final lastPeriod = profile.lastPeriodDate;

      _updatePredictionFromLastPeriod(lastPeriod, cycleLength);

      setState(() {
        _nameController.text = profile.name;
        _ageController.text = profile.age.toString();
        _cycleLengthController.text = cycleLength.toString();
        _lastPeriodController.text = DateFormat('yyyy-MM-dd').format(lastPeriod);
      });
    }
  }

  void _updatePredictionFromLastPeriod(DateTime lastPeriod, int cycleLength) {
    final now = DateTime.now();
    final daysSinceLast = now.difference(lastPeriod).inDays;
    final cyclesPassed = (daysSinceLast / cycleLength).floor();
    final updatedLastPeriod = lastPeriod.add(Duration(days: cyclesPassed * cycleLength));
    final nextPeriod = updatedLastPeriod.add(Duration(days: cycleLength));
    final ovulationDate = updatedLastPeriod.add(Duration(days: 14));

    setState(() {
      _lastPeriodDate = updatedLastPeriod;
      _predictedNextPeriod = nextPeriod;
      _predictedOvulation = ovulationDate;
      _cycleDay = now.difference(updatedLastPeriod).inDays + 1;
      _daysToNextPeriod = nextPeriod.difference(now).inDays;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _lastPeriodDate = picked;
        _lastPeriodController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      _updatePrediction(); // Recalculate predictions on new input
    }
  }

  void _updatePrediction() {
    final cycleLength = int.tryParse(_cycleLengthController.text);
    if (_lastPeriodDate != null && cycleLength != null) {
      _updatePredictionFromLastPeriod(_lastPeriodDate!, cycleLength);
    }
  }

  void _saveProfile() {
    final name = _nameController.text;
    final age = int.tryParse(_ageController.text);
    final cycleLength = int.tryParse(_cycleLengthController.text);

    if (name.isNotEmpty && age != null && cycleLength != null && _lastPeriodDate != null) {
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
          actions: [
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
    final appStrings = AppStrings();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 60,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          appStrings.completeYourProfileText,
          style: AppTextStyles.largeTextSemiBold(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              appStrings.completeProfileSubTitleText,
              style: AppTextStyles.smallTextRegular(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            CustomTextField(
              hintText: appStrings.completeProfileNameText,
              controller: _nameController,
              isOptionalLeadingIcon: false,
            ),
            SizedBox(height: 20),
            CustomTextField(
              hintText: appStrings.completeProfileAgeText,
              controller: _ageController,
              inputType: TextInputType.number,
              isOptionalLeadingIcon: false,
            ),
            SizedBox(height: 20),
            CustomTextField(
              hintText: appStrings.completeProfileAverageCycleText,
              controller: _cycleLengthController,
              inputType: TextInputType.number,
              onChanged: (_) => _updatePrediction(),
              isOptionalLeadingIcon: false,
            ),
            SizedBox(height: 20),
            CustomTextField(
              hintText: appStrings.completeProfileLastPeriodText,
              controller: _lastPeriodController,
              readOnly: true,
              onTap: () => _selectDate(context),
              isOptionalLeadingIcon: false,
            ),
            SizedBox(height: 20),

            if (_cycleDay != null)
              Text(
                "You are on Day $_cycleDay of your cycle",
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.teal),
              ),

            if (_daysToNextPeriod != null)
              Text(
                "Next period in $_daysToNextPeriod days",
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.purple),
              ),

            if (_predictedNextPeriod != null)
              Text(
                "${appStrings.completeProfileNextPeriodIsText} ${DateFormat('MMMM d, yyyy').format(_predictedNextPeriod!)}",
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.purple),
              ),

            if (_predictedOvulation != null)
              Text(
                "${appStrings.completeProfileEstimatedOvulationText} ${DateFormat('MMMM d, yyyy').format(_predictedOvulation!)}",
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
              ),

            SizedBox(height: 30),
            LongCustomButton(
              onTap: _saveProfile,
              title: appStrings.saveProfileBtnText,
            ),
            SizedBox(height: 10),
            Text(
              appStrings.completeProfileWeValueText,
              style: AppTextStyles.smallTextRegular(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
