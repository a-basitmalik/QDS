// theme/app_widgets.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_shadows.dart';

/// ✅ Glass container (fixes your old "blur:" param error by using sigmaX/sigmaY)
class Glass extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final double sigmaX;
  final double sigmaY;
  final EdgeInsets padding;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow>? shadows;

  const Glass({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.r18,
    this.sigmaX = 18,
    this.sigmaY = 18,
    this.padding = const EdgeInsets.all(14),
    this.color = const Color(0xFFFFFFFF),
    this.borderColor = const Color(0xFFFFFFFF),
    this.borderWidth = 1.1,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// ✅ Press scale wrapper (same interaction style as your screen)
class PressScale extends StatefulWidget {
  final Widget child;
  final double downScale;
  final Duration duration;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.downScale = 0.985,
    this.duration = const Duration(milliseconds: 140),
    this.borderRadius = AppRadius.r18,
  });

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  void _setDown(bool v) {
    if (_down == v) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => _setDown(true),
      onTapUp: (_) => _setDown(false),
      onTapCancel: () => _setDown(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.downScale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            boxShadow: _down
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 12),
              )
            ]
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// ✅ Small pill button (glass)
class GlassPill extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const GlassPill({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressScale(
      downScale: 0.97,
      borderRadius: AppRadius.pill(),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Glass(
        borderRadius: AppRadius.pill(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        sigmaX: 16,
        sigmaY: 16,
        color: Colors.white.withOpacity(0.66),
        borderColor: Colors.white.withOpacity(0.82),
        child: Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 11.8,
            fontWeight: FontWeight.w900,
            color: AppColors.ink.withOpacity(0.74),
          ),
        ),
      ),
    );
  }
}

/// ✅ Brand filled button (primary/secondary gradient)
class BrandButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const BrandButton({
    super.key,
    required this.text,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      downScale: 0.98,
      borderRadius: borderRadius,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: AppColors.brandLinear,
          borderRadius: borderRadius,
          border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.1),
          boxShadow: AppShadows.soft,
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.94),
            ),
          ),
        ),
      ),
    );
  }
}
