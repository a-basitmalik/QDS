import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_text.dart';
import '../../theme/app_shadows.dart';
import '../Customer/home.dart';
import '../auth/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────────
  // Controllers
  // ─────────────────────────────────────────────────────────────────────────────
  late final AnimationController _introController;
  late final AnimationController _loginController;

  // Ambient / background animation
  late final AnimationController _ambientCtrl;

  // Focus zoom (when keyboard/cursor active)
  late final AnimationController _focusCtrl;

  // Button 3D press
  late final AnimationController _btnCtrl;

  // NEW: holographic shimmer for intro text
  late final AnimationController _holoCtrl;
  late final Animation<double> _holoT;

  // ─────────────────────────────────────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────────────────────────────────────
  bool _showLoginForm = false;

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  final emailFocus = FocusNode();
  final passFocus = FocusNode();

  bool obscure = true;
  bool remember = true;

  // Static auth
  static const String _staticEmail = "customer@test.com";
  static const String _staticPassword = "123456";
  static const String _staticRole = "customer";

  // Brand
  final String _brand = "Nexora";
  final String _tagline = "Shopping that moves at your speed";
  late final List<_LetterAnim> _letters;

  // Intro animations
  late Animation<double> _introTagFade;
  late Animation<double> _introTagSlide;
  late Animation<double> _introTagTypeT;
  late Animation<double> _introIconScale;
  late Animation<double> _introIconFade;
  late Animation<double> _introOverallFadeIn;

  // Login reveal animations
  late Animation<double> _headerFadeIn;
  late Animation<double> _headerSlideIn;
  late Animation<double> _formFadeIn;
  late Animation<double> _formSlideIn;

  // Ambient animations
  late Animation<double> _bgT;
  late Animation<double> _floatT;

  // Focus zoom animations
  late Animation<double> _focusZoom;
  late Animation<double> _focusLift;

  // Button animations
  late Animation<double> _btnPress;

  static const Duration _introDuration = Duration(milliseconds: 6200);
  static const Duration _loginTransitionDuration = Duration(milliseconds: 1100);

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(vsync: this, duration: _introDuration);
    _loginController = AnimationController(vsync: this, duration: _loginTransitionDuration);

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

    _holoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _holoT = CurvedAnimation(parent: _holoCtrl, curve: Curves.linear);

    _setupIntroAnimations();
    _setupLoginAnimations();
    _setupAmbientAnimations();
    _setupFocusAnimations();
    _setupButtonAnimations();

    emailFocus.addListener(_onFocusChange);
    passFocus.addListener(_onFocusChange);

    _startAnimationSequence();
  }

  void _onFocusChange() {
    final hasFocus = emailFocus.hasFocus || passFocus.hasFocus;
    if (hasFocus) {
      _focusCtrl.forward();
    } else {
      _focusCtrl.reverse();
    }
    setState(() {});
  }

  void _setupAmbientAnimations() {
    _bgT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOut);
    _floatT = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOutSine);
  }

  void _setupFocusAnimations() {
    _focusZoom = Tween<double>(begin: 1.0, end: 1.045).animate(
      CurvedAnimation(parent: _focusCtrl, curve: Curves.easeOutCubic),
    );
    _focusLift = Tween<double>(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(parent: _focusCtrl, curve: Curves.easeOutCubic),
    );
  }

  void _setupButtonAnimations() {
    _btnPress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOut),
    );
  }

  void _setupIntroAnimations() {
    _introOverallFadeIn = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.00, 0.10, curve: Curves.easeOut),
    );

    // Letter animations
    final n = _brand.length;
    const double lettersStart = 0.08;
    const double lettersEnd = 0.55;
    final double window = (lettersEnd - lettersStart) / (n + 1);

    _letters = List.generate(n, (i) {
      final s = lettersStart + i * window * 0.92;
      final e = min(s + window * 1.75, lettersEnd);

      final t = CurvedAnimation(
        parent: _introController,
        curve: Interval(s, e, curve: Curves.easeOutCubic),
      );

      final jump = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 58.0, end: -12.0).chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 60,
        ),
        TweenSequenceItem(
          tween: Tween(begin: -12.0, end: 0.0).chain(CurveTween(curve: Curves.elasticOut)),
          weight: 40,
        ),
      ]).animate(t);

      final scale = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 0.75, end: 1.10).chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 70,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 1.10, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)),
          weight: 30,
        ),
      ]).animate(t);

      final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _introController,
          curve: Interval(s, min(s + window * 0.9, e), curve: Curves.easeOut),
        ),
      );

      final blur = Tween<double>(begin: 8.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _introController,
          curve: Interval(s, e, curve: Curves.easeOut),
        ),
      );

      return _LetterAnim(
        char: _brand[i],
        jumpY: jump,
        scale: scale,
        opacity: opacity,
        blur: blur,
      );
    });

    _introTagFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.58, 0.72, curve: Curves.easeOut),
      ),
    );

    _introTagSlide = Tween<double>(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.58, 0.72, curve: Curves.easeOutCubic),
      ),
    );

    _introTagTypeT = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.60, 0.80, curve: Curves.linear),
    );

    _introIconScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.85, end: 1.08).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.08, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.78, 0.92, curve: Curves.easeOut),
      ),
    );

    _introIconFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.74, 0.90, curve: Curves.easeOut),
      ),
    );
  }

  void _setupLoginAnimations() {
    _headerFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loginController,
        curve: const Interval(0.05, 0.35, curve: Curves.easeIn),
      ),
    );

    _headerSlideIn = Tween<double>(begin: -18.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _loginController,
        curve: const Interval(0.05, 0.35, curve: Curves.easeOutCubic),
      ),
    );

    _formFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loginController,
        curve: const Interval(0.22, 0.70, curve: Curves.easeIn),
      ),
    );

    _formSlideIn = Tween<double>(begin: 22.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _loginController,
        curve: const Interval(0.22, 0.70, curve: Curves.easeOutCubic),
      ),
    );
  }

  void _startAnimationSequence() {
    _introController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 250), () {
        setState(() => _showLoginForm = true);
        _loginController.forward();
      });
    });
  }

  @override
  void dispose() {
    emailFocus.removeListener(_onFocusChange);
    passFocus.removeListener(_onFocusChange);
    emailFocus.dispose();
    passFocus.dispose();

    _introController.dispose();
    _loginController.dispose();
    _ambientCtrl.dispose();
    _focusCtrl.dispose();
    _btnCtrl.dispose();
    _holoCtrl.dispose();

    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // ✅ Upgraded: glassy light-indigo + sky-blue background
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
                      Color.lerp(const Color(0xFFF5F8FF), const Color(0xFFEAF0FF), t)!,
                      Color.lerp(const Color(0xFFEFF6FF), const Color(0xFFEAF9FF), t)!,
                      Color.lerp(const Color(0xFFF7F7FA), const Color(0xFFF1F4FF), t)!,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              );
            },
          ),

          // ✅ extra glass haze (subtle, premium)
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
                          colors: [
                            Color(0xFFB9C7FF),
                            Color(0xFFBCE9FF),
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.42, 1.0],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ✅ Floating glow blobs (kept, tuned slightly for indigo/sky)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _ambientCtrl,
              builder: (context, _) {
                final t = _floatT.value;
                return Stack(
                  children: [
                    _GlowBlob(
                      dx: lerpDouble(-50, 24, t)!,
                      dy: lerpDouble(110, 70, t)!,
                      size: 240,
                      opacity: 0.16,
                    ),
                    _GlowBlob(
                      dx: lerpDouble(240, 300, t)!,
                      dy: lerpDouble(250, 205, t)!,
                      size: 290,
                      opacity: 0.12,
                    ),
                    // NEW: top-right cool blue blob
                    _GlowBlob(
                      dx: lerpDouble(220, 260, 1 - t)!,
                      dy: lerpDouble(40, 20, t)!,
                      size: 220,
                      opacity: 0.10,
                    ),
                  ],
                );
              },
            ),
          ),

          // ✅ Top cap (kept)
          if (_showLoginForm)
            Positioned(
              top: -topInset,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: _HeaderCapClipper(),
                child: Container(
                  height: 170 + topInset,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: AppShadows.topCap,
                  ),
                ),
              ),
            ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeIn,
            child: _showLoginForm ? _buildLoginScreen() : _buildIntroScreen(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // INTRO SCREEN (Upgraded holographic glass text)
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildIntroScreen() {
    return AnimatedBuilder(
      animation: Listenable.merge([_introController, _holoCtrl, _ambientCtrl]),
      builder: (context, _) {
        final double introFade = _introOverallFadeIn.value.clamp(0.0, 1.0);

        final int visibleChars = (_tagline.length * _introTagTypeT.value.clamp(0.0, 1.0)).round();
        final String typed = visibleChars <= 0 ? "" : _tagline.substring(0, min(visibleChars, _tagline.length));

        return Opacity(
          opacity: introFade,
          child: Center(
            child: _NexoraFullLockup(
              letters: _letters,
              typedTagline: typed,
              iconScale: _introIconScale.value,
              iconFade: _introIconFade.value,
              tagFade: _introTagFade.value,
              tagSlide: _introTagSlide.value,
              // NEW:
              holoT: _holoT.value,
              ambientT: _floatT.value,
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // LOGIN SCREEN (kept same)
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildLoginScreen() {
    return AnimatedBuilder(
      animation: Listenable.merge([_loginController, _focusCtrl, _ambientCtrl]),
      builder: (context, _) {
        final topInset = MediaQuery.of(context).padding.top;

        return SafeArea(
          child: Column(
            children: [
              // Header (top-left)
              Transform.translate(
                offset: Offset(0, _headerSlideIn.value),
                child: Opacity(
                  opacity: _headerFadeIn.value,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/logo.png",
                          width: 42,
                          height: 42,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Nexora",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF1E2235),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Shopping that moves at your speed",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF7A7E92),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(18, 24, 18, 24 + topInset * 0.12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Transform.translate(
                        offset: Offset(0, _formSlideIn.value),
                        child: Opacity(
                          opacity: _formFadeIn.value,
                          child: const Column(
                            children: [
                              _Welcome3DTitle(text: "WELCOME BACK"),
                              SizedBox(height: 18),
                            ],
                          ),
                        ),
                      ),

                      Transform.translate(
                        offset: Offset(0, _formSlideIn.value + _focusLift.value),
                        child: Transform.scale(
                          scale: _focusZoom.value,
                          child: Opacity(
                            opacity: _formFadeIn.value,
                            child: _GlassCard(
                              floatingT: _floatT.value,
                              child: _buildLoginCard(),
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildLoginCard() {
    return Column(
      children: [
        _buildTextField(
          label: "Email",
          hint: "you@example.com",
          controller: emailCtrl,
          focusNode: emailFocus,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.mail_outline_rounded,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: "Password",
          hint: "••••••••",
          controller: passCtrl,
          focusNode: passFocus,
          obscureText: obscure,
          prefixIcon: Icons.lock_outline_rounded,
          suffix: IconButton(
            onPressed: () => setState(() => obscure = !obscure),
            icon: Icon(
              obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: AppColors.textMid,
              size: 20,
            ),
            splashRadius: 18,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            _buildRememberToggle(),
            const Spacer(),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textDark,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              child: const Text(
                "Forgot password?",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        _Shiny3DButton(
          controller: _btnCtrl,
          pressT: _btnPress,
          text: "Sign in",
          onPressed: () async {
            await _btnCtrl.forward();
            await _btnCtrl.reverse();
            _handleSignIn();
          },
        ),

        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account?",
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMid,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textDark,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text(
                "Create one",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRememberToggle() {
    return InkWell(
      onTap: () => setState(() => remember = !remember),
      borderRadius: BorderRadius.circular(999),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: remember ? AppColors.textDark : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.divider),
            ),
            child: remember
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
          const SizedBox(width: 10),
          const Text(
            "Remember me",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textMid,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    TextInputType? keyboardType,
    bool obscureText = false,
    required IconData prefixIcon,
    Widget? suffix,
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
              color: isFocused ? const Color(0xFF1E2235) : AppColors.textMid,
            ),
            child: Text(label),
          ),
        ),

        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(AppRadius.r18),
            border: Border.all(
              color: isFocused
                  ? const Color(0xFF6B7CFF).withOpacity(0.55)
                  : AppColors.divider,
              width: isFocused ? 1.3 : 1.0,
            ),
            boxShadow: isFocused
                ? [
              BoxShadow(
                color: const Color(0xFF6B7CFF).withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 10),
              )
            ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.r18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(
                    prefixIcon,
                    size: 18,
                    color: isFocused ? const Color(0xFF1E2235) : AppColors.textMid,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      focusNode: focusNode,
                      controller: controller,
                      keyboardType: keyboardType,
                      obscureText: obscureText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB0B0B6),
                        ),
                      ).copyWith(hintText: hint),
                    ),
                  ),
                  if (suffix != null) suffix,
                  const SizedBox(width: 6),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSignIn() {
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    if (email != _staticEmail || password != _staticPassword) {
      _showError(context, "Invalid email or password");
      return;
    }

    switch (_staticRole) {
      case "customer":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case "shop":
        _showError(context, "Shop portal coming soon");
        break;
      case "rider":
        _showError(context, "Rider portal coming soon");
        break;
      default:
        _showError(context, "Unknown role");
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium helpers
// ─────────────────────────────────────────────────────────────────────────────

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
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.r18),
          border: Border.all(color: Colors.white.withOpacity(0.55)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.70),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.r18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: child,
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
        final t = pressT.value; // 0..1
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
                borderRadius: BorderRadius.circular(AppRadius.r22),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E2235),
                    Color(0xFF3A3F67),
                  ],
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
                      borderRadius: BorderRadius.circular(AppRadius.r22),
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

/// 3D extruded “WELCOME BACK” title (kept)
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
                letterSpacing: 0.6,
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
            letterSpacing: 0.6,
            color: const Color(0xFF1E2235),
            shadows: [
              Shadow(
                blurRadius: 18,
                offset: const Offset(0, 10),
                color: const Color(0xFF6B7CFF).withOpacity(0.18),
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

// ─────────────────────────────────────────────────────────────────────────────
// INTRO LOCKUP (Upgraded)
// ─────────────────────────────────────────────────────────────────────────────

class _NexoraFullLockup extends StatelessWidget {
  final List<_LetterAnim> letters;
  final String typedTagline;
  final double iconScale;
  final double iconFade;
  final double tagFade;
  final double tagSlide;

  // NEW
  final double holoT;
  final double ambientT;

  const _NexoraFullLockup({
    required this.letters,
    required this.typedTagline,
    required this.iconScale,
    required this.iconFade,
    required this.tagFade,
    required this.tagSlide,
    required this.holoT,
    required this.ambientT,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;

    final bool isMobile = w < 600;

    // 🔒 SAFE sizes (no overflow)
    final double logoSize = isMobile ? 165 : 200;
    final double brandScale = isMobile ? 1.18 : 1.32;

    // small horizontal push only (visual balance)
    final double textOffsetX = isMobile ? 6 : 10;

    return Align(
      // slightly lower than exact center
      alignment: const Alignment(0, 0.10),
      child: SizedBox(
        width: w, // ✅ fill width without forcing overflow
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // LOGO (kept safe)
              Opacity(
                opacity: iconFade.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: iconScale,
                  child: Image.asset(
                    "assets/logo.png",
                    width: logoSize,
                    height: logoSize,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),

              const SizedBox(width: 18), // controlled gap

              // BRAND TEXT
              Flexible(
                child: Transform.translate(
                  offset: Offset(textOffsetX, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HoloGlassBrandWord(
                        letters: letters,
                        scaleBoost: brandScale,
                        holoT: holoT,
                        ambientT: ambientT,
                      ),
                      const SizedBox(height: 10),
                      Transform.translate(
                        offset: Offset(0, tagSlide),
                        child: Opacity(
                          opacity: tagFade.clamp(0.0, 1.0),
                          child: _TaglineTypedText(text: typedTagline),
                        ),
                      ),
                    ],
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

class _LetterAnim {
  final String char;
  final Animation<double> jumpY;
  final Animation<double> scale;
  final Animation<double> opacity;
  final Animation<double> blur;

  _LetterAnim({
    required this.char,
    required this.jumpY,
    required this.scale,
    required this.opacity,
    required this.blur,
  });
}

/// NEW: Brand word wrapper (keeps your per-letter jump/scale animation)
class _HoloGlassBrandWord extends StatelessWidget {
  final List<_LetterAnim> letters;
  final double scaleBoost;
  final double holoT;
  final double ambientT;

  const _HoloGlassBrandWord({
    required this.letters,
    required this.scaleBoost,
    required this.holoT,
    required this.ambientT,
  });

  @override
  Widget build(BuildContext context) {
    // Animated holographic movement direction (shimmer)
    final shimmerX = lerpDouble(-0.9, 1.1, holoT)!;
    final shimmerY = sin(holoT * pi * 2) * 0.15;

    return RepaintBoundary(
      child: Stack(
        children: [
          // subtle outer glow behind everything
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(sin(ambientT * pi * 2) * 2.0, cos(ambientT * pi * 2) * 1.0),
              child: Opacity(
                opacity: 0.55,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
                  child: _BrandWord(
                    letters: letters,
                    // base style only for glow layer
                    baseStyle: GoogleFonts.manrope(
                      fontSize: 66 * scaleBoost,
                      height: 0.92,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.3,
                      color: const Color(0xFF6B7CFF).withOpacity(0.28),
                    ),
                    scaleBoost: scaleBoost,
                    useHoloPaint: false,
                    holoPaint: null,
                  ),
                ),
              ),
            ),
          ),

          // glass body layer (frosted)
          _BrandWord(
            letters: letters,
            baseStyle: GoogleFonts.manrope(
              fontSize: 66 * scaleBoost,
              height: 0.92,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.3,
              color: const Color(0xFF1E2235).withOpacity(0.88),
            ),
            scaleBoost: scaleBoost,
            useHoloPaint: false,
            holoPaint: null,
            glassOverlay: true,
          ),

          // holographic gradient + shimmer (top layer)
          ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (rect) {
              // moving holographic gradient
              final begin = Alignment(shimmerX, -0.9 + shimmerY);
              final end = Alignment(-shimmerX, 0.9 - shimmerY);

              return LinearGradient(
                begin: begin,
                end: end,
                colors: const [
                  Color(0xFF6B7CFF), // indigo
                  Color(0xFF7EDCFF), // sky
                  Color(0xFFFF6BD6), // soft pink
                  Color(0xFFB9C7FF), // lilac
                ],
                stops: const [0.0, 0.35, 0.68, 1.0],
              ).createShader(rect);
            },
            child: _BrandWord(
              letters: letters,
              baseStyle: GoogleFonts.manrope(
                fontSize: 66 * scaleBoost,
                height: 0.92,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.3,
                color: Colors.white.withOpacity(0.95),
              ),
              scaleBoost: scaleBoost,
              useHoloPaint: true,
              holoPaint: Paint()
                ..color = Colors.white.withOpacity(0.90)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6),
            ),
          ),

          // glossy specular highlight sweep (very subtle)
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.16,
                child: Transform.rotate(
                  angle: -0.26,
                  child: FractionallySizedBox(
                    widthFactor: 0.55,
                    alignment: Alignment(shimmerX, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.55),
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
      ),
    );
  }
}

class _BrandWord extends StatelessWidget {
  final List<_LetterAnim> letters;

  // new optional styling controls
  final TextStyle baseStyle;
  final double scaleBoost;
  final bool useHoloPaint;
  final Paint? holoPaint;
  final bool glassOverlay;

  const _BrandWord({
    required this.letters,
    required this.baseStyle,
    required this.scaleBoost,
    required this.useHoloPaint,
    required this.holoPaint,
    this.glassOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final l in letters)
          _LetterWidget(
            char: l.char,
            jumpY: l.jumpY.value,
            scale: l.scale.value,
            opacity: l.opacity.value,
            blur: l.blur.value,
            baseStyle: baseStyle,
            scaleBoost: scaleBoost,
            useHoloPaint: useHoloPaint,
            holoPaint: holoPaint,
            glassOverlay: glassOverlay,
          ),
      ],
    );
  }
}

class _LetterWidget extends StatelessWidget {
  final String char;
  final double jumpY;
  final double scale;
  final double opacity;
  final double blur;

  // new
  final TextStyle baseStyle;
  final double scaleBoost;
  final bool useHoloPaint;
  final Paint? holoPaint;
  final bool glassOverlay;

  const _LetterWidget({
    required this.char,
    required this.jumpY,
    required this.scale,
    required this.opacity,
    required this.blur,
    required this.baseStyle,
    required this.scaleBoost,
    required this.useHoloPaint,
    required this.holoPaint,
    required this.glassOverlay,
  });

  @override
  Widget build(BuildContext context) {
    final face = Text(
      char,
      style: baseStyle,
    );

    // glass overlay effect (frosty highlights)
    final glass = ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (rect) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.55),
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.28),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(rect);
      },
      child: face,
    );

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, jumpY),
        child: Transform.scale(
          scale: scale,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: Stack(
                children: [
                  // extrusion (depth) for premium 3D
                  for (int i = 10; i >= 1; i--)
                    Transform.translate(
                      offset: Offset(0, i.toDouble()),
                      child: Text(
                        char,
                        style: baseStyle.copyWith(
                          color: Colors.black.withOpacity(0.06),
                        ),
                      ),
                    ),

                  // main face
                  if (glassOverlay) glass else face,

                  // tiny crisp edge to avoid blur on web
                  if (kIsWeb)
                    Text(
                      char,
                      style: baseStyle.copyWith(
                        color: (baseStyle.color ?? Colors.black).withOpacity(0.22),
                        shadows: const [],
                      ),
                    ),

                  // subtle light stroke (helps holographic layer pop)
                  if (useHoloPaint && holoPaint != null)
                    Text(
                      char,
                      style: baseStyle.copyWith(
                        foreground: holoPaint,
                        color: null,
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
}

class _TaglineTypedText extends StatelessWidget {
  final String text;
  const _TaglineTypedText({required this.text});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final fontSize = w < 380 ? 15.0 : (w < 700 ? 16.0 : 17.0);

    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.clip,
      style: GoogleFonts.manrope(
        fontSize: fontSize,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF7A7E92),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOP CAP CLIPPER (kept)
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderCapClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final r = 22.0;
    final slant = 36.0;
    final bottomY = size.height;
    final cutY = size.height - 52;

    final path = Path();
    path.moveTo(r, 0);
    path.lineTo(size.width - r, 0);
    path.quadraticBezierTo(size.width, 0, size.width, r);

    path.lineTo(size.width, cutY);
    path.lineTo(size.width - slant, bottomY);
    path.lineTo(slant, bottomY);
    path.lineTo(0, cutY);
    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
