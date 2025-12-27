import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qds/screens/Customer/profile_screen.dart';
import 'package:qds/screens/Customer/shop_listing_screen.dart';
import 'package:qds/screens/Customer/shop_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const _HomeTopCap(),
          _body(context),

        ],
      ),
    );
  }

  Widget _body(BuildContext context) {

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 44, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topBar(context),
          const SizedBox(height: 22),

          _sectionTitle("🔥 Promoted Shops", trailing: "Sponsored"),
          const SizedBox(height: 12),
          _horizontalCards(height: 140),

          const SizedBox(height: 22),
          _sectionTitle("🏷️ Categories"),
          const SizedBox(height: 12),
          _categories(context),


          const SizedBox(height: 22),
          _sectionTitle("⚡ Flash Deals", trailing: "Limited time"),
          const SizedBox(height: 12),
          _horizontalCards(height: 150),

          const SizedBox(height: 22),
          _sectionTitle("📍 Nearby Shops", trailing: "Map view"),
          const SizedBox(height: 12),
          _nearbyShops(context),

          const SizedBox(height: 22),
          _sectionTitle("⭐ Top Rated Shops"),
          const SizedBox(height: 12),
          _horizontalCards(height: 140),

          const SizedBox(height: 22),
          _sectionTitle("🎯 Festival Picks"),
          const SizedBox(height: 12),
          _festivalBanners(),
        ],
      ),
    );
  }

  // ───────────────────── Top Bar ─────────────────────

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Discover",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Fast deliveries near you",
              style: AppText.body14Soft,
            ),
          ],
        ),
        const Spacer(),

        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search_rounded),
          splashRadius: 22,
        ),

        // 🔹 PROFILE ENTRY
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.chipFill,
              border: Border.all(color: AppColors.divider),
            ),
            alignment: Alignment.center,
            child: const Text(
              "A",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────── Sections ─────────────────────

  Widget _sectionTitle(String title, {String? trailing}) {
    return Row(
      children: [
        Text(
          title,
          style: AppText.h18,
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSoft,
            ),
          ),
      ],
    );
  }

  Widget _horizontalCards({required double height}) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ShopScreen(
                    shopName: "Urban Style Store",
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(AppRadius.r18),
            child: Container(
              width: 220,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r18),
                border: Border.all(color: AppColors.divider),
                boxShadow: AppShadows.softCard,
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Spacer(),
                  Text(
                    "Urban Style Store",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Fast delivery • 4.8 ★",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMid,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _categories(BuildContext context) {
    final items = [
      "Clothing",
      "Shoes",
      "Gifts",
      "Accessories",
      "Perfumes",
      "Electronics",
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((category) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ShopListingScreen(category: category),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppRadius.r22),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r22),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }


  Widget _nearbyShops(BuildContext context) {

    return Column(
      children: List.generate(4, (index) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ShopScreen(
                  shopName: "Nearby Fashion Hub",
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppRadius.r18),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r18),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: const [
                Icon(Icons.store_mall_directory_outlined),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nearby Fashion Hub",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "1.2 km away • Open now",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMid,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _festivalBanners() {
    return Column(
      children: List.generate(2, (index) {
        return Container(
          height: 140,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.r18),
            gradient: const LinearGradient(
              colors: [Color(0xFFEEE6FF), Color(0xFFE0D7FF)],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: const Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              "Festival Special\nUp to 30% off",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ───────────────────── Top Cap ─────────────────────

class _HomeTopCap extends StatelessWidget {
  const _HomeTopCap();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: -topInset,
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: _HeaderCapClipper(),
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

class _HeaderCapClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final r = 22.0;
    final slant = 36.0;
    final cutY = size.height - 52;

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
