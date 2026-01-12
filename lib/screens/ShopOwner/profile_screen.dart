import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';
import '../../theme/app_widgets.dart';

/// ✅ ProfileScreen (content-only)
/// - Shop name, contract start, delivered, profit, etc.
/// - Logout button (hook later)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data (replace with backend later)
    const shopName = "Charcoal Boutique";
    const city = "Lahore";
    final contractStart = DateTime(2024, 9, 15);
    const delivered = 482;
    const profit = 186500; // Rs
    const rating = 4.7;

    String fmtDate(DateTime d) =>
        "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";

    return Column(
      children: [
        // Header
        Glass(
          borderRadius: AppRadius.r22,
          sigmaX: 18,
          sigmaY: 18,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          color: Colors.white.withOpacity(0.72),
          borderColor: Colors.white.withOpacity(0.86),
          shadows: AppShadows.soft,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.brandLinear,
                  borderRadius: AppRadius.r16,
                  boxShadow: AppShadows.soft,
                ),
                child: Icon(Icons.store_rounded, color: Colors.white.withOpacity(0.96)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Shop Profile", style: AppText.h2()),
                    const SizedBox(height: 4),
                    Text("View shop stats & contract details.", style: AppText.subtle()),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.pill(),
                  color: Colors.white.withOpacity(0.68),
                  border: Border.all(
                    color: AppColors.divider.withOpacity(0.55),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  "INFO",
                  style: AppText.kicker().copyWith(
                    color: AppColors.ink.withOpacity(0.72),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            ],
          ),
        ),

        const SizedBox(height: 14),

        Expanded(
          child: Glass(
            borderRadius: AppRadius.r24,
            sigmaX: 18,
            sigmaY: 18,
            padding: const EdgeInsets.all(16),
            color: Colors.white.withOpacity(0.66),
            borderColor: Colors.white.withOpacity(0.84),
            shadows: AppShadows.shadowLg,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // Identity card
                Glass(
                  borderRadius: AppRadius.r22,
                  sigmaX: 18,
                  sigmaY: 18,
                  padding: const EdgeInsets.all(14),
                  color: Colors.white.withOpacity(0.72),
                  borderColor: Colors.white.withOpacity(0.86),
                  shadows: AppShadows.soft,
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.r18,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withOpacity(0.18),
                              AppColors.secondary.withOpacity(0.12),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.62),
                            width: 1.0,
                          ),
                        ),
                        child: Icon(Icons.storefront_rounded,
                            color: AppColors.ink.withOpacity(0.65)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(shopName, style: AppText.h3()),
                            const SizedBox(height: 4),
                            Text("$city • Contract since ${fmtDate(contractStart)}",
                                style: AppText.subtle()),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.pill(),
                          color: AppColors.success.withOpacity(0.12),
                          border: Border.all(
                            color: AppColors.success.withOpacity(0.22),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          "ACTIVE",
                          style: AppText.kicker().copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Text("Performance", style: AppText.h3()),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_shipping_rounded,
                        title: "Delivered",
                        value: "$delivered",
                        tint: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.payments_rounded,
                        title: "Profit",
                        value: "Rs $profit",
                        tint: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                _StatCardWide(
                  icon: Icons.star_rounded,
                  title: "Rating",
                  subtitle: "Average customer rating",
                  value: "$rating / 5",
                  tint: AppColors.warning,
                ),

                const SizedBox(height: 18),

                Text("Account", style: AppText.h3()),
                const SizedBox(height: 10),

                _ActionRow(
                  icon: Icons.support_agent_rounded,
                  title: "Support",
                  subtitle: "Contact help center",
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Support: coming soon")),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _ActionRow(
                  icon: Icons.logout_rounded,
                  title: "Logout",
                  subtitle: "Sign out of shop portal",
                  danger: true,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Logout hook here")),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color tint;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Glass(
      borderRadius: AppRadius.r22,
      sigmaX: 18,
      sigmaY: 18,
      padding: const EdgeInsets.all(14),
      color: Colors.white.withOpacity(0.72),
      borderColor: Colors.white.withOpacity(0.86),
      shadows: AppShadows.soft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: AppRadius.r16,
              color: tint.withOpacity(0.12),
              border: Border.all(color: tint.withOpacity(0.22), width: 1.0),
            ),
            child: Icon(icon, color: tint.withOpacity(0.95)),
          ),
          const SizedBox(height: 10),
          Text(title, style: AppText.subtle()),
          const SizedBox(height: 6),
          Text(value, style: AppText.h3()),
        ],
      ),
    );
  }
}

class _StatCardWide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final Color tint;

  const _StatCardWide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Glass(
      borderRadius: AppRadius.r22,
      sigmaX: 18,
      sigmaY: 18,
      padding: const EdgeInsets.all(14),
      color: Colors.white.withOpacity(0.72),
      borderColor: Colors.white.withOpacity(0.86),
      shadows: AppShadows.soft,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: AppRadius.r16,
              color: tint.withOpacity(0.12),
              border: Border.all(color: tint.withOpacity(0.22), width: 1.0),
            ),
            child: Icon(icon, color: tint.withOpacity(0.95)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.h3()),
                const SizedBox(height: 4),
                Text(subtitle, style: AppText.subtle()),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(value, style: AppText.h3()),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = danger ? AppColors.danger : AppColors.ink;

    return PressScale(
      borderRadius: AppRadius.r22,
      downScale: 0.99,
      onTap: onTap,
      child: Glass(
        borderRadius: AppRadius.r22,
        sigmaX: 18,
        sigmaY: 18,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        color: Colors.white.withOpacity(0.72),
        borderColor: Colors.white.withOpacity(0.86),
        shadows: AppShadows.soft,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: AppRadius.r16,
                color: c.withOpacity(0.10),
                border: Border.all(color: c.withOpacity(0.18), width: 1.0),
              ),
              child: Icon(icon, color: c.withOpacity(0.92)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.h3()),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppText.subtle()),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.ink.withOpacity(0.40)),
          ],
        ),
      ),
    );
  }
}
