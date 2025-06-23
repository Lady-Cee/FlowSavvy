import 'package:flow_savvy/features/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final String subTitle;
  
  const CustomHeader({super.key, required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        child: Column(
          spacing: 8,
          children: [
            Text(title, style: AppTextStyles.largeTextSemiBold(context), textAlign: TextAlign.center,),
            Text(subTitle, style: AppTextStyles.smallTextRegular(context), textAlign: TextAlign.center,),
          ],
        ),
      ),
    );
  }
}
