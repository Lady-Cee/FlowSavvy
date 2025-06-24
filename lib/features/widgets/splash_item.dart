import 'package:flutter/material.dart';

class SplashItem extends StatelessWidget {
  final String image;

  const SplashItem({required this.image});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset(
        image,
        filterQuality: FilterQuality.high,
        fit: BoxFit.cover,
      ),
    );
  }
}