import 'package:flow_savvy/features/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class LongCustomButton extends StatelessWidget {
  final Function()? onTap;
  final String title;

  const LongCustomButton({super.key, required this.onTap, required this.title});
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 38,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        // margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
            color: color.primary,
            borderRadius: BorderRadius.circular(8)
        ),
        child:  Text(title, style: AppTextStyles.smallTextSemiBold(context).copyWith(color: color.surface),textAlign: TextAlign.center,))
    );
  }
}
