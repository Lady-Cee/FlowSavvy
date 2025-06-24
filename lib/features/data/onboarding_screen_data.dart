import 'package:flow_savvy/features/utils/app_strings.dart';

import '../models/onboarding_data_model.dart';

final AppStrings appStrings = AppStrings();

final List<OnboardingContent> onboardingPages = [
  OnboardingContent(
    image: 'assets/images/onboarding/onboarding1.png',
    title: appStrings.onboardingHeaderTitle1,
    description: appStrings.onboardingHeaderSubTitle1,
  ),
  OnboardingContent(
    image: 'assets/images/onboarding/onboarding2.png',
    title: appStrings.onboardingHeaderTitle2,
    description: appStrings.onboardingHeaderSubTitle2,
  ),
  OnboardingContent(
    image: 'assets/images/onboarding/onboarding3.png',
    title: appStrings.onboardingHeaderTitle3,
    description: appStrings.onboardingHeaderSubTitle3,
  ),
  OnboardingContent(
    image: 'assets/images/onboarding/onboarding4.png',
    title: appStrings.onboardingHeaderTitle3,
    description: appStrings.onboardingHeaderSubTitle3,
  ),
];
