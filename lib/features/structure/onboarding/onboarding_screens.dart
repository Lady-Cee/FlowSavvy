import 'package:flow_savvy/features/utils/app_text_styles.dart';
import 'package:flow_savvy/features/widgets/long_custom_button.dart';
import 'package:flutter/material.dart';
import '../../data/onboarding_screen_data.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _nextPage() {
    if (_currentIndex < onboardingPages.length - 1) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _skipToLastPage() {
    _pageController.jumpToPage(onboardingPages.length - 1);
  }

  void _finishOnboarding() {
    Navigator.pushReplacementNamed(context, '/signup'); // or '/signup'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SafeArea(
            child: Column(
              children: [
                // --- Page Content ---
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: onboardingPages.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final content = onboardingPages[index];
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            SizedBox(
                              height: constraints.maxHeight * 0.4,
                              child: Image.asset(content.image,
                                  fit: BoxFit.contain),
                            ),
                            SizedBox(height: 40),
                            Text(content.title,
                                textAlign: TextAlign.center,
                                style:
                                    AppTextStyles.mediumTextSemiBold(context)),
                            SizedBox(height: 12),
                            Text(content.description,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.smallTextRegular(context)),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // --- Page Indicator Dots ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingPages.length,
                    (index) => AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: _currentIndex == index ? 8 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentIndex == index
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // --- Navigation Buttons (Previous/Next) ---
                if (_currentIndex > 0 &&
                    _currentIndex < onboardingPages.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _previousPage,
                          child: Row(
                            spacing: 4,
                            children: [
                              Icon(Icons.arrow_circle_left,
                                  size: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary),
                              Text('Previous',
                                  style:
                                      AppTextStyles.smallTextRegular(context)
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary)),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _nextPage,
                          child: Row(
                            spacing: 4,
                            children: [
                              Text('Next',
                                  style:
                                      AppTextStyles.smallTextRegular(context)),
                              Icon(Icons.arrow_circle_right,
                                  size: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // --- Next button only on first page ---
                if (_currentIndex == 0)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TextButton(
                        onPressed: _nextPage,
                        child: Row(
                          spacing: 4,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('Next',
                                style:
                                    AppTextStyles.smallTextRegular(context)),
                            Icon(Icons.arrow_circle_right,
                                size: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
                          ],
                        ),
                      ),
                    ),
                  ),

                // --- previous button only on last page ---
                if (_currentIndex == onboardingPages.length - 1)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TextButton(
                        onPressed: _previousPage,
                        child: Row(
                          spacing: 4,
                          children: [
                            Icon(Icons.arrow_circle_left,
                                size: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary),
                            Text('Previous',
                                style: AppTextStyles.smallTextRegular(context)
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary)),
                          ],
                        ),
                      ),
                    ),
                  ),

                SizedBox(height: 20),

                // --- Skip / Get Started full-width button ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: LongCustomButton(
                      onTap: _currentIndex == onboardingPages.length - 1
                          ? _finishOnboarding
                          : _skipToLastPage,
                      title: _currentIndex == onboardingPages.length - 1
                          ? 'Get Started'
                          : 'Skip'),
                ),

                SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
