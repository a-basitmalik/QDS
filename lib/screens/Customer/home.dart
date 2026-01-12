import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ Add this dependency in pubspec.yaml if not already:
// google_maps_flutter: ^2.6.1
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:qds/screens/Customer/profile_screen.dart';
import 'package:qds/screens/Customer/shop_listing_screen.dart';
import 'package:qds/screens/Customer/shop_screen.dart';
import 'package:qds/screens/Customer/ai_outfit/ai_outfit.dart';
import 'package:qds/screens/Customer/wardrobe/wardrobe_interior_screen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class ShopCardData {
  final String name;
  final String meta;
  final String image;
  final bool isAd;
  final String? offer;
  final String? pro;

  const ShopCardData({
    required this.name,
    required this.meta,
    required this.image,
    this.isAd = false,
    this.offer,
    this.pro,
  });
}

class CardMedia {
  final String bg;
  const CardMedia({required this.bg});
}

bool _isNetwork(String s) => s.startsWith('http://') || s.startsWith('https://');

Widget _img(String path, {BoxFit fit = BoxFit.cover}) {
  return _isNetwork(path)
      ? Image.network(path, fit: fit, errorBuilder: (_, __, ___) => const SizedBox())
      : Image.asset(path, fit: fit, errorBuilder: (_, __, ___) => const SizedBox());
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Ambient BG
  late final AnimationController _ambientCtrl;
  late final Animation<double> _bgT;
  late final Animation<double> _floatT;

  // ✅ Location state
  SelectedLocation? _selectedLocation;
  final List<SelectedLocation> _savedLocations = const [
    SelectedLocation(label: "Home", latLng: LatLng(31.5204, 74.3587)),
    SelectedLocation(label: "Office", latLng: LatLng(24.8607, 67.0011)),
  ];

  // ✅ LIGHT THEME + YOUR COLORS
  static const _primary = Color(0xFF440C08);
  static const _secondary = Color(0xFF750A03);
  static const _other = Color(0xFF9B0F03);

  static const _bg1 = Color(0xFFF9F6F5);
  static const _bg2 = Color(0xFFF4EEED);
  static const _bg3 = Color(0xFFFFFFFF);
  static const _ink = Color(0xFF140504);

  TextStyle _subtle() => GoogleFonts.manrope(
    fontSize: 12.6,
    fontWeight: FontWeight.w700,
    height: 1.22,
    color: _ink.withOpacity(0.55),
  );

  @override
  void initState() {
    super.initState();

    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5600),
    )..repeat(reverse: true);

    _bgT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOut);
    _floatT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOutSine);

    _selectedLocation ??= const SelectedLocation(
      label: "Current location",
      latLng: LatLng(31.5204, 74.3587),
    );
  }

  @override
  void dispose() {
    _ambientCtrl.dispose();
    super.dispose();
  }

  // ✅ Same flow you already had — just moved into a method
  Future<void> _openAiFlow() async {
    HapticFeedback.mediumImpact();

    final prefs = await showModalBottomSheet<OutfitGenPrefs>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiOutfitPickerSheet(
        primary: _primary,
        secondary: _secondary,
        ink: _ink,
      ),
    );

    if (!mounted || prefs == null) return;

    final outfits = await showDialog<List<OutfitBundle>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AiGeneratingDialog(
        primary: _primary,
        secondary: _secondary,
        other: _other,
        ink: _ink,
        prefs: prefs,
      ),
    );

    if (!mounted || outfits == null || outfits.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AiOutfitResultsScreen(
          primary: _primary,
          secondary: _secondary,
          other: _other,
          ink: _ink,
          initialOutfits: outfits,
          prefs: prefs,
          fullScreenGlassSheet: () => const _FullScreenGlassSheet(),
          title3d: (text, {fontSize = 20, fontWeight = FontWeight.w900}) =>
              _Title3D(text, fontSize: fontSize, fontWeight: fontWeight),
          imgBuilder: (image, {fit = BoxFit.cover}) => _img(image, fit: fit),
        ),
      ),
    );
  }

// ✅ NEW: Wardrobe button route (opens WardrobeInteriorScreen)
  void _openWardrobe() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 520),
        pageBuilder: (_, __, ___) => const WardrobeInteriorScreen(),
        transitionsBuilder: (_, anim, __, child) {
          final a = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(a),
              child: child,
            ),
          );
        },
      ),
    );
  }


  // ✅ NEW: Wardrobe button (Option 1 under search)
  Widget _wardrobeButton(BuildContext context) {
    final r = BorderRadius.circular(22);

    return _PressScale(
      downScale: 0.985,
      borderRadius: r,
      onTap: _openWardrobe,
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              borderRadius: r,
              color: Colors.white.withOpacity(0.70),
              border: Border.all(color: Colors.white.withOpacity(0.82), width: 1.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 22,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _secondary.withOpacity(0.95),
                        _primary.withOpacity(0.95),
                      ],
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.76), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: _secondary.withOpacity(0.22),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.95)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Wardrobe",
                        style: GoogleFonts.manrope(
                          fontSize: 14.6,
                          fontWeight: FontWeight.w900,
                          color: _ink.withOpacity(0.92),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Open your digital closet • set availability • generate outfits",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w800,
                          color: _ink.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _primary.withOpacity(0.10),
                        _secondary.withOpacity(0.08),
                      ],
                    ),
                    border: Border.all(color: _primary.withOpacity(0.18), width: 1.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 16, color: _primary.withOpacity(0.86)),
                      const SizedBox(width: 6),
                      Text(
                        "Open",
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w900,
                          fontSize: 11.8,
                          color: _ink.withOpacity(0.82),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: _ink.withOpacity(0.70)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _bg1,
      bottomNavigationBar: _flashDealsBar(context),
      body: Stack(
        children: [
          // Background
          AnimatedBuilder(
            animation: _ambientCtrl,
            builder: (context, _) {
              final t = _bgT.value;
              final tt = _floatT.value;

              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.lerp(_bg3, _bg2, t)!,
                          Color.lerp(_bg2, _bg1, t)!,
                          Color.lerp(_bg3, _bg2, t)!,
                        ],
                        stops: const [0.0, 0.58, 1.0],
                      ),
                    ),
                  ),
                  const _FullScreenGlassSheet(),
                  IgnorePointer(
                    child: Stack(
                      children: [
                        _GlowBlob(
                          dx: lerpDouble(-70, -18, tt)!,
                          dy: lerpDouble(110, 80, tt)!,
                          size: 300,
                          opacity: 0.11,
                          a: _secondary,
                          b: _primary,
                        ),
                        _GlowBlob(
                          dx: lerpDouble(220, 310, tt)!,
                          dy: lerpDouble(290, 220, tt)!,
                          size: 360,
                          opacity: 0.09,
                          a: _primary,
                          b: _other,
                        ),
                        _GlowBlob(
                          dx: lerpDouble(190, 250, 1 - tt)!,
                          dy: lerpDouble(26, 14, tt)!,
                          size: 260,
                          opacity: 0.07,
                          a: _other,
                          b: _secondary,
                        ),
                        _ShimmerSweep(t: tt, colorA: _secondary, colorB: _primary),
                      ],
                    ),
                  ),
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.white.withOpacity(0.70),
                            Colors.white.withOpacity(0.20),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Top cap
          Positioned(
            top: -topInset,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _HeaderCapClipper(),
              child: Container(
                height: 220 + topInset,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.92),
                      Colors.white.withOpacity(0.58),
                      Colors.white.withOpacity(0.06),
                    ],
                    stops: const [0.0, 0.62, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 52,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(child: _body(context)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    final nearbyMedia = const [
      CardMedia(bg: "assets/shops/Charcoal.png"),
      CardMedia(bg: "assets/shops/Monark.jpg"),
      CardMedia(bg: "assets/shops/Outfitters.png"),
      CardMedia(bg: "assets/shops/Uniworth.png"),
    ];

    return AnimatedBuilder(
      animation: _ambientCtrl,
      builder: (context, _) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(18, 12, 18, 28 + topInset * 0.10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topLocationRow(context),
              const SizedBox(height: 12),
              _searchRow(context),

              // ✅ Option 1: Wardrobe button directly under search
              const SizedBox(height: 12),
              _wardrobeButton(context),

              const SizedBox(height: 14),
              _heroCard(context),
              const SizedBox(height: 18),
              _categoriesRow(context),

              const SizedBox(height: 18),
              AiOutfitSection(
                primary: _primary,
                secondary: _secondary,
                other: _other,
                ink: _ink,
                onActivated: _openAiFlow,
              ),

              const SizedBox(height: 22),
              _sectionHeader("Spotlight Stores", "Featured brands near you", Icons.auto_awesome_rounded),
              const SizedBox(height: 12),
              _horizontalCards(
                height: 210,
                items: const [
                  ShopCardData(
                    name: "Charcoal",
                    meta: "Men • Formalwear • Premium",
                    image: "assets/shops/Charcoal.png",
                    isAd: true,
                    offer: "Flat 15% OFF",
                    pro: "PRO • Free delivery over Rs.199",
                  ),
                  ShopCardData(
                    name: "Outfitters",
                    meta: "Men & Women • Casual • Trending",
                    image: "assets/shops/Outfitters.png",
                    isAd: true,
                    offer: "Buy 2 Save 10%",
                    pro: "PRO • Extra 5% off",
                  ),
                  ShopCardData(
                    name: "Uniworth",
                    meta: "Men • Smart Casual • Best sellers",
                    image: "assets/shops/Uniworth.png",
                    offer: "Winter Collection",
                    pro: "Free delivery over Rs.2499",
                  ),
                  ShopCardData(
                    name: "Monark",
                    meta: "Men • Eastern Wear • New arrivals",
                    image: "assets/shops/Monark.jpg",
                    offer: "Season Sale",
                    pro: "Limited time",
                  ),
                ],
              ),

              const SizedBox(height: 22),
              _sectionHeader("Trending Now", "Top Articles", Icons.local_fire_department_rounded),
              const SizedBox(height: 12),
              _trendingCategoryCards(
                height: 210,
                items: const [
                  ("Shirts", "Overshirts • Linen • New arrivals"),
                  ("Shoes", "Sneakers • Loafers • Best sellers"),
                  ("Hats", "Caps • Beanies • Street style"),
                  ("Coats", "Winter • Puffers • Warm picks"),
                  ("Accessories", "Belts • Watches • Wallets"),
                  ("Perfumes", "Fresh • Woody • Top rated"),
                ],
                media: const CardMedia(bg: "assets/articles/hats.jpeg"),
              ),

              const SizedBox(height: 22),
              _sectionHeader("Nearby Shops", "Fast near you", Icons.near_me_rounded),
              const SizedBox(height: 12),
              _nearbyShops(context, nearbyMedia),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TOP: Location + Cart + Profile
  // ─────────────────────────────────────────────────────────────
  Widget _topLocationRow(BuildContext context) {
    final label = _selectedLocation?.label ?? "Current location";

    return Row(
      children: [
        Expanded(
          child: _PressScale(
            downScale: 0.985,
            borderRadius: BorderRadius.circular(999),
            onTap: () async {
              HapticFeedback.selectionClick();
              final result = await Navigator.push<SelectedLocation>(
                context,
                MaterialPageRoute(
                  builder: (_) => LocationSelectScreen(
                    current: _selectedLocation,
                    saved: List.of(_savedLocations),
                  ),
                ),
              );

              if (result != null) {
                setState(() {
                  _selectedLocation = result;
                });
              }
            },
            child: _LocationPill(label: label),
          ),
        ),
        const SizedBox(width: 12),
        _TopGlassIconButton(
          icon: Icons.shopping_cart_rounded,
          tintIcon: _ink.withOpacity(0.72),
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Cart clicked",
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        const SizedBox(width: 10),
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
  // Search bar
  // ─────────────────────────────────────────────────────────────
  Widget _searchRow(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.68),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.80), width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: _ink.withOpacity(0.62)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    color: _ink.withOpacity(0.86),
                  ),
                  decoration: InputDecoration(
                    hintText: "Search shops, items...",
                    hintStyle: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      color: _ink.withOpacity(0.40),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (_) => HapticFeedback.selectionClick(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HERO CARD
  // ─────────────────────────────────────────────────────────────
  Widget _heroCard(BuildContext context) {
    final t = _floatT.value;
    final floatY = sin(t * pi * 2) * 3.0;

    return Transform.translate(
      offset: Offset(0, floatY),
      child: _PressScale(
        downScale: 0.992,
        borderRadius: BorderRadius.circular(24),
        onTap: () => HapticFeedback.lightImpact(),
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
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _primary.withOpacity(0.96),
                      _secondary.withOpacity(0.92),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.16),
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
                                Colors.white.withOpacity(0.14),
                                Colors.transparent,
                                Colors.black.withOpacity(0.06),
                              ],
                              stops: const [0.0, 0.52, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _MiniHeroPuck(icon: Icons.local_shipping_rounded),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const _GlassTagDark(text: "2-HOUR DELIVERY"),
                                  const Spacer(),
                                  const _MiniGlassIconDark(icon: Icons.bolt_rounded),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Shopping at your speed",
                                style: GoogleFonts.manrope(
                                  fontSize: 16.6,
                                  fontWeight: FontWeight.w900,
                                  height: 1.12,
                                  color: Colors.white.withOpacity(0.96),
                                  letterSpacing: -0.35,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Nearby stores, instant deals, and curated picks — delivered fast.",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize: 12.4,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                  color: Colors.white.withOpacity(0.80),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _HeroPill(
                                    text: "Explore",
                                    filled: true,
                                    onTap: () => HapticFeedback.lightImpact(),
                                  ),
                                  const SizedBox(width: 10),
                                  _HeroPill(
                                    text: "Deals",
                                    filled: false,
                                    onTap: () => HapticFeedback.selectionClick(),
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
  // Categories Row
  // ─────────────────────────────────────────────────────────────
  Widget _categoriesRow(BuildContext context) {
    final items = <Map<String, dynamic>>[
      {"name": "Clothing", "icon": Icons.shopping_bag_rounded},
      {"name": "Shoes", "icon": Icons.sports_rounded},
      {"name": "Gifts", "icon": Icons.card_giftcard_rounded},
      {"name": "Accessories", "icon": Icons.watch_rounded},
      {"name": "Perfumes", "icon": Icons.spa_rounded},
      {"name": "Electronics", "icon": Icons.phone_iphone_rounded},
    ];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final name = items[i]["name"] as String;
          final icon = items[i]["icon"] as IconData;

          return _PressScale(
            downScale: 0.985,
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShopListingScreen(category: name),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.66),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.82), width: 1.1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 18, color: _primary.withOpacity(0.80)),
                      const SizedBox(width: 8),
                      Text(
                        name,
                        style: GoogleFonts.manrope(
                          fontSize: 12.2,
                          fontWeight: FontWeight.w900,
                          color: _ink.withOpacity(0.80),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SECTION HEADER
  // ─────────────────────────────────────────────────────────────
  Widget _sectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _FloatingIcon(icon: icon, ink: _primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
  // HORIZONTAL CARDS
  // ─────────────────────────────────────────────────────────────
  Widget _horizontalCards({
    required double height,
    required List<ShopCardData> items,
  }) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = items[index];

          return _PressScale(
            downScale: 0.98,
            borderRadius: BorderRadius.circular(22),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShopScreen(shopName: item.name),
                ),
              );
            },
            child: _TopImageGlassFooterCard(
              width: 260,
              height: height,
              image: item.image,
              title: item.name,
              subtitle: item.meta,
              isAd: item.isAd,
              offerText: item.offer,
              proText: item.pro,
              primary: _primary,
              secondary: _secondary,
              ink: _ink,
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Nearby Shops
  // ─────────────────────────────────────────────────────────────
  Widget _nearbyShops(BuildContext context, List<CardMedia> media) {
    final shopNames = ["Charcoal", "Monark", "Outfitters", "Uniworth"];
    final distances = ["1.2 km", "2.5 km", "3.1 km", "0.8 km"];
    final ratings = ["4.7", "4.5", "4.9", "4.3"];

    return Column(
      children: List.generate(media.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _NearbyImageRowCard(
            name: shopNames[index],
            distance: distances[index],
            rating: ratings[index],
            image: media[index].bg,
            primary: _primary,
            ink: _ink,
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

  Widget _trendingCategoryCards({
    required double height,
    required List<(String, String)> items,
    required CardMedia media,
  }) {
    return SizedBox(
      height: 300,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final (title, meta) = items[index];

          return _PressScale(
            downScale: 0.98,
            borderRadius: BorderRadius.circular(22),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ShopListingScreen(category: title)),
              );
            },
            child: _TopImageGlassFooterCard(
              width: 230,
              height: height,
              image: media.bg,
              title: title,
              subtitle: meta,
              isAd: false,
              offerText: "Trending",
              proText: "Tap to explore",
              primary: _primary,
              secondary: _secondary,
              ink: _ink,
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Persistent bottom bar (Flash Deals)
  // ─────────────────────────────────────────────────────────────
  Widget _flashDealsBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _primary.withOpacity(0.96),
                    _secondary.withOpacity(0.92),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.14), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.22),
                    blurRadius: 22,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.bolt_rounded, color: Colors.white.withOpacity(0.92), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    "Flash Deals",
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.92),
                      fontSize: 13.2,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        height: 34,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 6,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, i) => _DealChip(
                            text: const ["25% OFF", "BOGO", "Rs.199", "1+1", "Mega", "Hot"][i],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _PressScale(
                    downScale: 0.98,
                    borderRadius: BorderRadius.circular(999),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Flash deals opened",
                            style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withOpacity(0.16), width: 1),
                      ),
                      child: Text(
                        "View",
                        style: GoogleFonts.manrope(
                          fontSize: 11.6,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withOpacity(0.90),
                        ),
                      ),
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

// ============================================================================
// ✅ Everything below is your existing widgets / helpers as-is (unchanged),
// plus your AiOutfitSection + painters.
// (Keeping it in one file, “completed updated screen” as requested)
// ============================================================================

// ─────────────────────────────────────────────────────────────
// ✅ NEW CARD STYLE (matches screenshot)
// image fully shown on top, glass footer below
// ─────────────────────────────────────────────────────────────
class _TopImageGlassFooterCard extends StatefulWidget {
  final double width;
  final double height;
  final String image;

  final String title;
  final String subtitle;

  final bool isAd;
  final String? offerText;
  final String? proText;

  final Color primary;
  final Color secondary;
  final Color ink;

  const _TopImageGlassFooterCard({
    required this.width,
    required this.height,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.isAd,
    required this.offerText,
    required this.proText,
    required this.primary,
    required this.secondary,
    required this.ink,
  });

  @override
  State<_TopImageGlassFooterCard> createState() => _TopImageGlassFooterCardState();
}

class _TopImageGlassFooterCardState extends State<_TopImageGlassFooterCard> {
  bool fav = false;

  @override
  Widget build(BuildContext context) {
    final cardR = BorderRadius.circular(22);
    final imgR = const BorderRadius.only(
      topLeft: Radius.circular(22),
      topRight: Radius.circular(22),
    );

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: cardR,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.white.withOpacity(0.45))),
            Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: imgR,
                    child: Stack(
                      children: [
                        Positioned.fill(child: _img(widget.image, fit: BoxFit.cover)),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.center,
                                  colors: [
                                    Colors.black.withOpacity(0.22),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: _GlassCircleButton(
                            icon: fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            iconColor: fav ? const Color(0xFFE11D48) : widget.ink.withOpacity(0.75),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => fav = !fav);
                            },
                          ),
                        ),
                        if ((widget.offerText ?? "").isNotEmpty)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: _GlassBadge(
                              text: widget.offerText!,
                              icon: Icons.local_offer_rounded,
                              tint: widget.secondary,
                            ),
                          ),
                        if (widget.isAd)
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: _AdPill(),
                          ),
                      ],
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(22),
                    bottomRight: Radius.circular(22),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.72),
                        border: Border(
                          top: BorderSide(color: Colors.white.withOpacity(0.65), width: 1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w900,
                              fontSize: 14.2,
                              color: widget.ink.withOpacity(0.92),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                              fontSize: 11.8,
                              color: widget.ink.withOpacity(0.58),
                            ),
                          ),
                          if ((widget.proText ?? "").isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _ProPill(text: widget.proText!, primary: widget.primary),
                                const Spacer(),
                                Icon(Icons.arrow_forward_ios_rounded,
                                    size: 16, color: widget.ink.withOpacity(0.40)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: cardR,
                    border: Border.all(color: Colors.white.withOpacity(0.70), width: 1.1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _GlassCircleButton({
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(child: Icon(icon, size: 20, color: iconColor)),
          ),
        ),
      ),
    );
  }
}

class _GlassBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color tint;

  const _GlassBadge({
    required this.text,
    required this.icon,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.78),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.88), width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: tint.withOpacity(0.95)),
              const SizedBox(width: 6),
              Text(
                text,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w900,
                  fontSize: 11.2,
                  color: const Color(0xFF140504).withOpacity(0.86),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
      ),
      child: Text(
        "Ad",
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.w900,
          fontSize: 10.6,
          color: Colors.white.withOpacity(0.92),
        ),
      ),
    );
  }
}

class _ProPill extends StatelessWidget {
  final String text;
  final Color primary;
  const _ProPill({required this.text, required this.primary});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: primary.withOpacity(0.22), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.workspace_premium_rounded, size: 14, color: primary.withOpacity(0.92)),
              const SizedBox(width: 6),
              Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w900,
                  fontSize: 11.0,
                  color: const Color(0xFF140504).withOpacity(0.78),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Location selection page (Google Map + Saved Locations)
// ─────────────────────────────────────────────────────────────
class LocationSelectScreen extends StatefulWidget {
  final SelectedLocation? current;
  final List<SelectedLocation> saved;

  const LocationSelectScreen({
    super.key,
    required this.current,
    required this.saved,
  });

  @override
  State<LocationSelectScreen> createState() => _LocationSelectScreenState();
}

class _LocationSelectScreenState extends State<LocationSelectScreen> {
  GoogleMapController? _ctrl;
  late LatLng _center;
  late List<SelectedLocation> _saved;
  String _label = "Pinned location";

  @override
  void initState() {
    super.initState();
    _center = widget.current?.latLng ?? const LatLng(31.5204, 74.3587);
    _saved = List.of(widget.saved);
    _label = widget.current?.label ?? "Pinned location";
  }

  void _onCameraMove(CameraPosition p) {
    _center = p.target;
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF9F6F5);
    const ink = Color(0xFF140504);
    const primary = Color(0xFF440C08);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Choose location",
          style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: ink),
        ),
        iconTheme: const IconThemeData(color: ink),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: _center, zoom: 14),
                  onMapCreated: (c) => _ctrl = c,
                  onCameraMove: _onCameraMove,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: false,
                  zoomControlsEnabled: false,
                ),
                Center(
                  child: IgnorePointer(
                    child: Transform.translate(
                      offset: const Offset(0, -16),
                      child: Icon(Icons.location_pin, size: 44, color: primary.withOpacity(0.95)),
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.70),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withOpacity(0.82), width: 1.1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Selected", style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 6),
                            Text(
                              "$_label • ${_center.latitude.toStringAsFixed(5)}, ${_center.longitude.toStringAsFixed(5)}",
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w800,
                                color: ink.withOpacity(0.72),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _ActionPill(
                                    text: "Use this location",
                                    filled: true,
                                    onTap: () {
                                      Navigator.pop(
                                        context,
                                        SelectedLocation(label: _label, latLng: _center),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _ActionPill(
                                    text: "Save",
                                    filled: false,
                                    onTap: () async {
                                      final name = await _askLabel(context);
                                      if (name == null || name.trim().isEmpty) return;
                                      setState(() {
                                        _label = name.trim();
                                        _saved.insert(
                                          0,
                                          SelectedLocation(label: _label, latLng: _center),
                                        );
                                      });
                                      HapticFeedback.selectionClick();
                                    },
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
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Saved locations", style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: ink)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 70,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _saved.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final s = _saved[i];
                      return _SavedLocationChip(
                        label: s.label,
                        onTap: () => Navigator.pop(context, s),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _askLabel(BuildContext context) async {
    final c = TextEditingController(text: _label);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Name this location", style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(hintText: "e.g., Home, Office"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, c.text),
            child: Text("Save", style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class SelectedLocation {
  final String label;
  final LatLng latLng;
  const SelectedLocation({required this.label, required this.latLng});
}

// ─────────────────────────────────────────────────────────────
// SMALL UI PARTS
// ─────────────────────────────────────────────────────────────
class _LocationPill extends StatelessWidget {
  final String label;
  const _LocationPill({required this.label});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF140504);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.68),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.82), width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.location_on_rounded, size: 18, color: const Color(0xFF440C08).withOpacity(0.85)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w900,
                    color: ink.withOpacity(0.86),
                    fontSize: 12.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down_rounded, color: ink.withOpacity(0.55)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DealChip extends StatelessWidget {
  final String text;
  const _DealChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
          ),
          child: Text(
            text,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w900,
              fontSize: 11.2,
              color: Colors.white.withOpacity(0.90),
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedLocationChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SavedLocationChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF440C08);
    const ink = Color(0xFF140504);

    return _PressScale(
      downScale: 0.985,
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.76),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.82), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.bookmark_rounded, size: 18, color: primary.withOpacity(0.85)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w900,
                  color: ink.withOpacity(0.82),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final String text;
  final bool filled;
  final VoidCallback onTap;
  const _ActionPill({required this.text, required this.filled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF440C08);
    const ink = Color(0xFF140504);

    return _PressScale(
      downScale: 0.98,
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: filled ? primary : Colors.white.withOpacity(0.76),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: filled ? Colors.white.withOpacity(0.18) : Colors.white.withOpacity(0.82),
            width: 1.1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w900,
              color: filled ? Colors.white.withOpacity(0.94) : ink.withOpacity(0.86),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PRESS SCALE
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
                b.withOpacity(opacity * 0.70),
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
// TOP CAP CLIPPER
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
// TOP ICON BUTTON
// ─────────────────────────────────────────────────────────────
class _TopGlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? tintIcon;

  const _TopGlassIconButton({
    required this.icon,
    required this.onTap,
    this.tintIcon,
  });

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
                color: Colors.white.withOpacity(0.72),
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
                      color: (tintIcon ?? const Color(0xFF140504)).withOpacity(0.74),
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
    const primary = Color(0xFF440C08);
    const secondary = Color(0xFF750A03);

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
          gradient: LinearGradient(
            colors: [secondary.withOpacity(0.95), primary.withOpacity(0.95)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
                      colors: [Colors.white.withOpacity(0.65), Colors.transparent],
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
                  color: Colors.white.withOpacity(0.95),
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
// 3D TITLE
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
    const base = Color(0xFF140504);

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
    const ink = Color(0xFF140504);
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
              color: Colors.white.withOpacity(0.66),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withOpacity(0.82), width: 1.1),
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
                fontSize: 11.8,
                fontWeight: FontWeight.w900,
                color: ink.withOpacity(0.74),
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
  final Color ink;
  const _FloatingIcon({required this.icon, required this.ink});

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
                color: Colors.white.withOpacity(0.74),
                border: Border.all(color: Colors.white.withOpacity(0.86), width: 1.1),
              ),
              child: Center(
                child: Icon(icon, size: 20, color: ink.withOpacity(0.82)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Hero mini widgets
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.18),
              border: Border.all(color: Colors.white.withOpacity(0.22), width: 1.1),
            ),
            child: Center(
              child: Icon(icon, size: 24, color: Colors.white.withOpacity(0.92)),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassTagDark extends StatelessWidget {
  final String text;
  const _GlassTagDark({required this.text});

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
            color: Colors.white.withOpacity(0.14),
            border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
          ),
          child: Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 9.6,
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.88),
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniGlassIconDark extends StatelessWidget {
  final IconData icon;
  const _MiniGlassIconDark({required this.icon});

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
            color: Colors.white.withOpacity(0.14),
            border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
          ),
          child: Icon(icon, size: 18, color: Colors.white.withOpacity(0.86)),
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final String text;
  final bool filled;
  final VoidCallback onTap;

  const _HeroPill({
    required this.text,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF140504);

    return _PressScale(
      downScale: 0.975,
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: filled ? Colors.white.withOpacity(0.92) : Colors.white.withOpacity(0.16),
          border: Border.all(color: Colors.white.withOpacity(0.20), width: 1.1),
        ),
        child: Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 12.4,
            fontWeight: FontWeight.w900,
            color: filled ? ink.withOpacity(0.88) : Colors.white.withOpacity(0.92),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Nearby card
// ─────────────────────────────────────────────────────────────
class _NearbyImageRowCard extends StatelessWidget {
  final String name;
  final String distance;
  final String rating;
  final String? image;
  final Color primary;
  final Color ink;
  final VoidCallback onTap;

  const _NearbyImageRowCard({
    required this.name,
    required this.distance,
    required this.rating,
    required this.image,
    required this.primary,
    required this.ink,
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
              child: image == null ? Container(color: Colors.white.withOpacity(0.75)) : _img(image!, fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withOpacity(0.10),
                        Colors.black.withOpacity(0.16),
                        Colors.black.withOpacity(0.22),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.white.withOpacity(0.06)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.72),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.84), width: 1.1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primary.withOpacity(0.10),
                            border: Border.all(color: Colors.white.withOpacity(0.85), width: 1),
                          ),
                          child: Icon(Icons.store_rounded, color: primary.withOpacity(0.82)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize: 15.4,
                                  fontWeight: FontWeight.w900,
                                  color: ink.withOpacity(0.90),
                                  letterSpacing: -0.25,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _InfoTag(icon: Icons.location_on_rounded, text: distance, ink: ink),
                                  _InfoTag(icon: Icons.access_time_rounded, text: "Open", ink: ink),
                                  _RatingTag(text: "$rating ★"),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _ChevronOrb(primary: primary),
                      ],
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
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color ink;
  const _InfoTag({required this.icon, required this.text, required this.ink});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.46),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.82), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: ink.withOpacity(0.62)),
              const SizedBox(width: 5),
              Text(
                text,
                style: GoogleFonts.manrope(
                  fontSize: 10.8,
                  fontWeight: FontWeight.w800,
                  color: ink.withOpacity(0.70),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
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
              fontSize: 10.8,
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
  final Color primary;
  const _ChevronOrb({required this.primary});

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
          color: Colors.white.withOpacity(0.70),
          border: Border.all(color: Colors.white.withOpacity(0.86), width: 1.1),
        ),
        child: Center(
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: primary.withOpacity(0.82),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// FULL SCREEN GLASS SHEET
// ─────────────────────────────────────────────────────────────
class _FullScreenGlassSheet extends StatelessWidget {
  const _FullScreenGlassSheet();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: const SizedBox.expand(),
            ),
            Container(color: Colors.white.withOpacity(0.10)),
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.75, -0.85),
                  radius: 1.0,
                  colors: [
                    Colors.white.withOpacity(0.55),
                    Colors.white.withOpacity(0.18),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.35, 1.0],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.85, 0.90),
                  radius: 1.2,
                  colors: [
                    Colors.white.withOpacity(0.22),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
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
// SHIMMER SWEEP
// ─────────────────────────────────────────────────────────────
class _ShimmerSweep extends StatelessWidget {
  final double t;
  final Color colorA;
  final Color colorB;

  const _ShimmerSweep({
    required this.t,
    required this.colorA,
    required this.colorB,
  });

  @override
  Widget build(BuildContext context) {
    final dx = lerpDouble(-0.5, 0.7, t)!;
    final dy = lerpDouble(-0.2, 0.6, t)!;

    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.06,
          child: Transform.rotate(
            angle: -0.35,
            child: FractionalTranslation(
              translation: Offset(dx, dy),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      colorA.withOpacity(0.22),
                      colorB.withOpacity(0.22),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.42, 0.58, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// ============================================================================
// ✅ NEW: AI OUTFIT SECTION (MODULAR)
// - On click:
//    1) Electric border “travels” around edges
//    2) Border fills/glows stronger
//    3) Then triggers your onActivated() to open AI flow
// - Center: Heartbeat core with smoky aura
// ============================================================================
// ✅ FUTURISTIC AI OUTFIT SECTION (center AI core + wires + electrifying border)
// - Idle: AI core “breathes”, wires softly pulse, border has faint energy shimmer
// - Tap: energy runs from core through wires → completes border current → then opens screen
//
// IMPORTANT imports you need in this file:
// import 'dart:math';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';

class AiOutfitSection extends StatefulWidget {
  final Color primary;
  final Color secondary;
  final Color other;
  final Color ink;
  final Future<void> Function() onActivated;

  const AiOutfitSection({
    super.key,
    required this.primary,
    required this.secondary,
    required this.other,
    required this.ink,
    required this.onActivated,
  });

  @override
  State<AiOutfitSection> createState() => _AiOutfitSectionState();
}

class _AiOutfitSectionState extends State<AiOutfitSection>
    with TickerProviderStateMixin {
  late final AnimationController _idleCtrl;
  late final AnimationController _electricCtrl;

  bool _busy = false;

  @override
  void initState() {
    super.initState();

    // Ambient idle pulse
    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // Electric fill (tap)
    _electricCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 980),
    );
  }

  @override
  void dispose() {
    _idleCtrl.dispose();
    _electricCtrl.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    if (_busy) return;
    setState(() => _busy = true);
    HapticFeedback.mediumImpact();

    // Run the electric sequence (wires → border complete)
    await _electricCtrl.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 120));

    await widget.onActivated();

    if (!mounted) return;
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(26);

    return _PressScale(
      downScale: 0.985,
      borderRadius: r,
      onTap: _activate,
      child: AnimatedBuilder(
        animation: Listenable.merge([_idleCtrl, _electricCtrl]),
        builder: (context, _) {
          final t = _idleCtrl.value; // 0..1
          final e = _electricCtrl.value; // 0..1

          // Idle breathing scale
          final breathe = 1.0 + 0.035 * sin(t * pi * 2);

          // Small drift for aura/wires
          final drift = sin(t * pi * 2) * 1.6;

          // Electric intensity
          final glow = lerpDouble(0.12, 0.30, Curves.easeOut.transform(e))!;

          return ClipRRect(
            borderRadius: r,
            child: Stack(
              children: [
                // Base glass card
                BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.70),
                      borderRadius: r,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.78),
                        width: 1.1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 22,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "AI Outfit Studio",
                                style: GoogleFonts.manrope(
                                  fontSize: 16.2,
                                  fontWeight: FontWeight.w900,
                                  color: widget.ink.withOpacity(0.90),
                                  letterSpacing: -0.25,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Tap the AI core. Energy runs through wires and electrifies the border before launch.",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize: 12.2,
                                  fontWeight: FontWeight.w800,
                                  color: widget.ink.withOpacity(0.58),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _AiChip(text: "Brands", color: widget.primary),
                                  _AiChip(text: "Styles", color: widget.secondary),
                                  _AiChip(text: "5 Results", color: widget.other),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),

                        // ✅ Center AI core cluster (NOT heart)
                        SizedBox(
                          width: 104,
                          height: 104,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Ambient “plasma” aura
                              Transform.translate(
                                offset: Offset(0, drift),
                                child: _PlasmaAura(
                                  a: widget.primary,
                                  b: widget.secondary,
                                  intensity: 0.18 + (1 - e) * 0.06,
                                ),
                              ),

                              // Core glow
                              _CoreGlow(
                                color: widget.primary,
                                intensity: 0.12 + glow,
                              ),

                              // AI core button
                              Transform.scale(
                                scale: breathe,
                                child: _AiCoreButton(
                                  primary: widget.primary,
                                  secondary: widget.secondary,
                                  ink: widget.ink,
                                  busy: _busy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ✅ Wires that connect core → border + current traveling
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _WireNetworkPainter(
                        idleT: t,
                        electricT: e,
                        primary: widget.primary,
                        secondary: widget.secondary,
                        strength: _busy ? 1.0 : 0.7,
                      ),
                    ),
                  ),
                ),

                // ✅ Electric border: completes before opening screen
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ElectricBorderCompletePainter(
                        t: e,
                        primary: widget.primary,
                        secondary: widget.secondary,
                        strength: _busy ? 1.0 : 0.7,
                      ),
                    ),
                  ),
                ),

                // Subtle top highlight
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: r,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.22),
                            Colors.transparent,
                            Colors.black.withOpacity(0.04),
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AiChip extends StatelessWidget {
  final String text;
  final Color color;
  const _AiChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withOpacity(0.20), width: 1),
          ),
          child: Text(
            text,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w900,
              fontSize: 11.2,
              color: const Color(0xFF140504).withOpacity(0.78),
            ),
          ),
        ),
      ),
    );
  }
}

class _AiCoreButton extends StatelessWidget {
  final Color primary;
  final Color secondary;
  final Color ink;
  final bool busy;

  const _AiCoreButton({
    required this.primary,
    required this.secondary,
    required this.ink,
    required this.busy,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primary.withOpacity(0.96),
                secondary.withOpacity(0.86),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.28), width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 22,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: busy
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.92),
                  ),
                ),
              )
                  : Column(
                key: const ValueKey("ai"),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome_rounded,
                      color: Colors.white.withOpacity(0.95), size: 22),
                  const SizedBox(height: 2),
                  Text(
                    "AI",
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: Colors.white.withOpacity(0.95),
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

class _CoreGlow extends StatelessWidget {
  final Color color;
  final double intensity;
  const _CoreGlow({required this.color, required this.intensity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 94,
      height: 94,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(intensity),
            color.withOpacity(intensity * 0.55),
            Colors.transparent,
          ],
          stops: const [0.0, 0.60, 1.0],
        ),
      ),
    );
  }
}

class _PlasmaAura extends StatelessWidget {
  final Color a;
  final Color b;
  final double intensity;
  const _PlasmaAura({required this.a, required this.b, required this.intensity});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _softBlob(0, 0, 86, a.withOpacity(intensity)),
        _softBlob(18, 18, 58, b.withOpacity(intensity * 0.95)),
        _softBlob(-16, 24, 64, a.withOpacity(intensity * 0.80)),
      ],
    );
  }

  Widget _softBlob(double dx, double dy, double size, Color c) {
    return Transform.translate(
      offset: Offset(dx, dy),
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: c),
        ),
      ),
    );
  }
}
// Helper: match your card background look (glass white)
Color _bgWire(Color primary, double strength) =>
    Color.lerp(Colors.white.withOpacity(0.0), Colors.white.withOpacity(0.70), 1.0)!
        .withOpacity(0.35 * strength);

Color _bgBorder(double strength) =>
    Colors.white.withOpacity(0.35 * strength); // subtle, blends into glass

Color _darkNeonRed(Color primary) {
  final hot = Color.lerp(const Color(0xFFFF1A1A), primary, 0.55)!;
  return Color.lerp(hot, const Color(0xFF120000), 0.18)!;
}

/// ✅ Wires: idle = background-ish, click = dark neon current travels
class _WireNetworkPainter extends CustomPainter {
  final double idleT;
  final double electricT;
  final Color primary;
  final Color secondary;
  final double strength;

  _WireNetworkPainter({
    required this.idleT,
    required this.electricT,
    required this.primary,
    required this.secondary,
    required this.strength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 0..0.40 = wires phase
    final wiresP = (electricT / 0.40).clamp(0.0, 1.0);
    final neon = _darkNeonRed(primary);

    final coreCenter = Offset(size.width - 16 - 52, 16 + 52);

    final r = 26.0;
    final rect = Rect.fromLTWH(3.0, 3.0, size.width - 6.0, size.height - 6.0);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(r));

    final targets = <Offset>[
      Offset(rr.left + rr.width * 0.62, rr.top),
      Offset(rr.right, rr.top + rr.height * 0.48),
      Offset(rr.left + rr.width * 0.55, rr.bottom),
      Offset(rr.left, rr.top + rr.height * 0.52),
    ];

    // ✅ IDLE wires = background-ish (almost invisible)
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = _bgWire(primary, strength).withOpacity(0.22 * strength);

    final pulse = (0.5 + 0.5 * sin(idleT * pi * 2));
    final shimmer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..color = _bgWire(primary, strength).withOpacity((0.10 + 0.10 * pulse) * strength);

    // ✅ CLICK current paints (neon)
    final energizedOuter = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final energizedInner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    for (final target in targets) {
      final path = Path();

      final mid = Offset(
        (coreCenter.dx + target.dx) / 2,
        (coreCenter.dy + target.dy) / 2,
      );

      final bend = 18.0 + 10.0 * sin((idleT * pi * 2) + target.dx * 0.01);
      final c1 = Offset(
        coreCenter.dx + (mid.dx - coreCenter.dx) * 0.35,
        coreCenter.dy + (mid.dy - coreCenter.dy) * 0.35 - bend,
      );
      final c2 = Offset(
        coreCenter.dx + (mid.dx - coreCenter.dx) * 0.75,
        coreCenter.dy + (mid.dy - coreCenter.dy) * 0.75 + bend * 0.6,
      );

      path.moveTo(coreCenter.dx, coreCenter.dy);
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, target.dx, target.dy);

      // ✅ idle draw
      canvas.drawPath(path, base);
      canvas.drawPath(path, shimmer);

      // ✅ neon current ONLY on click
      if (wiresP > 0.001) {
        final pm = path.computeMetrics().first;
        final len = pm.length;
        final end = len * Curves.easeOut.transform(wiresP);
        final segPath = pm.extractPath(0, end, startWithMoveTo: true);

        energizedOuter.shader = ui.Gradient.linear(
          coreCenter,
          target,
          [
            neon.withOpacity(0.06 * strength),
            neon.withOpacity(0.95 * strength),
            neon.withOpacity(0.10 * strength),
          ],
          const [0.0, 0.62, 1.0],
        );

        energizedInner.shader = ui.Gradient.linear(
          coreCenter,
          target,
          [
            Colors.white.withOpacity(0.40 * strength),
            neon.withOpacity(1.00 * strength),
            Colors.white.withOpacity(0.14 * strength),
          ],
          const [0.0, 0.52, 1.0],
        );

        canvas.drawPath(segPath, energizedOuter);
        canvas.drawPath(segPath, energizedInner);

        final headTan = pm.getTangentForOffset(end.clamp(0, len));
        if (headTan != null) {
          final p = headTan.position;

          final sparkOuter = Paint()
            ..color = neon.withOpacity(0.60 * strength)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

          final sparkInner = Paint()
            ..color = Colors.white.withOpacity(0.52 * strength)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

          canvas.drawCircle(p, 4.3, sparkOuter);
          canvas.drawCircle(p, 2.0, sparkInner);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WireNetworkPainter oldDelegate) {
    return oldDelegate.idleT != idleT ||
        oldDelegate.electricT != electricT ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.strength != strength;
  }
}

/// ✅ Border: idle = background-ish, click = dark neon current travels & completes
class _ElectricBorderCompletePainter extends CustomPainter {
  final double t;
  final Color primary;
  final Color secondary;
  final double strength;

  _ElectricBorderCompletePainter({
    required this.t,
    required this.primary,
    required this.secondary,
    required this.strength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final neon = _darkNeonRed(primary);

    final r = 26.0;
    final rect = Rect.fromLTWH(3.0, 3.0, size.width - 6.0, size.height - 6.0);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(r));

    // border phase: 0.40..1.0
    final borderP = ((t - 0.40) / 0.60).clamp(0.0, 1.0);

    // ✅ IDLE border = background-ish (blends into glass)
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = _bgBorder(strength).withOpacity(0.35 * strength);
    canvas.drawRRect(rr, base);

    // ✅ If not charging, keep it quiet and return
    if (borderP <= 0.001) {
      final idleGlow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
        ..color = _bgBorder(strength).withOpacity(0.18 * strength);
      canvas.drawRRect(rr, idleGlow);
      return;
    }

    // ✅ Charging neon bloom
    final bloom = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..color = neon.withOpacity(
        lerpDouble(0.08, 0.38, Curves.easeOut.transform(borderP))! * strength,
      );
    canvas.drawRRect(rr, bloom);

    final path = Path()..addRRect(rr);
    final pm = path.computeMetrics().first;
    final len = pm.length;

    final end = len * Curves.easeOut.transform(borderP);
    final donePath = pm.extractPath(0, end, startWithMoveTo: true);

    // Completion stroke (neon outer + white-hot core)
    final doneOuter = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final doneInner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.1
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    doneOuter.shader = ui.Gradient.linear(
      rect.topLeft,
      rect.bottomRight,
      [
        neon.withOpacity(0.18 * strength),
        neon.withOpacity(1.00 * strength),
        neon.withOpacity(0.20 * strength),
      ],
      const [0.0, 0.55, 1.0],
    );

    doneInner.shader = ui.Gradient.linear(
      rect.topLeft,
      rect.bottomRight,
      [
        Colors.white.withOpacity(0.45 * strength),
        neon.withOpacity(1.00 * strength),
        Colors.white.withOpacity(0.18 * strength),
      ],
      const [0.0, 0.55, 1.0],
    );

    canvas.drawPath(donePath, doneOuter);
    canvas.drawPath(donePath, doneInner);

    // Traveling head
    final seg = len * 0.20;
    final head = end % len;
    final segPath =
    pm.extractPath(head, (head + seg).clamp(0, len), startWithMoveTo: true);

    final boltOuter = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final boltInner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.3
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    boltOuter.shader = ui.Gradient.linear(
      rect.topLeft,
      rect.bottomRight,
      [
        neon.withOpacity(0.24 * strength),
        neon.withOpacity(1.00 * strength),
        neon.withOpacity(0.24 * strength),
      ],
      const [0.0, 0.55, 1.0],
    );

    boltInner.shader = ui.Gradient.linear(
      rect.topLeft,
      rect.bottomRight,
      [
        Colors.white.withOpacity(0.52 * strength),
        neon.withOpacity(1.00 * strength),
        Colors.white.withOpacity(0.20 * strength),
      ],
      const [0.0, 0.55, 1.0],
    );

    canvas.drawPath(segPath, boltOuter);
    canvas.drawPath(segPath, boltInner);
  }

  @override
  bool shouldRepaint(covariant _ElectricBorderCompletePainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.strength != strength;
  }
}
