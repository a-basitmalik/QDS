import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
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
  late final AnimationController _enterCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slideUp;

  late final AnimationController _cartPulseCtrl;
  late final Animation<double> _cartPulse;

  final PageController _pageCtrl = PageController();
  int _page = 0;

  int _selectedSize = 0;
  int _selectedVariant = 0;
  int _qty = 1;

  // Soft stock (not harsh)
  bool _inStock = true;
  int _stockLeft = 7;

  // Delivery ETA (static for now)
  final String _eta = "25–35 min";
  final String _distance = "1.4 km";

  final List<String> _images = const [
    "https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=1400&q=70",
    "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=1400&q=70",
    "https://images.unsplash.com/photo-1520975958225-3f61d0b22b43?auto=format&fit=crop&w=1400&q=70",
  ];

  final List<String> _sizes = const ["S", "M", "L", "XL"];
  final List<String> _variants = const ["Black", "Silver", "Rose"];

  // Price (static)
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
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));

    _cartPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _cartPulse = Tween<double>(begin: 1, end: 1.03).animate(
      CurvedAnimation(parent: _cartPulseCtrl, curve: Curves.easeOutBack),
    );

    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _cartPulseCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          _imageGallery(),
          _content(),
          _topControls(context),
          _bottomBar(context),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Image Gallery (PageView + blur overlay)
  // ─────────────────────────────────────────────────────────────

  Widget _imageGallery() {
    return SizedBox(
      height: 420,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageCtrl,
            itemCount: _images.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) {
              return Image.network(
                _images[i],
                fit: BoxFit.cover,
              );
            },
          ),

          // Gradient for legibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.10),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Bottom blur edge (premium)
          Positioned(
            left: 0,
            right: 0,
            bottom: -1,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  height: 26,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Main Content
  // ─────────────────────────────────────────────────────────────

  Widget _content() {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slideUp,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 370, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sheetTop(),
              const SizedBox(height: 12),

              _headerBlock(),
              const SizedBox(height: 14),

              _priceBlock(),
              const SizedBox(height: 14),

              _deliveryEtaBlock(),
              const SizedBox(height: 18),

              _sizesBlock(),
              const SizedBox(height: 14),

              _variantsBlock(),
              const SizedBox(height: 18),

              _stockBlock(),
              const SizedBox(height: 18),

              _detailsBlock(),
              const SizedBox(height: 22),

              _reviewsPreview(),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetTop() {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  Widget _headerBlock() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r18),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.softCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.productName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.shopName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textMid,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Icon(Icons.star_rounded, size: 18, color: Colors.amber),
              SizedBox(width: 4),
              Text(
                "4.8",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              SizedBox(width: 10),
              Text(
                "Best seller",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMid,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          _galleryDots(),
        ],
      ),
    );
  }

  Widget _galleryDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_images.length, (i) {
        final active = i == _page;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 18 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? AppColors.textDark : AppColors.divider,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Price + Qty
  // ─────────────────────────────────────────────────────────────

  Widget _priceBlock() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: _priceText(),
          ),
          _qtyStepper(),
        ],
      ),
    );
  }

  Widget _priceText() {
    final discount = (((_oldPrice - _price) / _oldPrice) * 100).round();

    return Column(
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
                fontWeight: FontWeight.w700,
                color: AppColors.textMid,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                "$discount% off",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _qtyStepper() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          _iconRound(
            icon: Icons.remove_rounded,
            onTap: () {
              if (_qty > 1) setState(() => _qty--);
            },
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
          _iconRound(
            icon: Icons.add_rounded,
            onTap: () {
              setState(() => _qty++);
            },
          ),
        ],
      ),
    );
  }

  Widget _iconRound({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 18),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Delivery ETA
  // ─────────────────────────────────────────────────────────────

  Widget _deliveryEtaBlock() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.chipFill,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.local_shipping_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Delivery ETA",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMid,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "$_eta • $_distance",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Text(
              "Live",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          )
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Sizes
  // ─────────────────────────────────────────────────────────────

  Widget _sizesBlock() {
    return _sectionCard(
      title: "Sizes",
      subtitle: "Choose a size",
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(_sizes.length, (i) {
          final active = i == _selectedSize;
          return _choiceChip(
            label: _sizes[i],
            active: active,
            onTap: () => setState(() => _selectedSize = i),
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Variants
  // ─────────────────────────────────────────────────────────────

  Widget _variantsBlock() {
    return _sectionCard(
      title: "Variants",
      subtitle: "Pick a color",
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(_variants.length, (i) {
          final active = i == _selectedVariant;
          return _choiceChip(
            label: _variants[i],
            active: active,
            onTap: () => setState(() => _selectedVariant = i),
          );
        }),
      ),
    );
  }

  Widget _choiceChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.textDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r22),
          border: Border.all(color: AppColors.divider),
          boxShadow: active
              ? [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 10),
              color: Colors.black.withOpacity(0.12),
            ),
          ]
              : null,
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

  // ─────────────────────────────────────────────────────────────
  // Stock (soft)
  // ─────────────────────────────────────────────────────────────

  Widget _stockBlock() {
    final label = _inStock ? "In stock" : "Out of stock";
    final hint = _inStock
        ? (_stockLeft <= 8 ? "Only $_stockLeft left" : "Available")
        : "Check again soon";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r18),
        border: Border.all(color: AppColors.divider),
      ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hint,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMid,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Demo toggler (remove later)
              setState(() => _inStock = !_inStock);
            },
            child: const Text(
              "Refresh",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
          )
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Details
  // ─────────────────────────────────────────────────────────────

  Widget _detailsBlock() {
    return _sectionCard(
      title: "Details",
      subtitle: "Product description",
      child: const Text(
        "A premium everyday piece designed for comfort and style. "
            "Soft-touch materials, durable stitching, and a clean modern silhouette. "
            "Perfect for gifting and daily wear.\n\n"
            "• High quality finish\n"
            "• Comfortable fit\n"
            "• Long-lasting build\n"
            "• Easy to maintain",
        style: TextStyle(
          fontSize: 13,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: AppColors.textMid,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Reviews Preview
  // ─────────────────────────────────────────────────────────────

  Widget _reviewsPreview() {
    return _sectionCard(
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
            height: 48,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.divider),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r18),
                ),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.chipFill,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider),
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
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMid,
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

  // ─────────────────────────────────────────────────────────────
  // Shared section card
  // ─────────────────────────────────────────────────────────────

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r18),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.softCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.h18),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textMid,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Top Controls (Back + Favorite)
  // ─────────────────────────────────────────────────────────────

  Widget _topControls(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Positioned(
      top: top + 10,
      left: 12,
      right: 12,
      child: Row(
        children: [
          _blurIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          _blurIconButton(
            icon: Icons.favorite_border_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _blurIconButton({required IconData icon, required VoidCallback onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withOpacity(0.12),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Bottom Bar (Sticky Add to Cart)
  // ─────────────────────────────────────────────────────────────

  Widget _bottomBar(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: AnimatedBuilder(
            animation: _cartPulse,
            builder: (_, __) {
              return Transform.scale(
                scale: _cartPulse.value,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.r22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F12).withOpacity(0.92),
                        borderRadius: BorderRadius.circular(AppRadius.r22),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 28,
                            offset: Offset(0, 18),
                            color: Color(0x33000000),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Rs. ${_format(_price * _qty)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed:_inStock
                                  ? () async {
                                await _cartPulseCtrl.forward();
                                await _cartPulseCtrl.reverse();

                                _toast(context, "Added to cart");

                                // Navigate to Cart / Checkout
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CartCheckoutScreen(),
                                  ),
                                );
                              }
                                  : null,


                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.textDark,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(AppRadius.r18),
                                ),
                              ),
                              child: const Text(
                                "Add to cart",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
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

  // ─────────────────────────────────────────────────────────────
  // Utils
  // ─────────────────────────────────────────────────────────────

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

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
