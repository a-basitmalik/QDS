import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';
import '../../theme/app_widgets.dart';

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
    with TickerProviderStateMixin {
  // page entrance
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  // ambient like login
  late final AnimationController _ambientCtrl;
  late final Animation<double> _bgT;
  late final Animation<double> _floatT;

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
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat(reverse: true);

    _bgT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOut);
    _floatT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOutSine);

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _ambientCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ✅ Theme-aligned animated background
          AnimatedBuilder(
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
          ),

          // glow blobs (now using your palette)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _ambientCtrl,
              builder: (context, _) {
                final t = _floatT.value;
                return Stack(
                  children: [
                    _GlowBlob(
                      dx: lerpDouble(-48, 18, t)!,
                      dy: lerpDouble(70, 50, t)!,
                      size: 260,
                      opacity: 0.12,
                      a: AppColors.primary,
                      b: AppColors.secondary,
                    ),
                    _GlowBlob(
                      dx: lerpDouble(210, 290, t)!,
                      dy: lerpDouble(230, 195, t)!,
                      size: 300,
                      opacity: 0.10,
                      a: AppColors.secondary,
                      b: AppColors.other,
                    ),
                  ],
                );
              },
            ),
          ),

          // top cap (same shape, theme shadow)
          Positioned(
            top: -topInset,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _HeaderClipper(),
              child: Container(
                height: 155 + topInset,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: AppShadows.soft, // ✅ replaces missing topCap
                ),
              ),
            ),
          ),

          // content
          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  118 + topInset,
                  16,
                  34,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CenteredHeader3D(type: widget.type),
                    const SizedBox(height: 16),
                    _resultCard(floatingT: _floatT.value),
                    const SizedBox(height: 18),
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

  Widget _resultCard({required double floatingT}) {
    final config = _configFor(widget.type);
    final floatY = sin(floatingT * pi * 2) * 5.0;

    return Transform.translate(
      offset: Offset(0, floatY),
      child: Glass(
        borderRadius: AppRadius.r18,
        sigmaX: 16,
        sigmaY: 16,
        padding: const EdgeInsets.all(22),
        color: Colors.white.withOpacity(0.62),
        borderColor: Colors.white.withOpacity(0.72),
        borderWidth: 1.1,
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 22,
            offset: const Offset(0, 16),
          ),
        ],
        child: Column(
          children: [
            _ResultIcon3D(config: config),
            const SizedBox(height: 16),

            // ✅ 3D title
            _Title3D(
              config.title,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            Text(
              config.message,
              style: AppText.body().copyWith(
                fontSize: 13,
                height: 1.35,
                color: AppColors.ink.withOpacity(0.55),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // ✅ Order id pill (use your widget)
            GlassPill(
              text: "Order ID: ${widget.orderId}",
              onTap: () {}, // NOOP (keeps pill look, no behavior change)
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── ACTIONS ─────────────────────────

  Widget _actionButtons(BuildContext context) {
    return Column(
      children: [
        if (widget.type == OrderResultType.delivered)
          BrandButton(
            text: "Track Order",
            onTap: () {
              // Navigator.push → OrderTrackingScreen
            },
          ),

        if (widget.type != OrderResultType.delivered)
          BrandButton(
            text: "Contact Support",
            onTap: () {},
          ),

        const SizedBox(height: 12),

        // secondary glass button
        PressScale(
          borderRadius: AppRadius.r22,
          downScale: 0.985,
          onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
          child: Glass(
            borderRadius: AppRadius.r22,
            sigmaX: 16,
            sigmaY: 16,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            color: Colors.white.withOpacity(0.55),
            borderColor: Colors.white.withOpacity(0.78),
            borderWidth: 1.1,
            shadows: AppShadows.soft,
            child: Center(
              child: Text(
                "Back to Home",
                style: AppText.button().copyWith(
                  fontSize: 14,
                  color: AppColors.ink.withOpacity(0.90),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────── TOP BAR ─────────────────────────

  Widget _topBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 12,
      child: PressScale(
        borderRadius: AppRadius.pill(),
        downScale: 0.96,
        onTap: () => Navigator.pop(context),
        child: Glass(
          borderRadius: AppRadius.pill(),
          sigmaX: 14,
          sigmaY: 14,
          padding: const EdgeInsets.all(0),
          color: Colors.white.withOpacity(0.58),
          borderColor: Colors.white.withOpacity(0.74),
          borderWidth: 1.1,
          shadows: AppShadows.puck,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.ink.withOpacity(0.72),
            ),
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
          bg: const Color(0xFF10B981),
          title: "Delivered Successfully",
          message: "Your order has been delivered.\nWe hope you enjoyed shopping with us.",
        );

      case OrderResultType.cancelled:
        return _ResultConfig(
          icon: Icons.cancel_rounded,
          bg: const Color(0xFFF59E0B),
          title: "Order Cancelled",
          message: "Unfortunately this item went out of stock.\nYou were not charged.",
        );

      case OrderResultType.refunded:
        return _ResultConfig(
          icon: Icons.account_balance_wallet_rounded,
          bg: const Color(0xFF3B82F6),
          title: "Refund Processed",
          message: "Your amount has been credited to your wallet.\nYou can use it on your next order.",
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

// ============================================================================
// ✅ centered 3D header
// ============================================================================

class _CenteredHeader3D extends StatelessWidget {
  final OrderResultType type;
  const _CenteredHeader3D({required this.type});

  @override
  Widget build(BuildContext context) {
    final String heading = switch (type) {
      OrderResultType.delivered => "ORDER COMPLETE",
      OrderResultType.cancelled => "ORDER UPDATE",
      OrderResultType.refunded => "WALLET UPDATE",
    };

    return Center(
      child: _Title3D(
        heading,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ============================================================================
// ✅ 3D icon badge inside the card
// ============================================================================

class _ResultIcon3D extends StatelessWidget {
  final _ResultConfig config;
  const _ResultIcon3D({required this.config});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 14,
      shadowColor: Colors.black.withOpacity(0.16),
      shape: const CircleBorder(),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  config.bg.withOpacity(0.92),
                  config.bg.withOpacity(0.70),
                ],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.55)),
            ),
            child: Icon(
              config.icon,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ✅ 3D Title (letter-by-letter extrusion) - now theme ink
// ============================================================================

class _Title3D extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign? textAlign;

  const _Title3D(
      this.text, {
        required this.fontSize,
        required this.fontWeight,
        this.textAlign,
      });

  @override
  Widget build(BuildContext context) {
    final base = AppColors.ink;

    return Text.rich(
      TextSpan(
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
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
      textAlign: textAlign ?? TextAlign.left,
    );
  }
}

// ============================================================================
// TOP CAP CLIPPER
// ============================================================================

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

// ============================================================================
// Glow blob (palette-aware)
// ============================================================================

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
