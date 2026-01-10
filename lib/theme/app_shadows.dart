import 'package:flutter/material.dart';

class AppShadows {
  // ✅ Soft glass shadow
  static List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 18,
      offset: const Offset(0, 10),
    ),
  ];

  // ✅ Larger “card” shadow
  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Colors.black.withOpacity(0.10),
      blurRadius: 26,
      offset: const Offset(0, 14),
    ),
    BoxShadow(
      color: Colors.white.withOpacity(0.70),
      blurRadius: 22,
      offset: const Offset(-10, -10),
      spreadRadius: -10,
    ),
  ];

  // ✅ Elevated icon / puck shadow
  static List<BoxShadow> puck = [
    BoxShadow(
      color: Colors.black.withOpacity(0.16),
      blurRadius: 22,
      offset: const Offset(0, 12),
    ),
  ];

  // ✅ Top cap (for header cut shape)
  static const List<BoxShadow> topCap = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 24,
      offset: Offset(0, 16),
    ),
  ];
}
