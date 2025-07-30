import 'package:flutter/material.dart';

import '../../../utils/app_strings.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/long_custom_button.dart';

class ProfileCompleteScreen extends StatefulWidget {
  const ProfileCompleteScreen({super.key});

  @override
  State<ProfileCompleteScreen> createState() => _ProfileCompleteScreenState();
}

class _ProfileCompleteScreenState extends State<ProfileCompleteScreen> {

  // Signup controllers
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _selectDateController = TextEditingController();
 // final TextEditingController _selectGenderController = TextEditingController();
  final TextEditingController _avgCycleController = TextEditingController();
 final TextEditingController _periodLengthController = TextEditingController();
  final TextEditingController _firstDayOfLastPeriodController = TextEditingController();
  // DateTime? _firstDayOfLastPeriod;
  // DateTime? _Date;

  Widget _profileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          hintText: 'Enter your age',
          controller: _ageController,
          isObscure: false,
          isOptionalLeadingIcon: false,
          //optionalLeadingIcon: Icons.email,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          hintText: 'Select Date',
          controller: _selectDateController,
          isObscure: false,
          isOptionalLeadingIcon: false,
          //optionalLeadingIcon: Icons.person,
        ),
        const SizedBox(height: 20),
        // CustomTextField(
        //   hintText: 'Select your Gender',
        //   controller: _selectGenderController,
        //   isObscure: false,
        //   isOptionalLeadingIcon: false,
        //   //optionalLeadingIcon: Icons.email,
        // ),
       // const SizedBox(height: 20),
        CustomTextField(
          hintText: 'Enter Average Cycle Length',
          controller: _avgCycleController,
          isObscure: false,
          isOptionalLeadingIcon: false,
         // optionalLeadingIcon: Icons.lock,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          hintText: 'Enter Period Length',
          controller: _periodLengthController,
          isObscure: false,
          isOptionalLeadingIcon: false,
          //optionalLeadingIcon: Icons.lock,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          hintText: 'Select First day of Last Period',
          controller: _firstDayOfLastPeriodController,
          isObscure: false,
          isOptionalLeadingIcon: false,
          //optionalLeadingIcon: Icons.lock,
        ),
        const SizedBox(height: 40),
        LongCustomButton(
          onTap: () {
            // Handle signup
            //Navigator.pushNamed(context, '/profileCompleteScreen');
          },
          title: 'Save Profile',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings appStrings = AppStrings();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 60,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back arrow
            TextButton(
              onPressed: () {
                // Handle skip logic here
                // Navigator.pop(context); // or push to home screen
              },
              child: Text(
                '<',
                style: AppTextStyles.smallTextRegular(context),
              ),
            ),


            // Center welcome text
            Text(
              'Complete Your Profile',
              style: AppTextStyles.largeTextSemiBold(context),
            ),


            // Skip button
            TextButton(
              onPressed: () {
                // Handle skip logic here
               // Navigator.pop(context); // or push to home screen
              },
              child: Text('Skip',
                style: AppTextStyles.smallTextRegular(context),),
            ),
          ],
        ),
      ),


      // SizedBox(height: 32),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppConstants.scaffoldPadding,
            child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      'Tell us more about you so we can personalise your experience',
                      style: AppTextStyles.smallTextRegular(context), textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    _profileForm(),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'We value your privacy. Your information stay secure with us',
                      style: AppTextStyles.smallTextRegular(context),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
