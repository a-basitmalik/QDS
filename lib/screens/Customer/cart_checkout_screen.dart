// ✅ COMPLETE updated Checkout screen — MATCHES your FINAL Theme (AppColors/AppRadius/AppShadows/AppText)
// FIXED (so it compiles with your theme files):
// - ❌ Removed AppColors.bg / textDark / textMid / divider (not in your theme)
// - ❌ Removed AppShadows.topCap (not in your theme)
// - ✅ Uses AppColors.bg1/bg2/bg3, ink, muted, borderBase(), brandLinear, primary/secondary/other
// - ✅ Uses AppRadius + AppShadows.soft everywhere
// - ✅ Keeps: layout, sticky header, step tracking, scroll, dialogs, animations, bottom CTA, success sheet
// NOTE: Self-contained helpers included (PressGlowScale etc.)

import 'dart:math';
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
    with TickerProviderStateMixin {
  // Page enter
  late final AnimationController _enterCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  // Ambient background
  late final AnimationController _ambientCtrl;
  late final Animation<double> _bgT;
  late final Animation<double> _floatT;

  // CTA press
  late final AnimationController _btnCtrl;
  late final Animation<double> _btnT;

  // Scroll + step tracking
  final ScrollController _scrollCtrl = ScrollController();
  final _kAddress = GlobalKey();
  final _kPayment = GlobalKey();
  final _kConfirm = GlobalKey();
  int _activeStep = 0; // 0=Address, 1=Payment, 2=Confirm

  final phoneCtrl = TextEditingController(text: "03XX-XXXXXXX");
  final addressCtrl =
  TextEditingController(text: "House 12, Street 8, Johar Town, Lahore");

  int paymentMethod = 0; // 0 = COD, 1 = Wallet

  final cartItems = const [
    {"name": "Classic Watch", "price": 4999, "qty": 1},
    {"name": "Leather Wallet", "price": 2999, "qty": 1},
  ];

  static const double _capBaseH = 140.0;
  static const double _stickyHeaderH = 64.0;
  static const double _stickyStepsH = 52.0;

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));

    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    )..repeat(reverse: true);
    _bgT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOut);
    _floatT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOutSine);

    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _btnT = CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOut);

    _enterCtrl.forward();

    _scrollCtrl.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleScroll());
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_handleScroll);
    _scrollCtrl.dispose();

    phoneCtrl.dispose();
    addressCtrl.dispose();
    _enterCtrl.dispose();
    _ambientCtrl.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  int get subtotal => cartItems.fold(
    0,
        (sum, e) => sum + (e["price"] as int) * (e["qty"] as int),
  );

  int get deliveryFee => 199;
  int get total => subtotal + deliveryFee;

  // ───────────────────────── Step tracking ─────────────────────────

  void _handleScroll() {
    final idx = _closestSectionIndex();
    if (idx != null && idx != _activeStep) {
      setState(() => _activeStep = idx);
    }
  }

  int? _closestSectionIndex() {
    final topInset = MediaQuery.of(context).padding.top;

    // "reading line" below header + steps row
    final readingY = topInset + 6 + _stickyHeaderH + 10 + _stickyStepsH + 14;

    final a = _distToKey(_kAddress, readingY);
    final p = _distToKey(_kPayment, readingY);
    final c = _distToKey(_kConfirm, readingY);

    final entries = <int, double?>{0: a, 1: p, 2: c}
        .entries
        .where((e) => e.value != null)
        .map((e) => MapEntry(e.key, e.value!))
        .toList();

    if (entries.isEmpty) return null;
    entries.sort((x, y) => x.value.compareTo(y.value));
    return entries.first.key;
  }

  double? _distToKey(GlobalKey key, double readingY) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final ro = ctx.findRenderObject();
    if (ro is! RenderBox) return null;
    final dy = ro.localToGlobal(Offset.zero).dy;
    return (dy - readingY).abs();
  }

  void _scrollToKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;

    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      alignment: 0.06,
    );
  }

  // ───────────────────────── BUILD ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    // Prevent collision with sticky header + step row
    final contentTopPadding =
        _capBaseH + topInset + _stickyHeaderH + 10 + _stickyStepsH + 16;

    return Scaffold(
      backgroundColor: AppColors.bg3,
      body: Stack(
        children: [
          // ✅ Animated theme background
          AnimatedBuilder(
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
          ),

          // ✅ Subtle haze overlay
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _ambientCtrl,
              builder: (context, _) {
                final t = _floatT.value;
                return Opacity(
                  opacity: 0.10,
                  child: Transform.translate(
                    offset: Offset(
                      lerpDouble(-18, 18, t)!,
                      lerpDouble(10, -10, t)!,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0.2, -0.6),
                          radius: 1.25,
                          colors: [
                            AppColors.secondary.withOpacity(0.30),
                            AppColors.primary.withOpacity(0.22),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.42, 1.0],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ✅ Floating blobs (theme colors)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _ambientCtrl,
              builder: (context, _) {
                final t = _floatT.value;
                return Stack(
                  children: [
                    _GlowBlob(
                      dx: lerpDouble(-40, 22, t)!,
                      dy: lerpDouble(86, 58, t)!,
                      size: 230,
                      opacity: 0.14,
                      a: AppColors.secondary,
                      b: AppColors.other,
                    ),
                    _GlowBlob(
                      dx: lerpDouble(240, 290, t)!,
                      dy: lerpDouble(240, 200, t)!,
                      size: 270,
                      opacity: 0.11,
                      a: AppColors.primary,
                      b: AppColors.secondary,
                    ),
                    _GlowBlob(
                      dx: lerpDouble(210, 250, 1 - t)!,
                      dy: lerpDouble(28, 18, t)!,
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

          // ✅ Top cap (unchanged shape, theme shadows)
          const _CheckoutTopCap(),

          // ✅ Content
          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16, contentTopPadding, 16, 170),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ADDRESS
                    Container(
                      key: _kAddress,
                      child: _sectionCard(
                        title: "Address Details",
                        icon: Icons.location_on_outlined,
                        child: _addressBlock(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // PHONE
                    _sectionCard(
                      title: "Phone Number",
                      icon: Icons.phone_rounded,
                      child: _phoneBlock(),
                    ),
                    const SizedBox(height: 16),

                    // PAYMENT
                    Container(
                      key: _kPayment,
                      child: _sectionCard(
                        title: "Payment",
                        icon: Icons.payments_outlined,
                        child: _paymentBlock(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CONFIRM
                    Container(
                      key: _kConfirm,
                      child: _sectionCard(
                        title: "Confirm",
                        icon: Icons.verified_rounded,
                        child: _confirmBlock(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ORDER SUMMARY
                    _sectionCard(
                      title: "Order Summary",
                      icon: Icons.receipt_long_rounded,
                      child: _summaryBlock(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ✅ Sticky header + step row
          _stickyCenteredHeader(context),
          _stickyStepCards(context),

          // ✅ Bottom CTA
          _bottomCTA(context),
        ],
      ),
    );
  }

  // ───────────────────────── Sticky Header ─────────────────────────

  Widget _stickyCenteredHeader(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topInset + 6,
      left: 12,
      right: 12,
      child: _PressGlowScale(
        downScale: 0.992,
        glowColor: AppColors.secondary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        onTap: () {}, // decorative press
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: _stickyHeaderH,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.80),
                    Colors.white.withOpacity(0.58),
                    Colors.white.withOpacity(0.74),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderBase(0.85)),
                boxShadow: AppShadows.soft,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _PressGlowScale(
                      downScale: 0.94,
                      glowColor: AppColors.secondary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.pop(context),
                      child: _IconPillButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  const _Title3DHolo(text: "CHECKOUT", fontSize: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _PressGlowScale(
                      downScale: 0.94,
                      glowColor: AppColors.other.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {},
                      child: _IconPillButton(
                        icon: Icons.lock_outline_rounded,
                        onTap: () {},
                        muted: true,
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

  // ───────────────────────── Sticky Step Cards ─────────────────────────

  Widget _stickyStepCards(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topInset + 6 + _stickyHeaderH + 10,
      left: 12,
      right: 12,
      child: Row(
        children: [
          Expanded(
            child: _StepCard(
              text: "Address",
              active: _activeStep == 0,
              onTap: () => _scrollToKey(_kAddress),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StepCard(
              text: "Payment",
              active: _activeStep == 1,
              onTap: () => _scrollToKey(_kPayment),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StepCard(
              text: "Confirm",
              active: _activeStep == 2,
              onTap: () => _scrollToKey(_kConfirm),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Address Block ─────────────────────────

  Widget _addressBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lightWhitishFieldRow(
          leading: Icons.home_rounded,
          child: TextField(
            controller: addressCtrl,
            maxLines: 2,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
            decoration: InputDecoration(
              hintText: "Enter delivery address",
              hintStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.muted.withOpacity(0.95),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.only(top: 6, bottom: 2),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: _PressGlowScale(
            downScale: 0.97,
            glowColor: AppColors.secondary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
            onTap: () {},
            child: _GhostAction(
              icon: Icons.my_location_rounded,
              text: "Use current location",
              onTap: () {},
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────── Phone Block ─────────────────────────

  Widget _phoneBlock() {
    return _lightWhitishFieldRow(
      leading: Icons.phone_rounded,
      child: TextField(
        controller: phoneCtrl,
        keyboardType: TextInputType.phone,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
        decoration: InputDecoration(
          hintText: "03XX-XXXXXXX",
          hintStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.muted.withOpacity(0.95),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.only(top: 6, bottom: 2),
        ),
      ),
    );
  }

  // ───────────────────────── Payment ─────────────────────────

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
    final isCashOnDelivery = index == 0;

    return _PressGlowScale(
      downScale: 0.985,
      glowColor: (active
          ? AppColors.secondary.withOpacity(0.14)
          : Colors.black.withOpacity(0.05))
          .withOpacity(1),
      borderRadius: AppRadius.r18,
      onTap: enabled ? () => setState(() => paymentMethod = index) : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: AppRadius.r18,
          border: Border.all(
            color: active && isCashOnDelivery
                ? Colors.white.withOpacity(0.20)
                : active
                ? AppColors.borderBase(0.85)
                : AppColors.borderBase(0.70),
          ),
          gradient: active && isCashOnDelivery
              ? AppColors.brandLinear
              : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(active ? 0.95 : 0.92),
              Colors.white.withOpacity(active ? 0.88 : 0.86),
            ],
          ),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            _iconChipLight(
              icon,
              enabled: enabled,
              isCashOnDeliveryActive: active && isCashOnDelivery,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: active && isCashOnDelivery
                          ? Colors.white
                          : enabled
                          ? AppColors.ink
                          : AppColors.muted.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: active && isCashOnDelivery
                          ? Colors.white.withOpacity(0.85)
                          : AppColors.muted.withOpacity(enabled ? 1 : 0.6),
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              active
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: active && isCashOnDelivery
                  ? Colors.white
                  : active
                  ? AppColors.ink.withOpacity(0.65)
                  : AppColors.muted.withOpacity(enabled ? 0.65 : 0.35),
            ),
            if (!enabled) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: AppRadius.pill(),
                  border: Border.all(color: AppColors.borderBase(0.75)),
                ),
                child: Text(
                  "Soon",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    color: AppColors.muted.withOpacity(0.95),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


  Widget _iconChipLight(
      IconData icon, {
        required bool enabled,
        bool isCashOnDeliveryActive = false,
      }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isCashOnDeliveryActive
            ? Colors.white.withOpacity(0.20)
            : Colors.white.withOpacity(0.95),
        border: Border.all(
          color: isCashOnDeliveryActive
              ? Colors.white.withOpacity(0.28)
              : AppColors.borderBase(0.80),
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Icon(
        icon,
        size: 20,
        color: isCashOnDeliveryActive
            ? Colors.white
            : enabled
            ? AppColors.ink.withOpacity(0.80)
            : AppColors.muted.withOpacity(0.70),
      ),
    );
  }

  // ───────────────────────── Confirm ─────────────────────────

  Widget _confirmBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Review your details before placing the order.",
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.muted.withOpacity(0.95),
          ),
        ),
        const SizedBox(height: 10),
        _confirmRow("Address", addressCtrl.text),
        const SizedBox(height: 8),
        _confirmRow("Phone", phoneCtrl.text),
        const SizedBox(height: 8),
        _confirmRow(
          "Payment",
          paymentMethod == 0 ? "Cash on Delivery" : "Wallet",
        ),
      ],
    );
  }

  Widget _confirmRow(String label, String value) {
    return _lightWhitishMiniRow(leftLabel: label, value: value);
  }

  // ───────────────────────── Summary ─────────────────────────

  Widget _summaryBlock() {
    return Column(
      children: [
        ...cartItems.map(
              (e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "${e["name"]} ×${e["qty"]}",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                Text(
                  "Rs. ${(e["price"] as int) * (e["qty"] as int)}",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(height: 18, color: AppColors.borderBase(0.75)),
        _summaryRow("Subtotal", "Rs. $subtotal"),
        _summaryRow("Delivery", "Rs. $deliveryFee"),
        const SizedBox(height: 8),
        _summaryRow("Total", "Rs. $total", bold: true),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
                color: bold ? AppColors.ink : AppColors.muted,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Section Card ─────────────────────────

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return _PressGlowScale(
      downScale: 0.992,
      glowColor: AppColors.secondary.withOpacity(0.10),
      borderRadius: AppRadius.r18, // ✅ fixed
      onTap: () {}, // decorative press
      child: _LightWhitishCard(
        floatingT: _floatT.value,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _PressGlowScale(
                  downScale: 0.95,
                  glowColor: AppColors.other.withOpacity(0.10),
                  borderRadius: AppRadius.r12, // ✅ fixed (matches your AppRadius)
                  onTap: () {},
                  child: _IconBadgeLight(icon: icon),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppText.h2().copyWith(
                    fontSize: 18,
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }


  // ───────────────────────── Bottom CTA ─────────────────────────

  Widget _bottomCTA(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _LightWhitishCard(
            floatingT: _floatT.value,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.muted.withOpacity(0.95),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Rs. $total",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _ShinyCTAButton(
                  ctrl: _btnCtrl,
                  t: _btnT,
                  text: "Place Order",
                  onTap: () async {
                    await _btnCtrl.forward();
                    await _btnCtrl.reverse();
                    _placeOrder(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Place Order -> BIG glass success sheet 3 sec -> next screen
  void _placeOrder(BuildContext context) async {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "order_success",
      barrierColor: Colors.black.withOpacity(0.10),
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (ctx, a1, a2) => const _OrderSuccessBigGlassSheet(),
      transitionBuilder: (ctx, anim, secAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.18),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    Navigator.of(context).pop(); // close sheet

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OrderTrackingScreen()),
    );
  }

  // ───────────────────────── Inputs (LIGHT rows) ─────────────────────────

  Widget _lightWhitishFieldRow({
    required IconData leading,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: AppRadius.r18,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: AppRadius.r18,
            border: Border.all(color: AppColors.borderBase(0.90)),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PressGlowScale(
                downScale: 0.94,
                glowColor: AppColors.secondary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
                onTap: () {},
                child: _alignedLeadingIconLight(leading),
              ),
              const SizedBox(width: 10),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }

  Widget _alignedLeadingIconLight(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderBase(0.80)),
        boxShadow: AppShadows.soft,
      ),
      child: Icon(icon, size: 18, color: AppColors.ink),
    );
  }

  Widget _lightWhitishMiniRow({
    required String leftLabel,
    required String value,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderBase(0.90)),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 76,
                child: Text(
                  leftLabel,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
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
          height: _CartCheckoutScreenState._capBaseH + topInset,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: AppShadows.soft,
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

// ───────────────────── BACKGROUND BLOBS ─────────────────────

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

// ───────────────────── LIGHT CARDS ─────────────────────

class _LightWhitishCard extends StatelessWidget {
  final Widget child;
  final double floatingT;
  final EdgeInsets padding;

  const _LightWhitishCard({
    required this.child,
    required this.floatingT,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final floatY = sin(floatingT * pi * 2) * 2.2;

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
              border: Border.all(color: AppColors.borderBase(0.90)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.78),
                  Colors.white.withOpacity(0.56),
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
                            Colors.white.withOpacity(0.62),
                            Colors.white.withOpacity(0.12),
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

class _IconBadgeLight extends StatelessWidget {
  final IconData icon;
  const _IconBadgeLight({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderBase(0.80)),
        boxShadow: AppShadows.soft,
      ),
      child: Icon(icon, color: AppColors.ink, size: 18),
    );
  }
}

// ───────────────────── TITLE (3D HOLO) ─────────────────────

class _Title3DHolo extends StatelessWidget {
  final String text;
  final double fontSize;
  const _Title3DHolo({required this.text, this.fontSize = 20});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (int i = 12; i >= 1; i--)
          Transform.translate(
            offset: Offset(0, i.toDouble() * 0.8),
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.6,
                color: Colors.black.withOpacity(0.05),
              ),
            ),
          ),
        ShaderMask(
          shaderCallback: (rect) => AppColors.brandLinear.createShader(rect),
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                  color: AppColors.secondary.withOpacity(0.18),
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

// ───────────────────── STEP CARD ─────────────────────

class _StepCard extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _StepCard({
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PressGlowScale(
      downScale: 0.97,
      glowColor: active
          ? AppColors.secondary.withOpacity(0.10)
          : Colors.black.withOpacity(0.05),
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.white.withOpacity(active ? 0.95 : 0.88),
          border: Border.all(
            color: active ? AppColors.borderBase(0.85) : AppColors.borderBase(0.70),
          ),
          boxShadow: AppShadows.soft,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: active ? AppColors.ink.withOpacity(0.95) : AppColors.muted.withOpacity(0.90),
          ),
        ),
      ),
    );
  }
}

// ───────────────────── ICON BUTTON ─────────────────────

class _IconPillButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool muted;

  const _IconPillButton({
    required this.icon,
    required this.onTap,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderBase(0.80)),
          boxShadow: AppShadows.soft,
        ),
        child: Icon(
          icon,
          color: muted ? AppColors.muted.withOpacity(0.95) : AppColors.ink,
        ),
      ),
    );
  }
}

// ───────────────────── GHOST ACTION BUTTON ─────────────────────

class _GhostAction extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _GhostAction({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderBase(0.80)),
              boxShadow: AppShadows.soft,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: AppColors.ink),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
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

// ───────────────────── CTA BUTTON (kept) ─────────────────────

class _ShinyCTAButton extends StatelessWidget {
  final AnimationController ctrl;
  final Animation<double> t;
  final String text;
  final VoidCallback onTap;

  const _ShinyCTAButton({
    required this.ctrl,
    required this.t,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) {
        final press = lerpDouble(0, 2.5, t.value)!;
        final lift = lerpDouble(3, 0, t.value)!;

        return GestureDetector(
          onTapDown: (_) => ctrl.forward(),
          onTapCancel: () => ctrl.reverse(),
          onTapUp: (_) => ctrl.reverse(),
          onTap: onTap,
          child: Transform.translate(
            offset: Offset(0, -lift + press),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        opacity: 0.20,
                        child: Transform.rotate(
                          angle: -0.35,
                          child: Container(
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
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
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

// ───────────────────── PRESS + LIGHT-UP (NO HOVER) ─────────────────────

class _PressGlowScale extends StatefulWidget {
  final Widget child;
  final double downScale;
  final Duration duration;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  final Color glowColor;
  final double glowBlur;
  final Offset glowOffset;

  const _PressGlowScale({
    required this.child,
    this.onTap,
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

// ───────────────────── SUCCESS BIG GLASS SHEET (kept) ─────────────────────

class _OrderSuccessBigGlassSheet extends StatefulWidget {
  const _OrderSuccessBigGlassSheet();

  @override
  State<_OrderSuccessBigGlassSheet> createState() =>
      _OrderSuccessBigGlassSheetState();
}

class _OrderSuccessBigGlassSheetState extends State<_OrderSuccessBigGlassSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _tickPop;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _tickPop = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final sheetH = max(h * 0.52, 360.0);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer()),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (context, _) {
                    return FadeTransition(
                      opacity: _fade,
                      child: Transform.scale(
                        scale: lerpDouble(0.98, 1.0, _scale.value)!,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                            child: Container(
                              height: sheetH,
                              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.68),
                                    Colors.white.withOpacity(0.48),
                                    Colors.white.withOpacity(0.62),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: AppColors.borderBase(0.90),
                                  width: 1.5,
                                ),
                                boxShadow: AppShadows.soft,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Transform.scale(
                                    scale: lerpDouble(0.60, 1.0, _tickPop.value)!,
                                    child: ClipOval(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                        child: Container(
                                          width: 118,
                                          height: 118,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.white.withOpacity(0.78),
                                                Colors.white.withOpacity(0.58),
                                              ],
                                            ),
                                            border: Border.all(
                                              color: AppColors.borderBase(0.90),
                                              width: 1.8,
                                            ),
                                            boxShadow: AppShadows.soft,
                                          ),
                                          child: Icon(
                                            Icons.check_rounded,
                                            size: 66,
                                            color: AppColors.ink.withOpacity(0.75),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  Text(
                                    "Order Confirmed",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Preparing your delivery…",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                      child: Container(
                                        height: 12,
                                        width: 240,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.45),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(
                                            color: AppColors.borderBase(0.80),
                                          ),
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: FractionallySizedBox(
                                            widthFactor: min(1.0, _ctrl.value * 1.2),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.secondary.withOpacity(0.28),
                                                    AppColors.primary.withOpacity(0.35),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Redirecting…",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
