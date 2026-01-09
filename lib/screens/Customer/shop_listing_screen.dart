import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';

/// ✅ Premium Shop Listing Screen (Nexora Theme)
/// - SAME login/signup premium glassmorphism + animated gradient + glow blobs
/// - NO hover animations (works identical on Mobile + Web)
/// - Press/Click zoom + “light-up” glow (mobile + web)
/// - Sticky centered glass header (no collision)
/// - Sort chips redesigned to light premium style
/// - Cards redesigned to premium, consistent typography + spacing
class ShopListingScreen extends StatefulWidget {
  final String category;

  const ShopListingScreen({
    super.key,
    required this.category,
  });

  @override
  State<ShopListingScreen> createState() => _ShopListingScreenState();
}

class _ShopListingScreenState extends State<ShopListingScreen> with TickerProviderStateMixin {
  // Page entrance
  late final AnimationController _pageCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  // Ambient background
  late final AnimationController _ambientCtrl;
  late final Animation<double> _bgT;
  late final Animation<double> _floatT;

  // Search (optional)
  final TextEditingController _searchCtrl = TextEditingController();
  bool _showSearch = false;

  // Sort selection
  int _activeSort = 0;

  // Layout constants
  static const double _capBaseH = 148.0;
  static const double _stickyHeaderH = 66.0;

  @override
  void initState() {
    super.initState();

    _pageCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 660),
    );

    _fade = CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOutCubic));

    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5600),
    )..repeat(reverse: true);

    _bgT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOut);
    _floatT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOutSine);

    _pageCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _ambientCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    // ✅ padding so content never collides with sticky header
    final contentTopPadding = _capBaseH + topInset + _stickyHeaderH + 14.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ✅ Nexora-style animated background (same as login/signup)
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

          // ✅ Soft haze overlay (premium atmosphere)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _ambientCtrl,
              builder: (context, _) {
                final t = _floatT.value;
                return Opacity(
                  opacity: 0.10,
                  child: Transform.translate(
                    offset: Offset(lerpDouble(-14, 14, t)!, lerpDouble(12, -10, t)!),
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

          // ✅ Glow blobs (premium Nexora feel)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _ambientCtrl,
              builder: (context, _) {
                final t = _floatT.value;
                return Stack(
                  children: [
                    _GlowBlob(
                      dx: lerpDouble(-45, 18, t)!,
                      dy: lerpDouble(78, 56, t)!,
                      size: 250,
                      opacity: 0.15,
                    ),
                    _GlowBlob(
                      dx: lerpDouble(220, 310, t)!,
                      dy: lerpDouble(240, 205, t)!,
                      size: 300,
                      opacity: 0.11,
                    ),
                    _GlowBlob(
                      dx: lerpDouble(140, 210, 1 - t)!,
                      dy: lerpDouble(36, 18, t)!,
                      size: 220,
                      opacity: 0.10,
                    ),
                  ],
                );
              },
            ),
          ),

          // ✅ Top cap (same family as your other screens)
          Positioned(
            top: -topInset,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _HeaderCapClipper(),
              child: Container(
                height: _capBaseH + topInset,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.92),
                      Colors.white.withOpacity(0.58),
                      Colors.white.withOpacity(0.12),
                    ],
                    stops: const [0.0, 0.62, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.035),
                      blurRadius: 44,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ✅ Page content (pushed down)
          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14, contentTopPadding, 14, 16),
                  child: Column(
                    children: [
                      // Search bar (optional)
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 220),
                        crossFadeState: _showSearch ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                        firstChild: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SearchGlassField(
                            controller: _searchCtrl,
                            hint: "Search shops in ${widget.category}",
                            onChanged: (v) => setState(() {}),
                            onClear: () => setState(() => _searchCtrl.clear()),
                          ),
                        ),
                        secondChild: const SizedBox.shrink(),
                      ),

                      _sortBar(),
                      const SizedBox(height: 10),

                      Expanded(child: _list()),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ✅ Sticky centered header (glass, click animation, no hover)
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
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(14),
                child: const _GlassIconSquare(icon: Icons.arrow_back_rounded),
              ),
            ),

            // ✅ Center title (3D)
            _Title3DCentered(text: widget.category.toUpperCase(), fontSize: 20),

            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PressGlowScale(
                    onTap: () => setState(() => _showSearch = !_showSearch),
                    borderRadius: BorderRadius.circular(14),
                    child: _GlassIconSquare(icon: _showSearch ? Icons.close_rounded : Icons.search_rounded),
                  ),
                  const SizedBox(width: 10),
                  _PressGlowScale(
                    onTap: () => _openFilters(context),
                    borderRadius: BorderRadius.circular(14),
                    child: const _GlassIconSquare(icon: Icons.tune_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────── Sort Bar (premium light chips) ─────────────────────

  Widget _sortBar() {
    final sorts = [
      _SortItem("Nearest", Icons.near_me_rounded),
      _SortItem("Fastest", Icons.bolt_rounded),
      _SortItem("Popular", Icons.star_rounded),
      _SortItem("Top Rated", Icons.verified_rounded),
    ];

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: sorts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final active = i == _activeSort;

          return _PressGlowScale(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _activeSort = i);
            },
            borderRadius: BorderRadius.circular(AppRadius.r22),
            downScale: 0.988,
            glowOpacity: 0.10,
            child: _GlassChoiceChip(
              label: sorts[i].label,
              icon: sorts[i].icon,
              active: active,
            ),
          );
        },
      ),
    );
  }

  // ───────────────────── List ─────────────────────

  Widget _list() {
    final query = _searchCtrl.text.trim().toLowerCase();

    final shops = <_ShopData>[
      const _ShopData("Urban Style Store", "1.2 km", "25–35 min", "4.8", true),
      const _ShopData("Boutique Central", "2.4 km", "20–30 min", "4.6", true),
      const _ShopData("Style Gallery", "0.9 km", "18–28 min", "4.9", true),
      const _ShopData("Trendy Emporium", "3.1 km", "30–40 min", "4.4", true),
      const _ShopData("Modern Wear House", "1.7 km", "22–32 min", "4.7", true),
      const _ShopData("Luxury Lane", "2.9 km", "28–38 min", "4.5", true),
      const _ShopData("Streetwear Point", "1.1 km", "19–29 min", "4.8", true),
      const _ShopData("Classic Corner", "0.7 km", "16–24 min", "4.3", true),
    ];

    final filtered = query.isEmpty
        ? shops
        : shops.where((s) => s.name.toLowerCase().contains(query)).toList();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 18),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _shopCard(filtered[i], i),
    );
  }

  Widget _shopCard(_ShopData data, int index) {
    return _PressGlowScale(
      onTap: () {
        HapticFeedback.lightImpact();
        // ✅ Keep your route logic here.
        // Navigator.push(context, MaterialPageRoute(builder: (_) => ShopScreen(...)));
      },
      borderRadius: BorderRadius.circular(AppRadius.r18),
      downScale: 0.992,
      glowOpacity: 0.12,
      child: _PremiumShopCard(
        data: data,
        accent: _accentForIndex(index),
        floatingT: _floatT.value,
      ),
    );
  }

  Color _accentForIndex(int i) {
    const accents = [
      Color(0xFF6B7CFF), // indigo
      Color(0xFFFF6BD6), // pink
      Color(0xFF7EDCFF), // sky
      Color(0xFFCEB8FF), // lavender
      Color(0xFF10B981), // green
      Color(0xFFF59E0B), // amber
    ];
    return accents[i % accents.length];
  }

  // ───────────────────── Filters ─────────────────────

  void _openFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _FiltersSheetGlass(),
    );
  }
}

// ============================================================================
// ✅ Premium Shop Card
// ============================================================================

class _PremiumShopCard extends StatelessWidget {
  final _ShopData data;
  final Color accent;
  final double floatingT;

  const _PremiumShopCard({
    required this.data,
    required this.accent,
    required this.floatingT,
  });

  @override
  Widget build(BuildContext context) {
    final floatY = sin(floatingT * pi * 2) * 1.8;

    return Transform.translate(
      offset: Offset(0, floatY),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.r18),
        child: Stack(
          children: [
            // blur base
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: const SizedBox.expand(),
              ),
            ),

            // card surface
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.r18),
                color: Colors.white.withOpacity(0.58),
                border: Border.all(color: Colors.white.withOpacity(0.70), width: 1.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 20,
                    offset: const Offset(0, 14),
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
                              Colors.white.withOpacity(0.72),
                              Colors.white.withOpacity(0.14),
                              Colors.white.withOpacity(0.02),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // accent blob inside card
                  Positioned(
                    right: -40,
                    top: -50,
                    child: IgnorePointer(
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withOpacity(0.12),
                        ),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      _ShopIconTile(accent: accent),
                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // title
                            _Title3DInline(
                              text: data.name,
                              fontSize: 14.6,
                              fontWeight: FontWeight.w900,
                            ),
                            const SizedBox(height: 7),

                            // meta pills
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _MetaPill(
                                  icon: Icons.location_on_rounded,
                                  text: data.distance,
                                  tint: const Color(0xFF1E2235),
                                ),
                                _MetaPill(
                                  icon: Icons.access_time_rounded,
                                  text: data.eta,
                                  tint: const Color(0xFF1E2235),
                                ),
                                _MetaPill(
                                  icon: Icons.star_rounded,
                                  text: "${data.rating} ★",
                                  tint: const Color(0xFFF59E0B),
                                  fill: const Color(0xFFFFF2D6),
                                ),
                                _MetaPill(
                                  icon: Icons.check_circle_rounded,
                                  text: data.openNow ? "Open now" : "Closed",
                                  tint: data.openNow ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                  fill: data.openNow
                                      ? const Color(0xFFECFDF5)
                                      : const Color(0xFFFEE2E2),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // subtle CTA row
                            Row(
                              children: [
                                _SoftCTA(accent: accent, text: "View shop"),
                                const Spacer(),
                                Icon(Icons.chevron_right_rounded,
                                    color: const Color(0xFF1E2235).withOpacity(0.55)),
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
    );
  }
}

class _ShopIconTile extends StatelessWidget {
  final Color accent;
  const _ShopIconTile({required this.accent});

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
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.58),
              border: Border.all(color: Colors.white.withOpacity(0.78), width: 1.0),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: RadialGradient(
                          center: const Alignment(-0.55, -0.55),
                          radius: 1.0,
                          colors: [
                            Colors.white.withOpacity(0.85),
                            Colors.white.withOpacity(0.18),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.52, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
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
                    Icons.storefront_rounded,
                    size: 30,
                    color: accent.withOpacity(0.88),
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

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color tint;
  final Color? fill;

  const _MetaPill({
    required this.icon,
    required this.text,
    required this.tint,
    this.fill,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: (fill ?? Colors.white).withOpacity(fill == null ? 0.46 : 0.85),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.75), width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: tint.withOpacity(0.85)),
              const SizedBox(width: 5),
              Text(
                text,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: tint.withOpacity(0.80),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftCTA extends StatelessWidget {
  final Color accent;
  final String text;
  const _SoftCTA({required this.accent, required this.text});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFF3ECFF).withOpacity(0.92),
                const Color(0xFFEAF3FF).withOpacity(0.90),
              ],
            ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.82), width: 1.1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_forward_rounded, size: 14, color: accent.withOpacity(0.85)),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2D1B69),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ✅ Glass Sort Chip
// ============================================================================

class _GlassChoiceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;

  const _GlassChoiceChip({
    required this.label,
    required this.icon,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final fg = active ? const Color(0xFF2D1B69) : const Color(0xFF1E2235);
    final bgA = active ? const Color(0xFFEDE2FF) : const Color(0xFFF8FAFC);
    final bgB = active ? const Color(0xFFEAF3FF) : const Color(0xFFF8FAFC);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.r22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.r22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                bgA.withOpacity(active ? 0.92 : 0.62),
                bgB.withOpacity(active ? 0.90 : 0.54),
              ],
            ),
            border: Border.all(
              color: active ? const Color(0xFF9EC9FF).withOpacity(0.65) : Colors.white.withOpacity(0.72),
              width: 1.15,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(active ? 0.10 : 0.06),
                blurRadius: active ? 16 : 12,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.75),
                blurRadius: 14,
                offset: const Offset(-8, -8),
                spreadRadius: -10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: fg.withOpacity(0.85)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: fg.withOpacity(0.92),
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ✅ Filters Sheet (updated: light premium; no hover)
// ============================================================================

class _FiltersSheetGlass extends StatefulWidget {
  const _FiltersSheetGlass();

  @override
  State<_FiltersSheetGlass> createState() => _FiltersSheetGlassState();
}

class _FiltersSheetGlassState extends State<_FiltersSheetGlass> {
  int dist = 0;
  int rate = 0;
  int price = 0;
  bool openNow = true;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10 + bottom),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.60),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: Colors.white.withOpacity(0.70), width: 1.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 28,
                    offset: const Offset(0, -12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _handle(),
                  const SizedBox(height: 14),

                  const _Title3DInline(
                    text: "Filters",
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),

                  _section("Distance"),
                  _segmented(
                    items: const ["< 2 km", "2–5 km", "5+ km"],
                    active: dist,
                    onChange: (v) => setState(() => dist = v),
                  ),

                  _section("Rating"),
                  _segmented(
                    items: const ["4★+", "3★+", "All"],
                    active: rate,
                    onChange: (v) => setState(() => rate = v),
                  ),

                  _section("Price range"),
                  _segmented(
                    items: const ["₨", "₨₨", "₨₨₨"],
                    active: price,
                    onChange: (v) => setState(() => price = v),
                  ),

                  const SizedBox(height: 14),
                  _toggleRow(),

                  const SizedBox(height: 16),

                  _PressGlowScale(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(AppRadius.r22),
                    downScale: 0.988,
                    glowOpacity: 0.14,
                    child: _PrimaryGlassButtonLight(
                      text: "Apply filters",
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

  Widget _handle() {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFF1E2235).withOpacity(0.12),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF7A7E92).withOpacity(0.95),
        ),
      ),
    );
  }

  Widget _segmented({
    required List<String> items,
    required int active,
    required ValueChanged<int> onChange,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(items.length, (i) {
        final isActive = i == active;

        return _PressGlowScale(
          onTap: () {
            HapticFeedback.selectionClick();
            onChange(i);
          },
          borderRadius: BorderRadius.circular(999),
          downScale: 0.988,
          glowOpacity: 0.10,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: isActive
                      ? const Color(0xFFEDE2FF).withOpacity(0.92)
                      : Colors.white.withOpacity(0.52),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF9EC9FF).withOpacity(0.65)
                        : Colors.white.withOpacity(0.72),
                    width: 1.05,
                  ),
                ),
                child: Text(
                  items[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E2235).withOpacity(isActive ? 0.92 : 0.82),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _toggleRow() {
    return Row(
      children: [
        Switch(
          value: openNow,
          onChanged: (v) => setState(() => openNow = v),
        ),
        const SizedBox(width: 8),
        const Text(
          "Open now",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E2235),
          ),
        ),
      ],
    );
  }
}

class _PrimaryGlassButtonLight extends StatelessWidget {
  final String text;
  const _PrimaryGlassButtonLight({required this.text});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.r22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 52,
          width: double.infinity,
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
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF2D1B69),
              fontSize: 14.5,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ✅ Search Field (Premium Glass)
// ============================================================================

class _SearchGlassField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchGlassField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.r22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.62),
            borderRadius: BorderRadius.circular(AppRadius.r22),
            border: Border.all(color: Colors.white.withOpacity(0.74), width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: const Color(0xFF1E2235).withOpacity(0.60)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E2235),
                    fontSize: 13.5,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF7A7E92).withOpacity(0.85),
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (controller.text.isNotEmpty)
                _PressGlowScale(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onClear();
                    onChanged("");
                  },
                  borderRadius: BorderRadius.circular(12),
                  downScale: 0.95,
                  glowOpacity: 0.10,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.72),
                      border: Border.all(color: Colors.white.withOpacity(0.78)),
                    ),
                    child: Icon(Icons.close_rounded, color: const Color(0xFF1E2235).withOpacity(0.65)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ✅ Small reusable helpers (NO hover, press only)
// ============================================================================

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

class _GlassHeaderShell extends StatelessWidget {
  final Widget child;
  final double height;

  const _GlassHeaderShell({
    required this.child,
    required this.height,
  });

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
                const Color(0xFF7EDCFF).withOpacity(opacity * 0.72),
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

class _Title3DCentered extends StatelessWidget {
  final String text;
  final double fontSize;

  const _Title3DCentered({
    required this.text,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (int i = 10; i >= 1; i--)
          Transform.translate(
            offset: Offset(0, i.toDouble() * 0.8),
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
                color: Colors.black.withOpacity(0.050),
              ),
            ),
          ),
        Text(
          text,
          style: TextStyle(
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

class _Title3DInline extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  const _Title3DInline({
    required this.text,
    required this.fontSize,
    required this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    const base = Color(0xFF1B1E2B);

    // same 3D letter trick but inline widget
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

// ============================================================================
// Top cap clipper (same shape system-wide)
// ============================================================================

class _HeaderCapClipper extends CustomClipper<Path> {
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

// ============================================================================
// Small models
// ============================================================================

class _SortItem {
  final String label;
  final IconData icon;
  const _SortItem(this.label, this.icon);
}

class _ShopData {
  final String name;
  final String distance;
  final String eta;
  final String rating;
  final bool openNow;
  const _ShopData(this.name, this.distance, this.eta, this.rating, this.openNow);
}
