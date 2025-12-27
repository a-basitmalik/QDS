import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';
import 'order_tracking_screen.dart';

class CartCheckoutScreen extends StatefulWidget {
  const CartCheckoutScreen({super.key});

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  final phoneCtrl = TextEditingController(text: "03XX-XXXXXXX");
  final addressCtrl = TextEditingController(
    text: "House 12, Street 8, Johar Town, Lahore",
  );

  int paymentMethod = 0; // 0 = COD, 1 = Wallet

  final cartItems = const [
    {"name": "Classic Watch", "price": 4999, "qty": 1},
    {"name": "Leather Wallet", "price": 2999, "qty": 1},
  ];

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic),
    );

    _enterCtrl.forward();
  }

  @override
  void dispose() {
    phoneCtrl.dispose();
    addressCtrl.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  int get subtotal =>
      cartItems.fold(
        0,
            (sum, e) => sum + (e["price"] as int) * (e["qty"] as int),
      );

  int get deliveryFee => 199;

  int get total => subtotal + deliveryFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const _CheckoutTopCap(),
          _content(context),
          _topBar(context),
          _bottomCTA(context),
        ],
      ),
    );
  }

  // ───────────────────────── CONTENT ─────────────────────────

  Widget _content(BuildContext context) {
    final topInset = MediaQuery
        .of(context)
        .padding
        .top;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            140 + topInset, // ✅ KEY FIX (header visible)
            16,
            140,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionCard(title: "Delivery Address", child: _addressBlock()),
              const SizedBox(height: 16),

              _sectionCard(title: "Phone Number", child: _phoneBlock()),
              const SizedBox(height: 16),

              _sectionCard(title: "Payment Method", child: _paymentBlock()),
              const SizedBox(height: 16),

              _sectionCard(title: "Order Summary", child: _summaryBlock()),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── ADDRESS ─────────────────────────

  Widget _addressBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: addressCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: "Enter delivery address",
            border: InputBorder.none,
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.my_location_rounded, size: 18),
          label: const Text(
            "Use current location",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  // ───────────────────────── PHONE ─────────────────────────

  Widget _phoneBlock() {
    return TextField(
      controller: phoneCtrl,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        hintText: "03XX-XXXXXXX",
        border: InputBorder.none,
      ),
    );
  }

  // ───────────────────────── PAYMENT ─────────────────────────

  Widget _paymentBlock() {
    return Column(
      children: [
        _paymentTile(
          index: 0,
          title: "Cash on Delivery",
          subtitle: "Pay when order arrives",
          icon: Icons.payments_outlined,
          enabled: true,
        ),
        const SizedBox(height: 12),
        _paymentTile(
          index: 1,
          title: "Wallet",
          subtitle: "Coming soon",
          icon: Icons.account_balance_wallet_outlined,
          enabled: false,
        ),
      ],
    );
  }

  Widget _paymentTile({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool enabled,
  }) {
    final active = paymentMethod == index;

    return InkWell(
      onTap: enabled ? () => setState(() => paymentMethod = index) : null,
      borderRadius: BorderRadius.circular(AppRadius.r18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? AppColors.textDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r18),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? Colors.white : AppColors.textDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: active ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white70 : AppColors.textMid,
                    ),
                  ),
                ],
              ),
            ),
            if (active)
              const Icon(Icons.check_circle, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── SUMMARY ─────────────────────────

  Widget _summaryBlock() {
    return Column(
      children: [
        ...cartItems.map(
              (e) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _summaryRow(
                  "${e["name"]} ×${e["qty"]}",
                  "Rs. ${(e["price"] as int) * (e["qty"] as int)}",
                ),
              ),
        ),
        const Divider(),
        _summaryRow("Subtotal", "Rs. $subtotal"),
        _summaryRow("Delivery", "Rs. $deliveryFee"),
        const SizedBox(height: 6),
        _summaryRow("Total", "Rs. $total", bold: true),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ───────────────────────── SECTION CARD ─────────────────────────

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
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
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ───────────────────────── TOP BAR ─────────────────────────

  Widget _topBar(BuildContext context) {
    return Positioned(
      top: MediaQuery
          .of(context)
          .padding
          .top + 10,
      left: 12,
      right: 12,
      child: Row(
        children: [
          _blurButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            "Checkout",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _blurButton({required IconData icon, required VoidCallback onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: IconButton(onPressed: onTap, icon: Icon(icon)),
      ),
    );
  }

  // ───────────────────────── BOTTOM CTA ─────────────────────────

  Widget _bottomCTA(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.r22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F12).withOpacity(0.94),
                  borderRadius: BorderRadius.circular(AppRadius.r22),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Rs. $total",
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
                        onPressed: () => _placeOrder(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textDark,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(AppRadius.r18),
                          ),
                        ),
                        child: const Text(
                          "Place Order",
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
        ),
      ),
    );
  }

  void _placeOrder(BuildContext context) async {
    // Optional success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Order placed successfully 🎉",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 900),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 900));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const OrderTrackingScreen(),
      ),
    );
  }
}

// ───────────────────── TOP CAP ─────────────────────

class _CheckoutTopCap extends StatelessWidget {
  const _CheckoutTopCap();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: -topInset,
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: _CheckoutHeaderClipper(),
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

class _CheckoutHeaderClipper extends CustomClipper<Path> {
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
