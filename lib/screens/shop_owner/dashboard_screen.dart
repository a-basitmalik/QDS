import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';
import 'order_management_screen.dart';

// ✅ ADD THIS IMPORT

class ShopOwnerDashboardScreen extends StatelessWidget {
  const ShopOwnerDashboardScreen({super.key});

  void _openOrderManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ShopOrderManagementScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const _DashboardTopCap(),
          _content(context, topInset),
          _topBar(context),
        ],
      ),
    );
  }

  // ───────────────────────── CONTENT ─────────────────────────

  Widget _content(BuildContext context, double topInset) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 140 + topInset, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Overview", style: AppText.h18),
          const SizedBox(height: 14),

          _statsGrid(context),
          const SizedBox(height: 22),

          _sectionTitle(
            context,
            "Today’s Orders",
            trailing: "Manage",
            onTrailingTap: () => _openOrderManagement(context),
          ),
          const SizedBox(height: 12),
          _todayOrders(context),

          const SizedBox(height: 22),
          _sectionTitle(context, "Inventory Alerts"),
          const SizedBox(height: 12),
          _inventoryAlerts(),
        ],
      ),
    );
  }

  // ───────────────────────── TOP BAR ─────────────────────────

  Widget _topBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 12,
      right: 12,
      child: Row(
        children: [
          const Text(
            "Dashboard",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          _iconBtn(Icons.notifications_none_rounded),
          _iconBtn(Icons.settings_outlined),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: IconButton(
          onPressed: () {},
          icon: Icon(icon),
        ),
      ),
    );
  }

  // ───────────────────────── STATS GRID ─────────────────────────

  Widget _statsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.3,
      children: [
        // ✅ Click -> Order Management
        _TapCard(
          onTap: () => _openOrderManagement(context),
          child: const _StatCard(
            title: "Today’s Orders",
            value: "18",
            icon: Icons.receipt_long_rounded,
          ),
        ),
        // ✅ Click -> Order Management
        _TapCard(
          onTap: () => _openOrderManagement(context),
          child: const _StatCard(
            title: "Pending",
            value: "5",
            icon: Icons.hourglass_bottom_rounded,
          ),
        ),

        // Keep these normal
        const _StatCard(
          title: "Earnings",
          value: "Rs. 24,500",
          icon: Icons.account_balance_wallet_rounded,
        ),
        const _StatCard(
          title: "Rating",
          value: "4.8 ★",
          icon: Icons.star_rounded,
        ),
      ],
    );
  }

  // ───────────────────────── TODAY ORDERS ─────────────────────────

  Widget _todayOrders(BuildContext context) {
    return Column(
      children: List.generate(3, (i) {
        return InkWell(
          onTap: () => _openOrderManagement(context), // ✅ Click whole tile
          borderRadius: BorderRadius.circular(AppRadius.r18),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r18),
              border: Border.all(color: AppColors.divider),
              boxShadow: AppShadows.softCard,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.chipFill,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order #QDS-2304",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "2 items • COD",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMid,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  "Rs. 3,499",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMid),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ───────────────────────── INVENTORY ALERTS ─────────────────────────

  Widget _inventoryAlerts() {
    return Column(
      children: [
        _alertTile("Leather Wallet", "Only 2 left"),
        _alertTile("Classic Watch", "Out of stock"),
      ],
    );
  }

  Widget _alertTile(String title, String status) {
    final isOut = status.contains("Out");

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: isOut ? Colors.redAccent : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isOut ? Colors.redAccent : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── SECTION TITLE ─────────────────────────

  Widget _sectionTitle(
      BuildContext context,
      String title, {
        String? trailing,
        VoidCallback? onTrailingTap,
      }) {
    return Row(
      children: [
        Text(title, style: AppText.h18),
        const Spacer(),
        if (trailing != null)
          InkWell(
            onTap: onTrailingTap,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                trailing,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ───────────────────── CLICK WRAPPER ─────────────────────

class _TapCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TapCard({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.r18),
      child: child,
    );
  }
}

// ───────────────────── STAT CARD ─────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r18),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.softCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 26),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMid,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────── TOP CAP ─────────────────────

class _DashboardTopCap extends StatelessWidget {
  const _DashboardTopCap();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: -topInset,
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: _DashboardHeaderClipper(),
        child: Container(
          height: 140 + topInset,
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: AppShadows.topCap,
          ),
        ),
      ),
    );
  }
}

class _DashboardHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final r = 22.0;
    final slant = 36.0;
    final cutY = size.height - 52;

    return Path()
      ..moveTo(r, 0)
      ..lineTo(size.width - r, 0)
      ..quadraticBezierTo(size.width, 0, size.width, r)
      ..lineTo(size.width, cutY)
      ..lineTo(size.width - slant, size.height)
      ..lineTo(slant, size.height)
      ..lineTo(0, cutY)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
