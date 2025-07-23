import 'package:flow_savvy/features/utils/app_strings.dart';
import 'package:flow_savvy/features/widgets/custom_text_field.dart';
import 'package:flow_savvy/features/widgets/long_custom_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../utils/app_text_styles.dart';

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
        _lastPeriodController.text =
            DateFormat('yyyy-MM-dd').format(profile.lastPeriodDate);
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
        _predictedNextPeriod =
            _lastPeriodDate!.add(Duration(days: cycleLength));
        _predictedOvulation =
            _predictedNextPeriod!.subtract(Duration(days: 14));
      });
    }
  }

  void _saveProfile() {
    final name = _nameController.text;
    final age = int.tryParse(_ageController.text);
    final cycleLength = int.tryParse(_cycleLengthController.text);

    if (name.isNotEmpty &&
        age != null &&
        cycleLength != null &&
        _lastPeriodDate != null) {
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
    final appStrings = AppStrings();

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            // Handle skip logic here
            Navigator.pop(context); // or push to home screen
          },
          child: Text(
            '<',
            style: AppTextStyles.smallTextRegular(context),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 60,
        title: Text(
          appStrings.completeYourProfileText,
          style: AppTextStyles.largeTextSemiBold(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // SizedBox(
                //   height: 12,
                // ),
                Center(
                  child: FittedBox(
                    child: Text(
                      appStrings.completeProfileSubTitleText,
                      style: AppTextStyles.smallTextRegular(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                CustomTextField(
                    hintText: appStrings.completeProfileNameText,
                    controller: _nameController,
                    isOptionalLeadingIcon: false),
                SizedBox(height: 20),
                CustomTextField(
                    hintText: appStrings.completeProfileAgeText,
                    controller: _ageController,
                    inputType: TextInputType.number,
                    isOptionalLeadingIcon: false),
                SizedBox(height: 20),
                CustomTextField(
                  hintText: appStrings.completeProfileAverageCycleText,
                  controller: _cycleLengthController,
                  inputType: TextInputType.number,
                  isOptionalLeadingIcon: false,
                  onChanged: (_) => _updatePrediction(),
                ),
                SizedBox(height: 20),
                CustomTextField(
                  hintText: appStrings.completeProfileLastPeriodText,
                  controller: _lastPeriodController,
                  inputType: TextInputType.number,
                  isOptionalLeadingIcon: false,
                  onTap: () => _selectDate(context),
                  readOnly: true,
                ),
                SizedBox(height: 20),
                if (_predictedNextPeriod != null)
                  Text(
                    "${appStrings.completeProfileNextPeriodIsText} ${DateFormat('MMMM d, yyyy').format(_predictedNextPeriod!)}",
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.purple),
                  ),
                if (_predictedOvulation != null)
                  Text(
                    "${appStrings.completeProfileEstimatedOvulationText} ${DateFormat('MMMM d, yyyy').format(_predictedOvulation!)}",
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.green),
                  ),
                SizedBox(height: 20),
                LongCustomButton(
                    onTap: _saveProfile, title: appStrings.saveProfileBtnText),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: FittedBox(
                    child: Text(
                      appStrings.completeProfileWeValueText,
                      style: AppTextStyles.smallTextRegular(context),
                      // textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
