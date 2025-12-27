import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_shadows.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = AppRadius.r18,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }
}

class AppDarkCapsule extends StatelessWidget {
  const AppDarkCapsule({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = AppRadius.r26,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.pill,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppShadows.darkCapsule,
      ),
      child: child,
    );
  }
}

class AppGlassPill extends StatelessWidget {
  const AppGlassPill({
    super.key,
    required this.child,
    this.height = 64,
  });

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.pill.withOpacity(0.92),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: AppShadows.navPill,
          ),
          child: child,
        ),
      ),
    );
  }
}
