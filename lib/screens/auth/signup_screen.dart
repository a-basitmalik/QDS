import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with TickerProviderStateMixin {
  // Controllers
  late final AnimationController _ambientCtrl;
  late final AnimationController _focusCtrl;
  late final AnimationController _btnCtrl;

  late final Animation<double> _bgT;
  late final Animation<double> _floatT;

  late final Animation<double> _focusZoom;
  late final Animation<double> _focusLift;

  late final Animation<double> _btnPress;

  // Form controllers
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final pinCtrl = TextEditingController();

  // Focus nodes
  final nameFocus = FocusNode();
  final emailFocus = FocusNode();
  final phoneFocus = FocusNode();
  final passFocus = FocusNode();
  final addressFocus = FocusNode();
  final cityFocus = FocusNode();
  final pinFocus = FocusNode();

  bool obscure = true;

  @override
  void initState() {
    super.initState();

    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    )..repeat(reverse: true);

    _focusCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );

    _bgT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOut);
    _floatT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOutSine);

    _focusZoom = Tween<double>(begin: 1.0, end: 1.045).animate(
      CurvedAnimation(parent: _focusCtrl, curve: Curves.easeOutCubic),
    );
    _focusLift = Tween<double>(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(parent: _focusCtrl, curve: Curves.easeOutCubic),
    );

    _btnPress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOut),
    );

    for (final f in [
      nameFocus,
      emailFocus,
      phoneFocus,
      passFocus,
      addressFocus,
      cityFocus,
      pinFocus,
    ]) {
      f.addListener(_onFocusChange);
    }
  }

  void _onFocusChange() {
    final hasFocus = nameFocus.hasFocus ||
        emailFocus.hasFocus ||
        phoneFocus.hasFocus ||
        passFocus.hasFocus ||
        addressFocus.hasFocus ||
        cityFocus.hasFocus ||
        pinFocus.hasFocus;

    if (hasFocus) {
      _focusCtrl.forward();
    } else {
      _focusCtrl.reverse();
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (final f in [
      nameFocus,
      emailFocus,
      phoneFocus,
      passFocus,
      addressFocus,
      cityFocus,
      pinFocus,
    ]) {
      f.removeListener(_onFocusChange);
      f.dispose();
    }

    _ambientCtrl.dispose();
    _focusCtrl.dispose();
    _btnCtrl.dispose();

    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
    addressCtrl.dispose();
    cityCtrl.dispose();
    pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Animated soft gradient
          AnimatedBuilder(
            animation: _ambientCtrl,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(const Color(0xFFF5F8FF), const Color(0xFFEAF0FF), _bgT.value)!,
                      Color.lerp(const Color(0xFFEFF6FF), const Color(0xFFEAF9FF), _bgT.value)!,
                      Color.lerp(const Color(0xFFF7F7FA), const Color(0xFFF1F4FF), _bgT.value)!,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              );
            },
          ),

          // Subtle haze overlay
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _ambientCtrl,
              builder: (context, _) {
                final t = _floatT.value;
                return Opacity(
                  opacity: 0.10,
                  child: Transform.translate(
                    offset: Offset(lerpDouble(-18, 18, t)!, lerpDouble(10, -10, t)!),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0.2, -0.6),
                          radius: 1.25,
                          colors: [Color(0xFFB9C7FF), Color(0xFFBCE9FF), Colors.transparent],
                          stops: [0.0, 0.42, 1.0],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Glow blobs
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _ambientCtrl,
              builder: (context, _) {
                final t = _floatT.value;
                return Stack(
                  children: [
                    _GlowBlob(dx: lerpDouble(-40, 20, t)!, dy: lerpDouble(90, 60, t)!, size: 230, opacity: 0.16),
                    _GlowBlob(dx: lerpDouble(240, 285, t)!, dy: lerpDouble(250, 205, t)!, size: 280, opacity: 0.12),
                    _GlowBlob(dx: lerpDouble(210, 250, 1 - t)!, dy: lerpDouble(35, 18, t)!, size: 210, opacity: 0.10),
                  ],
                );
              },
            ),
          ),

          // Top cap (remove const because AppShadows.topCap might not be const)
          Positioned(
            top: -topInset,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _HeaderCapClipper(),
              child: Container(
                height: 150 + topInset,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: AppShadows.topCap,
                ),
              ),
            ),
          ),

          SafeArea(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    return AnimatedBuilder(
      animation: Listenable.merge([_ambientCtrl, _focusCtrl]),
      builder: (context, _) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              _PressScale(
                downScale: 0.992,
                borderRadius: AppRadius.pill(),
                onTap: () => Navigator.pop(context),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.50),
                      borderRadius: AppRadius.pill(),
                      border: Border.all(color: Colors.white.withOpacity(0.55)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.ink),
                        const SizedBox(width: 8),
                        Text(
                          "Back to sign in",
                          style: GoogleFonts.manrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              const _Welcome3DTitle(text: "CREATE ACCOUNT"),
              const SizedBox(height: 18),

              Transform.translate(
                offset: Offset(0, _focusLift.value),
                child: Transform.scale(
                  scale: _focusZoom.value,
                  child: Column(
                    children: [
                      _GlassCard(
                        floatingT: _floatT.value,
                        child: Column(
                          children: [
                            _field(
                              label: "Full name",
                              hint: "Your name",
                              controller: nameCtrl,
                              icon: Icons.person_outline,
                              focusNode: nameFocus,
                            ),
                            const SizedBox(height: 12),
                            _field(
                              label: "Email address",
                              hint: "you@example.com",
                              controller: emailCtrl,
                              icon: Icons.mail_outline_rounded,
                              focusNode: emailFocus,
                              keyboard: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),
                            _field(
                              label: "Phone number",
                              hint: "03XX XXXXXXX",
                              controller: phoneCtrl,
                              icon: Icons.phone_outlined,
                              focusNode: phoneFocus,
                              keyboard: TextInputType.phone,
                            ),
                            const SizedBox(height: 12),
                            _passwordField(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      _GlassCard(
                        floatingT: (_floatT.value + 0.35) % 1.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Delivery essentials",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.muted, // ✅ theme
                              ),
                            ),
                            const SizedBox(height: 12),
                            _field(
                              label: "Address",
                              hint: "House / Street / Block",
                              controller: addressCtrl,
                              icon: Icons.location_on_outlined,
                              focusNode: addressFocus,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _field(
                                    label: "City",
                                    hint: "City",
                                    controller: cityCtrl,
                                    icon: Icons.location_city_outlined,
                                    focusNode: cityFocus,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _field(
                                    label: "PIN code",
                                    hint: "Postal",
                                    controller: pinCtrl,
                                    icon: Icons.local_post_office_outlined,
                                    focusNode: pinFocus,
                                    keyboard: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _gpsDetect(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      _Shiny3DButton(
                        controller: _btnCtrl,
                        pressT: _btnPress,
                        text: "Create account",
                        onPressed: () async {
                          await _btnCtrl.forward();
                          await _btnCtrl.reverse();
                          // TODO: handle signup
                        },
                      ),

                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.muted, // ✅ theme
                            ),
                          ),
                          const SizedBox(width: 8),
                          _PressScale(
                            downScale: 0.96,
                            borderRadius: AppRadius.pill(),
                            onTap: () => Navigator.pop(context),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Text(
                                "Sign in",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.ink, // ✅ theme
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ───────────────────────── Fields ─────────────────────────

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required FocusNode focusNode,
    TextInputType? keyboard,
  }) {
    final isFocused = focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, top: 2, bottom: 8),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
              color: isFocused ? AppColors.ink : AppColors.muted,
            ),
            child: Text(label),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: AppRadius.r18, // ✅ fixed
            border: Border.all(
              color: isFocused ? AppColors.secondary.withOpacity(0.55) : AppColors.borderBase(0.60),
              width: isFocused ? 1.3 : 1.0,
            ),
            boxShadow: isFocused
                ? [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 10),
              )
            ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.r18, // ✅ fixed
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(
                    icon,
                    size: 18,
                    color: isFocused ? AppColors.ink : AppColors.muted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      focusNode: focusNode,
                      controller: controller,
                      keyboardType: keyboard,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB0B0B6),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordField() {
    final isFocused = passFocus.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, top: 2, bottom: 8),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
              color: isFocused ? AppColors.ink : AppColors.muted,
            ),
            child: const Text("Password"),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: AppRadius.r18, // ✅ fixed
            border: Border.all(
              color: isFocused ? AppColors.secondary.withOpacity(0.55) : AppColors.borderBase(0.60),
              width: isFocused ? 1.3 : 1.0,
            ),
            boxShadow: isFocused
                ? [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 10),
              )
            ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.r18, // ✅ fixed
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: isFocused ? AppColors.ink : AppColors.muted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      focusNode: passFocus,
                      controller: passCtrl,
                      obscureText: obscure,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Create password",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB0B0B6),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    splashRadius: 18,
                    icon: Icon(
                      obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 18,
                      color: AppColors.muted,
                    ),
                    onPressed: () => setState(() => obscure = !obscure),
                  ),
                  const SizedBox(width: 6),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _gpsDetect() {
    return _PressScale(
      downScale: 0.985,
      borderRadius: AppRadius.r18, // ✅ fixed
      onTap: () {},
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: AppRadius.r18, // ✅ fixed
          border: Border.all(color: AppColors.borderBase(0.65)),
          color: Colors.white.withOpacity(0.35),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.my_location_rounded, size: 18, color: AppColors.ink),
            const SizedBox(width: 10),
            Text(
              "Auto-detect location",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.ink, // ✅ theme
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PRESS SCALE (NO HOVER)
// ─────────────────────────────────────────────────────────────

class _PressScale extends StatefulWidget {
  final Widget child;
  final double downScale;
  final Duration duration;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  const _PressScale({
    required this.child,
    this.onTap,
    this.downScale = 0.985,
    this.duration = const Duration(milliseconds: 140),
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
  });

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _down = false;

  void _setDown(bool v) {
    if (_down == v) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => _setDown(true),
      onTapUp: (_) => _setDown(false),
      onTapCancel: () => _setDown(false),
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
                color: Colors.black.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 12),
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

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────

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
                const Color(0xFF7EDCFF).withOpacity(opacity * 0.70),
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
  const _GlassCard({required this.child, required this.floatingT});

  @override
  Widget build(BuildContext context) {
    final floatY = sin(floatingT * pi * 2) * 5.0;

    return Transform.translate(
      offset: Offset(0, floatY),
      child: _PressScale(
        downScale: 0.992,
        borderRadius: AppRadius.r18, // ✅ fixed
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          decoration: BoxDecoration(
            borderRadius: AppRadius.r18, // ✅ fixed
            border: Border.all(color: Colors.white.withOpacity(0.55)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.72),
                Colors.white.withOpacity(0.46),
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
          child: ClipRRect(
            borderRadius: AppRadius.r18, // ✅ fixed
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _Shiny3DButton extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> pressT;
  final String text;
  final VoidCallback onPressed;

  const _Shiny3DButton({
    required this.controller,
    required this.pressT,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = pressT.value;
        final lift = lerpDouble(0, 3, 1 - t)!;
        final press = lerpDouble(0, 2.5, t)!;

        return GestureDetector(
          onTapDown: (_) => controller.forward(),
          onTapCancel: () => controller.reverse(),
          onTapUp: (_) => controller.reverse(),
          onTap: onPressed,
          child: Transform.translate(
            offset: Offset(0, -lift + press),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: AppRadius.r22, // ✅ fixed
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E2235), Color(0xFF3A3F67)],
                ),
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
                      borderRadius: AppRadius.r22, // ✅ fixed
                      child: Opacity(
                        opacity: 0.22,
                        child: Transform.rotate(
                          angle: -0.35,
                          child: Container(
                            width: 200,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.2,
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

class _Welcome3DTitle extends StatelessWidget {
  final String text;
  const _Welcome3DTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (int i = 12; i >= 1; i--)
          Transform.translate(
            offset: Offset(0, i.toDouble()),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: Colors.black.withOpacity(0.055),
              ),
            ),
          ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: AppColors.ink,
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
      ],
    );
  }
}

class _HeaderCapClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final r = 22.0;
    final slant = 36.0;
    final cutY = size.height - 52;

    final path = Path()
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

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
