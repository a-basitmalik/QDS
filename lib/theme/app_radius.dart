// theme/app_radius.dart
import 'package:flutter/material.dart';

class AppRadius {
  // ─────────────────────────────────────────
  // BorderRadius (USE for BoxDecoration, ClipRRect)
  // ─────────────────────────────────────────
  static const BorderRadius r12 = BorderRadius.all(Radius.circular(12));
  static const BorderRadius r14 = BorderRadius.all(Radius.circular(14));
  static const BorderRadius r16 = BorderRadius.all(Radius.circular(16));
  static const BorderRadius r18 = BorderRadius.all(Radius.circular(18));
  static const BorderRadius r22 = BorderRadius.all(Radius.circular(22));
  static const BorderRadius r24 = BorderRadius.all(Radius.circular(24));

  static BorderRadius pill() => BorderRadius.circular(999);

  // ─────────────────────────────────────────
  // Double radii (USE where a double is required)
  // ─────────────────────────────────────────
  static const double d12 = 12;
  static const double d14 = 14;
  static const double d16 = 16;
  static const double d18 = 18;
  static const double d22 = 22;
  static const double d24 = 24;
}
