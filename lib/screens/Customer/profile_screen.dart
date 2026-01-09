import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';

/// ✅ Premium Profile Screen (Nexora Theme)
/// - SAME premium glassmorphism + glow blobs as Login/Signup
/// - NO hover animations (works identical on mobile + web)
/// - Press/Click zoom + soft “light-up” highlight (mobile + web)
/// - Sticky centered glass header (no collision)
/// - Full page code (no missing helpers)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  // Entrance
  late final AnimationController _enterCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  // Ambient / background
  late final AnimationController _ambientCtrl;
  late final Animation<double> _bgT;
  late final Animation<double> _floatT;

  // Header layout constants
  static const double _capBaseH = 150.0;
  static const double _stickyHeaderH = 66.0;

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    );

    _fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));

    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5600),
    )..repeat(reverse: true);

    _bgT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOut);
    _floatT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOutSine);

    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _ambientCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    // ✅ Extra top padding so content NEVER collides with sticky header
    final contentTopPadding = _capBaseH + topInset + _stickyHeaderH + 18.0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // ✅ Animated premium gradient background (same family as Login/Signup)
          AnimatedBuilder(
            animation: _ambientCtrl,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(const Color(0xFFF5F8FF), const Color(0xFFEAF0FF), _bgT.value)!,
                      Color.lerp(const Color(0xFFEFF6FF), const Color(0xFFFBEFFF), _bgT.value)!,
                      Color.lerp(const Color(0xFFF7F7FA), const Color(0xFFF1F4FF), _bgT.value)!,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              );
            },
          ),

          // ✅ Soft haze overlay (premium glass atmosphere)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _ambientCtrl,
              builder: (context, _) {
                final t = _floatT.value;
                return Opacity(
                  opacity: 0.10,
                  child: Transform.translate(
                    offset: Offset(lerpDouble(-16, 16, t)!, lerpDouble(10, -10, t)!),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0.14, -0.55),
                          radius: 1.25,
                          colors: [
                            Color(0xFFB9C7FF),
                            Color(0xFFBCE9FF),
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.42, 1.0],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ✅ Floating glow blobs (Nexora vibe)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _ambientCtrl,
              builder: (context, _) {
                final t = _floatT.value;
                return Stack(
                  children: [
                    _GlowBlob(
                      dx: lerpDouble(-44, 26, t)!,
                      dy: lerpDouble(92, 62, t)!,
                      size: 240,
                      opacity: 0.15,
                    ),
                    _GlowBlob(
                      dx: lerpDouble(230, 300, t)!,
                      dy: lerpDouble(260, 210, t)!,
                      size: 290,
                      opacity: 0.12,
                    ),
                    _GlowBlob(
                      dx: lerpDouble(160, 220, 1 - t)!,
                      dy: lerpDouble(40, 20, t)!,
                      size: 220,
                      opacity: 0.10,
                    ),
                  ],
                );
              },
            ),
          ),

          // ✅ Top Cap (same cut / premium)
          const _ProfileTopCap(baseHeight: _capBaseH),

          // ✅ Scroll content (pushed down; no collision)
          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16, contentTopPadding, 16, 44),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _profileHeader(),
                    const SizedBox(height: 18),

                    _sectionCard(
                      title: "Orders",
                      subtitle: "Track & manage purchases",
                      child: Column(
                        children: [
                          _menuTile(
                            icon: Icons.receipt_long_rounded,
                            title: "Order History",
                            subtitle: "Track & reorder past purchases",
                            onTap: () {},
                          ),
                          const _SoftDivider(),
                          _menuTile(
                            icon: Icons.local_shipping_outlined,
                            title: "Active Orders",
                            subtitle: "Live tracking & updates",
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    _sectionCard(
                      title: "Saved Info",
                      subtitle: "Your delivery & payments",
                      child: Column(
                        children: [
                          _menuTile(
                            icon: Icons.location_on_outlined,
                            title: "Addresses",
                            subtitle: "Manage delivery locations",
                            onTap: () {},
                          ),
                          const _SoftDivider(),
                          _menuTile(
                            icon: Icons.favorite_border_rounded,
                            title: "Saved Shops",
                            subtitle: "Your favorites & recently viewed",
                            onTap: () {},
                          ),
                          const _SoftDivider(),
                          _menuTile(
                            icon: Icons.account_balance_wallet_outlined,
                            title: "Wallet",
                            subtitle: "Cashbacks & refunds (coming soon)",
                            onTap: () {},
                            disabled: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    _sectionCard(
                      title: "Support & Feedback",
                      subtitle: "Help and experience",
                      child: Column(
                        children: [
                          _menuTile(
                            icon: Icons.support_agent_rounded,
                            title: "Customer Support",
                            subtitle: "Chat or call for help",
                            onTap: () {},
                          ),
                          const _SoftDivider(),
                          _menuTile(
                            icon: Icons.star_rate_rounded,
                            title: "Rate Shop & Rider",
                            subtitle: "Share your experience",
                            onTap: () {},
                          ),
                          const _SoftDivider(),
                          _menuTile(
                            icon: Icons.privacy_tip_outlined,
                            title: "Privacy & Terms",
                            subtitle: "Read policies and permissions",
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ✅ Premium logout button (light theme – matches Nexora)
                    _logoutButton(),

                    const SizedBox(height: 12),

                    Center(
                      child: Text(
                        "Nexora • Shopping that moves at your speed",
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMid.withOpacity(0.85),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ✅ Sticky centered header (glassy, premium, click animations)
          _stickyCenteredHeader(context),
        ],
      ),
    );
  }

  // ───────────────────── Sticky Center Header ─────────────────────

  Widget _stickyCenteredHeader(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topInset + 8,
      left: 12,
      right: 12,
      child: _GlassHeaderShell(
        height: _stickyHeaderH,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _PressGlowScale(
                onTap: () => Navigator.maybePop(context),
                borderRadius: BorderRadius.circular(14),
                child: _GlassIconSquare(icon: Icons.arrow_back_rounded),
              ),
            ),

            const _Title3DCentered(text: "PROFILE", fontSize: 22),

            Align(
              alignment: Alignment.centerRight,
              child: _PressGlowScale(
                onTap: () {},
                borderRadius: BorderRadius.circular(14),
                child: _GlassIconSquare(icon: Icons.settings_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────── Profile Header ─────────────────────

  Widget _profileHeader() {
    return _PressGlowScale(
      onTap: () {
        HapticFeedback.selectionClick();
      },
      borderRadius: BorderRadius.circular(AppRadius.r18),
      child: _GlassCard(
        floatingT: _floatT.value,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const _Avatar3D(letter: "A", size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Abdul Basit",
                    style: GoogleFonts.manrope(
                      fontSize: 16.2,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "03XX-XXXXXXX",
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMid,
                    ),
                  ),
                ],
              ),
            ),
            _PressGlowScale(
              onTap: () {},
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.chipFill.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider.withOpacity(0.85)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.85),
                      blurRadius: 12,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Icon(Icons.edit_outlined, color: AppColors.textDark.withOpacity(0.92), size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────── Section Card ─────────────────────

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return _PressGlowScale(
      onTap: () {
        // subtle feedback when tapping the card container itself
        HapticFeedback.selectionClick();
      },
      borderRadius: BorderRadius.circular(AppRadius.r18),
      downScale: 0.994,
      glowOpacity: 0.10,
      child: _GlassCard(
        floatingT: _floatT.value,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row (3D + subtitle)
            Row(
              children: [
                _SectionIconPuck(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.manrope(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMid.withOpacity(0.90),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  // ───────────────────── Menu Tile ─────────────────────

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    return _PressGlowScale(
      enabled: !disabled,
      onTap: disabled ? null : () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      downScale: 0.985,
      glowOpacity: 0.12,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            _IconBadge3D(icon: icon, disabled: disabled),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 14.4,
                      fontWeight: FontWeight.w900,
                      color: disabled ? AppColors.textMid : AppColors.textDark,
                      letterSpacing: -0.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMid,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: disabled
                  ? AppColors.textMid.withOpacity(0.70)
                  : AppColors.textDark.withOpacity(0.75),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────── Logout ─────────────────────

  Widget _logoutButton() {
    return _PressGlowScale(
      onTap: () {},
      borderRadius: BorderRadius.circular(AppRadius.r22),
      downScale: 0.988,
      glowOpacity: 0.14,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.r22),
        child: Stack(
          children: [
            // blur base
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: const SizedBox.expand(),
              ),
            ),

            // premium light gradient (NOT dark)
            Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.r22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFF3ECFF).withOpacity(0.95),
                    const Color(0xFFEAF3FF).withOpacity(0.92),
                  ],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.82), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // specular highlight
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.r22),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.68),
                              Colors.white.withOpacity(0.14),
                              Colors.white.withOpacity(0.02),
                            ],
                            stops: const [0.0, 0.42, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // subtle shine stripe
                  Positioned(
                    left: -40,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Transform.rotate(
                        angle: -0.25,
                        child: Container(
                          width: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.55),
                                Colors.white.withOpacity(0.0),
                              ],
                              stops: const [0.2, 0.5, 0.8],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.logout_rounded, color: const Color(0xFF2D1B69).withOpacity(0.92), size: 18),
                        const SizedBox(width: 10),
                        Text(
                          "Log out",
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2D1B69).withOpacity(0.92),
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TOP CAP
// ─────────────────────────────────────────────────────────────

class _ProfileTopCap extends StatelessWidget {
  final double baseHeight;
  const _ProfileTopCap({required this.baseHeight});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: -topInset,
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: _HeaderClipper(),
        child: Container(
          height: baseHeight + topInset,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.92),
                Colors.white.withOpacity(0.56),
                Colors.white.withOpacity(0.16),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 42,
                offset: const Offset(0, 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
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

// ─────────────────────────────────────────────────────────────
// PREMIUM HELPERS (NO HOVER)
// ─────────────────────────────────────────────────────────────

class _GlassHeaderShell extends StatelessWidget {
  final Widget child;
  final double height;
  const _GlassHeaderShell({required this.child, required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.66),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.60), width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              // specular highlight
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.70),
                          Colors.white.withOpacity(0.16),
                          Colors.white.withOpacity(0.02),
                        ],
                        stops: const [0.0, 0.48, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassIconSquare extends StatelessWidget {
  final IconData icon;
  const _GlassIconSquare({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.74),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withOpacity(0.70)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.85),
            blurRadius: 12,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.textDark),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double dx, dy, size, opacity;
  const _GlowBlob({
    required this.dx,
    required this.dy,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: dx,
      top: dy,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF6B7CFF).withOpacity(opacity),
                const Color(0xFF7EDCFF).withOpacity(opacity * 0.70),
                Colors.transparent,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final double floatingT;
  final EdgeInsets padding;

  const _GlassCard({
    required this.child,
    required this.floatingT,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final floatY = sin(floatingT * pi * 2) * 2.4;

    return Transform.translate(
      offset: Offset(0, floatY),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.r18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.r18),
              border: Border.all(color: Colors.white.withOpacity(0.62), width: 1.1),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.70),
                  Colors.white.withOpacity(0.50),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 22,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Stack(
              children: [
                // specular highlight
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.r18),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.74),
                            Colors.white.withOpacity(0.14),
                            Colors.white.withOpacity(0.02),
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ✅ Press/Click zoom + light-up glow (mobile + web)
/// No hover. Works on both.
class _PressGlowScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final double downScale;
  final double glowOpacity;
  final BorderRadius borderRadius;

  const _PressGlowScale({
    required this.child,
    this.onTap,
    this.enabled = true,
    this.downScale = 0.985,
    this.glowOpacity = 0.14,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
  });

  @override
  State<_PressGlowScale> createState() => _PressGlowScaleState();
}

class _PressGlowScaleState extends State<_PressGlowScale> {
  bool _down = false;

  void _setDown(bool v) {
    if (_down == v) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled && widget.onTap != null;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: enabled ? widget.onTap : null,
      onTapDown: enabled ? (_) => _setDown(true) : null,
      onTapUp: enabled ? (_) => _setDown(false) : null,
      onTapCancel: enabled ? () => _setDown(false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: _down
              ? [
            BoxShadow(
              color: const Color(0xFF6B7CFF).withOpacity(widget.glowOpacity),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ]
              : null,
        ),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          scale: _down ? widget.downScale : 1.0,
          child: widget.child,
        ),
      ),
    );
  }
}

class _Title3DCentered extends StatelessWidget {
  final String text;
  final double fontSize;
  const _Title3DCentered({required this.text, this.fontSize = 22});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (int i = 10; i >= 1; i--)
          Transform.translate(
            offset: Offset(0, i.toDouble() * 0.9),
            child: Text(
              text,
              style: GoogleFonts.manrope(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
                color: Colors.black.withOpacity(0.055),
              ),
            ),
          ),
        Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
            color: const Color(0xFF1E2235),
            shadows: [
              Shadow(
                blurRadius: 18,
                offset: const Offset(0, 10),
                color: const Color(0xFF6B7CFF).withOpacity(0.18),
              ),
              Shadow(
                blurRadius: 10,
                offset: const Offset(0, 5),
                color: Colors.black.withOpacity(0.10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Avatar3D extends StatelessWidget {
  final String letter;
  final double size;
  const _Avatar3D({required this.letter, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFBFA8FF), Color(0xFFAEDBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.85),
            blurRadius: 12,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF2D1B69),
        ),
      ),
    );
  }
}

class _IconBadge3D extends StatelessWidget {
  final IconData icon;
  final bool disabled;

  const _IconBadge3D({required this.icon, required this.disabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.chipFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.80),
            blurRadius: 12,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: disabled ? AppColors.textMid : AppColors.textDark,
      ),
    );
  }
}

class _SectionIconPuck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF8FAFC).withOpacity(0.62),
        border: Border.all(color: Colors.white.withOpacity(0.75), width: 1.0),
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        size: 18,
        color: const Color(0xFF6B7CFF).withOpacity(0.85),
      ),
    );
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 18,
      thickness: 1,
      color: AppColors.divider.withOpacity(0.65),
    );
  }
}
