import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_text.dart';
import 'cart_checkout_screen.dart';

class ProductScreen extends StatefulWidget {
  final String productName;
  final String shopName;

  const ProductScreen({
    super.key,
    required this.productName,
    required this.shopName,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> with TickerProviderStateMixin {
  // ───────────────────────── Page enter ─────────────────────────
  late final AnimationController _enterCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slideUp;

  // ───────────────────────── Ambient BG ─────────────────────────
  late final AnimationController _ambientCtrl;
  late final Animation<double> _bgT;
  late final Animation<double> _floatT;

  // ───────────────────────── CTA press ─────────────────────────
  late final AnimationController _ctaCtrl;
  late final Animation<double> _ctaT;

  // ───────────────────────── Success sheet ─────────────────────────
  bool _showAddedSheet = false;

  // ✅ Show bottom CTA ONLY when scrolled to end
  final ScrollController _scrollCtrl = ScrollController();
  bool _showBottomCTA = false;

  // Gallery
  final PageController _pageCtrl = PageController(viewportFraction: 1.0);
  int _page = 0;

  // Options
  int _selectedSize = 2;
  int _selectedVariant = 0;
  int _qty = 1;

  // Stock
  bool _inStock = true;
  int _stockLeft = 7;

  // Delivery
  final String _eta = "25–35 min";
  final String _distance = "1.4 km";

  // ✅ Network images
  static const String _img =
      "https://images.unsplash.com/photo-1520975958225-3f61d0b22b43?auto=format&fit=crop&w=1400&q=70";

  final List<String> _images = const [_img, _img, _img, _img];
  final List<String> _sizes = const ["S", "M", "L", "XL", "XXL"];
  final List<String> _variants = const ["Black", "Silver", "Rose"];

  // Pricing
  final int _price = 4999;
  final int _oldPrice = 5999;

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));

    _ambientCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 5600))..repeat(reverse: true);
    _bgT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOut);
    _floatT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOutSine);

    _ctaCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 140));
    _ctaT = CurvedAnimation(parent: _ctaCtrl, curve: Curves.easeOut);

    _scrollCtrl.addListener(_onScroll);

    _enterCtrl.forward();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final max = _scrollCtrl.position.maxScrollExtent;
    final cur = _scrollCtrl.position.pixels;

    // ✅ show when user reaches (near) the end
    const threshold = 120.0;
    final shouldShow = (max - cur) <= threshold;

    if (shouldShow != _showBottomCTA) {
      setState(() => _showBottomCTA = shouldShow);
    }
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();

    _enterCtrl.dispose();
    _ambientCtrl.dispose();
    _ctaCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  int get subtotal => _price * _qty;
  int get deliveryFee => 199;
  int get total => subtotal + deliveryFee;

  // ───────────────────────── BUILD ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: Stack(
        children: [
          _animatedBackground(),
          _blobs(),

          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slideUp,
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  16,
                  topInset + 132,
                  16,
                  // keep bottom space so CTA doesn't cover last content
                  170,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _galleryCard(),
                    const SizedBox(height: 14),
                    _headerCard(),
                    const SizedBox(height: 14),
                    _priceQtyCard(),
                    const SizedBox(height: 14),
                    _deliveryCard(),
                    const SizedBox(height: 14),
                    _sizesCard(),
                    const SizedBox(height: 14),
                    _variantsCard(),
                    const SizedBox(height: 14),
                    _stockCard(),
                    const SizedBox(height: 14),
                    _detailsCard(),
                    const SizedBox(height: 16),
                    _reviewsCard(),
                    const SizedBox(height: 34),

                    // ✅ optional hint area at end (looks nice)
                    Center(
                      child: Text(
                        "End of details",
                        style: AppText.subtle().copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink.withOpacity(0.45),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],
                ),
              ),
            ),
          ),

          _mahoganyHeader(context),


          // ✅ CTA only shows when user reaches the end
          if (_showBottomCTA) _premiumBottomCTA(context),

          if (_showAddedSheet)
            _AddedToCartBottomSheet(
              onFinished: () {
                if (!mounted) return;
                setState(() => _showAddedSheet = false);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartCheckoutScreen()),
                );
              },
            ),
        ],
      ),
    );
  }

  // ───────────────────────── BG ─────────────────────────

  Widget _animatedBackground() {
    return AnimatedBuilder(
      animation: _ambientCtrl,
      builder: (context, _) {
        final t = _bgT.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(AppColors.bg3, AppColors.bg2, t)!,
                Color.lerp(AppColors.bg2, AppColors.bg1, t)!,
                AppColors.bg3,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _blobs() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ambientCtrl,
        builder: (context, _) {
          final t = _floatT.value;
          return Stack(
            children: [
              _GlowBlob(
                dx: lerpDouble(-50, 24, t)!,
                dy: lerpDouble(90, 66, t)!,
                size: 240,
                opacity: 0.12,
                a: AppColors.secondary,
                b: AppColors.other,
              ),
              _GlowBlob(
                dx: lerpDouble(250, 300, t)!,
                dy: lerpDouble(280, 220, t)!,
                size: 290,
                opacity: 0.10,
                a: AppColors.primary,
                b: AppColors.secondary,
              ),
              _GlowBlob(
                dx: lerpDouble(120, 140, t)!,
                dy: lerpDouble(520, 560, t)!,
                size: 240,
                opacity: 0.08,
                a: AppColors.other,
                b: AppColors.secondary,
              ),
            ],
          );
        },
      ),
    );
  }

  // ───────────────────────── GALLERY ─────────────────────────

  Widget _galleryCard() {
    return _GlassCard(
      // ✅ now SOLID theme card (no glass / no reddish tint bleed)
      floatingT: _floatT.value,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: AppRadius.r22,
            child: AspectRatio(
              aspectRatio: 1.05,
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _images.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(_images[i], fit: BoxFit.cover),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.10),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.10),
                                ],
                                stops: const [0.0, 0.45, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: 0.22,
                            child: Transform.rotate(
                              angle: -0.35,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 260,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.0),
                                        Colors.white.withOpacity(0.35),
                                        Colors.white.withOpacity(0.0),
                                      ],
                                      stops: const [0.2, 0.5, 0.8],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_images.length, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: active ? AppColors.ink.withOpacity(0.85) : AppColors.divider.withOpacity(0.9),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 66,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final active = i == _page;

                return _PressScale(
                  onTap: () {
                    _pageCtrl.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 360),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: 64,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: active
                            ? [Colors.white.withOpacity(0.92), AppColors.bg2.withOpacity(0.92)]
                            : [Colors.white.withOpacity(0.80), Colors.white.withOpacity(0.62)],
                      ),
                      border: Border.all(
                        color: active ? AppColors.ink.withOpacity(0.22) : AppColors.divider.withOpacity(0.9),
                        width: active ? 1.4 : 1.0,
                      ),
                      boxShadow: active
                          ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 12),
                        ),
                      ]
                          : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(_images[i], fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── HEADER ─────────────────────────
  Widget _mahoganyHeader(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: _MahoganyHeaderBar(
        topInset: topInset,
        title: widget.productName,
        subtitle: widget.shopName,
        onBack: () => Navigator.pop(context),
        onCart: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartCheckoutScreen()),
          );
        },
        cartBadge: "3",
        t: _floatT.value,
      ),
    );
  }


  Widget _headerCard() {
    return _SectionCard(
      floatingT: _floatT.value,
      titleWidget: Text(
        widget.productName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppText.h2().copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: AppColors.ink,
        ),
      ),
      subtitle: widget.shopName,
      right: _ratingPill(),
      child: Row(
        children: [
          _pill("Best seller"),
          const SizedBox(width: 10),
          _pill("Premium"),
          const Spacer(),
          _stockPill(_inStock),
        ],
      ),
    );
  }

  Widget _ratingPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.divider.withOpacity(0.9)),
        boxShadow: _S.shadowSm,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 16, color: Colors.amber),
          SizedBox(width: 4),
          Text("4.8", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _stockPill(bool inStock) {
    final ok = AppColors.success;
    final warn = AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: inStock ? ok.withOpacity(0.10) : warn.withOpacity(0.12),
        border: Border.all(color: inStock ? ok.withOpacity(0.22) : warn.withOpacity(0.22)),
      ),
      child: Text(
        inStock ? "In stock" : "Out of stock",
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: inStock ? ok : warn),
      ),
    );
  }

  // ───────────────────────── PRICE + QTY ─────────────────────────

  Widget _priceQtyCard() {
    final discount = (((_oldPrice - _price) / _oldPrice) * 100).round();

    return _SectionCard(
      floatingT: _floatT.value,
      title: "Price",
      subtitle: "Limited time deal",
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rs. ${_format(_price)}", style: AppText.h2()),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      "Rs. ${_format(_oldPrice)}",
                      style: AppText.subtle().copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.ink.withOpacity(0.55),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        boxShadow: _S.shadowSmStrong,
                      ),
                      child: Text(
                        "$discount% off",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _qtyStepperNew(),
        ],
      ),
    );
  }

  Widget _qtyStepperNew() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white,
        border: Border.all(color: AppColors.divider.withOpacity(0.92)),
        boxShadow: _S.shadowCard,
      ),
      child: Row(
        children: [
          _PressScale(
            onTap: () {
              if (_qty > 1) setState(() => _qty--);
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(Icons.remove_rounded, size: 18, color: AppColors.ink),
            ),
          ),
          SizedBox(
            width: 36,
            child: Center(
              child: Text(
                _qty.toString(),
                style: AppText.body().copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink.withOpacity(0.92),
                ),
              ),
            ),
          ),
          _PressScale(
            onTap: () => setState(() => _qty++),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(Icons.add_rounded, size: 18, color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── DELIVERY ─────────────────────────

  Widget _deliveryCard() {
    return _SectionCard(
      floatingT: _floatT.value,
      title: "Delivery ETA",
      subtitle: "Fast delivery",
      child: Row(
        children: [
          _softIconBox(Icons.local_shipping_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$_eta • $_distance",
              style: AppText.body().copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.ink.withOpacity(0.92),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Colors.white,
              border: Border.all(color: AppColors.divider.withOpacity(0.92)),
            ),
            child: Text(
              "Live",
              style: AppText.kicker().copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.ink.withOpacity(0.90),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _softIconBox(IconData icon) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: AppColors.divider.withOpacity(0.92)),
        boxShadow: _S.shadowSm,
      ),
      child: Icon(icon, color: AppColors.ink),
    );
  }

  // ───────────────────────── SIZE / VARIANT ─────────────────────────

  Widget _sizesCard() {
    return _SectionCard(
      floatingT: _floatT.value,
      title: "Size",
      subtitle: "Choose a size",
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(_sizes.length, (i) {
          final active = i == _selectedSize;
          return _ChoiceChipNeo(
            label: _sizes[i],
            active: active,
            onTap: () => setState(() => _selectedSize = i),
          );
        }),
      ),
    );
  }

  Widget _variantsCard() {
    return _SectionCard(
      floatingT: _floatT.value,
      title: "Variant",
      subtitle: "Pick a color",
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(_variants.length, (i) {
          final active = i == _selectedVariant;
          return _ChoiceChipNeo(
            label: _variants[i],
            active: active,
            onTap: () => setState(() => _selectedVariant = i),
          );
        }),
      ),
    );
  }

  // ───────────────────────── STOCK ─────────────────────────

  Widget _stockCard() {
    final label = _inStock ? "In stock" : "Out of stock";
    final hint = _inStock ? (_stockLeft <= 8 ? "Only $_stockLeft left" : "Available") : "Check again soon";

    return _SectionCard(
      floatingT: _floatT.value,
      title: "Availability",
      subtitle: hint,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _inStock ? AppColors.success : AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppText.body().copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.ink.withOpacity(0.92),
              ),
            ),
          ),
          _PressScale(
            onTap: () => setState(() => _inStock = !_inStock),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider.withOpacity(0.92)),
              ),
              child: Text(
                "Refresh",
                style: AppText.kicker().copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink.withOpacity(0.90),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── DETAILS ─────────────────────────

  Widget _detailsCard() {
    return _SectionCard(
      floatingT: _floatT.value,
      title: "Details",
      subtitle: "Product description",
      child: Text(
        "A premium everyday piece designed for comfort and style. "
            "Soft-touch materials, durable stitching, and a clean modern silhouette.\n\n"
            "• High quality finish\n"
            "• Comfortable fit\n"
            "• Long-lasting build\n"
            "• Easy to maintain",
        style: AppText.body().copyWith(
          fontSize: 13,
          height: 1.4,
          fontWeight: FontWeight.w700,
          color: AppColors.ink.withOpacity(0.55),
        ),
      ),
    );
  }

  // ───────────────────────── REVIEWS ─────────────────────────

  Widget _reviewsCard() {
    return _SectionCard(
      floatingT: _floatT.value,
      title: "Reviews",
      subtitle: "What customers say",
      child: Column(
        children: [
          _reviewTile(
            name: "Ayesha",
            rating: 5,
            text: "Quality is excellent. Delivered fast and packed nicely.",
          ),
          const SizedBox(height: 10),
          _reviewTile(
            name: "Hamza",
            rating: 4,
            text: "Looks premium. Worth the price. Would buy again.",
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            width: double.infinity,
            child: _PressScale(
              onTap: () {},
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.r18,
                  color: Colors.white,
                  border: Border.all(color: AppColors.divider.withOpacity(0.92)),
                  boxShadow: _S.shadowSm,
                ),
                child: Text(
                  "See all reviews",
                  style: AppText.body().copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink.withOpacity(0.92),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewTile({
    required String name,
    required int rating,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider.withOpacity(0.92)),
        boxShadow: _S.shadowCard,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.divider.withOpacity(0.92)),
            ),
            alignment: Alignment.center,
            child: Text(
              name.characters.first.toUpperCase(),
              style: AppText.body().copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.ink.withOpacity(0.92),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: AppText.body().copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink.withOpacity(0.92),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: List.generate(
                        5,
                            (i) => Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: i < rating ? Colors.amber : AppColors.divider,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: AppText.body().copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink.withOpacity(0.55),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Pills ─────────────────────────

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.divider.withOpacity(0.92)),
      ),
      child: Text(
        text,
        style: AppText.kicker().copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AppColors.ink.withOpacity(0.90),
        ),
      ),
    );
  }

  // ───────────────────────── TOP BAR ─────────────────────────

  Widget _topBar(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topInset + 8,
      left: 12,
      right: 12,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider.withOpacity(0.55)),
          boxShadow: _S.shadowTopBar,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _PressScale(
                onTap: () => Navigator.pop(context),
                child: _iconPill(Icons.arrow_back_rounded),
              ),
            ),
            const _TitleCaps3D(text: "PRODUCT DETAILS"),
            Align(
              alignment: Alignment.centerRight,
              child: _PressScale(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartCheckoutScreen()),
                  );
                },
                child: _iconPill(Icons.shopping_cart_outlined, badge: "3"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconPill(IconData icon, {String? badge}) {
    final red = AppColors.primary; // your theme red

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: red.withOpacity(0.22)), // optional red border
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, color: red), // ✅ back + cart icon red

          if (badge != null)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: red, // ✅ red badge
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: _S.shadowBadge,
                ),
                alignment: Alignment.center,
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }


  // ───────────────────────── PREMIUM CTA BAR ─────────────────────────

  Widget _premiumBottomCTA(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AnimatedBuilder(
            animation: Listenable.merge([_ctaCtrl, _ambientCtrl]),
            builder: (context, _) {
              final press = lerpDouble(0, 2.6, _ctaT.value)!;
              final lift = lerpDouble(10, 0, _ctaT.value)!;
              final floatY = sin(_floatT.value * pi * 2) * 1.2;

              return AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                opacity: _showBottomCTA ? 1 : 0,
                child: Transform.translate(
                  offset: Offset(0, -lift + press + floatY),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.r14,
                      color: Colors.white,
                      border: Border.all(color: AppColors.divider.withOpacity(0.55), width: 1.2),
                      boxShadow: _S.shadowCtaBar,
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _totalMiniCard()),
                        const SizedBox(width: 10),
                        _PressScale(
                          onTap: _inStock
                              ? () async {
                            await _ctaCtrl.forward();
                            await _ctaCtrl.reverse();
                            if (!mounted) return;
                            setState(() => _showAddedSheet = true);
                          }
                              : () {},
                          downScale: 0.975,
                          child: _primaryCTAButton(
                            enabled: _inStock,
                            label: _inStock ? "ADD TO CART" : "OUT OF STOCK",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _totalMiniCard() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: AppRadius.r22,
        color: AppColors.bg2,
        border: Border.all(color: AppColors.divider.withOpacity(0.55)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white,
              border: Border.all(color: AppColors.divider.withOpacity(0.55)),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.shopping_bag_outlined, color: AppColors.ink, size: 22),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TOTAL",
                style: AppText.kicker().copyWith(
                  color: AppColors.ink.withOpacity(0.55),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                "Rs. ${_format(total)}",
                style: AppText.body().copyWith(
                  color: AppColors.ink.withOpacity(0.92),
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _primaryCTAButton({required bool enabled, required String label}) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: AppRadius.r22,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: enabled
              ? [AppColors.primary, AppColors.secondary]
              : [AppColors.ink.withOpacity(0.20), AppColors.ink.withOpacity(0.14)],
        ),
        boxShadow: enabled ? _S.shadowCtaBtnEnabled : _S.shadowCtaBtnDisabled,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: enabled ? 0.18 : 0.08,
                child: Transform.rotate(
                  angle: -0.35,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 220,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.65),
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
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(enabled ? Icons.add_shopping_cart_rounded : Icons.block_rounded, size: 18, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.7,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Utils ─────────────────────────

  String _format(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final left = s.length - i;
      buf.write(s[i]);
      if (left > 1 && left % 3 == 1) buf.write(",");
    }
    return buf.toString();
  }
}

// ───────────────────────── Widgets ─────────────────────────

class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double downScale;

  const _PressScale({
    required this.child,
    required this.onTap,
    this.downScale = 0.965,
  });

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        scale: _down ? widget.downScale : 1.0,
        child: widget.child,
      ),
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
    );
  }
}

/// ✅ Now a SOLID theme card (NO BackdropFilter / NO glass tint)
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
    final floatY = sin(floatingT * pi * 2) * 2.0;

    return Transform.translate(
      offset: Offset(0, floatY),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: AppRadius.r22,
          color: Colors.white, // solid => no reddish bleed
          border: Border.all(color: AppColors.divider.withOpacity(0.55)),
          boxShadow: _S.shadowGlass,
        ),
        child: child,
      ),
    );
  }
}

/// ✅ Solid section card (no blur / no transparent gradients)
class _SectionCard extends StatelessWidget {
  final double floatingT;
  final String? title;
  final Widget? titleWidget;
  final String subtitle;
  final Widget child;
  final Widget? right;

  const _SectionCard({
    required this.floatingT,
    this.title,
    this.titleWidget,
    required this.subtitle,
    required this.child,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    final floatY = sin(floatingT * pi * 2) * 2.0;

    return Transform.translate(
      offset: Offset(0, floatY),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: AppRadius.r22,
          color: Colors.white, // solid
          border: Border.all(color: AppColors.divider.withOpacity(0.55)),
          boxShadow: _S.shadowMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleWidget ??
                          Text(
                            title ?? "",
                            style: AppText.h2().copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: AppText.subtle().copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                if (right != null) ...[
                  const SizedBox(width: 10),
                  right!,
                ],
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ChoiceChipNeo extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ChoiceChipNeo({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: AppRadius.r22,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: active
                ? [AppColors.primary, AppColors.secondary]
                : [Colors.white, AppColors.bg2],
          ),
          border: Border.all(color: AppColors.divider.withOpacity(0.55)),
          boxShadow: active ? _S.shadowChipActive : _S.shadowChipIdle,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: active ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _TitleCaps3D extends StatelessWidget {
  final String text;
  const _TitleCaps3D({required this.text});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (int i = 10; i >= 1; i--)
          Transform.translate(
            offset: Offset(0, i.toDouble() * 0.7),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
                color: Colors.black.withOpacity(0.05),
              ),
            ),
          ),
        ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary, AppColors.primary],
          ).createShader(rect),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.3,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                  color: AppColors.secondary.withOpacity(0.16),
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

// ───────────────────────── SUCCESS BOTTOM OVERLAY ─────────────────────────

class _AddedToCartBottomSheet extends StatefulWidget {
  final VoidCallback onFinished;

  const _AddedToCartBottomSheet({required this.onFinished});

  @override
  State<_AddedToCartBottomSheet> createState() => _AddedToCartBottomSheetState();
}

class _AddedToCartBottomSheetState extends State<_AddedToCartBottomSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _tickPop;

  bool _done = false;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..forward();

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _tickPop = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );

    Future.delayed(const Duration(milliseconds: 1900), () {
      if (!mounted) return;
      setState(() => _done = true);
    });

    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      widget.onFinished();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.16),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Container(
                    width: min(w, 520),
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: Colors.white, // solid (no glass tint)
                      border: Border.all(color: AppColors.divider.withOpacity(0.55), width: 1.4),
                      boxShadow: _S.shadowSheet,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 52,
                          height: 52,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 1900),
                                curve: Curves.easeOutCubic,
                                builder: (_, v, __) {
                                  return CircularProgressIndicator(
                                    value: _done ? 1.0 : v,
                                    strokeWidth: 5,
                                    backgroundColor: AppColors.ink.withOpacity(0.08),
                                    // ✅ theme red progress ring
                                    valueColor: AlwaysStoppedAnimation(
                                      AppColors.primary.withOpacity(0.90),
                                    ),
                                  );
                                },
                              ),
                              AnimatedScale(
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeOutBack,
                                scale: _done ? lerpDouble(0.5, 1.0, _tickPop.value)! : 0.5,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 180),
                                  opacity: _done ? 1 : 0,
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 26,
                                    // ✅ theme red tick
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _done ? "Added to cart" : "Adding to cart…",
                                style: AppText.body().copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _done ? "Redirecting to checkout" : "Please wait a moment",
                                style: AppText.subtle().copyWith(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink.withOpacity(0.55),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: AppColors.primary.withOpacity(0.10),
                            border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                          ),
                          child: Text(
                            "Done",
                            style: AppText.kicker().copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
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

/// ---------------------------------------------------------------------------
/// Local shadows fallback
/// ---------------------------------------------------------------------------
class _S {
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 14,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get shadowSmStrong => [
    BoxShadow(
      color: Colors.black.withOpacity(0.18),
      blurRadius: 14,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 16),
    ),
  ];

  static List<BoxShadow> get shadowGlass => [
    BoxShadow(
      color: Colors.black.withOpacity(0.10),
      blurRadius: 28,
      offset: const Offset(0, 18),
    ),
  ];

  static List<BoxShadow> get shadowCard => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 18,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> get shadowTopBar => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 18,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> get shadowBadge => [
    BoxShadow(
      color: Colors.black.withOpacity(0.18),
      blurRadius: 10,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get shadowCtaBar => [
    BoxShadow(
      color: Colors.black.withOpacity(0.14),
      blurRadius: 34,
      offset: const Offset(0, 22),
    ),
  ];

  static List<BoxShadow> get shadowCtaBtnEnabled => [
    BoxShadow(
      color: Colors.black.withOpacity(0.22),
      blurRadius: 26,
      offset: const Offset(0, 18),
    ),
    BoxShadow(
      color: AppColors.secondary.withOpacity(0.14),
      blurRadius: 28,
      offset: const Offset(0, 16),
      spreadRadius: -10,
    ),
  ];

  static List<BoxShadow> get shadowCtaBtnDisabled => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 22,
      offset: const Offset(0, 16),
    ),
  ];

  static List<BoxShadow> get shadowChipActive => [
    BoxShadow(
      color: Colors.black.withOpacity(0.16),
      blurRadius: 22,
      offset: const Offset(0, 14),
    ),
  ];

  static List<BoxShadow> get shadowChipIdle => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> get shadowSheet => [
    BoxShadow(
      color: Colors.black.withOpacity(0.16),
      blurRadius: 40,
      offset: const Offset(0, 24),
    ),
  ];
}

class _MahoganyHeaderBar extends StatelessWidget {
  final double topInset;
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onCart;
  final String? cartBadge;
  final double t;

  const _MahoganyHeaderBar({
    required this.topInset,
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onCart,
    required this.t,
    this.cartBadge,
  });

  @override
  Widget build(BuildContext context) {
    final shine = (sin(t * pi * 2) * 0.5 + 0.5);

    return Container(
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
          _PressScale(
            onTap: onBack,
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
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.h2().copyWith(
                    color: Colors.white.withOpacity(0.94),
                    fontSize: 18.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body().copyWith(
                    color: Colors.white.withOpacity(0.74),
                    fontSize: 12.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          _PressScale(
            onTap: onCart,
            child: _mahoganyCartPuck(
              t: shine,
              badge: cartBadge,
            ),
          ),
        ],
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

  Widget _mahoganyCartPuck({required double t, String? badge}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.14 + 0.06 * t),
        border: Border.all(color: Colors.white.withOpacity(0.24)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 20, color: Colors.white.withOpacity(0.92)),
          if (badge != null)
            Positioned(
              right: 7,
              top: 7,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
