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

class _ProductScreenState extends State<ProductScreen>
    with TickerProviderStateMixin {
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

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));

    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5600),
    )..repeat(reverse: true);
    _bgT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOut);
    _floatT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOutSine);

    _ctaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _ctaT = CurvedAnimation(parent: _ctaCtrl, curve: Curves.easeOut);

    _enterCtrl.forward();
  }

  @override
  void dispose() {
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
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          _animatedBackground(),
          _blobs(),

          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slideUp,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16, topInset + 92, 16, 170),
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
                  ],
                ),
              ),
            ),
          ),

          _topBar(context),
          _premiumBottomCTA(context),

          if (_showAddedSheet) _AddedToCartBottomSheet(
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
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(const Color(0xFFF7F7FA), const Color(0xFFEFF1FF), _bgT.value)!,
                Color.lerp(const Color(0xFFF7F7FA), const Color(0xFFFBEFFF), _bgT.value)!,
                const Color(0xFFF7F7FA),
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
                opacity: 0.14,
              ),
              _GlowBlob(
                dx: lerpDouble(250, 300, t)!,
                dy: lerpDouble(280, 220, t)!,
                size: 280,
                opacity: 0.11,
              ),
              _GlowBlob(
                dx: lerpDouble(120, 140, t)!,
                dy: lerpDouble(520, 560, t)!,
                size: 240,
                opacity: 0.09,
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
      floatingT: _floatT.value,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.r22),
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
                      Image.network(
                        _images[i],
                        fit: BoxFit.cover,
                      ),

                      // Premium top highlight
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

                      // subtle “shine”
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

          // Dots
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
                  color: active
                      ? const Color(0xFF111827).withOpacity(0.85)
                      : AppColors.divider.withOpacity(0.9),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Thumbnails
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
                            ? [
                          Colors.white.withOpacity(0.88),
                          const Color(0xFFF0F2FF).withOpacity(0.82),
                        ]
                            : [
                          Colors.white.withOpacity(0.62),
                          Colors.white.withOpacity(0.42),
                        ],
                      ),
                      border: Border.all(
                        color: active
                            ? const Color(0xFF111827).withOpacity(0.22)
                            : AppColors.divider.withOpacity(0.9),
                        width: active ? 1.4 : 1.0,
                      ),
                      boxShadow: active
                          ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.75),
                          blurRadius: 12,
                          offset: const Offset(0, -6),
                          spreadRadius: -6,
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
                      child: Image.network(
                        _images[i],
                        fit: BoxFit.cover,
                      ),
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

  Widget _headerCard() {
    return _SectionCard(
      floatingT: _floatT.value,
      titleWidget: _Title3DHolo(
        text: widget.productName,
        fontSize: 18,
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
        color: Colors.white.withOpacity(0.62),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.divider.withOpacity(0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 16, color: Colors.amber),
          SizedBox(width: 4),
          Text(
            "4.8",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _stockPill(bool inStock) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: inStock
            ? const Color(0xFF0F7A3B).withOpacity(0.12)
            : Colors.orange.withOpacity(0.14),
        border: Border.all(
          color: inStock
              ? const Color(0xFF0F7A3B).withOpacity(0.22)
              : Colors.orange.withOpacity(0.22),
        ),
      ),
      child: Text(
        inStock ? "In stock" : "Out of stock",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: inStock ? const Color(0xFF0F7A3B) : Colors.orange,
        ),
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
                Text(
                  "Rs. ${_format(_price)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      "Rs. ${_format(_oldPrice)}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMid,
                        decoration: TextDecoration.lineThrough,
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
                          colors: [
                            const Color(0xFF111827),
                            const Color(0xFF3A3F67),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Text(
                        "$discount% off",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Colors.white.withOpacity(0.62),
            border: Border.all(color: AppColors.divider.withOpacity(0.92)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.75),
                blurRadius: 12,
                offset: const Offset(0, -6),
                spreadRadius: -6,
              ),
            ],
          ),
          child: Row(
            children: [
              _PressScale(
                onTap: () {
                  if (_qty > 1) setState(() => _qty--);
                },
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.remove_rounded, size: 18),
                ),
              ),
              SizedBox(
                width: 36,
                child: Center(
                  child: Text(
                    _qty.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
              _PressScale(
                onTap: () => setState(() => _qty++),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.add_rounded, size: 18),
                ),
              ),
            ],
          ),
        ),
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
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Colors.white.withOpacity(0.62),
              border: Border.all(color: AppColors.divider.withOpacity(0.92)),
            ),
            child: const Text(
              "Live",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.88),
            const Color(0xFFF0F2FF).withOpacity(0.78),
          ],
        ),
        border: Border.all(color: AppColors.divider.withOpacity(0.92)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.textDark),
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
    final hint = _inStock
        ? (_stockLeft <= 8 ? "Only $_stockLeft left" : "Available")
        : "Check again soon";

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
              color: _inStock ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
          ),
          _PressScale(
            onTap: () => setState(() => _inStock = !_inStock),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.62),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider.withOpacity(0.92)),
              ),
              child: const Text(
                "Refresh",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
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
      child: const Text(
        "A premium everyday piece designed for comfort and style. "
            "Soft-touch materials, durable stitching, and a clean modern silhouette.\n\n"
            "• High quality finish\n"
            "• Comfortable fit\n"
            "• Long-lasting build\n"
            "• Easy to maintain",
        style: TextStyle(
          fontSize: 13,
          height: 1.4,
          fontWeight: FontWeight.w700,
          color: AppColors.textMid,
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
                  borderRadius: BorderRadius.circular(AppRadius.r18),
                  color: Colors.white.withOpacity(0.62),
                  border: Border.all(color: AppColors.divider.withOpacity(0.92)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Text(
                  "See all reviews",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.58),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider.withOpacity(0.92)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.72),
                blurRadius: 12,
                offset: const Offset(0, -6),
                spreadRadius: -6,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.92),
                      const Color(0xFFF0F2FF).withOpacity(0.78),
                    ],
                  ),
                  border: Border.all(color: AppColors.divider.withOpacity(0.92)),
                ),
                alignment: Alignment.center,
                child: Text(
                  name.characters.first.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
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
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
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
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMid,
                        height: 1.35,
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

  // ───────────────────────── Pills ─────────────────────────

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.62),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.divider.withOpacity(0.92)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.76),
                  const Color(0xFFF3F4F8).withOpacity(0.58),
                  Colors.white.withOpacity(0.70),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.62)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: const Color(0xFF6B7CFF).withOpacity(0.08),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
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
        ),
      ),
    );
  }

  Widget _iconPill(IconData icon, {String? badge}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withOpacity(0.78)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, color: AppColors.textDark),
          if (badge != null)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
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
              final floatY = sin(_floatT.value * pi * 2) * 2.0;

              return Transform.translate(
                offset: Offset(0, -lift + press + floatY),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.r14),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.r14),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.70),
                            const Color(0xFFF3F4F8).withOpacity(0.52),
                            Colors.white.withOpacity(0.64),
                          ],
                        ),
                        border: Border.all(color: Colors.white.withOpacity(0.70), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.14),
                            blurRadius: 34,
                            offset: const Offset(0, 22),
                          ),
                          BoxShadow(
                            color: const Color(0xFF6B7CFF).withOpacity(0.10),
                            blurRadius: 28,
                            offset: const Offset(0, 18),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.75),
                            blurRadius: 18,
                            offset: const Offset(0, -10),
                            spreadRadius: -12,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Total block
                          Expanded(
                            child: _totalMiniCard(),
                          ),
                          const SizedBox(width: 10),

                          // Primary button
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _totalMiniCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.r22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.r22),
            color: Colors.white.withOpacity(0.62),
            border: Border.all(color: Colors.white.withOpacity(0.72)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFEFF1FF).withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
                  ),
                  border: Border.all(color: AppColors.divider.withOpacity(0.72)),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.shopping_bag_outlined, color: AppColors.textDark, size: 22),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TOTAL",
                    style: TextStyle(
                      color: AppColors.textMid.withOpacity(0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "Rs. ${_format(total)}",
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _primaryCTAButton({required bool enabled, required String label}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.r22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.r22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: enabled
                  ? [
                const Color(0xFF111827),
                const Color(0xFF3A3F67),
              ]
                  : [
                const Color(0xFF9CA3AF).withOpacity(0.55),
                const Color(0xFF6B7280).withOpacity(0.45),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(enabled ? 0.22 : 0.12),
                blurRadius: 26,
                offset: const Offset(0, 18),
              ),
              if (enabled)
                BoxShadow(
                  color: const Color(0xFF6B7CFF).withOpacity(0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                  spreadRadius: -10,
                ),
              if (enabled)
                BoxShadow(
                  color: const Color(0xFFFF6BD6).withOpacity(0.10),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                  spreadRadius: -12,
                ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // shine stripe
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
                  Icon(
                    enabled ? Icons.add_shopping_cart_rounded : Icons.block_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
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
        ),
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
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFF6B7CFF).withOpacity(opacity),
              const Color(0xFFFF6BD6).withOpacity(opacity * 0.65),
              Colors.transparent,
            ],
            stops: const [0.0, 0.55, 1.0],
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
        borderRadius: BorderRadius.circular(AppRadius.r22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.r22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.76),
                  Colors.white.withOpacity(0.52),
                ],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.68)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.70),
                  blurRadius: 16,
                  offset: const Offset(0, -10),
                  spreadRadius: -10,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.r22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.r22),
              border: Border.all(color: Colors.white.withOpacity(0.65)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.74),
                  Colors.white.withOpacity(0.52),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 16),
                ),
              ],
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
                                style: AppText.h18.copyWith(fontWeight: FontWeight.w900),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMid,
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
          borderRadius: BorderRadius.circular(AppRadius.r22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: active
                ? [
              const Color(0xFF111827),
              const Color(0xFF3A3F67),
            ]
                : [
              Colors.white.withOpacity(0.66),
              Colors.white.withOpacity(0.46),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(active ? 0.18 : 0.65)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(active ? 0.16 : 0.08),
              blurRadius: active ? 22 : 16,
              offset: const Offset(0, 14),
            ),
            if (!active)
              BoxShadow(
                color: Colors.white.withOpacity(0.70),
                blurRadius: 14,
                offset: const Offset(0, -8),
                spreadRadius: -10,
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: active ? Colors.white : AppColors.textDark,
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
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF111827), Color(0xFF3A3F67), Color(0xFF111827)],
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
                  color: const Color(0xFF6B7CFF).withOpacity(0.16),
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

class _Title3DHolo extends StatelessWidget {
  final String text;
  final double fontSize;

  const _Title3DHolo({
    required this.text,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (int i = 10; i >= 1; i--)
          Transform.translate(
            offset: Offset(0, i.toDouble() * 0.9),
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                height: 1.08,
                fontWeight: FontWeight.w900,
                color: Colors.black.withOpacity(0.05),
              ),
            ),
          ),
        ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF111827), Color(0xFF3A3F67), Color(0xFF111827)],
          ).createShader(rect),
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              height: 1.08,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                  color: const Color(0xFF6B7CFF).withOpacity(0.14),
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

class _AddedToCartBottomSheetState extends State<_AddedToCartBottomSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _tickPop;

  bool _done = false;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400), // ✅ 2–3 sec feel
    )..forward();

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _tickPop = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );

    // Mark done near end + auto finish
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                      child: Container(
                        width: min(w, 520),
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.72),
                              Colors.white.withOpacity(0.52),
                              Colors.white.withOpacity(0.66),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.78),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.16),
                              blurRadius: 40,
                              offset: const Offset(0, 24),
                            ),
                            BoxShadow(
                              color: const Color(0xFF6B7CFF).withOpacity(0.10),
                              blurRadius: 28,
                              offset: const Offset(0, 18),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.86),
                              blurRadius: 26,
                              offset: const Offset(0, -14),
                              spreadRadius: -14,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Circle progress -> tick
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
                                        backgroundColor: const Color(0xFF111827).withOpacity(0.08),
                                        valueColor: AlwaysStoppedAnimation(
                                          const Color(0xFF111827).withOpacity(0.78),
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
                                      child: const Icon(
                                        Icons.check_rounded,
                                        size: 26,
                                        color: Color(0xFF111827),
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
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _done ? "Redirecting to checkout" : "Please wait a moment",
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF6B7280).withOpacity(0.95),
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
                                color: Colors.white.withOpacity(0.60),
                                border: Border.all(color: const Color(0xFFD1D5DB).withOpacity(0.9)),
                              ),
                              child: const Text(
                                "Done",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  color: Color(0xFF111827),
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
        ),
      ),
    );
  }
}
