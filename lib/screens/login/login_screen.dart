import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_text.dart';
import '../../theme/app_shadows.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool obscure = true;
  bool remember = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const _LoginTopCap(),
          _body(),
        ],
      ),
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 40, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 26),

          // Logo / Title
          const Text(
            "Welcome Back",
            textAlign: TextAlign.center,
            style: AppText.displaySerif,
          ),
          const SizedBox(height: 10),
          const Text(
            "Sign in to continue shopping that\nmoves at your speed",
            textAlign: TextAlign.center,
            style: AppText.body14Soft,
          ),
          const SizedBox(height: 22),

          // Card
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r18),
              border: Border.all(color: AppColors.divider),
              boxShadow: AppShadows.softCard,
            ),
            child: Column(
              children: [
                _field(
                  label: "Email",
                  hint: "you@example.com",
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline_rounded,
                ),
                const SizedBox(height: 12),
                _field(
                  label: "Password",
                  hint: "••••••••",
                  controller: passCtrl,
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
                    _rememberToggle(),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textDark,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Sign In button (theme style)
                SizedBox(
                  height: 54,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textDark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.r22),
                      ),
                    ),
                    child: const Text(
                      "Sign in",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don’t have an account?",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMid,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
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
            ),
          ),

          const SizedBox(height: 18),

          // Social sign-in (optional, matches theme)
          _socialRow(),
        ],
      ),
    );
  }

  Widget _rememberToggle() {
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

  Widget _socialRow() {
    Widget socialButton({required String label, required IconData icon, VoidCallback? onTap}) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.r18),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r18),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: AppColors.textDark),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        socialButton(label: "Google", icon: Icons.g_mobiledata_rounded, onTap: () {}),
        const SizedBox(width: 12),
        socialButton(label: "Apple", icon: Icons.apple_rounded, onTap: () {}),
      ],
    );
  }

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    required IconData prefixIcon,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.textMid,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r18),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(prefixIcon, size: 18, color: AppColors.textMid),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
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
              if (suffix != null) suffix,
              const SizedBox(width: 6),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoginTopCap extends StatelessWidget {
  const _LoginTopCap();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: -topInset,
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: _HeaderCapClipper(),
        child: Container(
          height: 150 + topInset,
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: AppShadows.topCap,
          ),
        ),
      ),
    );
  }
}

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
