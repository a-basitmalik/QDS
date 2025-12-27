import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const _ProfileTopCap(),

          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  140 + topInset,
                  16,
                  40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _profileHeader(),
                    const SizedBox(height: 20),

                    _sectionCard(
                      title: "Orders",
                      child: _menuTile(
                        icon: Icons.receipt_long_rounded,
                        title: "Order History",
                        subtitle: "Track & reorder past purchases",
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(height: 16),

                    _sectionCard(
                      title: "Saved Info",
                      child: Column(
                        children: [
                          _menuTile(
                            icon: Icons.location_on_outlined,
                            title: "Addresses",
                            subtitle: "Manage delivery locations",
                            onTap: () {},
                          ),
                          const Divider(),
                          _menuTile(
                            icon: Icons.account_balance_wallet_outlined,
                            title: "Wallet",
                            subtitle: "Cashbacks & refunds (coming soon)",
                            onTap: () {},
                            disabled: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _sectionCard(
                      title: "Support & Feedback",
                      child: Column(
                        children: [
                          _menuTile(
                            icon: Icons.support_agent_rounded,
                            title: "Customer Support",
                            subtitle: "Chat or call for help",
                            onTap: () {},
                          ),
                          const Divider(),
                          _menuTile(
                            icon: Icons.star_rate_rounded,
                            title: "Rate Shop & Rider",
                            subtitle: "Share your experience",
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    _logoutButton(),
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

  // ───────────────────── PROFILE HEADER ─────────────────────

  Widget _profileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r18),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.softCard,
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.chipFill,
              border: Border.all(color: AppColors.divider),
            ),
            alignment: Alignment.center,
            child: const Text(
              "A",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Abdul Basit",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "03XX-XXXXXXX",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMid,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────── SECTION CARD ─────────────────────

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

  // ───────────────────── MENU TILE ─────────────────────

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.chipFill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.textDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMid,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  // ───────────────────── LOGOUT ─────────────────────

  Widget _logoutButton() {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.divider),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r18),
        ),
      ),
      child: const Text(
        "Log out",
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: Colors.redAccent,
        ),
      ),
    );
  }

  // ───────────────────── TOP BAR ─────────────────────

  Widget _topBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 12,
      right: 12,
      child: Row(
        children: const [
          Text(
            "Profile",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────── TOP CAP ─────────────────────

class _ProfileTopCap extends StatelessWidget {
  const _ProfileTopCap();

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
