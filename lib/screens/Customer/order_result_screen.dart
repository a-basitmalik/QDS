import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';

enum OrderResultType {
  delivered,
  cancelled,
  refunded,
}

class OrderResultScreen extends StatefulWidget {
  final OrderResultType type;
  final String orderId;

  const OrderResultScreen({
    super.key,
    required this.type,
    required this.orderId,
  });

  @override
  State<OrderResultScreen> createState() => _OrderResultScreenState();
}

class _OrderResultScreenState extends State<OrderResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const _OrderResultTopCap(),

          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  140 + topInset,
                  16,
                  40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _resultCard(),
                    const SizedBox(height: 20),
                    _actionButtons(context),
                  ],
                ),
              ),
            ),
          ),

          _topBar(context),
        ],
      ),
    );
  }

  // ───────────────────────── RESULT CARD ─────────────────────────

  Widget _resultCard() {
    final config = _configFor(widget.type);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r18),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.softCard,
      ),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: config.bg,
            ),
            child: Icon(
              config.icon,
              size: 38,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),

          Text(
            config.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          Text(
            config.message,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMid,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.chipFill,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              "Order ID: ${widget.orderId}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── ACTIONS ─────────────────────────

  Widget _actionButtons(BuildContext context) {
    return Column(
      children: [
        if (widget.type == OrderResultType.delivered)
          _primaryButton(
            label: "Track Order",
            onTap: () {
              // Navigator.push → OrderTrackingScreen
            },
          ),

        if (widget.type != OrderResultType.delivered)
          _primaryButton(
            label: "Contact Support",
            onTap: () {},
          ),

        const SizedBox(height: 12),

        _secondaryButton(
          label: "Back to Home",
          onTap: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ],
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.r22),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.r22),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }

  // ───────────────────────── TOP BAR ─────────────────────────

  Widget _topBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 12,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── CONFIG ─────────────────────────

  _ResultConfig _configFor(OrderResultType type) {
    switch (type) {
      case OrderResultType.delivered:
        return _ResultConfig(
          icon: Icons.check_circle_rounded,
          bg: Colors.green,
          title: "Delivered Successfully 🎉",
          message:
          "Your order has been delivered.\nWe hope you enjoyed shopping with us.",
        );

      case OrderResultType.cancelled:
        return _ResultConfig(
          icon: Icons.cancel_rounded,
          bg: Colors.orange,
          title: "Order Cancelled",
          message:
          "Unfortunately this item went out of stock.\nYou were not charged.",
        );

      case OrderResultType.refunded:
        return _ResultConfig(
          icon: Icons.account_balance_wallet_rounded,
          bg: Colors.blue,
          title: "Refund Processed",
          message:
          "Your amount has been credited to your wallet.\nYou can use it on your next order.",
        );
    }
  }
}

// ───────────────────────── MODEL ─────────────────────────

class _ResultConfig {
  final IconData icon;
  final Color bg;
  final String title;
  final String message;

  _ResultConfig({
    required this.icon,
    required this.bg,
    required this.title,
    required this.message,
  });
}

// ───────────────────── TOP CAP ─────────────────────

class _OrderResultTopCap extends StatelessWidget {
  const _OrderResultTopCap();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: -topInset,
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: _HeaderClipper(),
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

class _HeaderClipper extends CustomClipper<Path> {
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
