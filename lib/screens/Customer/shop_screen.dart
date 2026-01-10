import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qds/screens/Customer/product_screen.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';

/// ✅ SHOP SCREEN — Aligned with YOUR theme
/// - No hover-only behavior
/// - Press/click zoom + glow (mobile + web)
/// - Keeps ambient animations + entrance + focus zoom
/// - Uses AppColors/AppRadius/AppShadows/AppText ONLY
class ShopScreen extends StatefulWidget {
  final String shopName;

  const ShopScreen({
    super.key,
    required this.shopName,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with TickerProviderStateMixin {
  // Page entrance
  late final AnimationController _pageCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  // Ambient background
  late final AnimationController _ambientCtrl;
  late final Animation<double> _bgT;
  late final Animation<double> _floatT;

  // Focus zoom (search focus)
  late final AnimationController _focusCtrl;
  late final Animation<double> _focusZoom;
  late final Animation<double> _focusLift;

  // CTA press controller
  late final AnimationController _btnCtrl;
  late final Animation<double> _btnPress;

  final searchCtrl = TextEditingController();
  final searchFocus = FocusNode();

  int selectedCategory = 0;

  final categories = const [
    "All",
    "Men",
    "Women",
    "Shoes",
    "Accessories",
  ];

  @override
  void initState() {
    super.initState();

    _pageCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOutCubic));

    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    )..repeat(reverse: true);

    _bgT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOut);
    _floatT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOutSine);

    _focusCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _focusZoom = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _focusCtrl, curve: Curves.easeOutCubic),
    );
    _focusLift = Tween<double>(begin: 0.0, end: -8.0).animate(
      CurvedAnimation(parent: _focusCtrl, curve: Curves.easeOutCubic),
    );

    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );

    _btnPress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOut),
    );

    searchFocus.addListener(_onFocusChange);

    _pageCtrl.forward();
  }

  void _onFocusChange() {
    if (searchFocus.hasFocus) {
      _focusCtrl.forward();
    } else {
      _focusCtrl.reverse();
    }
    setState(() {});
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    searchFocus.removeListener(_onFocusChange);
    searchFocus.dispose();

    _pageCtrl.dispose();
    _ambientCtrl.dispose();
    _focusCtrl.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bg3,
      body: Stack(
        children: [
          _animatedThemeBackground(),

          // ✅ Glow blobs (theme colors)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _ambientCtrl,
              builder: (context, _) {
                final t = _floatT.value;
                return Stack(
                  children: [
                    _GlowBlob(
                      dx: lerpDouble(-50, 20, t)!,
                      dy: lerpDouble(80, 55, t)!,
                      size: 240,
                      opacity: 0.14,
                      a: AppColors.secondary,
                      b: AppColors.other,
                    ),
                    _GlowBlob(
                      dx: lerpDouble(220, 290, t)!,
                      dy: lerpDouble(220, 190, t)!,
                      size: 280,
                      opacity: 0.10,
                      a: AppColors.primary,
                      b: AppColors.secondary,
                    ),
                    _GlowBlob(
                      dx: lerpDouble(205, 260, 1 - t)!,
                      dy: lerpDouble(18, 30, t)!,
                      size: 210,
                      opacity: 0.09,
                      a: AppColors.other,
                      b: AppColors.secondary,
                    ),
                  ],
                );
              },
            ),
          ),

          // ✅ Banner
          _shopBanner(),

          // ✅ Content
          _content(topInset),

          // ✅ Mini header
          _topMiniHeader(context),
        ],
      ),
    );
  }

  // ───────────────────────── Background ─────────────────────────

  Widget _animatedThemeBackground() {
    return AnimatedBuilder(
      animation: _ambientCtrl,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(AppColors.bg3, AppColors.bg2, _bgT.value)!,
                Color.lerp(AppColors.bg2, AppColors.bg1, _bgT.value)!,
                AppColors.bg1,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────── Top mini header ─────────────────────────

  Widget _topMiniHeader(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topInset + 10,
      left: 14,
      right: 14,
      child: Row(
        children: [
          _PressGlowScale(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(999),
            glowColor: AppColors.secondary.withOpacity(0.16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.borderBase(0.85)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.ink),
                  const SizedBox(width: 8),
                  Text(
                    "Back",
                    style: GoogleFonts.manrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Center(
              child: _Welcome3DTitleCentered(
                text: widget.shopName.toUpperCase(),
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _PressGlowScale(
            onTap: () {},
            glowColor: AppColors.other.withOpacity(0.14),
            borderRadius: BorderRadius.circular(18),
            child: _GlassIconPuck(
              icon: Icons.share_outlined,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Banner ─────────────────────────

  Widget _shopBanner() {
    return SizedBox(
      height: 270,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            child: Image.network(
              "https://images.unsplash.com/photo-1521334884684-d80222895322",
              fit: BoxFit.cover,
            ),
          ),

          // overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.46),
                  Colors.black.withOpacity(0.18),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // glossy sheen
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.10),
                      Colors.white.withOpacity(0.00),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // bottom blend to bg
          Positioned(
            left: 0,
            right: 0,
            bottom: -1,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.bg3.withOpacity(0.92),
                    AppColors.bg3,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Content ─────────────────────────

  Widget _content(double topInset) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(top: 210, bottom: 22 + topInset * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shopInfo(),
              const SizedBox(height: 16),

              AnimatedBuilder(
                animation: _focusCtrl,
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset(0, _focusLift.value),
                    child: Transform.scale(
                      scale: _focusZoom.value,
                      child: _search(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),
              _categoryChips(),
              const SizedBox(height: 18),

              _sectionHeader(
                title: "Featured products",
                subtitle: "Popular picks from this shop",
                actionText: "See all",
                onAction: () {},
              ),
              const SizedBox(height: 12),
              _products(),

              const SizedBox(height: 18),
              _sectionHeader(
                title: "Customer reviews",
                subtitle: "What people say about this shop",
                actionText: "Write review",
                onAction: () {},
              ),
              const SizedBox(height: 12),
              _reviews(),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _Shiny3DButton(
                  controller: _btnCtrl,
                  pressT: _btnPress,
                  text: "Browse all products",
                  onPressed: () async {
                    await _btnCtrl.forward();
                    await _btnCtrl.reverse();
                  },
                ),
              ),

              const SizedBox(height: 26),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.h2().copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppText.body().copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _PressGlowScale(
            onTap: onAction,
            downScale: 0.96,
            borderRadius: BorderRadius.circular(999),
            glowColor: AppColors.secondary.withOpacity(0.12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                actionText,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Shop Info ─────────────────────────

  Widget _shopInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _GlassCard(
        floatingT: _floatT.value,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.shopName,
              style: AppText.h2().copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "25–35 min • 1.4 km away",
              style: AppText.body().copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                _InfoPill(
                  icon: Icons.star_rounded,
                  iconColor: Color(0xFFF59E0B),
                  text: "4.8",
                ),
                SizedBox(width: 10),
                _InfoPill(
                  icon: Icons.schedule_rounded,
                  iconColor: Color(0xFF10B981),
                  text: "Open now",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Search ─────────────────────────

  Widget _search() {
    final focused = searchFocus.hasFocus;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: AppRadius.r18,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(focused ? 0.64 : 0.56),
              borderRadius: AppRadius.r18,
              border: Border.all(
                color: focused
                    ? AppColors.secondary.withOpacity(0.38)
                    : AppColors.borderBase(0.85),
                width: focused ? 1.2 : 1.0,
              ),
              boxShadow: focused
                  ? [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                )
              ]
                  : AppShadows.soft,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppColors.ink.withOpacity(0.65),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    focusNode: searchFocus,
                    controller: searchCtrl,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search in shop",
                      hintStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted.withOpacity(0.95),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _PressGlowScale(
                  onTap: () {},
                  downScale: 0.94,
                  glowColor: AppColors.secondary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                  child: _GlassIconPuck(
                    icon: Icons.tune_rounded,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── Categories ─────────────────────────

  Widget _categoryChips() {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final active = i == selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _PressGlowScale(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => selectedCategory = i);
              },
              downScale: 0.965,
              glowColor: active
                  ? AppColors.secondary.withOpacity(0.16)
                  : AppColors.secondary.withOpacity(0.08),
              borderRadius: AppRadius.r22,
              child: ClipRRect(
                borderRadius: AppRadius.r22,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.r22,
                      gradient: active
                          ? AppColors.brandLinear
                          : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.62),
                          Colors.white.withOpacity(0.46),
                        ],
                      ),
                      border: Border.all(
                        color: active
                            ? Colors.white.withOpacity(0.22)
                            : AppColors.borderBase(0.85),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(active ? 0.14 : 0.06),
                          blurRadius: active ? 16 : 12,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Text(
                      categories[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: active ? Colors.white : AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ───────────────────────── Products ─────────────────────────

  Widget _products() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, i) => _productCard(context, i),
      ),
    );
  }

  Widget _productCard(BuildContext context, int index) {
    final items = const [
      ("Classic Watch", "Rs. 4,999",
      "https://images.unsplash.com/photo-1523275335684-37898b6baf30"),
      ("Urban Hoodie", "Rs. 3,499",
      "https://images.unsplash.com/photo-1520975958225-9e2e7f1b7a0a"),
      ("Leather Wallet", "Rs. 1,299",
      "https://images.unsplash.com/photo-1522312346375-d1a52e2b99b3"),
      ("Sneakers Pro", "Rs. 6,799",
      "https://images.unsplash.com/photo-1542291026-7eec264c27ff"),
      ("Denim Jacket", "Rs. 5,999",
      "https://images.unsplash.com/photo-1520975682311-781b54b85f34"),
      ("Minimal Backpack", "Rs. 2,899",
      "https://images.unsplash.com/photo-1542291026-7eec264c27ff"),
    ];

    final p = items[index % items.length];

    return _PressGlowScale(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductScreen(
              productName: p.$1,
              shopName: widget.shopName,
            ),
          ),
        );
      },
      downScale: 0.975,
      glowColor: AppColors.secondary.withOpacity(0.12),
      borderRadius: AppRadius.r18,
      child: ClipRRect(
        borderRadius: AppRadius.r18,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.58),
              borderRadius: AppRadius.r18,
              border: Border.all(color: AppColors.borderBase(0.85)),
              boxShadow: AppShadows.soft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(p.$3, fit: BoxFit.cover),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.12),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: _PressGlowScale(
                            onTap: () {},
                            downScale: 0.94,
                            glowColor: AppColors.other.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                            child: _GlassIconPuck(
                              icon: Icons.add_rounded,
                              onTap: () {},
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body().copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p.$2,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink.withOpacity(0.92),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── Reviews ─────────────────────────

  Widget _reviews() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _GlassCard(
        floatingT: _floatT.value,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "★★★★★  4.8",
              style: AppText.h2().copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Based on 320 reviews",
              style: AppText.body().copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 12),
            const _SoftDivider(),
            const SizedBox(height: 12),
            _reviewRow(
              name: "Hassan",
              text: "Fast delivery and great quality. The packaging was premium.",
              stars: 5,
            ),
            const SizedBox(height: 12),
            const _SoftDivider(),
            const SizedBox(height: 12),
            _reviewRow(
              name: "Ayesha",
              text: "Loved the collection. Sizes were accurate and delivery was quick.",
              stars: 5,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: _PressGlowScale(
                onTap: () {},
                downScale: 0.96,
                glowColor: AppColors.secondary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Text(
                    "View all reviews",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink.withOpacity(0.92),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewRow({
    required String name,
    required String text,
    required int stars,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar3D(letter: name.substring(0, 1).toUpperCase(), size: 38),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: List.generate(
                      5,
                          (i) => Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: i < stars ? const Color(0xFFF59E0B) : const Color(0xFFD6D7DE),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                text,
                style: AppText.body().copyWith(
                  fontSize: 12.8,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ✅ Press Glow Scale (no hover)
// ============================================================================

class _PressGlowScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  final double downScale;
  final Duration duration;
  final BorderRadius borderRadius;

  final Color glowColor;
  final double glowBlur;
  final Offset glowOffset;

  const _PressGlowScale({
    required this.child,
    required this.onTap,
    this.downScale = 0.985,
    this.duration = const Duration(milliseconds: 140),
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.glowColor = const Color(0x226B7CFF),
    this.glowBlur = 22,
    this.glowOffset = const Offset(0, 14),
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
    final enabled = widget.onTap != null;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: enabled ? (_) => _setDown(true) : null,
      onTapUp: enabled ? (_) => _setDown(false) : null,
      onTapCancel: enabled ? () => _setDown(false) : null,
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
                color: widget.glowColor,
                blurRadius: widget.glowBlur,
                offset: widget.glowOffset,
              ),
            ]
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ============================================================================
// ✅ Helpers
// ============================================================================

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
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final floatY = sin(floatingT * pi * 2) * 3.0;

    return Transform.translate(
      offset: Offset(0, floatY),
      child: ClipRRect(
        borderRadius: AppRadius.r18,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: AppRadius.r18,
              border: Border.all(color: AppColors.borderBase(0.85)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.70),
                  Colors.white.withOpacity(0.46),
                ],
              ),
              boxShadow: AppShadows.soft,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.r18,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.55),
                            Colors.white.withOpacity(0.08),
                            Colors.transparent,
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

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _InfoPill({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.52),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.borderBase(0.85)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ✅ No hover. Press handled by wrapper.
class _GlassIconPuck extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool darkPuck;

  const _GlassIconPuck({
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.darkPuck = false,
  });

  @override
  State<_GlassIconPuck> createState() => _GlassIconPuckState();
}

class _GlassIconPuckState extends State<_GlassIconPuck> {
  bool _press = false;

  @override
  Widget build(BuildContext context) {
    final active = _press;
    final scale = _press ? 0.96 : 1.0;

    final bg = widget.darkPuck
        ? AppColors.ink.withOpacity(active ? 0.55 : 0.42)
        : Colors.white.withOpacity(active ? 0.70 : 0.58);

    final border = widget.darkPuck
        ? Colors.white.withOpacity(active ? 0.55 : 0.40)
        : AppColors.borderBase(active ? 0.95 : 0.85);

    final iconColor = widget.iconColor ??
        (widget.darkPuck ? Colors.white : AppColors.ink.withOpacity(0.75));

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _press = true),
      onTapUp: (_) => setState(() => _press = false),
      onTapCancel: () => setState(() => _press = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        scale: scale,
        child: Material(
          color: Colors.transparent,
          elevation: active ? 12 : 9,
          shadowColor: Colors.black.withOpacity(0.18),
          shape: const CircleBorder(),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bg,
                  border: Border.all(color: border, width: 1.1),
                ),
                child: Center(
                  child: Icon(widget.icon, size: 20, color: iconColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Welcome3DTitleCentered extends StatelessWidget {
  final String text;
  final double fontSize;
  const _Welcome3DTitleCentered({required this.text, this.fontSize = 22});

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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                  color: AppColors.secondary.withOpacity(0.14),
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
        color: Colors.white.withOpacity(0.70),
        border: Border.all(color: AppColors.borderBase(0.85)),
        boxShadow: AppShadows.soft,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: AppColors.ink,
        ),
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

class _Shiny3DButton extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> pressT;
  final String text;
  final VoidCallback onPressed;

  const _Shiny3DButton({
    required this.controller,
    required this.pressT,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = pressT.value; // 0..1
        final lift = lerpDouble(0, 3, 1 - t)!;
        final press = lerpDouble(0, 2.5, t)!;

        return GestureDetector(
          onTapDown: (_) => controller.forward(),
          onTapCancel: () => controller.reverse(),
          onTapUp: (_) => controller.reverse(),
          onTap: onPressed,
          child: Transform.translate(
            offset: Offset(0, -lift + press),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: AppRadius.r22,
                gradient: AppColors.brandLinear,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 18,
                    offset: Offset(0, 12 + press),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: AppRadius.r22,
                      child: Opacity(
                        opacity: 0.22,
                        child: Transform.rotate(
                          angle: -0.35,
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.55),
                                  Colors.white.withOpacity(0.0),
                                ],
                                stops: const [0.25, 0.5, 0.75],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
