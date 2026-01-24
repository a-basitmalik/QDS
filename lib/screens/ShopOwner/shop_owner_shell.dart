// lib/screens/ShopOwner/shop_owner_shell.dart
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'owner_add_product_screen.dart'; // ✅ add this import
import 'owner_size_chart_screen.dart';  // optional direct navigation tab if you want
import 'owner_products_list_screen.dart';
import 'owner_dashboard_screen.dart'; // stats dashboard (below)
import 'owner_orders_screen.dart';    // your orders screen (below)
class ShopOwnerShell extends StatefulWidget {
  final int ownerUserId;   // ✅ receive from login

  const ShopOwnerShell({
    super.key,
    required this.ownerUserId,
  });

  @override
  State<ShopOwnerShell> createState() => _ShopOwnerShellState();
}

class _ShopOwnerShellState extends State<ShopOwnerShell>
    with TickerProviderStateMixin {
  // ✅ Match your customer theme colors
  static const _primary = Color(0xFF440C08);
  static const _secondary = Color(0xFF750A03);
  static const _other = Color(0xFF9B0F03);

  static const _bg1 = Color(0xFFF9F6F5);
  static const _bg2 = Color(0xFFF4EEED);
  static const _ink = Color(0xFF140504);

  int _index = 0;

  // You can wire this to real orders count later
  int _ordersBadge = 5;

  late final AnimationController _ambientCtrl;

  @override
  void initState() {
    super.initState();
    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ambientCtrl.dispose();
    super.dispose();
  }

  void _goOrders() {
    HapticFeedback.selectionClick();
    setState(() => _index = 1);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      OwnerDashboardScreen(
        ownerUserId: widget.ownerUserId,
        onOpenOrders: _goOrders,
      ),

      OwnerOrdersScreen(
        // optional: if you want Orders screen to clear badge when opened
        onOrdersSeen: () => setState(() => _ordersBadge = 0),
      ),
      // ✅ NEW Products tab
      OwnerAddProductScreen(
        ownerUserId: widget.ownerUserId,
        shopId: 1, // TODO: pass real shopId from login/prefs
      ),
      OwnerProductsListScreen(
        ownerUserId: widget.ownerUserId,
        shopId: 1, // TODO pass real shopId
      ),
      // const _PlaceholderScreen(
      //   title: "Articles",
      //   subtitle: "Coming soon • publish & promote articles",
      //   icon: Icons.article_rounded,
      // ),
      const _PlaceholderScreen(
        title: "Account",
        subtitle: "Coming soon • shop profile & settings",
        icon: Icons.person_rounded,
      ),
    ];

    return Scaffold(
      backgroundColor: _bg1,
      body: AnimatedBuilder(
        animation: _ambientCtrl,
        builder: (context, _) {
          final t = _ambientCtrl.value;
          final float = sin(t * pi * 2);

          return Stack(
            children: [
              // ── soft gradient bg
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _bg1,
                        _bg2,
                        Colors.white,
                      ],
                    ),
                  ),
                ),
              ),

              // ── glow blobs (premium)
              Positioned(
                left: -70 + float * 10,
                top: 90 + float * 8,
                child: _GlowBlob(color: _secondary.withOpacity(0.22), size: 240),
              ),
              Positioned(
                right: -90 - float * 8,
                top: 180 - float * 6,
                child: _GlowBlob(color: _other.withOpacity(0.18), size: 290),
              ),

              // ── content
              Positioned.fill(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                    child: IndexedStack(index: _index, children: pages),
                  ),
                ),
              ),
            ],
          );
        },
      ),

      // ✅ Bottom nav (screenshot style): icon + label + badge, rounded top corners
      bottomNavigationBar: _OwnerBottomNav(
        primary: _primary,
        secondary: _secondary,
        ink: _ink,
        index: _index,
        ordersBadge: _ordersBadge,
        onChanged: (i) {
          HapticFeedback.selectionClick();
          setState(() => _index = i);
        },
      ),
    );
  }
}

class _OwnerBottomNav extends StatelessWidget {
  final Color primary;
  final Color secondary;
  final Color ink;
  final int index;
  final int ordersBadge;
  final ValueChanged<int> onChanged;

  const _OwnerBottomNav({
    required this.primary,
    required this.secondary,
    required this.ink,
    required this.index,
    required this.ordersBadge,
    required this.onChanged,
  });

  TextStyle _label(bool active) => GoogleFonts.manrope(
    fontSize: 11.5,
    fontWeight: FontWeight.w900,
    height: 1.05,
    color: active ? primary.withOpacity(0.96) : ink.withOpacity(0.48),
  );

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(22);

    Widget item({
      required int i,
      required IconData icon,
      required String label,
      int badge = 0,
    }) {
      final active = i == index;

      return Expanded(
        child: _PressScale(
          downScale: 0.97,
          borderRadius: BorderRadius.circular(16),
          onTap: () => onChanged(i),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      size: 24,
                      color: active
                          ? primary.withOpacity(0.96)
                          : ink.withOpacity(0.52),
                    ),
                    if (badge > 0)
                      Positioned(
                        right: -8,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                secondary.withOpacity(0.96),
                                primary.withOpacity(0.96),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.7),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: secondary.withOpacity(0.22),
                                blurRadius: 14,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Text(
                            "$badge",
                            style: GoogleFonts.manrope(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white.withOpacity(0.96),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(label, style: _label(active)),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: ClipRRect(
          borderRadius: r,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.76),
                borderRadius: r,
                border: Border.all(
                  color: Colors.white.withOpacity(0.85),
                  width: 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 26,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Row(
                children: [
                  item(i: 0, icon: Icons.grid_view_rounded, label: "Dashboard"),
                  item(
                    i: 1,
                    icon: Icons.receipt_long_rounded,
                    label: "Orders",
                    badge: ordersBadge,
                  ),
                  item(i: 2, icon: Icons.inventory_2_rounded, label: "Add Products"), // ✅ new
                  item(i: 3, icon: Icons.article_rounded, label: "Products"),
                  item(i: 4, icon: Icons.person_rounded, label: "Account"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _PlaceholderScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.86), width: 1.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 22,
                  offset: const Offset(0, 14),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 42, color: const Color(0xFF440C08).withOpacity(0.72)),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF140504).withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 12.6,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF140504).withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _PressScale extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;
  final double downScale;

  const _PressScale({
    required this.child,
    required this.onTap,
    required this.borderRadius,
    this.downScale = 0.98,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 1),
      duration: const Duration(milliseconds: 1),
      builder: (_, __, ___) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onTap,
            child: child,
          ),
        );
      },
    );
  }
}
