import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:qds/screens/Customer/profile_screen.dart';
import 'package:qds/screens/Customer/shop_listing_screen.dart';
import 'package:qds/screens/Customer/shop_screen.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';

/// ✅ Premium Nexora Homepage (Mobile + Web friendly)
/// - Same light indigo/sky glass theme as Login/Signup
/// - NO hover-only UI (no MouseRegion)
/// - Tap/Click press zoom for BOTH mobile + web
/// - Premium glass, glow blobs, top cap, 3D headings, frosted cards
///
/// ✅ UPDATE (Less congested):
/// - Smaller, crisp headings
/// - Shorter copy + improved line-height
/// - More breathing space between sections
/// - Compact section headers
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _ambientCtrl;
  late final Animation<double> _bgT;
  late final Animation<double> _floatT;

  @override
  void initState() {
    super.initState();
    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5600),
    )..repeat(reverse: true);

    _bgT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOut);
    _floatT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOutSine);
  }

  @override
  void dispose() {
    _ambientCtrl.dispose();
    super.dispose();
  }

  // Typography helpers (crisp + consistent)
  TextStyle _kicker() => GoogleFonts.manrope(
    fontSize: 12.2,
    fontWeight: FontWeight.w700,
    height: 1.10,
    color: const Color(0xFF1B1E2B).withOpacity(0.52),
  );

  TextStyle _subtle() => GoogleFonts.manrope(
    fontSize: 12.6,
    fontWeight: FontWeight.w700,
    height: 1.22,
    color: const Color(0xFF1B1E2B).withOpacity(0.55),
  );

  TextStyle _cardTitle() => GoogleFonts.manrope(
    fontSize: 14.6,
    fontWeight: FontWeight.w900,
    height: 1.10,
    color: const Color(0xFF1B1E2B),
    letterSpacing: -0.2,
  );

  TextStyle _cardMeta() => GoogleFonts.manrope(
    fontSize: 12.0,
    fontWeight: FontWeight.w800,
    height: 1.18,
    color: const Color(0xFF1B1E2B).withOpacity(0.58),
  );

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // ✅ Animated premium background (light indigo + sky)
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
                      Color.lerp(const Color(0xFFEFF6FF), const Color(0xFFEAF9FF), _bgT.value)!,
                      Color.lerp(const Color(0xFFF7F7FA), const Color(0xFFF1F4FF), _bgT.value)!,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              );
            },
          ),

          // ✅ Subtle glass haze overlay (adds premium depth)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _ambientCtrl,
              builder: (context, _) {
                final t = _floatT.value;
                return Opacity(
                  opacity: 0.10,
                  child: Transform.translate(
                    offset: Offset(lerpDouble(-18, 18, t)!, lerpDouble(10, -10, t)!),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0.18, -0.55),
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

          // ✅ Floating glow blobs (same vibe as Login/Signup)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _ambientCtrl,
              builder: (context, _) {
                final t = _floatT.value;
                return Stack(
                  children: [
                    _GlowBlob(
                      dx: lerpDouble(-55, 12, t)!,
                      dy: lerpDouble(120, 72, t)!,
                      size: 240,
                      opacity: 0.16,
                    ),
                    _GlowBlob(
                      dx: lerpDouble(240, 300, t)!,
                      dy: lerpDouble(280, 210, t)!,
                      size: 300,
                      opacity: 0.12,
                    ),
                    _GlowBlob(
                      dx: lerpDouble(190, 240, 1 - t)!,
                      dy: lerpDouble(30, 16, t)!,
                      size: 220,
                      opacity: 0.10,
                    ),
                  ],
                );
              },
            ),
          ),

          // ✅ Top cap (premium header cut like your auth screens)
          Positioned(
            top: -topInset,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _HeaderCapClipper(),
              child: Container(
                height: 210 + topInset,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.92),
                      Colors.white.withOpacity(0.55),
                      Colors.white.withOpacity(0.18),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.035),
                      blurRadius: 46,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: _body(context),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return AnimatedBuilder(
      animation: _ambientCtrl,
      builder: (context, _) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          // ✅ slightly more top breathing, but overall cleaner
          padding: EdgeInsets.fromLTRB(18, 12, 18, 28 + topInset * 0.10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(context),

              const SizedBox(height: 14),

              // ✅ premium hero card
              _heroCard(context),

              const SizedBox(height: 22),

              _sectionHeader("Promoted Shops", "Sponsored picks", Icons.campaign_rounded),
              const SizedBox(height: 12),
              _horizontalCards(height: 160, isPromoted: true),

              const SizedBox(height: 22),
              _sectionHeader("Categories", "Browse all", Icons.grid_view_rounded),
              const SizedBox(height: 12),
              _categories(context),

              const SizedBox(height: 22),
              _sectionHeader("Flash Deals", "Limited drops", Icons.bolt_rounded),
              const SizedBox(height: 12),
              _horizontalCards(height: 170, isFlashDeal: true),

              const SizedBox(height: 22),
              _sectionHeader("Nearby Shops", "Fast near you", Icons.near_me_rounded),
              const SizedBox(height: 12),
              _nearbyShops(context),

              const SizedBox(height: 22),
              _sectionHeader("Top Rated", "Best reviewed", Icons.star_rounded),
              const SizedBox(height: 12),
              _horizontalCards(height: 160, isTopRated: true),

              const SizedBox(height: 22),
              _sectionHeader("Festival Picks", "Special offers", Icons.celebration_rounded),
              const SizedBox(height: 12),
              _festivalBanners(),

              const SizedBox(height: 18),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TOP BAR (less tall, crisp)
  // ─────────────────────────────────────────────────────────────

  Widget _topBar(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome back,", style: _kicker()),
              const SizedBox(height: 6),
              const _Title3D(
                "Discover Shops",
                fontSize: 22, // ✅ slightly smaller
                fontWeight: FontWeight.w900,
              ),
            ],
          ),
        ),

        _TopGlassIconButton(
          icon: Icons.search_rounded,
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),
        const SizedBox(width: 12),

        _PressScale(
          downScale: 0.965,
          borderRadius: BorderRadius.circular(999),
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
          child: const _ProfilePuck(letter: "A"),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HERO CARD (less text + more air)
  // ─────────────────────────────────────────────────────────────

  Widget _heroCard(BuildContext context) {
    final t = _floatT.value;
    final floatY = sin(t * pi * 2) * 3.0;

    return Transform.translate(
      offset: Offset(0, floatY),
      child: _PressScale(
        downScale: 0.992,
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          HapticFeedback.lightImpact();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
                  child: const SizedBox.expand(),
                ),
              ),
              Container(
                width: double.infinity,
                // ✅ slightly tighter, still premium
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC).withOpacity(0.58),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.78), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 26,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.74),
                                Colors.white.withOpacity(0.16),
                                Colors.white.withOpacity(0.02),
                              ],
                              stops: const [0.0, 0.42, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -36,
                      right: -44,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFCEB8FF).withOpacity(0.16),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -42,
                      left: -40,
                      child: Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFBCE9FF).withOpacity(0.14),
                        ),
                      ),
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MiniHeroPuck(icon: Icons.local_shipping_rounded),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const _GlassTag(text: "2-HOUR DELIVERY"),
                                  const Spacer(),
                                  _MiniGlassIcon(icon: Icons.bolt_rounded),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // ✅ shorter line, slightly smaller
                              Text(
                                "Shopping at your speed",
                                style: GoogleFonts.manrope(
                                  fontSize: 16.6,
                                  fontWeight: FontWeight.w900,
                                  height: 1.12,
                                  color: const Color(0xFF2D1B69),
                                  letterSpacing: -0.35,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // ✅ shorter copy + 2 lines max
                              Text(
                                "Nearby stores, instant deals, and curated picks — delivered fast.",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize: 12.4,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                  color: const Color(0xFF2D1B69).withOpacity(0.62),
                                ),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  _GlassPrimaryPill(
                                    text: "Explore",
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  _GlassSecondaryPill(
                                    text: "Deals",
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SECTION HEADER (compact + airy)
  // ─────────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _FloatingIcon(icon: icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ smaller heading
              _Title3D(title, fontSize: 18.5, fontWeight: FontWeight.w900),
              const SizedBox(height: 3),
              Text(subtitle, style: _subtle()),
            ],
          ),
        ),
        _GlassSmallPill(text: "View", onTap: () {}),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HORIZONTAL CARDS (slightly shorter)
  // ─────────────────────────────────────────────────────────────

  Widget _horizontalCards({
    required double height,
    bool isPromoted = false,
    bool isFlashDeal = false,
    bool isTopRated = false,
  }) {
    const sky1 = Color(0xFFF2F8FF);
    const sky2 = Color(0xFFEAF4FF);
    const borderBase = Color(0xFFD7ECFF);
    const borderActive = Color(0xFF9EC9FF);

    Color accentA() {
      if (isFlashDeal) return const Color(0xFFFFD7E6);
      if (isTopRated) return const Color(0xFFDCE7FF);
      return const Color(0xFFEDE2FF);
    }

    Color accentB() {
      if (isFlashDeal) return const Color(0xFFFFF1F6);
      if (isTopRated) return const Color(0xFFF0F6FF);
      return const Color(0xFFF6F1FF);
    }

    return SizedBox(
      height: height,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return _InteractiveGlassCard(
            width: 248,
            height: height,
            borderBase: borderBase,
            borderActive: borderActive,
            tint: sky1,
            tint2: sky2,
            accentA: accentA(),
            accentB: accentB(),
            isPromoted: isPromoted,
            // ✅ unchanged routing
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ShopScreen(shopName: "Urban Style Store"),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CATEGORIES
  // ─────────────────────────────────────────────────────────────

  Widget _categories(BuildContext context) {
    final items = [
      {"name": "Clothing", "icon": Icons.shopping_bag, "color": const Color(0xFF7C3AED)},
      {"name": "Shoes", "icon": Icons.sports, "color": const Color(0xFF4F46E5)},
      {"name": "Gifts", "icon": Icons.card_giftcard, "color": const Color(0xFFEC4899)},
      {"name": "Accessories", "icon": Icons.watch, "color": const Color(0xFF10B981)},
      {"name": "Perfumes", "icon": Icons.spa, "color": const Color(0xFFF59E0B)},
      {"name": "Electronics", "icon": Icons.phone_iphone, "color": const Color(0xFF3B82F6)},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((category) {
        final name = category["name"] as String;
        final icon = category["icon"] as IconData;
        final c = category["color"] as Color;

        return _CategoryGlassTile(
          name: name,
          icon: icon,
          accent: c,
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ShopListingScreen(category: name)),
            );
          },
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // NEARBY SHOPS (slightly tighter tags)
  // ─────────────────────────────────────────────────────────────

  Widget _nearbyShops(BuildContext context) {
    final shopNames = ["Urban Fashion Hub", "Boutique Central", "Style Gallery", "Trendy Emporium"];
    final distances = ["1.2 km", "2.5 km", "3.1 km", "0.8 km"];
    final ratings = ["4.7", "4.5", "4.9", "4.3"];

    return Column(
      children: List.generate(4, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _NearbyGlassRowCard(
            name: shopNames[index],
            distance: distances[index],
            rating: ratings[index],
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShopScreen(shopName: shopNames[index]),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // FESTIVAL BANNERS (copy already ok, just spacing above is fixed)
  // ─────────────────────────────────────────────────────────────

  Widget _festivalBanners() {
    final titles = ["Seasonal Sale", "Festival Deals"];
    final subtitles = [
      "Up to 40% off on winter collection",
      "Special discounts for festival shopping",
    ];
    final percentages = ["40%", "35%"];

    return Column(
      children: List.generate(2, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _GlassBannerCard(
            title: titles[index],
            subtitle: subtitles[index],
            percent: percentages[index],
            icon: index == 0 ? Icons.local_offer_rounded : Icons.celebration_rounded,
            onTap: () {
              HapticFeedback.lightImpact();
            },
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PRESS SCALE (NO HOVER) — mobile + web click/touch
// ─────────────────────────────────────────────────────────────

class _PressScale extends StatefulWidget {
  final Widget child;
  final double downScale;
  final Duration duration;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  const _PressScale({
    required this.child,
    this.onTap,
    this.downScale = 0.985,
    this.duration = const Duration(milliseconds: 140),
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
  });

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
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

// ─────────────────────────────────────────────────────────────
// BACKGROUND GLOW BLOB
// ─────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────
// TOP CAP CLIPPER (same family as auth screens)
// ─────────────────────────────────────────────────────────────

class _HeaderCapClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final r = 22.0;
    final slant = 36.0;
    final cutY = size.height - 58;

    final path = Path()
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

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ─────────────────────────────────────────────────────────────
// TOP ICON BUTTON (press-only)
// ─────────────────────────────────────────────────────────────

class _TopGlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TopGlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      downScale: 0.965,
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.16),
        shape: const CircleBorder(),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF8FAFC).withOpacity(0.64),
                border: Border.all(color: Colors.white.withOpacity(0.84), width: 1.1),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(-0.65, -0.65),
                            radius: 1.0,
                            colors: [
                              Colors.white.withOpacity(0.85),
                              Colors.white.withOpacity(0.18),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.55, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      icon,
                      size: 20,
                      color: const Color(0xFF2D1B69).withOpacity(0.70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PROFILE PUCK
// ─────────────────────────────────────────────────────────────

class _ProfilePuck extends StatelessWidget {
  final String letter;
  const _ProfilePuck({required this.letter});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.18),
      shape: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFBFA8FF), Color(0xFFAEDBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.1),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.65, -0.65),
                      radius: 1.0,
                      colors: [
                        Colors.white.withOpacity(0.75),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.7],
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                letter,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2D1B69),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 3D TITLE (same style family)
// ─────────────────────────────────────────────────────────────

class _Title3D extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  const _Title3D(
      this.text, {
        required this.fontSize,
        required this.fontWeight,
      });

  @override
  Widget build(BuildContext context) {
    const base = Color(0xFF1B1E2B);

    return RichText(
      text: TextSpan(
        children: text.split('').map((ch) {
          if (ch == ' ') return const TextSpan(text: ' ');
          return WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Stack(
              children: [
                Transform.translate(
                  offset: const Offset(0.9, 1.1),
                  child: Text(
                    ch,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      color: base.withOpacity(0.18),
                      height: 1.0,
                      fontFamily: GoogleFonts.manrope().fontFamily,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0.0, 0.8),
                  child: Text(
                    ch,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      color: base.withOpacity(0.10),
                      height: 1.0,
                      fontFamily: GoogleFonts.manrope().fontFamily,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(-0.5, -0.6),
                  child: Text(
                    ch,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      color: Colors.white.withOpacity(0.55),
                      height: 1.0,
                      fontFamily: GoogleFonts.manrope().fontFamily,
                    ),
                  ),
                ),
                Text(
                  ch,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    color: base,
                    height: 1.0,
                    fontFamily: GoogleFonts.manrope().fontFamily,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SMALL GLASS PILL
// ─────────────────────────────────────────────────────────────

class _GlassSmallPill extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _GlassSmallPill({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      downScale: 0.97,
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC).withOpacity(0.55),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFFD7ECFF).withOpacity(0.95),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              text,
              style: GoogleFonts.manrope(
                fontSize: 11.8, // ✅ slightly smaller
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1B1E2B).withOpacity(0.70),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// FLOATING ICON
// ─────────────────────────────────────────────────────────────

class _FloatingIcon extends StatelessWidget {
  final IconData icon;
  const _FloatingIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -2),
      child: Material(
        color: Colors.transparent,
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.18),
        shape: const CircleBorder(),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF8FAFC).withOpacity(0.70),
                border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.1),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(-0.65, -0.65),
                            radius: 1.0,
                            colors: [
                              Colors.white.withOpacity(0.85),
                              Colors.white.withOpacity(0.18),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      icon,
                      size: 20,
                      color: const Color(0xFF2D1B69).withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HERO MINI WIDGETS
// ─────────────────────────────────────────────────────────────

class _MiniHeroPuck extends StatelessWidget {
  final IconData icon;
  const _MiniHeroPuck({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 12,
      shadowColor: Colors.black.withOpacity(0.16),
      shape: const CircleBorder(),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: 56, // ✅ slightly smaller
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF8FAFC).withOpacity(0.66),
              border: Border.all(color: Colors.white.withOpacity(0.86), width: 1.1),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: const Alignment(-0.65, -0.65),
                          radius: 1.0,
                          colors: [
                            Colors.white.withOpacity(0.90),
                            Colors.white.withOpacity(0.18),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    icon,
                    size: 24, // ✅ slightly smaller
                    color: const Color(0xFF7C3AED).withOpacity(0.85),
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

class _GlassTag extends StatelessWidget {
  final String text;
  const _GlassTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: const Color(0xFFF8FAFC).withOpacity(0.48),
            border: Border.all(color: Colors.white.withOpacity(0.75), width: 1),
          ),
          child: Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 9.6, // ✅ smaller
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2D1B69).withOpacity(0.75),
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniGlassIcon extends StatelessWidget {
  final IconData icon;
  const _MiniGlassIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF8FAFC).withOpacity(0.48),
            border: Border.all(color: Colors.white.withOpacity(0.75), width: 1),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF2D1B69).withOpacity(0.65)),
        ),
      ),
    );
  }
}

class _GlassPrimaryPill extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _GlassPrimaryPill({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      downScale: 0.975,
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF3ECFF).withOpacity(0.95),
                  const Color(0xFFEAF3FF).withOpacity(0.90),
                ],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.80), width: 1.2),
            ),
            child: Text(
              text,
              style: GoogleFonts.manrope(
                fontSize: 12.4,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2D1B69),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassSecondaryPill extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _GlassSecondaryPill({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      downScale: 0.975,
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: const Color(0xFFF8FAFC).withOpacity(0.48),
              border: Border.all(color: Colors.white.withOpacity(0.80), width: 1.2),
            ),
            child: Text(
              text,
              style: GoogleFonts.manrope(
                fontSize: 12.4,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2D1B69).withOpacity(0.78),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// INTERACTIVE GLASS CARD (NO HOVER, press-only)
// ✅ Reduced density: smaller title/meta + simpler button label
// ─────────────────────────────────────────────────────────────

class _InteractiveGlassCard extends StatelessWidget {
  final double width;
  final double height;
  final Color borderBase;
  final Color borderActive;
  final Color tint;
  final Color tint2;
  final Color accentA;
  final Color accentB;
  final bool isPromoted;
  final VoidCallback onTap;

  const _InteractiveGlassCard({
    required this.width,
    required this.height,
    required this.borderBase,
    required this.borderActive,
    required this.tint,
    required this.tint2,
    required this.accentA,
    required this.accentB,
    required this.isPromoted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      downScale: 0.975,
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                  child: const SizedBox.expand(),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        tint.withOpacity(0.62),
                        tint2.withOpacity(0.52),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 26,
                        offset: const Offset(0, 14),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.70),
                        blurRadius: 22,
                        offset: const Offset(-10, -10),
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: borderBase.withOpacity(0.95), width: 1.3),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.all(1.2),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.5),
                        border: Border.all(color: Colors.white.withOpacity(0.65), width: 1),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.75),
                          Colors.white.withOpacity(0.18),
                          Colors.white.withOpacity(0.02),
                        ],
                        stops: const [0.0, 0.40, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentA.withOpacity(0.95),
                        accentB.withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, c) {
                  const padTop = 12.0;
                  const padBottom = 12.0;
                  const padH = 14.0;

                  const topRowH = 42.0;
                  const bottomRowH = 36.0;

                  final middleMaxH =
                  (c.maxHeight - padTop - padBottom - topRowH - bottomRowH)
                      .clamp(26.0, 84.0);

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(padH, padTop, padH, padBottom),
                    child: Column(
                      children: [
                        SizedBox(
                          height: topRowH,
                          child: Row(
                            children: [
                              _SoftIconBubble(icon: Icons.store_rounded, border: borderBase),
                              const Spacer(),
                              if (isPromoted)
                                _SoftBadge(
                                  text: "SPONSORED",
                                  a: accentA,
                                  b: accentB,
                                  border: borderBase,
                                ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: middleMaxH,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Urban Style Store",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize: 14.6,
                                  fontWeight: FontWeight.w900,
                                  height: 1.10,
                                  color: const Color(0xFF1B1E2B),
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Fast delivery • 4.8 ★",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize: 11.8,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                  color: const Color(0xFF1B1E2B).withOpacity(0.58),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: bottomRowH,
                          child: Row(
                            children: [
                              _SoftGlassPillButton(text: "Open", border: borderBase),
                              const Spacer(),
                              Text(
                                "2.3 km",
                                style: GoogleFonts.manrope(
                                  fontSize: 11.8,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1B1E2B).withOpacity(0.52),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftIconBubble extends StatelessWidget {
  final Color border;
  final IconData icon;
  const _SoftIconBubble({required this.border, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF8FAFC).withOpacity(0.55),
            border: Border.all(color: border.withOpacity(0.9), width: 1),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: const Color(0xFF2D1B69).withOpacity(0.65)),
        ),
      ),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  final String text;
  final Color a;
  final Color b;
  final Color border;

  const _SoftBadge({
    required this.text,
    required this.a,
    required this.b,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(colors: [a.withOpacity(0.85), b.withOpacity(0.85)]),
            border: Border.all(color: border.withOpacity(0.85), width: 1),
          ),
          child: Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 9.6, // ✅ smaller
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2D1B69),
              letterSpacing: 0.7,
            ),
          ),
        ),
      ),
    );
  }
}

class _SoftGlassPillButton extends StatelessWidget {
  final String text;
  final Color border;
  const _SoftGlassPillButton({required this.text, required this.border});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: const Color(0xFFF8FAFC).withOpacity(0.50),
            border: Border.all(color: border.withOpacity(0.9), width: 1),
          ),
          child: Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 11.6, // ✅ smaller
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2D1B69).withOpacity(0.72),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CATEGORY TILE (NO HOVER — press-only)
// ✅ text slightly smaller
// ─────────────────────────────────────────────────────────────

class _CategoryGlassTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _CategoryGlassTile({
    required this.name,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const baseBorder = Color(0xFFD7ECFF);

    return _PressScale(
      downScale: 0.972,
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: const SizedBox.expand(),
              ),
            ),
            Container(
              width: 108,
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: const Color(0xFFF8FAFC).withOpacity(0.58),
                border: Border.all(color: baseBorder.withOpacity(0.95), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.75),
                    blurRadius: 18,
                    offset: const Offset(-8, -8),
                    spreadRadius: -10,
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
                              Colors.white.withOpacity(0.12),
                              Colors.white.withOpacity(0.02),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _IconPuck3D(icon: icon, accent: accent),
                      const SizedBox(height: 6),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 12.2, // ✅ smaller
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1B1E2B).withOpacity(0.80),
                        ),
                      ),
                    ],
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

class _IconPuck3D extends StatelessWidget {
  final IconData icon;
  final Color accent;

  const _IconPuck3D({
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -7),
      child: Material(
        color: Colors.transparent,
        elevation: 9,
        shadowColor: Colors.black.withOpacity(0.16),
        shape: const CircleBorder(),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF8FAFC).withOpacity(0.66),
                border: Border.all(color: Colors.white.withOpacity(0.82), width: 1.1),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(-0.6, -0.6),
                            radius: 1.0,
                            colors: [
                              Colors.white.withOpacity(0.88),
                              Colors.white.withOpacity(0.18),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.48, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              accent.withOpacity(0.12),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      icon,
                      size: 24,
                      color: accent.withOpacity(0.90),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// NEARBY ROW CARD (press-only, premium)
// ✅ slightly smaller typography for tags
// ─────────────────────────────────────────────────────────────

class _NearbyGlassRowCard extends StatelessWidget {
  final String name;
  final String distance;
  final String rating;
  final VoidCallback onTap;

  const _NearbyGlassRowCard({
    required this.name,
    required this.distance,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      downScale: 0.982,
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: const SizedBox.expand(),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: const Color(0xFFF8FAFC).withOpacity(0.58),
                border: Border.all(color: Colors.white.withOpacity(0.80), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 22,
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
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.72),
                              Colors.white.withOpacity(0.16),
                              Colors.white.withOpacity(0.02),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _RowIconPuck(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                fontSize: 15.4, // ✅ smaller
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF2D1B69),
                                letterSpacing: -0.25,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _InfoTag(icon: Icons.location_on_rounded, text: distance),
                                const _InfoTag(icon: Icons.access_time_rounded, text: "Open"),
                                _RatingTag(text: "$rating ★"),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      _ChevronOrb(),
                    ],
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

class _RowIconPuck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.16),
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFFF8FAFC).withOpacity(0.66),
              border: Border.all(color: Colors.white.withOpacity(0.84), width: 1.1),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.75),
                            Colors.white.withOpacity(0.14),
                            Colors.white.withOpacity(0.02),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    Icons.storefront_rounded,
                    color: const Color(0xFF7C3AED).withOpacity(0.85),
                    size: 28,
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

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoTag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), // ✅ slightly smaller
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.40),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.75), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: Colors.black.withOpacity(0.62)),
              const SizedBox(width: 5),
              Text(
                text,
                style: GoogleFonts.manrope(
                  fontSize: 10.8, // ✅ smaller
                  fontWeight: FontWeight.w800,
                  color: Colors.black.withOpacity(0.70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingTag extends StatelessWidget {
  final String text;
  const _RatingTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), // ✅ smaller
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 12, color: const Color(0xFFF59E0B).withOpacity(0.85)),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 10.8, // ✅ smaller
              fontWeight: FontWeight.w900,
              color: const Color(0xFFF59E0B).withOpacity(0.92),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChevronOrb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.14),
      shape: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF8FAFC).withOpacity(0.56),
          border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.1),
        ),
        child: Center(
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: const Color(0xFF7C3AED).withOpacity(0.82),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// FESTIVAL BANNER (press-only)
// ─────────────────────────────────────────────────────────────

class _GlassBannerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String percent;
  final IconData icon;
  final VoidCallback onTap;

  const _GlassBannerCard({
    required this.title,
    required this.subtitle,
    required this.percent,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      downScale: 0.987,
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
                child: const SizedBox.expand(),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFFF8FAFC).withOpacity(0.58),
                border: Border.all(color: Colors.white.withOpacity(0.72), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.72),
                              Colors.white.withOpacity(0.18),
                              Colors.white.withOpacity(0.04),
                            ],
                            stops: const [0.0, 0.38, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFCEB8FF).withOpacity(0.16),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PercentBubble(percent: percent),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const _GlassTag(text: "LIMITED TIME"),
                                const Spacer(),
                                _MiniGlassIcon(icon: icon),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              title,
                              style: GoogleFonts.manrope(
                                fontSize: 16.8, // ✅ slightly smaller
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF2D1B69),
                                letterSpacing: -0.35,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                fontSize: 12.6, // ✅ smaller
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D1B69).withOpacity(0.62),
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _PercentBubble extends StatelessWidget {
  final String percent;
  const _PercentBubble({required this.percent});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 62, // ✅ slightly smaller
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF8FAFC).withOpacity(0.55),
            border: Border.all(color: Colors.white.withOpacity(0.75), width: 1.2),
          ),
          alignment: Alignment.center,
          child: Text(
            percent,
            style: GoogleFonts.manrope(
              fontSize: 18.5, // ✅ smaller
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2D1B69),
            ),
          ),
        ),
      ),
    );
  }
}
