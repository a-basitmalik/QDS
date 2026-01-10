// theme/app_text.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppText {
  static TextStyle h1() => GoogleFonts.manrope(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    height: 1.05,
    color: AppColors.ink,
    letterSpacing: -0.6,
  );

  static TextStyle h2() => GoogleFonts.manrope(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    height: 1.10,
    color: AppColors.ink,
    letterSpacing: -0.4,
  );

  static TextStyle h3() => GoogleFonts.manrope(
    fontSize: 16.5,
    fontWeight: FontWeight.w900,
    height: 1.12,
    color: AppColors.ink,
    letterSpacing: -0.25,
  );

  static TextStyle body() => GoogleFonts.manrope(
    fontSize: 13.2,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.ink.withOpacity(0.86),
  );

  static TextStyle subtle() => GoogleFonts.manrope(
    fontSize: 12.6,
    fontWeight: FontWeight.w700,
    height: 1.22,
    color: AppColors.ink.withOpacity(0.55),
  );

  static TextStyle kicker() => GoogleFonts.manrope(
    fontSize: 12.2,
    fontWeight: FontWeight.w800,
    height: 1.10,
    color: AppColors.ink.withOpacity(0.55),
  );

  static TextStyle button() => GoogleFonts.manrope(
    fontSize: 12.4,
    fontWeight: FontWeight.w900,
    height: 1.0,
    color: AppColors.ink.withOpacity(0.88),
  );
}
