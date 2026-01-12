// lib/screens/ShopOwner/shop_owner_shell.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';
import '../../theme/app_widgets.dart';

// ✅ Tabs (content-only screens)
import 'owner_dashboard_screen.dart';   // your dashboard content-only (no bottom nav)
import 'orders_screen.dart';           // your orders content-only (no bottom nav)
import 'articles_screen.dart';         // from me (content-only)
import 'profile_screen.dart';          // your pasted ProfileScreen (content-only)

/// ✅ Shop Owner Portal Shell
/// - SINGLE BottomNavigation (Rules/Dashboard / Orders / Articles / Profile)
/// - One background + one bottom dock for entire portal
/// - Uses IndexedStack so tab states persist
class ShopOwnerShell extends StatefulWidget {
  const ShopOwnerShell({super.key});

  @override
  State<ShopOwnerShell> createState() => _ShopOwnerShellState();
}

class _ShopOwnerShellState extends State<ShopOwnerShell>
    with TickerProviderStateMixin {
  int _index = 0;

  late final AnimationController _enterCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();

    _fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  void _setIndex(int v) {
    if (_index == v) return;
    HapticFeedback.selectionClick();
    setState(() => _index = v);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Keep state alive using IndexedStack
    final pages = <Widget>[
      const _OwnerRulesScreen(),     // Tab 0: Rules + "Move to Dashboard" button
      const OwnerDashboardScreen(),  // Tab 1: Dashboard
      const OrdersScreen(),          // Tab 2: Orders
      const ArticlesScreen(),        // Tab 3: Articles
      const ProfileScreen(),         // Tab 4: Profile
    ];

    return Scaffold(
      body: Stack(
        children: [
          // ───────────────────────── Ambient background ─────────────────────────
          const _OwnerAmbientBackground(),

          // ───────────────────────── Page content ─────────────────────────
          SafeArea(
            child: Padding(
              // ✅ reserve space for bottom dock
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 96),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: IndexedStack(
                    index: _index,
                    children: pages,
                  ),
                ),
              ),
            ),
          ),

          // ───────────────────────── Bottom glass dock ─────────────────────────
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: _OwnerBottomDock(
              index: _index,
              onChanged: _setIndex,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🌫️ Background with subtle gradient + glow blobs (light theme)
class _OwnerAmbientBackground extends StatelessWidget {
  const _OwnerAmbientBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.baseBgLinear),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -70,
            child: _GlowBlob(
              size: 240,
              color: AppColors.primary.withOpacity(0.16),
            ),
          ),
          Positioned(
            top: 120,
            right: -90,
            child: _GlowBlob(
              size: 260,
              color: AppColors.secondary.withOpacity(0.12),
            ),
          ),
          Positioned(
            bottom: -140,
            left: 40,
            child: _GlowBlob(
              size: 280,
              color: AppColors.other.withOpacity(0.10),
            ),
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

/// 🧊 Bottom Dock (Glass + icons + selected pill)
class _OwnerBottomDock extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _OwnerBottomDock({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Glass(
      borderRadius: AppRadius.r24,
      sigmaX: 18,
      sigmaY: 18,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      color: Colors.white.withOpacity(0.66),
      borderColor: Colors.white.withOpacity(0.82),
      shadows: AppShadows.shadowLg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _DockItem(
            active: index == 0,
            label: "Rules",
            icon: Icons.rule_rounded,
            onTap: () => onChanged(0),
          ),
          _DockItem(
            active: index == 1,
            label: "Dashboard",
            icon: Icons.grid_view_rounded,
            onTap: () => onChanged(1),
          ),
          _DockItem(
            active: index == 2,
            label: "Orders",
            icon: Icons.receipt_long_rounded,
            onTap: () => onChanged(2),
          ),
          _DockItem(
            active: index == 3,
            label: "Articles",
            icon: Icons.inventory_2_rounded,
            onTap: () => onChanged(3),
          ),
          _DockItem(
            active: index == 4,
            label: "Profile",
            icon: Icons.person_rounded,
            onTap: () => onChanged(4),
          ),
        ],
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final bool active;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _DockItem({
    required this.active,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = active
        ? Colors.white.withOpacity(0.96)
        : AppColors.ink.withOpacity(0.72);

    return Expanded(
      child: PressScale(
        downScale: 0.985,
        borderRadius: AppRadius.pill(),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: AppRadius.pill(),
            gradient: active ? AppColors.brandLinear : null,
            color: active ? null : Colors.white.withOpacity(0.0),
            border: Border.all(
              color: active
                  ? Colors.white.withOpacity(0.22)
                  : AppColors.divider.withOpacity(0.45),
              width: 1.05,
            ),
            boxShadow: active ? AppShadows.soft : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.0, color: fg),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.kicker().copyWith(
                    color: fg,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────
/// TAB 0: Rules screen (content-only)
/// ─────────────────────────────────────────
class _OwnerRulesScreen extends StatelessWidget {
  const _OwnerRulesScreen();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Glass(
          borderRadius: AppRadius.r22,
          sigmaX: 18,
          sigmaY: 18,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          color: Colors.white.withOpacity(0.70),
          borderColor: Colors.white.withOpacity(0.85),
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
                child: Icon(Icons.rule_rounded,
                    color: Colors.white.withOpacity(0.96)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Shop Owner Rules", style: AppText.h2()),
                    const SizedBox(height: 4),
                    Text("How orders flow in your shop portal.",
                        style: AppText.subtle()),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.pill(),
                  color: Colors.white.withOpacity(0.68),
                  border: Border.all(
                    color: AppColors.divider.withOpacity(0.55),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  "READ",
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Rules", style: TextStyle()), // overridden below by DefaultTextStyle
                SizedBox(height: 10),
                _RuleItem(index: 1, text: "Shop must be OPEN to receive new orders. When CLOSED, no new orders will arrive."),
                _RuleItem(index: 2, text: "Each new order must be accepted within 2 minutes. If not accepted, it will automatically move to the next shop."),
                _RuleItem(index: 3, text: "Rejecting an order immediately forwards it away from your shop."),
                _RuleItem(index: 4, text: "Once accepted, the order moves to the Accepted section and rider assignment starts."),
                _RuleItem(index: 5, text: "Order Details will show rider name/number and ETA, plus full items, qty, price."),
                _RuleItem(index: 6, text: "After rider picks up, mark the order as Completed. Completed orders cannot be edited."),
                _RuleItem(index: 7, text: "Articles (inventory) can be added/edited anytime (image, price, quantity)."),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RuleItem extends StatelessWidget {
  final int index;
  final String text;

  const _RuleItem({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: AppText.body(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppColors.brandLinear,
                borderRadius: AppRadius.pill(),
                boxShadow: AppShadows.soft,
              ),
              child: Text(
                "$index",
                style: AppText.kicker().copyWith(
                  color: Colors.white.withOpacity(0.96),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: AppText.body())),
          ],
        ),
      ),
    );
  }
}
