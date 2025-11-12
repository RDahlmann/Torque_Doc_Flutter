import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const headline = TextStyle(
    fontFamily: 'MyFont',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  static const body = TextStyle(
    fontFamily: 'MyFont',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  static const button = TextStyle(
    fontFamily: 'MyFont',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}
