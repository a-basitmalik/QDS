import 'dart:ui';
import 'package:flutter/material.dart';

void main() => runApp(const FeedUiApp());

class FeedUiApp extends StatelessWidget {
  const FeedUiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        useMaterial3: true,
      ),
      home: const YourFeedScreen(),
    );
  }
}

class YourFeedScreen extends StatelessWidget {
  const YourFeedScreen({super.key});

  static const bg = Color(0xFFF5F5F7);
  static const textDark = Color(0xFF1C1C1E);
  static const textMid = Color(0xFF6B6B70);
  static const divider = Color(0xFFE9E9EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // ✅ Grey panel behind "Your Feed" section (like image)
            const _FeedGreyPanel(),

            // ✅ Pure white cap behind date/bell/avatar (and behind status bar too)
            const _TopCapWhite(),

            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _topChrome(),
                  const SizedBox(height: 18),

                  const Text(
                    "Your Feed",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      height: 1.05,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Georgia',
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Add your own pieces to create a\npersonalized feed",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: Color(0xFF8A8A90),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _hangerMock(),
                  const SizedBox(height: 16),

                  _closetCapsule(),
                  const SizedBox(height: 22),

                  Row(
                    children: const [
                      Text(
                        "Inspo",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                      Spacer(),
                      Text(
                        "Scroll for inspiration",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9A9AA0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _inspoPreviewCard(),
                ],
              ),
            ),

            const Align(
              alignment: Alignment.bottomCenter,
              child: _ThreeDNavBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topChrome() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "05",
              style: TextStyle(
                fontSize: 44,
                height: 1.0,
                fontWeight: FontWeight.w600,
                color: textDark,
                letterSpacing: -1.0,
              ),
            ),
            SizedBox(height: 2),
            Row(
              children: [
                Text(
                  "today",
                  style: TextStyle(
                    fontSize: 13,
                    color: textMid,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "feb",
                  style: TextStyle(
                    fontSize: 13,
                    color: textMid,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),

        // Bell + avatar (same)
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
          color: textDark,
          splashRadius: 22,
        ),
        const SizedBox(width: 2),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFEDEDF2),
            border: Border.all(color: divider),
          ),
          child: ClipOval(
            child: Image.network(
              "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=60",
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _hangerMock() {
    return Container(
      height: 170,
      alignment: Alignment.center,
      child: Container(
        width: 280,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.62),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: divider),
          boxShadow: const [
            BoxShadow(
              blurRadius: 26,
              offset: Offset(0, 16),
              color: Color(0x0F000000),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 180,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFFEDEDF2),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 14,
              children: List.generate(
                8,
                    (_) => Container(
                  width: 10,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE6E6EC)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _closetCapsule() {
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F12),
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              blurRadius: 30,
              offset: Offset(0, 18),
              color: Color(0x26000000),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: const [
                Text(
                  "Closet",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Text(
                  "0/6",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE9E9EE)),
              ),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add, color: textDark, size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Add to closet",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inspoPreviewCard() {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFD7D9DD), Color(0xFFBFC3C9)],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: divider),
                ),
                child: const Text(
                  "Inspo card",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ✅ Light grey sheet behind the "Your Feed" content area (matches image)
class _FeedGreyPanel extends StatelessWidget {
  const _FeedGreyPanel();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned(
      top: 70, // starts just under the cap
      left: 0,
      right: 0,
      child: Container(
        height: size.height * 0.50,
        decoration: const BoxDecoration(
          color: Color(0xFFEFEFF2), // the subtle grey difference like mock
        ),
      ),
    );
  }
}

/// ✅ Pure white cap behind date/bell/avatar.
/// Positioned slightly UP so it covers behind the real device status bar too.
class _TopCapWhite extends StatelessWidget {
  const _TopCapWhite();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: -topInset, // ✅ extend behind real status bar
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: _HeaderCapClipper(),
        child: Container(
          height: 132 + topInset,
          decoration: const BoxDecoration(
            color: Colors.white, // ✅ pure white like image top
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: Offset(0, 12),
                color: Color(0x12000000),
              ),
            ],
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

class _ThreeDNavBar extends StatelessWidget {
  const _ThreeDNavBar();

  static const _pill = Color(0xFF0F0F12);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: _pill.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 26,
                      offset: Offset(0, 14),
                      color: Color(0x33000000),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    _navIcon(Icons.home_rounded, active: true, onTap: () {}),
                    _navIcon(Icons.flash_on_rounded, active: false, onTap: () {}),
                    const Spacer(),
                    _navIcon(Icons.checkroom_rounded, active: false, onTap: () {}),
                    _navIcon(Icons.bookmark_rounded, active: false, onTap: () {}),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment(-0.2, -0.2),
                    radius: 0.9,
                    colors: [
                      Color(0xFF9FA0A7),
                      Color(0xFF3A3A44),
                      Color(0xFF14141A),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 18,
                      offset: Offset(0, 10),
                      color: Color(0x55000000),
                    ),
                    BoxShadow(
                      blurRadius: 8,
                      offset: Offset(0, -2),
                      color: Color(0x22FFFFFF),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _navIcon(IconData icon, {required bool active, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Center(
          child: Icon(
            icon,
            size: 22,
            color: active ? Colors.white : Colors.white.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
