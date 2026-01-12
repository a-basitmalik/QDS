import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';
import '../../theme/app_widgets.dart';

import 'orders_screen.dart'; // gives OwnerOrder, OwnerOrderStatus, OrderDetailsResult

class OrderDetailsScreen extends StatefulWidget {
  final OwnerOrder order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late OwnerOrder _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  void _setStatus(OwnerOrderStatus newStatus) {
    HapticFeedback.selectionClick();
    Navigator.pop(context, OrderDetailsResult(newStatus));
  }

  Future<bool> _confirm(String title, String body, String confirmText) async {
    return (await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Glass(
            borderRadius: AppRadius.r24,
            sigmaX: 22,
            sigmaY: 22,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            color: Colors.white.withOpacity(0.84),
            borderColor: Colors.white.withOpacity(0.90),
            shadows: AppShadows.shadowLg,
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.h2()),
                  const SizedBox(height: 8),
                  Text(body, style: AppText.body()),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: PressScale(
                          borderRadius: AppRadius.pill(),
                          onTap: () => Navigator.pop(context, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.62),
                              borderRadius: AppRadius.pill(),
                              border: Border.all(
                                color: AppColors.divider.withOpacity(0.55),
                                width: 1.05,
                              ),
                            ),
                            child: Center(
                              child: Text("Cancel", style: AppText.button()),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: BrandButton(
                          text: confirmText,
                          onTap: () => Navigator.pop(context, true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final OwnerOrderStatus status = _order.status;
    final items = _order.items;
    final eta = _order.riderEtaMinutes;

    return Scaffold(
      body: Stack(
        children: [
          const _AmbientBackground(),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                children: [
                  // Header
                  Glass(
                    borderRadius: AppRadius.r22,
                    sigmaX: 18,
                    sigmaY: 18,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    color: Colors.white.withOpacity(0.72),
                    borderColor: Colors.white.withOpacity(0.86),
                    shadows: AppShadows.soft,
                    child: Row(
                      children: [
                        PressScale(
                          borderRadius: AppRadius.pill(),
                          downScale: 0.97,
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.62),
                              borderRadius: AppRadius.pill(),
                              border: Border.all(
                                color: AppColors.divider.withOpacity(0.55),
                                width: 1.05,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 18.5,
                              color: AppColors.ink.withOpacity(0.75),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Order #${_order.shortId}", style: AppText.h2()),
                              const SizedBox(height: 4),
                              Text(
                                "Status: ${status.label}",
                                style: AppText.subtle(),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.pill(),
                            color: status.color.withOpacity(0.12),
                            border: Border.all(
                              color: status.color.withOpacity(0.22),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            status.label,
                            style: AppText.kicker().copyWith(
                              color: status.color,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Expanded(
                    child: Glass(
                      borderRadius: AppRadius.r24,
                      sigmaX: 18,
                      sigmaY: 18,
                      padding: const EdgeInsets.all(14),
                      color: Colors.white.withOpacity(0.66),
                      borderColor: Colors.white.withOpacity(0.84),
                      shadows: AppShadows.shadowLg,
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          // Rider
                          Text("Rider", style: AppText.h3()),
                          const SizedBox(height: 10),
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
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.brandLinear,
                                    borderRadius: AppRadius.r16,
                                    boxShadow: AppShadows.soft,
                                  ),
                                  child: Icon(
                                    Icons.delivery_dining_rounded,
                                    color: Colors.white.withOpacity(0.96),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_order.riderName, style: AppText.h3()),
                                      const SizedBox(height: 4),
                                      Text(_order.riderPhone, style: AppText.subtle()),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 7),
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadius.pill(),
                                    color: Colors.white.withOpacity(0.66),
                                    border: Border.all(
                                      color: AppColors.divider.withOpacity(0.55),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Text(
                                    eta == null ? "ETA --" : "ETA $eta min",
                                    style: AppText.kicker().copyWith(
                                      color: AppColors.ink.withOpacity(0.78),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Summary
                          Text("Order Summary", style: AppText.h3()),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _MetaChip(
                                icon: Icons.shopping_bag_rounded,
                                text: "${items.length} items",
                              ),
                              const SizedBox(width: 8),
                              _MetaChip(
                                icon: Icons.payments_rounded,
                                text: "Rs ${_order.total.toStringAsFixed(0)}",
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _MetaChip(
                                  icon: Icons.local_shipping_rounded,
                                  text: _order.deliveryLabel,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Items
                          Text("Items", style: AppText.h3()),
                          const SizedBox(height: 10),
                          ...items.map((it) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      borderRadius: AppRadius.r12,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.primary.withOpacity(0.16),
                                          AppColors.secondary.withOpacity(0.10),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.60),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.checkroom_rounded,
                                      size: 18,
                                      color: AppColors.ink.withOpacity(0.62),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(it.name, style: AppText.body()),
                                        const SizedBox(height: 3),
                                        Text(it.variant, style: AppText.subtle()),
                                      ],
                                    ),
                                  ),
                                  Text("x${it.qty}", style: AppText.kicker()),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 18),

                          // Actions (enum-based, no string compare)
                          Text("Actions", style: AppText.h3()),
                          const SizedBox(height: 10),

                          if (status == OwnerOrderStatus.accepted) ...[
                            BrandButton(
                              text: "Mark Packed (In Process)",
                              onTap: () async {
                                final ok = await _confirm(
                                  "Mark as In Process?",
                                  "Order will move to In-Process section.",
                                  "Confirm",
                                );
                                if (ok) _setStatus(OwnerOrderStatus.inProcess);
                              },
                            ),
                            const SizedBox(height: 10),
                            PressScale(
                              borderRadius: AppRadius.pill(),
                              onTap: () async {
                                final ok = await _confirm(
                                  "Reject order?",
                                  "This will move order to Rejected section.",
                                  "Reject",
                                );
                                if (ok) _setStatus(OwnerOrderStatus.rejected);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: AppRadius.pill(),
                                  color: Colors.white.withOpacity(0.62),
                                  border: Border.all(
                                    color: AppColors.danger.withOpacity(0.25),
                                    width: 1.1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Reject",
                                    style: AppText.button().copyWith(
                                      color: AppColors.danger.withOpacity(0.92),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ] else if (status == OwnerOrderStatus.inProcess) ...[
                            BrandButton(
                              text: "Mark Completed",
                              onTap: () async {
                                final ok = await _confirm(
                                  "Complete order?",
                                  "Order will move to Completed section.",
                                  "Complete",
                                );
                                if (ok) _setStatus(OwnerOrderStatus.completed);
                              },
                            ),
                          ] else if (status == OwnerOrderStatus.completed) ...[
                            Glass(
                              borderRadius: AppRadius.r22,
                              sigmaX: 18,
                              sigmaY: 18,
                              padding: const EdgeInsets.all(14),
                              color: Colors.white.withOpacity(0.70),
                              borderColor: Colors.white.withOpacity(0.86),
                              shadows: AppShadows.soft,
                              child: Row(
                                children: [
                                  Icon(Icons.verified_rounded,
                                      color: AppColors.success.withOpacity(0.9)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "This order is completed.",
                                      style: AppText.body(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Glass(
                              borderRadius: AppRadius.r22,
                              sigmaX: 18,
                              sigmaY: 18,
                              padding: const EdgeInsets.all(14),
                              color: Colors.white.withOpacity(0.70),
                              borderColor: Colors.white.withOpacity(0.86),
                              shadows: AppShadows.soft,
                              child: Row(
                                children: [
                                  Icon(Icons.block_rounded,
                                      color: AppColors.danger.withOpacity(0.9)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "This order is rejected.",
                                      style: AppText.body(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: AppRadius.pill(),
        color: Colors.white.withOpacity(0.60),
        border: Border.all(
          color: AppColors.divider.withOpacity(0.48),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.ink.withOpacity(0.72)),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppText.kicker().copyWith(
              color: AppColors.ink.withOpacity(0.70),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Same ambient background (only for details screen)
class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.baseBgLinear),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -70,
            child: _GlowBlob(size: 240, color: AppColors.primary.withOpacity(0.16)),
          ),
          Positioned(
            top: 120,
            right: -90,
            child: _GlowBlob(size: 260, color: AppColors.secondary.withOpacity(0.12)),
          ),
          Positioned(
            bottom: -140,
            left: 40,
            child: _GlowBlob(size: 280, color: AppColors.other.withOpacity(0.10)),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.22),
                  blurRadius: 60,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
