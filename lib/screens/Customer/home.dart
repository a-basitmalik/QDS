// home.dart
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qds/screens/Customer/shop_screen.dart';

// ✅ Add this dependency in pubspec.yaml if not already:
// google_maps_flutter: ^2.6.1
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:qds/screens/Customer/profile_screen.dart';
import 'package:qds/screens/Customer/shop_listing_screen.dart';
import 'package:qds/screens/Customer/shop_screen.dart';

/// ✅ Updated Home UI (routing/functionality preserved)
/// ✅ LIGHT THEME + your palette:
/// primary   #440C08
/// secondary #750A03
/// others    (invalid "9BOS03") -> using fallback #9B0F03
///
/// ✅ Update per your screenshot:
/// - Cards like Foodpanda:
///   ✅ image fully shown on top
///   ✅ text/info BELOW the image inside a frosted GLASS container
///   ✅ heart icon on image (optional)
///   ✅ small badges (Ad/Offer/PRO) optional
///
/// ⚠️ Assets:
/// flutter:
///   assets:
///     - assets/banners/
///     - assets/articles/
///     - assets/shops/
///     - assets/logos/
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// ─────────────────────────────────────────────────────────────
// MEDIA MODELS + HELPERS
// ─────────────────────────────────────────────────────────────
class CardMedia {
  final String bg; // image (asset or network)
  const CardMedia({required this.bg});
}

bool _isNetwork(String s) => s.startsWith('http://') || s.startsWith('https://');

Widget _img(String path, {BoxFit fit = BoxFit.cover}) {
  return _isNetwork(path)
      ? Image.network(
    path,
    fit: fit,
    errorBuilder: (_, __, ___) => const SizedBox(),
  )
      : Image.asset(
    path,
    fit: fit,
    errorBuilder: (_, __, ___) => const SizedBox(),
  );
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

  // ─────────────────────────────────────────────────────────────
  // ✅ LIGHT THEME + YOUR COLORS
  // ─────────────────────────────────────────────────────────────
  static const _primary = Color(0xFF440C08);
  static const _secondary = Color(0xFF750A03);
  static const _other = Color(0xFF9B0F03); // fallback for invalid hex

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

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _bg1,
      bottomNavigationBar: _flashDealsBar(context),
      body: Stack(
        children: [
          // ✅ Background (gradient + glass sheet + blobs + vignette)
          AnimatedBuilder(
            animation: _ambientCtrl,
            builder: (context, _) {
              final t = _bgT.value;
              final tt = _floatT.value;

              return Stack(
                children: [
                  // 1) Base bright gradient
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

                  // 2) Frosted “glass sheet” across the whole screen
                  const _FullScreenGlassSheet(),

                  // 3) Controlled glow blobs + shimmer
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
                        _ShimmerSweep(
                          t: tt,
                          colorA: _secondary,
                          colorB: _primary,
                        ),
                      ],
                    ),
                  ),

                  // 4) Soft top vignette
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

          // ✅ Top cap layer (over the background)
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

          // ✅ Actual content on top
          SafeArea(child: _body(context)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    // ✅ Example media (replace with your real asset/network paths)
    const promotedMedia = CardMedia(bg: "assets/banners/Edited.jpg");
    const articleMedia = CardMedia(bg: "assets/articles/Edited.jpg");

    final nearbyMedia = const [
      CardMedia(bg: "assets/shops/Edited.jpg"),
      CardMedia(bg: "assets/shops/Edited.jpg"),
      CardMedia(bg: "assets/shops/Edited.jpg"),
      CardMedia(bg: "assets/shops/Edited.jpg"),
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
              const SizedBox(height: 14),
              _heroCard(context),
              const SizedBox(height: 18),
              _categoriesRow(context),
              const SizedBox(height: 22),

              _sectionHeader(
                "Try something new",
                "Picked for you",
                Icons.auto_awesome_rounded,
              ),
              const SizedBox(height: 12),
              _horizontalCards(
                height: 210, // <-- slightly taller to fit image + footer
                titleText: "The Whispering Cup",
                metaText: "20–45 min • \$\$ • Continental",
                media: promotedMedia,
                isAd: true,
                offerText: "10% off",
                proText: "PRO • Free with Rs.599",
              ),

              const SizedBox(height: 22),

              _sectionHeader(
                "Top picks for you",
                "Cakes & Bakery",
                Icons.cake_rounded,
              ),
              const SizedBox(height: 12),
              _horizontalCards(
                height: 210,
                titleText: "Shezan Bakers • Township",
                metaText: "20–45 min • \$\$ • Cakes & Bakery",
                media: articleMedia,
                isAd: false,
                offerText: "10% off",
                proText: "PRO • Up to 15% off",
                routeToShop: true,
              ),

              const SizedBox(height: 22),

              _sectionHeader(
                "Nearby Shops",
                "Fast near you",
                Icons.near_me_rounded,
              ),
              const SizedBox(height: 12),
              _nearbyShops(context, nearbyMedia),

              const SizedBox(height: 90),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TOP: Location (left) + Cart & Profile (right)
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
  // Search bar row
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
  // HERO CARD (your palette)
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
                    border: Border.all(
                      color: Colors.white.withOpacity(0.82),
                      width: 1.1,
                    ),
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
  // ✅ HORIZONTAL CARDS (Foodpanda-like)
  // image on top + glass info footer below
  // ─────────────────────────────────────────────────────────────
  Widget _horizontalCards({
    required double height,
    required String titleText,
    required String metaText,
    required CardMedia media,
    bool routeToShop = true,
    bool isAd = false,
    String? offerText,
    String? proText,
  }) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return _PressScale(
            downScale: 0.98,
            borderRadius: BorderRadius.circular(22),
            onTap: () {
              HapticFeedback.lightImpact();
              if (!routeToShop) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShopScreen(shopName: "Urban Style Store"),
                ),
              );
            },
            child: _TopImageGlassFooterCard(
              width: 260,
              height: height,
              image: media.bg,
              title: titleText,
              subtitle: metaText,
              isAd: isAd,
              offerText: offerText,
              proText: proText,
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
  // Nearby Shops (kept as your nice row cards)
  // ─────────────────────────────────────────────────────────────
  Widget _nearbyShops(BuildContext context, List<CardMedia> media) {
    final shopNames = [
      "Urban Fashion Hub",
      "Boutique Central",
      "Style Gallery",
      "Trendy Emporium"
    ];
    final distances = ["1.2 km", "2.5 km", "3.1 km", "0.8 km"];
    final ratings = ["4.7", "4.5", "4.9", "4.3"];

    return Column(
      children: List.generate(4, (index) {
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
                border: Border.all(
                  color: Colors.white.withOpacity(0.14),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.22),
                    blurRadius: 22,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(Icons.bolt_rounded,
                      color: Colors.white.withOpacity(0.92), size: 20),
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
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: 6,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) => _DealChip(
                        text: ["25% OFF", "BOGO", "Rs.199", "1+1", "Mega", "Hot"][i],
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
                        border: Border.all(
                            color: Colors.white.withOpacity(0.16), width: 1),
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
            // subtle glass base behind everything (gives depth)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.45),
              ),
            ),

            Column(
              children: [
                // IMAGE AREA
                Expanded(
                  child: ClipRRect(
                    borderRadius: imgR,
                    child: Stack(
                      children: [
                        Positioned.fill(child: _img(widget.image, fit: BoxFit.cover)),

                        // top gradient like apps
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

                        // heart button (top-right)
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

                        // Offer badge (top-left) like "10% off"
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

                        // "Ad" badge (bottom-right on image)
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

                // GLASS FOOTER (text below)
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

            // outer highlight border
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
              Icon(Icons.workspace_premium_rounded,
                  size: 14, color: primary.withOpacity(0.92)),
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
// Returns SelectedLocation via Navigator.pop
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
                      child: Icon(
                        Icons.location_pin,
                        size: 44,
                        color: primary.withOpacity(0.95),
                      ),
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
                            Text("Selected",
                                style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
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
                Text("Saved locations",
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: ink)),
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
        title: Text("Name this location",
            style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
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
              Icon(Icons.location_on_rounded,
                  size: 18, color: const Color(0xFF440C08).withOpacity(0.85)),
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
                      colors: [
                        Colors.white.withOpacity(0.65),
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
// ✅ Nearby card (unchanged from your version)
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
            // FULL background image
            Positioned.fill(
              child: image == null
                  ? Container(color: Colors.white.withOpacity(0.75))
                  : _img(image!, fit: BoxFit.cover),
            ),

            // overlay for readability
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

            // frosted glaze
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.white.withOpacity(0.06)),
              ),
            ),

            // content glass row
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
