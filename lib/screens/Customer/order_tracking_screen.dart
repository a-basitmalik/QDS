import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';
import '../../theme/app_widgets.dart';
import 'order_result_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TickerProviderStateMixin {
  // page entrance
  late final AnimationController _enterCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  // ambient
  late final AnimationController _ambientCtrl;
  late final Animation<double> _bgT;
  late final Animation<double> _floatT;

  // bottom dock press
  late final AnimationController _dockCtrl;
  late final Animation<double> _dockT;

  /// Demo status index (0–5)
  int currentStep = 3;

  final steps = const [
    "Searching shop",
    "Accepted by shop",
    "Rider assigned",
    "Picked up",
    "On the way",
    "Delivered",
  ];

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));

    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5400),
    )..repeat(reverse: true);

    _bgT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOut);
    _floatT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOutSine);

    _dockCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _dockT = CurvedAnimation(parent: _dockCtrl, curve: Curves.easeOutCubic);

    _enterCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndNavigateResult();
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _ambientCtrl.dispose();
    _dockCtrl.dispose();
    super.dispose();
  }

  /// ✅ DELIVERY → RESULT LINK
  void _checkAndNavigateResult() {
    if (currentStep == steps.length - 1) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const OrderResultScreen(
              type: OrderResultType.delivered,
              orderId: "QDS-28471",
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _animatedBackground(),
          _glowBlobs(),

          _TrackingTopCap(),

          _content(topInset),

          _topBar(context),

          // ✅ redesigned premium dock
          _bottomCommandDock(context),
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
                Color.lerp(AppColors.bg3, AppColors.bg2, _bgT.value)!,
                Color.lerp(AppColors.bg3, AppColors.bg1, _bgT.value)!,
                AppColors.bg3,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _glowBlobs() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ambientCtrl,
        builder: (context, _) {
          final t = _floatT.value;
          return Stack(
            children: [
              _GlowBlob(
                dx: lerpDouble(-42, 18, t)!,
                dy: lerpDouble(72, 50, t)!,
                size: 240,
                opacity: 0.12,
                a: AppColors.primary,
                b: AppColors.secondary,
              ),
              _GlowBlob(
                dx: lerpDouble(230, 290, t)!,
                dy: lerpDouble(235, 195, t)!,
                size: 290,
                opacity: 0.10,
                a: AppColors.secondary,
                b: AppColors.other,
              ),
              _GlowBlob(
                dx: lerpDouble(110, 140, t)!,
                dy: lerpDouble(520, 560, t)!,
                size: 240,
                opacity: 0.08,
                a: AppColors.primary,
                b: AppColors.other,
              ),
            ],
          );
        },
      ),
    );
  }

  // ───────────────────────── CONTENT ─────────────────────────

  Widget _content(double topInset) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 140 + topInset, 16, 170),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _orderHeader(),
              const SizedBox(height: 18),
              _timeline(),
              const SizedBox(height: 24),
              _liveRiderCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── HEADER CARD ─────────────────────────

  Widget _orderHeader() {
    return _GlassCard(
      floatingT: _floatT.value,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order #QDS-28471",
            style: AppText.h2(),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                "Estimated delivery • 25–35 min",
                style: AppText.body().copyWith(
                  fontSize: 13,
                  color: AppColors.ink.withOpacity(0.55),
                ),
              ),
              const Spacer(),
              _miniStatusPill(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStatusPill() {
    final done = currentStep >= 4;
    final active = currentStep == 4;

    return AnimatedBuilder(
      animation: _ambientCtrl,
      builder: (_, __) {
        final pulse = 0.65 + sin(_floatT.value * pi * 2) * 0.18;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: AppRadius.pill(),
            color: Colors.white.withOpacity(0.62),
            border: Border.all(color: Colors.white.withOpacity(0.75)),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary
                    .withOpacity((active ? 0.22 : 0.12) * pulse),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                done ? Icons.check_circle_rounded : Icons.timelapse_rounded,
                size: 16,
                color: AppColors.ink.withOpacity(0.8),
              ),
              const SizedBox(width: 6),
              Text(
                done ? "Almost there" : "Live",
                style: AppText.kicker().copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink.withOpacity(0.88),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ───────────────────────── TIMELINE ─────────────────────────

  Widget _timeline() {
    return _GlassCard(
      floatingT: _floatT.value * 0.85,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(steps.length, (i) {
          final done = i <= currentStep;
          final active = i == currentStep;
          final last = i == steps.length - 1;

          // ✅ Removed hover: now pure press effect (works mobile+web)
          return _PressScale(
            onTap: () {}, // optional
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      _HoloTick(done: done, active: active, t: _floatT.value),
                      if (!last) _HoloLine(done: done, t: _floatT.value),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                          done ? FontWeight.w900 : FontWeight.w700,
                          color: done
                              ? AppColors.ink.withOpacity(0.92)
                              : AppColors.ink.withOpacity(0.55),
                        ),
                        child: Text(steps[i]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ───────────────────────── RIDER CARD ─────────────────────────

  Widget _liveRiderCard() {
    return _GlassCard(
      floatingT: _floatT.value,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _avatarPuck(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rider: Ali Khan", style: AppText.h3()),
                const SizedBox(height: 4),
                Text(
                  "Bike • 2.1 km away",
                  style: AppText.subtle().copyWith(
                    fontSize: 12,
                    color: AppColors.ink.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),
          _PressScale(
            onTap: () {},
            child: const _GlassActionPuck(
              icon: Icons.phone_rounded,
              label: "Call",
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarPuck() {
    return Material(
      color: Colors.transparent,
      elevation: 14,
      shadowColor: Colors.black.withOpacity(0.14),
      shape: const CircleBorder(),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.68),
                  Colors.white.withOpacity(0.46),
                ],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.72)),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.delivery_dining_rounded,
              color: AppColors.ink.withOpacity(0.75),
            ),
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
      right: 12,
      child: Row(
        children: [
          _PressScale(
            onTap: () => Navigator.pop(context),
            child: const _TopIconPuck(icon: Icons.arrow_back_ios_new_rounded),
          ),
          const Spacer(),
          const _Extruded3DTitle(text: "ORDER TRACKING"),
          const Spacer(),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  // ───────────────────────── NEW BOTTOM COMMAND DOCK ─────────────────────────

  Widget _bottomCommandDock(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AnimatedBuilder(
            animation: Listenable.merge([_ambientCtrl, _dockCtrl]),
            builder: (context, _) {
              final press = lerpDouble(0, 2.4, _dockT.value)!;
              final lift = lerpDouble(12, 0, _dockT.value)!;
              final floatY = sin(_floatT.value * pi * 2) * 2.0;

              return Transform.translate(
                offset: Offset(0, -lift + press + floatY),
                child: ClipRRect(
                  borderRadius: AppRadius.r24,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.r24,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.92),
                            AppColors.secondary.withOpacity(0.88),
                            AppColors.primary.withOpacity(0.92),
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.14),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.36),
                            blurRadius: 50,
                            offset: const Offset(0, 34),
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: AppColors.secondary.withOpacity(0.18),
                            blurRadius: 36,
                            offset: const Offset(0, 20),
                            spreadRadius: -8,
                          ),
                          BoxShadow(
                            color: AppColors.other.withOpacity(0.12),
                            blurRadius: 34,
                            offset: const Offset(0, 18),
                            spreadRadius: -12,
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.18),
                            blurRadius: 24,
                            offset: const Offset(0, -14),
                            spreadRadius: -18,
                            blurStyle: BlurStyle.inner,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // holographic sheen sweep
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Opacity(
                                opacity: 0.55,
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
                                            AppColors.secondary
                                                .withOpacity(0.18),
                                            AppColors.other.withOpacity(0.12),
                                            Colors.white.withOpacity(0.0),
                                          ],
                                          stops: const [0.10, 0.42, 0.62, 0.92],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // top mini info row
                              _dockMiniInfo(),

                              const SizedBox(height: 10),

                              // actions row
                              Row(
                                children: [
                                  // left: secondary actions as pucks
                                  _PressScale(
                                    onTap: () async {
                                      await _dockCtrl.forward();
                                      await _dockCtrl.reverse();
                                      // TODO: open chat/support
                                    },
                                    child: const _DockPuck(
                                      icon: Icons.chat_bubble_outline_rounded,
                                      label: "Chat",
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _PressScale(
                                    onTap: () async {
                                      await _dockCtrl.forward();
                                      await _dockCtrl.reverse();
                                      // TODO: open map
                                    },
                                    child: const _DockPuck(
                                      icon: Icons.location_on_outlined,
                                      label: "Map",
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // right: primary call button (big)
                                  Expanded(
                                    child: _PressScale(
                                      onTap: () async {
                                        await _dockCtrl.forward();
                                        await _dockCtrl.reverse();
                                        // TODO: call rider
                                      },
                                      downScale: 0.975,
                                      child: const _PrimaryDockButton(
                                        label: "CALL RIDER",
                                        subtitle: "Ali Khan • 2.1 km",
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // bottom row: call shop + help
                              Row(
                                children: [
                                  Expanded(
                                    child: _PressScale(
                                      onTap: () async {
                                        await _dockCtrl.forward();
                                        await _dockCtrl.reverse();
                                        // TODO: call shop
                                      },
                                      child:
                                      const _SoftDockButton(label: "Call Shop"),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _PressScale(
                                      onTap: () async {
                                        await _dockCtrl.forward();
                                        await _dockCtrl.reverse();
                                        // TODO: report issue
                                      },
                                      child:
                                      const _SoftDockButton(label: "Support"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

  Widget _dockMiniInfo() {
    return AnimatedBuilder(
      animation: _ambientCtrl,
      builder: (_, __) {
        final pulse = 0.70 + sin(_floatT.value * pi * 2) * 0.18;

        return Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF22C55E),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.14 * pulse),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                currentStep >= 4
                    ? "Rider is nearby • On the way"
                    : "Tracking live • Updates in real time",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.86),
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: AppRadius.pill(),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.12),
                    Colors.white.withOpacity(0.06),
                  ],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: Text(
                "ETA 25–35",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.86),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ───────────────────── TOP CAP ─────────────────────

class _TrackingTopCap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: -topInset,
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: _TrackingHeaderClipper(),
        child: Container(
          height: 140 + topInset,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: AppShadows.soft,
          ),
        ),
      ),
    );
  }
}

class _TrackingHeaderClipper extends CustomClipper<Path> {
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

// ───────────────────── PREMIUM HELPERS ─────────────────────

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

class _GlassCard extends StatelessWidget {
  final Widget child;
  final double floatingT;
  final EdgeInsets padding;

  const _GlassCard({
    required this.child,
    required this.floatingT,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final floatY = sin(floatingT * pi * 2) * 4.0;

    return Transform.translate(
      offset: Offset(0, floatY),
      child: Glass(
        borderRadius: AppRadius.r18,
        sigmaX: 16,
        sigmaY: 16,
        padding: padding,
        color: Colors.white.withOpacity(0.62),
        borderColor: Colors.white.withOpacity(0.62),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 22,
            offset: const Offset(0, 16),
          ),
        ],
        child: child,
      ),
    );
  }
}

/// ✅ Works on BOTH mobile + web (no hover). Pure press feedback.
class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double downScale;

  const _PressScale({
    required this.child,
    required this.onTap,
    this.downScale = 0.972,
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
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        scale: _down ? widget.downScale : 1.0,
        child: widget.child,
      ),
    );
  }
}

// ───────────────────── TOP ICON PUCK ─────────────────────

class _TopIconPuck extends StatelessWidget {
  final IconData icon;
  const _TopIconPuck({required this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.58),
            border: Border.all(color: Colors.white.withOpacity(0.72)),
            boxShadow: AppShadows.puck,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: AppColors.ink),
        ),
      ),
    );
  }
}

// ───────────────────── DOCK COMPONENTS ─────────────────────

class _DockPuck extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DockPuck({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.r18,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: 74,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: AppRadius.r18,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.14),
                Colors.white.withOpacity(0.06),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white.withOpacity(0.92)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.86),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryDockButton extends StatelessWidget {
  final String label;
  final String subtitle;

  const _PrimaryDockButton({
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.r18,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: AppRadius.r18,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.96),
                AppColors.bg2.withOpacity(0.92),
                AppColors.bg1.withOpacity(0.90),
              ],
              stops: const [0.0, 0.58, 1.0],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.75), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 24,
                offset: const Offset(0, 18),
              ),
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 14),
                spreadRadius: -10,
              ),
              BoxShadow(
                color: AppColors.other.withOpacity(0.10),
                blurRadius: 24,
                offset: const Offset(0, 14),
                spreadRadius: -12,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.ink.withOpacity(0.10),
                      AppColors.ink.withOpacity(0.04),
                    ],
                  ),
                  border: Border.all(color: AppColors.ink.withOpacity(0.10)),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.phone_rounded,
                  size: 18,
                  color: AppColors.ink.withOpacity(0.92),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                        letterSpacing: 0.7,
                        color: AppColors.ink.withOpacity(0.92),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: AppColors.ink.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.ink.withOpacity(0.92)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftDockButton extends StatelessWidget {
  final String label;
  const _SoftDockButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.r18,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: AppRadius.r18,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.06),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.88),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────── Rider action puck used in rider card ─────────────────────

class _GlassActionPuck extends StatelessWidget {
  final IconData icon;
  final String label;

  const _GlassActionPuck({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: 66,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.58),
            border: Border.all(color: Colors.white.withOpacity(0.72)),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.ink),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink.withOpacity(0.92),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────── 3D TITLE ─────────────────────

class _Extruded3DTitle extends StatelessWidget {
  final String text;
  const _Extruded3DTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (int i = 10; i >= 1; i--)
          Transform.translate(
            offset: Offset(0, i.toDouble()),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: Colors.black.withOpacity(0.05),
                height: 1.0,
              ),
            ),
          ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: AppColors.ink,
            height: 1.0,
            shadows: [
              Shadow(
                blurRadius: 18,
                offset: const Offset(0, 10),
                color: AppColors.secondary.withOpacity(0.14),
              ),
              Shadow(
                blurRadius: 10,
                offset: const Offset(0, 6),
                color: Colors.black.withOpacity(0.10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────────────────── HOLO TIMELINE ─────────────────────

class _HoloLine extends StatelessWidget {
  final bool done;
  final double t;
  const _HoloLine({required this.done, required this.t});

  @override
  Widget build(BuildContext context) {
    final pulse = 0.65 + sin(t * pi * 2) * 0.18;

    return Container(
      width: 2,
      height: 44,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: done ? AppColors.ink.withOpacity(0.90) : AppColors.borderBase(),
        boxShadow: done
            ? [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.18 * pulse),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ]
            : null,
      ),
    );
  }
}

class _HoloTick extends StatelessWidget {
  final bool done;
  final bool active;
  final double t;

  const _HoloTick({
    required this.done,
    required this.active,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final pulse = 0.70 + sin(t * pi * 2) * 0.20;
    final scale = active ? (1.0 + 0.03 * pulse) : 1.0;

    return Transform.scale(
      scale: scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (done)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.18 * pulse),
                    AppColors.other.withOpacity(0.12 * pulse),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(done ? 0.62 : 0.48),
                  border: Border.all(
                    color: Colors.white.withOpacity(done ? 0.82 : 0.62),
                    width: 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 14,
                      offset: const Offset(0, 10),
                    ),
                    if (done)
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.14 * pulse),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                  ],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeIn,
                    child: done
                        ? Icon(
                      Icons.check_rounded,
                      key: const ValueKey("done"),
                      size: 14,
                      color: AppColors.ink,
                    )
                        : const SizedBox(
                      key: ValueKey("empty"),
                      width: 12,
                      height: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
