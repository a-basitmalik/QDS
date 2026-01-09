import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppText {
  // Your Feed title
  static const displaySerif = TextStyle(
    fontSize: 34,
    height: 1.05,
    fontWeight: FontWeight.w500,
    fontFamily: 'Georgia', // optional
    color: AppColors.textDark,
  );

  static const h18 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const body14Soft = TextStyle(
    fontSize: 14,
    height: 1.35,
    color: AppColors.textSoft,
    fontWeight: FontWeight.w500,
  );

  static const label13Mid = TextStyle(
    fontSize: 13,
    color: AppColors.textMid,
    fontWeight: FontWeight.w500,
  );

  static const label13Soft = TextStyle(
    fontSize: 13,
    color: Color(0xFF9A9AA0),
    fontWeight: FontWeight.w500,
  );

  static const button15Bold = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const chromeDay = TextStyle(
    fontSize: 44,
    height: 1.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: -1.0,
  );
}