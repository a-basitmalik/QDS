import 'dart:math';
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
          // ✅ Nexora animated background (same vibe as login)
          AnimatedBuilder(
            animation: _ambientCtrl,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(
                        const Color(0xFFF7F7FA),
                        const Color(0xFFEFF1FF),
                        _bgT.value,
                      )!,
                      Color.lerp(
                        const Color(0xFFF7F7FA),
                        const Color(0xFFFBEFFF),
                        _bgT.value,
                      )!,
                      const Color(0xFFF7F7FA),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              );
            },
          ),

          // glow blobs
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
                      opacity: 0.14,
                    ),
                    _GlowBlob(
                      dx: lerpDouble(210, 290, t)!,
                      dy: lerpDouble(230, 195, t)!,
                      size: 300,
                      opacity: 0.10,
                    ),
                  ],
                );
              },
            ),
          ),

          // top cap (same shape)
          Positioned(
            top: -topInset,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _HeaderClipper(),
              child: Container(
                height: 155 + topInset,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: AppShadows.topCap,
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
                    // ✅ centered 3D heading (replaces old top title)
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.r18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.r18),
              border: Border.all(color: Colors.white.withOpacity(0.62)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.72),
                  Colors.white.withOpacity(0.48),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 22,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
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
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7A7E92).withOpacity(0.95),
                    height: 1.35,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Order id pill (glassy)
                _GlassSmallPill(
                  child: Text(
                    "Order ID: ${widget.orderId}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E2235),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── ACTIONS ─────────────────────────

  Widget _actionButtons(BuildContext context) {
    return Column(
      children: [
        if (widget.type == OrderResultType.delivered)
          _PrimaryGlassButton(
            label: "Track Order",
            onTap: () {
              // Navigator.push → OrderTrackingScreen
            },
          ),

        if (widget.type != OrderResultType.delivered)
          _PrimaryGlassButton(
            label: "Contact Support",
            onTap: () {},
          ),

        const SizedBox(height: 12),

        _SecondaryGlassButton(
          label: "Back to Home",
          onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
      ],
    );
  }

  // ───────────────────────── TOP BAR ─────────────────────────

  Widget _topBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 12,
      child: _GlassIconPuck(
        icon: Icons.arrow_back_ios_new_rounded,
        onTap: () => Navigator.pop(context),
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
// ✅ New: centered 3D header (like login’s premium heading)
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
// ✅ New: 3D icon badge inside the card
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
// ✅ Buttons (match login style: premium + depth)
// ============================================================================

class _PrimaryGlassButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryGlassButton({required this.label, required this.onTap});

  @override
  State<_PrimaryGlassButton> createState() => _PrimaryGlassButtonState();
}

class _PrimaryGlassButtonState extends State<_PrimaryGlassButton> {
  bool _hover = false;
  bool _press = false;

  @override
  Widget build(BuildContext context) {
    final active = _hover || _press;
    final scale = _press ? 0.97 : (_hover ? 1.03 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _press = false;
      }),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _press = true),
        onTapUp: (_) => setState(() => _press = false),
        onTapCancel: () => setState(() => _press = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          scale: scale,
          child: Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.r22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E2235),
                  Color.lerp(const Color(0xFF3A3F67), const Color(0xFF4B52A6), active ? 0.45 : 0.0)!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(active ? 0.18 : 0.14),
                  blurRadius: active ? 18 : 16,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                // glossy streak
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.r22),
                    child: Opacity(
                      opacity: 0.20,
                      child: Transform.rotate(
                        angle: -0.35,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.60),
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
                    widget.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontSize: 14,
                      letterSpacing: 0.2,
                    ),
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

class _SecondaryGlassButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _SecondaryGlassButton({required this.label, required this.onTap});

  @override
  State<_SecondaryGlassButton> createState() => _SecondaryGlassButtonState();
}

class _SecondaryGlassButtonState extends State<_SecondaryGlassButton> {
  bool _hover = false;
  bool _press = false;

  @override
  Widget build(BuildContext context) {
    final active = _hover || _press;
    final scale = _press ? 0.98 : (_hover ? 1.02 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _press = false;
      }),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _press = true),
        onTapUp: (_) => setState(() => _press = false),
        onTapCancel: () => setState(() => _press = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          scale: scale,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.r22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(active ? 0.62 : 0.54),
                  borderRadius: BorderRadius.circular(AppRadius.r22),
                  border: Border.all(
                    color: Colors.white.withOpacity(active ? 0.78 : 0.62),
                    width: active ? 1.2 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E2235),
                    fontSize: 14,
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

// ============================================================================
// ✅ Small glass pill for Order ID
// ============================================================================

class _GlassSmallPill extends StatelessWidget {
  final Widget child;
  const _GlassSmallPill({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.62)),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ============================================================================
// ✅ Glass icon puck (same style you used earlier)
// ============================================================================

class _GlassIconPuck extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconPuck({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: Colors.white.withOpacity(0.55),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.62)),
              ),
              child: Icon(
                icon,
                size: 20,
                color: const Color(0xFF1E2235).withOpacity(0.75),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ✅ 3D Title (letter-by-letter extrusion)
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
    const base = Color(0xFF1B1E2B);

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
// TOP CAP CLIPPER (same as your other screens)
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
      child: IgnorePointer(
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
      ),
    );
  }
}
