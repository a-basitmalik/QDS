import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';

/// ✅ Premium Profile Screen (Your Light Theme)
/// - Uses AppColors from your file (primary/secondary/other, bg1/bg2/bg3, ink/muted)
/// - No hover; press glow + scale works on mobile + web
/// - Sticky centered glass header
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  // Entrance
  late final AnimationController _enterCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  // Ambient / background
  late final AnimationController _ambientCtrl;
  late final Animation<double> _bgT;
  late final Animation<double> _floatT;

  // Header layout constants
  static const double _mahoganyHeaderH = 98.0; // ✅ header body height (excluding status bar)


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
    final contentTopPadding = topInset + _mahoganyHeaderH + 22.0;

    return Scaffold(
      backgroundColor: AppColors.bg3,
      body: Stack(
        children: [
          // ✅ Use your theme’s base gradient
          AnimatedBuilder(
            animation: _ambientCtrl,
            builder: (context, _) {
              // Subtle animated lerp between bg tones (keeps your palette)
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(AppColors.bg3, AppColors.bg2, _bgT.value)!,
                      Color.lerp(AppColors.bg2, AppColors.bg1, _bgT.value)!,
                      AppColors.bg3,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              );
            },
          ),

          // ✅ Soft haze overlay
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _ambientCtrl,
              builder: (context, _) {
                final t = _floatT.value;
                return Opacity(
                  opacity: 0.08,
                  child: Transform.translate(
                    offset: Offset(
                      lerpDouble(-16, 16, t)!,
                      lerpDouble(10, -10, t)!,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0.14, -0.55),
                          radius: 1.25,
                          colors: [
                            AppColors.primary.withOpacity(0.30),
                            AppColors.other.withOpacity(0.18),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ✅ Glow blobs using your brand colors
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
                      opacity: 0.14,
                      a: AppColors.secondary,
                      b: AppColors.other,
                    ),
                    _GlowBlob(
                      dx: lerpDouble(230, 300, t)!,
                      dy: lerpDouble(260, 210, t)!,
                      size: 290,
                      opacity: 0.11,
                      a: AppColors.primary,
                      b: AppColors.secondary,
                    ),
                    _GlowBlob(
                      dx: lerpDouble(160, 220, 1 - t)!,
                      dy: lerpDouble(40, 20, t)!,
                      size: 220,
                      opacity: 0.09,
                      a: AppColors.other,
                      b: AppColors.primary,
                    ),
                  ],
                );
              },
            ),
          ),

          // ✅ Top Cap
          _mahoganyProfileHeader(context),

          // ✅ Scroll content
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

                    _logoutButton(),

                    const SizedBox(height: 12),

                    Center(
                      child: Text(
                        "Nexora • Shopping that moves at your speed",
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink.withOpacity(0.45),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ✅ Sticky centered header
          _mahoganyProfileHeader(context),
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
        height: _mahoganyHeaderH,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _PressGlowScale(
                onTap: () => Navigator.maybePop(context),
                borderRadius: BorderRadius.circular(14),
                child: const _GlassIconSquare(icon: Icons.arrow_back_rounded),
              ),
            ),
            const _Title3DCentered(text: "PROFILE", fontSize: 22),
            Align(
              alignment: Alignment.centerRight,
              child: _PressGlowScale(
                onTap: () {},
                borderRadius: BorderRadius.circular(14),
                child: const _GlassIconSquare(icon: Icons.settings_outlined),
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
      onTap: () => HapticFeedback.selectionClick(),
      borderRadius: BorderRadius.circular(18),
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
                      color: AppColors.ink,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "03XX-XXXXXXX",
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink.withOpacity(0.55),
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
                  color: Colors.white.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderBase(0.70)),
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
                child: Icon(
                  Icons.edit_outlined,
                  color: AppColors.ink.withOpacity(0.92),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────── Section Card ─────────────────────

  Widget _mahoganyProfileHeader(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final shine = (sin(_floatT.value * pi * 2) * 0.5 + 0.5);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(12, topInset + 10, 12, 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.98),
              AppColors.secondary.withOpacity(0.96),
              AppColors.primary.withOpacity(0.94),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            _PressGlowScale(
              onTap: () => Navigator.maybePop(context),
              borderRadius: BorderRadius.circular(14),
              child: _mahoganyIconPuck(
                icon: Icons.arrow_back_ios_new_rounded,
                t: shine,
              ),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "PROFILE",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 18.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: Colors.white.withOpacity(0.94),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Abdul Basit • Manage account",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 12.2,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withOpacity(0.74),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            _PressGlowScale(
              onTap: () {
                // TODO: settings action
              },
              borderRadius: BorderRadius.circular(14),
              child: _mahoganyIconPuck(
                icon: Icons.settings_outlined,
                t: shine,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mahoganyIconPuck({required IconData icon, required double t}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.14 + 0.06 * t),
        border: Border.all(color: Colors.white.withOpacity(0.24)),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 20, color: Colors.white.withOpacity(0.92)),
    );
  }



  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return _PressGlowScale(
      onTap: () => HapticFeedback.selectionClick(),
      borderRadius: BorderRadius.circular(18),
      downScale: 0.994,
      glowOpacity: 0.10,
      child: _GlassCard(
        floatingT: _floatT.value,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _SectionIconPuck(),
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
                          color: AppColors.ink,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink.withOpacity(0.55),
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
      onTap: disabled
          ? null
          : () {
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
                      color: disabled
                          ? AppColors.ink.withOpacity(0.45)
                          : AppColors.ink,
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
                      color: AppColors.ink.withOpacity(0.55),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: disabled
                  ? AppColors.ink.withOpacity(0.35)
                  : AppColors.ink.withOpacity(0.70),
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
      borderRadius: BorderRadius.circular(22),
      downScale: 0.988,
      glowOpacity: 0.14,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: const SizedBox.expand(),
              ),
            ),
            Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.bg2.withOpacity(0.95),
                    Colors.white.withOpacity(0.92),
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
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
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
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.logout_rounded,
                            color: AppColors.secondary.withOpacity(0.92),
                            size: 18),
                        const SizedBox(width: 10),
                        Text(
                          "Log out",
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w900,
                            color: AppColors.secondary.withOpacity(0.92),
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
            color: Colors.white,
            boxShadow: AppShadows.topCap,
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
// HELPERS (NO HOVER)
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
        border: Border.all(color: AppColors.borderBase(0.70)),
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
      child: Icon(icon, color: AppColors.ink),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double dx, dy, size, opacity;
  final Color a, b;

  const _GlowBlob({
    required this.dx,
    required this.dy,
    required this.size,
    required this.opacity,
    required this.a,
    required this.b,
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
                a.withOpacity(opacity),
                b.withOpacity(opacity * 0.65),
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
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
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
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
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
              color: AppColors.secondary.withOpacity(widget.glowOpacity),
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
        ShaderMask(
          shaderCallback: (rect) => AppColors.brandLinear.createShader(rect),
          child: Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                  color: AppColors.secondary.withOpacity(0.18),
                ),
                Shadow(
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                  color: Colors.black.withOpacity(0.10),
                ),
              ],
            ),
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
        gradient: AppColors.brandLinear,
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
          color: Colors.white,
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
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderBase(0.72)),
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
        color: disabled ? AppColors.ink.withOpacity(0.45) : AppColors.ink,
      ),
    );
  }
}

class _SectionIconPuck extends StatelessWidget {
  const _SectionIconPuck();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.62),
        border: Border.all(color: Colors.white.withOpacity(0.75), width: 1.0),
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        size: 18,
        color: AppColors.secondary.withOpacity(0.85),
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
      color: AppColors.borderBase(0.70),
    );
  }
}
