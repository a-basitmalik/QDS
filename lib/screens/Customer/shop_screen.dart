import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qds/screens/Customer/product_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';

class ShopScreen extends StatefulWidget {
  final String shopName;

  const ShopScreen({
    super.key,
    required this.shopName,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  final searchCtrl = TextEditingController();
  int selectedCategory = 0;

  final categories = [
    "All",
    "Men",
    "Women",
    "Shoes",
    "Accessories",
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          _shopBanner(),
          _content(),
          _backButton(context),
        ],
      ),
    );
  }

  // ───────────────────────── Banner ─────────────────────────

  Widget _shopBanner() {
    return SizedBox(
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            "https://images.unsplash.com/photo-1521334884684-d80222895322",
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Content ─────────────────────────

  Widget _content() {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 220, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shopInfo(),
              const SizedBox(height: 18),
              _search(),
              const SizedBox(height: 16),
              _categoryChips(),
              const SizedBox(height: 20),
              _products(),
              const SizedBox(height: 28),
              _reviews(),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── Shop Info ─────────────────────────

  Widget _shopInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r18),
        boxShadow: AppShadows.softCard,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.shopName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "25–35 min • 1.4 km away",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMid,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              SizedBox(width: 4),
              Text(
                "4.8",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              SizedBox(width: 10),
              Text(
                "Open now",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Search ─────────────────────────

  Widget _search() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r18),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: searchCtrl,
                decoration: const InputDecoration(
                  hintText: "Search in shop",
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Categories ─────────────────────────

  Widget _categoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final active = i == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => selectedCategory = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: active ? AppColors.textDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.r22),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  categories[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: active ? Colors.white : AppColors.textDark,
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
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProductScreen(
              productName: "Classic Watch",
              shopName: "Urban Style Store",
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(AppRadius.r18),
      child: AnimatedScale(
        scale: 1,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r18),
            border: Border.all(color: AppColors.divider),
            boxShadow: AppShadows.softCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: Image.network(
                    "https://images.unsplash.com/photo-1523275335684-37898b6baf30",
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Classic Watch",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Rs. 4,999",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
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


  // ───────────────────────── Reviews ─────────────────────────

  Widget _reviews() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Customer Reviews",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "⭐️⭐️⭐️⭐️⭐️ 4.8 based on 320 reviews",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMid,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Back ─────────────────────────

  Widget _backButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 12,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
