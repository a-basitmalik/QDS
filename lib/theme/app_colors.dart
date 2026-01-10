// theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // ✅ Brand palette
  static const Color primary = Color(0xFF440C08);
  static const Color secondary = Color(0xFF750A03);

  // ⚠️ Your "9BOS03" is invalid hex. Using a safe fallback:
  static const Color other = Color(0xFF9B0F03);

  // ✅ Light backgrounds
  static const Color bg1 = Color(0xFFF9F6F5);
  static const Color bg2 = Color(0xFFF4EEED);
  static const Color bg3 = Color(0xFFFFFFFF);

  // ✅ Default background alias (many screens use AppColors.bg)
  static const Color bg = bg1;

  // ✅ Text
  static const Color ink = Color(0xFF140504);
  static const Color muted = Color(0xFF2A0A08);

  // ✅ Semantic colors (used in screens: success/warning/danger)
  static const Color success = Color(0xFF16A34A); // green
  static const Color warning = Color(0xFFF59E0B); // amber
  static const Color danger  = Color(0xFFEF4444); // red

  // ✅ Divider / neutral border (used in screens: divider)
  static const Color divider = Color(0xFFE9DDDB);

  // ✅ Borders
  static Color borderSoft([double o = 0.82]) => Colors.white.withOpacity(o);
  static Color borderBase([double o = 0.60]) => divider.withOpacity(o);

  // ✅ Base background gradient
  static const LinearGradient baseBgLinear = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bg3, bg2, bg1],
    stops: [0.0, 0.55, 1.0],
  );

  // ✅ Brand gradient (buttons, hero, etc.)
  static const LinearGradient brandLinear = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static Color get textDark => ink;
  static Color get textMid  => muted;

}
