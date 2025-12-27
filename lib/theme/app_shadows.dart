import 'package:flutter/material.dart';

class AppShadows {
  static const softCard = [
    BoxShadow(
      blurRadius: 26,
      offset: Offset(0, 16),
      color: Color(0x0F000000),
    ),
  ];

  static const topCap = [
    BoxShadow(
      blurRadius: 18,
      offset: Offset(0, 12),
      color: Color(0x12000000),
    ),
  ];

  static const darkCapsule = [
    BoxShadow(
      blurRadius: 30,
      offset: Offset(0, 18),
      color: Color(0x26000000),
    ),
  ];

  static const navPill = [
    BoxShadow(
      blurRadius: 26,
      offset: Offset(0, 14),
      color: Color(0x33000000),
    ),
  ];

  static const fab3d = [
    BoxShadow(
      blurRadius: 18,
      offset: Offset(0, 10),
      color: Color(0x55000000),
    ),
    BoxShadow(
      blurRadius: 8,
      offset: Offset(0, -2),
      color: Color(0x22FFFFFF),
    ),
  ];
}
