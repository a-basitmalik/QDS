import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../Customer/home.dart';
import '../auth/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────
  // THEME REDS (from your palette)
  // ─────────────────────────────────────────────────────────────
  static const Color _mahogany = Color(0xFF440C08);
  static const Color _blood = Color(0xFF750A03);
  static const Color _cherry = Color(0xFF9B0F03);
  static const Color _red = Color(0xFFD1322E);

  // Controllers
  late final AnimationController _introController;
  late final AnimationController _loginController;

  late final AnimationController _ambientCtrl;
  late final AnimationController _focusCtrl;
  late final AnimationController _btnCtrl;

  late final AnimationController _holoCtrl;
  late final Animation<double> _holoT;

  // State
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

  // Login reveal
  late Animation<double> _headerFadeIn;
  late Animation<double> _headerSlideIn;
  late Animation<double> _formFadeIn;
  late Animation<double> _formSlideIn;

  // Ambient
  late Animation<double> _bgT;
  late Animation<double> _floatT;

  // Focus zoom
  late Animation<double> _focusZoom;
  late Animation<double> _focusLift;

  // Button
  late Animation<double> _btnPress;

  // Logo motion
  late Animation<double> _logoX;
  late Animation<double> _logoTilt;
  late Animation<double> _logoSquash;
  late Animation<double> _logoSkidT;

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

  // ─────────────────────────────────────────────────────────────
  // INTRO ANIMS
  // ─────────────────────────────────────────────────────────────
  void _setupIntroAnimations() {
    _introOverallFadeIn = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.00, 0.10, curve: Curves.easeOut),
    );

    const logoStart = 0.02;
    const logoEnd = 0.32;

    _logoX = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: -620.0, end: -70.0).chain(
          CurveTween(curve: Cubic(0.08, 0.95, 0.18, 1.00)),
        ),
        weight: 58,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -70.0, end: 26.0).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 26.0, end: 0.0).chain(CurveTween(curve: Cubic(0.18, 0.00, 0.00, 1.00))),
        weight: 20,
      ),
    ]).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(logoStart, logoEnd)),
    );

    _logoTilt = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: -0.28, end: -0.06).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -0.06, end: 0.22).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.22, end: 0.0).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 25,
      ),
    ]).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(logoStart, logoEnd)),
    );

    _logoSquash = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.00, end: 1.10).chain(CurveTween(curve: Curves.easeOut)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.10, end: 0.92).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.92, end: 1.00).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 25,
      ),
    ]).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(logoStart, logoEnd)),
    );

    _logoSkidT = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.20, 0.32, curve: Curves.linear),
    );

    _introIconFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.03, 0.14, curve: Curves.easeOut)),
    );

    _introIconScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.92, end: 1.06).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.06, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.06, 0.32, curve: Curves.easeOut)),
    );

    final n = _brand.length;
    const double lettersStart = 0.35;
    const double lettersEnd = 0.68;
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
        CurvedAnimation(parent: _introController, curve: Interval(s, min(s + window * 0.9, e), curve: Curves.easeOut)),
      );

      final blur = Tween<double>(begin: 8.0, end: 0.0).animate(
        CurvedAnimation(parent: _introController, curve: Interval(s, e, curve: Curves.easeOut)),
      );

      return _LetterAnim(char: _brand[i], jumpY: jump, scale: scale, opacity: opacity, blur: blur);
    });

    _introTagFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.70, 0.82, curve: Curves.easeOut)),
    );

    _introTagSlide = Tween<double>(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.70, 0.82, curve: Curves.easeOutCubic)),
    );

    _introTagTypeT = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.72, 0.90, curve: Curves.linear),
    );
  }

  void _setupLoginAnimations() {
    _headerFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loginController, curve: const Interval(0.05, 0.35, curve: Curves.easeIn)),
    );

    _headerSlideIn = Tween<double>(begin: -18.0, end: 0.0).animate(
      CurvedAnimation(parent: _loginController, curve: const Interval(0.05, 0.35, curve: Curves.easeOutCubic)),
    );

    _formFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loginController, curve: const Interval(0.22, 0.70, curve: Curves.easeIn)),
    );

    _formSlideIn = Tween<double>(begin: 22.0, end: 0.0).animate(
      CurvedAnimation(parent: _loginController, curve: const Interval(0.22, 0.70, curve: Curves.easeOutCubic)),
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
      body: NexoraBackground(
        child: Stack(
          children: [
            if (_showLoginForm)
              Positioned(
                top: -topInset,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: _HeaderCapClipper(),
                  child: Container(
                    height: 170 + topInset,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.60),
                      border: Border(bottom: BorderSide(color: AppColors.borderBase(0.65), width: 1)),
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
      ),
    );
  }

  // INTRO
  Widget _buildIntroScreen() {
    return AnimatedBuilder(
      animation: Listenable.merge([_introController, _holoCtrl, _ambientCtrl]),
      builder: (context, _) {
        final introFade = _introOverallFadeIn.value.clamp(0.0, 1.0);
        final visibleChars = (_tagline.length * _introTagTypeT.value.clamp(0.0, 1.0)).round();
        final typed = visibleChars <= 0 ? "" : _tagline.substring(0, min(visibleChars, _tagline.length));

        return Opacity(
          opacity: introFade,
          child: Center(
            child: _NexoraFullLockup(
              mahogany: _mahogany,
              blood: _blood,
              cherry: _cherry,
              red: _red,
              letters: _letters,
              typedTagline: typed,
              iconScale: _introIconScale.value,
              iconFade: _introIconFade.value,
              tagFade: _introTagFade.value,
              tagSlide: _introTagSlide.value,
              holoT: _holoT.value,
              ambientT: _floatT.value,
              logoSlideX: _logoX.value,
              logoTilt: _logoTilt.value,
              logoSquash: _logoSquash.value,
              logoSkidT: _logoSkidT.value,
            ),
          ),
        );
      },
    );
  }

  // LOGIN
  Widget _buildLoginScreen() {
    return AnimatedBuilder(
      animation: Listenable.merge([_loginController, _focusCtrl, _ambientCtrl]),
      builder: (context, _) {
        final topInset = MediaQuery.of(context).padding.top;

        return SafeArea(
          child: Column(
            children: [
              Transform.translate(
                offset: Offset(0, _headerSlideIn.value),
                child: Opacity(
                  opacity: _headerFadeIn.value,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                    child: Row(
                      children: [
                        // ✅ LOGO BOX (WHITE)
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.r14,
                            color: Colors.white, // ✅ changed from red gradient to white
                            border: Border.all(
                              color: _red.withOpacity(0.22), // subtle theme border
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 18,
                                offset: const Offset(0, 12),
                              ),
                              BoxShadow(
                                color: _red.withOpacity(0.06),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(7),
                            child: _LogoAssetOrFallback(size: 28),
                          ),
                        ),

                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Nexora",
                                style: GoogleFonts.manrope(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.ink,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _tagline,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.muted,
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
                              _WelcomeSimpleTitle(text: "Welcome Back"),
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
              color: AppColors.muted,
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
                foregroundColor: AppColors.ink,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              child: const Text("Forgot password?", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // ✅ Sign in button now uses your theme reds
        _Shiny3DButton(
          controller: _btnCtrl,
          pressT: _btnPress,
          text: "Sign in",
          mahogany: _mahogany,
          blood: _blood,
          cherry: _cherry,
          red: _red,
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
            Text(
              "Don't have an account?",
              style: TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen()));
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.ink,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text("Create one", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRememberToggle() {
    return InkWell(
      onTap: () => setState(() => remember = !remember),
      borderRadius: AppRadius.pill(),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: remember ? AppColors.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderBase(0.65)),
            ),
            child: remember ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
          ),
          const SizedBox(width: 10),
          Text(
            "Remember me",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.muted),
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
            borderRadius: AppRadius.r18, // ✅ no BorderRadius.circular(AppRadius.r18)
            border: Border.all(
              color: isFocused ? _red.withOpacity(0.55) : AppColors.borderBase(0.60),
              width: isFocused ? 1.3 : 1.0,
            ),
            boxShadow: isFocused
                ? [
              BoxShadow(
                color: _red.withOpacity(0.16),
                blurRadius: 18,
                offset: const Offset(0, 10),
              )
            ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.r18,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(prefixIcon, size: 18, color: isFocused ? AppColors.ink : AppColors.muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      focusNode: focusNode,
                      controller: controller,
                      keyboardType: keyboardType,
                      obscureText: obscureText,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: hint,
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB0B0B6),
                        ),
                      ),
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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
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

/// ─────────────────────────────────────────────────────────────
/// Background (light + subtle red blobs)
/// ─────────────────────────────────────────────────────────────
class NexoraBackground extends StatelessWidget {
  final Widget child;
  const NexoraBackground({super.key, required this.child});

  static const Color _mahogany = Color(0xFF440C08);
  static const Color _blood = Color(0xFF750A03);
  static const Color _cherry = Color(0xFF9B0F03);
  static const Color _red = Color(0xFFD1322E);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppColors.bg),
        _RadialLayer(
          alignment: const Alignment(-0.65, -0.85),
          size: 1100,
          color: _red.withOpacity(0.12),
          stop: 0.65,
        ),
        _RadialLayer(
          alignment: const Alignment(0.85, -0.85),
          size: 900,
          color: _cherry.withOpacity(0.10),
          stop: 0.62,
        ),
        _RadialLayer(
          alignment: const Alignment(0.0, 0.95),
          size: 1100,
          color: _blood.withOpacity(0.10),
          stop: 0.68,
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.02), Colors.black.withOpacity(0.06)],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _RadialLayer extends StatelessWidget {
  final Alignment alignment;
  final double size;
  final Color color;
  final double stop;
  const _RadialLayer({
    required this.alignment,
    required this.size,
    required this.color,
    required this.stop,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [color, color.withOpacity(0.0)],
              stops: const [0.0, 1.0],
              radius: stop,
            ),
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// Glass (now accepts BorderRadius)
/// ─────────────────────────────────────────────────────────────
class Glass extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final Color background;
  final double blur;
  final List<BoxShadow> shadows;
  final BoxBorder? border;

  const Glass({
    super.key,
    required this.child,
    required this.borderRadius,
    required this.padding,
    required this.background,
    required this.blur,
    required this.shadows,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: shadows,
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: background,
              borderRadius: borderRadius,
              border: border,
            ),
            child: child,
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
    final floatY = sin(floatingT * pi * 2) * 2.0;

    return Transform.translate(
      offset: Offset(0, floatY),
      child: Glass(
        borderRadius: AppRadius.r22,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        background: Colors.white.withOpacity(0.72),
        blur: 18,
        shadows: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 26, offset: Offset(0, 18)),
          BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.65), width: 1),
        child: child,
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// Button + Titles (theme reds)
/// ─────────────────────────────────────────────────────────────
class _Shiny3DButton extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> pressT;
  final String text;
  final VoidCallback onPressed;

  final Color mahogany, blood, cherry, red;

  const _Shiny3DButton({
    required this.controller,
    required this.pressT,
    required this.text,
    required this.onPressed,
    required this.mahogany,
    required this.blood,
    required this.cherry,
    required this.red,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = pressT.value;
        final lift = lerpDouble(1.0, 0.0, t)!;
        final press = lerpDouble(0.0, 1.0, t)!;

        return GestureDetector(
          onTapDown: (_) => controller.forward(),
          onTapCancel: () => controller.reverse(),
          onTapUp: (_) => controller.reverse(),
          onTap: onPressed,
          child: Transform.translate(
            offset: Offset(0, -lift),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 140),
              scale: 1.0 - (0.01 * press),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.r18,
                  gradient: LinearGradient(
                    begin: const Alignment(-1, -1),
                    end: const Alignment(1, 1),
                    colors: [mahogany, blood, red],
                    stops: const [0.0, 0.58, 1.0],
                  ),
                  border: Border.all(color: cherry.withOpacity(0.35)),
                  boxShadow: [
                    BoxShadow(color: mahogany.withOpacity(0.20), blurRadius: 26, offset: const Offset(0, 18)),
                    BoxShadow(color: red.withOpacity(0.10), blurRadius: 2, offset: const Offset(0, 1)),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: AppRadius.r18,
                        child: Opacity(
                          opacity: 0.75,
                          child: Transform.translate(
                            offset: Offset(
                              lerpDouble(-40, 40, (sin(controller.value * pi * 2) * 0.5 + 0.5))!,
                              0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: const Alignment(-0.6, -0.4),
                                  radius: 0.9,
                                  colors: [red.withOpacity(0.35), Colors.transparent],
                                  stops: const [0.0, 0.55],
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
                        style: GoogleFonts.manrope(
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
          ),
        );
      },
    );
  }
}

class _WelcomeSimpleTitle extends StatelessWidget {
  final String text;
  const _WelcomeSimpleTitle({required this.text});

  static const Color _red = Color(0xFFD1322E);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.2,
        color: AppColors.ink,
        shadows: [
          Shadow(
            blurRadius: 16,
            offset: const Offset(0, 10),
            color: _red.withOpacity(0.12),
          ),
        ],
      ),
    );
  }
}

class _LogoAssetOrFallback extends StatelessWidget {
  final double size;
  const _LogoAssetOrFallback({required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/logo.png",
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(Icons.auto_awesome_rounded, color: const Color(0xFFD1322E), size: size),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// INTRO LOCKUP (holo gradient = theme reds)
/// ─────────────────────────────────────────────────────────────
class _NexoraFullLockup extends StatelessWidget {
  final Color mahogany, blood, cherry, red;

  final List<_LetterAnim> letters;
  final String typedTagline;
  final double iconScale;
  final double iconFade;
  final double tagFade;
  final double tagSlide;

  final double logoTilt;
  final double logoSquash;
  final double logoSkidT;

  final double holoT;
  final double ambientT;

  final double logoSlideX;

  const _NexoraFullLockup({
    required this.mahogany,
    required this.blood,
    required this.cherry,
    required this.red,
    required this.letters,
    required this.typedTagline,
    required this.iconScale,
    required this.iconFade,
    required this.tagFade,
    required this.tagSlide,
    required this.holoT,
    required this.ambientT,
    required this.logoSlideX,
    required this.logoTilt,
    required this.logoSquash,
    required this.logoSkidT,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final h = c.maxHeight;
      final bool isTight = w < 520;

      final double logoSize = isTight ? (w * 0.36).clamp(150.0, 205.0) : (w * 0.22).clamp(190.0, 280.0);

      final double brandScaleBoost = isTight ? 1.06 : 1.18;
      final double maxLockupWidth = isTight ? min(w - 32, 560) : min(w - 40, 980);

      final movingFactor = (logoSlideX.abs() / 620.0).clamp(0.0, 1.0);
      final runBob = sin((1 - movingFactor) * pi * 8) * 6.0 * movingFactor;

      final skidAmp = (1.0 - (logoSkidT - 0.5).abs() * 2.0).clamp(0.0, 1.0);
      final skid = sin(logoSkidT * pi * 10) * 3.0 * skidAmp;

      Widget logo = Transform.translate(
        offset: Offset(logoSlideX + skid, runBob + (skid * 0.25)),
        child: Transform.rotate(
          angle: logoTilt,
          child: Transform.scale(
            scaleY: logoSquash,
            scaleX: (2.0 - logoSquash).clamp(0.90, 1.20),
            child: Opacity(
              opacity: iconFade.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: iconScale,
                child: SizedBox(
                  width: logoSize,
                  height: logoSize,
                  child: _LogoAssetOrFallback(size: logoSize * 0.28),
                ),
              ),
            ),
          ),
        ),
      );

      Widget word = _HoloGlassBrandWord(
        mahogany: mahogany,
        blood: blood,
        cherry: cherry,
        red: red,
        letters: letters,
        scaleBoost: brandScaleBoost,
        holoT: holoT,
        ambientT: ambientT,
        tight: isTight,
      );

      Widget tag = Transform.translate(
        offset: Offset(0, tagSlide),
        child: Opacity(
          opacity: tagFade.clamp(0.0, 1.0),
          child: _TaglineTypedText(text: typedTagline, tight: isTight),
        ),
      );

      final lockup = isTight
          ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          logo,
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxLockupWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(child: word),
                const SizedBox(height: 10),
                Center(child: tag),
              ],
            ),
          ),
        ],
      )
          : Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          logo,
          const SizedBox(width: 18),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxLockupWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  word,
                  const SizedBox(height: 10),
                  tag,
                ],
              ),
            ),
          ),
        ],
      );

      return Align(
        alignment: const Alignment(0, 0.10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: maxLockupWidth,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxLockupWidth,
                  maxHeight: (h * 0.85).clamp(320.0, 900.0),
                ),
                child: lockup,
              ),
            ),
          ),
        ),
      );
    });
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

class _HoloGlassBrandWord extends StatelessWidget {
  final Color mahogany, blood, cherry, red;

  final List<_LetterAnim> letters;
  final double scaleBoost;
  final double holoT;
  final double ambientT;
  final bool tight;

  const _HoloGlassBrandWord({
    required this.mahogany,
    required this.blood,
    required this.cherry,
    required this.red,
    required this.letters,
    required this.scaleBoost,
    required this.holoT,
    required this.ambientT,
    required this.tight,
  });

  @override
  Widget build(BuildContext context) {
    final shimmerX = lerpDouble(-0.9, 1.1, holoT)!;
    final shimmerY = sin(holoT * pi * 2) * 0.15;

    final baseFont = tight ? 54.0 : 66.0;
    final fontSize = baseFont * scaleBoost;

    return RepaintBoundary(
      child: Stack(
        children: [
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(sin(ambientT * pi * 2) * 2.0, cos(ambientT * pi * 2) * 1.0),
              child: Opacity(
                opacity: 0.50,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
                  child: _BrandWord(
                    letters: letters,
                    baseStyle: GoogleFonts.manrope(
                      fontSize: fontSize,
                      height: 0.92,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.3,
                      color: red.withOpacity(0.18),
                    ),
                    useHoloPaint: false,
                    holoPaint: null,
                    glassOverlay: false,
                  ),
                ),
              ),
            ),
          ),
          _BrandWord(
            letters: letters,
            baseStyle: GoogleFonts.manrope(
              fontSize: fontSize,
              height: 0.92,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.3,
              color: AppColors.ink.withOpacity(0.88),
            ),
            useHoloPaint: false,
            holoPaint: null,
            glassOverlay: true,
          ),
          ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (rect) {
              final begin = Alignment(shimmerX, -0.9 + shimmerY);
              final end = Alignment(-shimmerX, 0.9 - shimmerY);

              return LinearGradient(
                begin: begin,
                end: end,
                colors: [red, cherry, blood, mahogany],
                stops: const [0.0, 0.35, 0.70, 1.0],
              ).createShader(rect);
            },
            child: _BrandWord(
              letters: letters,
              baseStyle: GoogleFonts.manrope(
                fontSize: fontSize,
                height: 0.92,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.3,
                color: Colors.white.withOpacity(0.95),
              ),
              useHoloPaint: true,
              holoPaint: Paint()
                ..color = Colors.white.withOpacity(0.90)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6),
              glassOverlay: false,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.14,
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
                            red.withOpacity(0.25),
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
  final TextStyle baseStyle;
  final bool useHoloPaint;
  final Paint? holoPaint;
  final bool glassOverlay;

  const _BrandWord({
    required this.letters,
    required this.baseStyle,
    required this.useHoloPaint,
    required this.holoPaint,
    required this.glassOverlay,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 0,
      runSpacing: 0,
      children: [
        for (final l in letters)
          _LetterWidget(
            char: l.char,
            jumpY: l.jumpY.value,
            scale: l.scale.value,
            opacity: l.opacity.value,
            blur: l.blur.value,
            baseStyle: baseStyle,
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

  final TextStyle baseStyle;
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
    required this.useHoloPaint,
    required this.holoPaint,
    required this.glassOverlay,
  });

  @override
  Widget build(BuildContext context) {
    final face = Text(char, style: baseStyle);

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
                  for (int i = 6; i >= 1; i--)
                    Transform.translate(
                      offset: Offset(0, i.toDouble()),
                      child: Text(
                        char,
                        style: baseStyle.copyWith(color: Colors.black.withOpacity(0.045)),
                      ),
                    ),
                  if (glassOverlay) glass else face,
                  if (kIsWeb)
                    Text(
                      char,
                      style: baseStyle.copyWith(
                        color: (baseStyle.color ?? Colors.black).withOpacity(0.20),
                        shadows: const [],
                      ),
                    ),
                  if (useHoloPaint && holoPaint != null)
                    Text(char, style: baseStyle.copyWith(foreground: holoPaint, color: null)),
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
  final bool tight;
  const _TaglineTypedText({required this.text, required this.tight});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final fontSize = tight ? 15.0 : (w < 900 ? 16.0 : 17.0);

    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: tight ? TextAlign.center : TextAlign.left,
      style: GoogleFonts.manrope(
        fontSize: fontSize,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: AppColors.muted,
      ),
    );
  }
}

/// TOP CAP CLIPPER
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
