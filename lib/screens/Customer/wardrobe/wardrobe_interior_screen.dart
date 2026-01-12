import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:qds/screens/Customer/wardrobe/wardrobe_demo_data.dart';
import 'package:qds/screens/Customer/wardrobe/wardrobe_models.dart';
import 'package:qds/screens/Customer/wardrobe/wardrobe_workshop_screen.dart';

import 'package:qds/theme/app_colors.dart';
import 'package:qds/theme/app_radius.dart';
import 'package:qds/theme/app_shadows.dart';
import 'package:qds/theme/app_text.dart';
import 'package:qds/theme/app_widgets.dart';

class WardrobeInteriorScreen extends StatefulWidget {
  const WardrobeInteriorScreen({super.key});

  @override
  State<WardrobeInteriorScreen> createState() => _WardrobeInteriorScreenState();
}

class _WardrobeInteriorScreenState extends State<WardrobeInteriorScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ambientCtrl;
  late final Animation<double> _t;

  // ✅ Hardcoded cards but now they carry DayType (so Workshop works)
  final List<_DayPick> _dayPicks = const [
    _DayPick(DayType.university, "🎓", "University Day", "Smart & comfy campus fits"),
    _DayPick(DayType.office, "🏢", "Office Day", "Polished work-ready outfits"),
    _DayPick(DayType.dayOut, "🌇", "Day Out", "Casual but stylish looks"),
    _DayPick(DayType.party, "🎉", "Party / Event", "Bold and elevated vibes"),
    _DayPick(DayType.casualHome, "🧘", "Casual / Home", "Relaxed, cozy essentials"),
    _DayPick(DayType.rainy, "🌧️", "Rainy Day", "Layered + weather-ready"),
    _DayPick(DayType.winter, "❄️", "Winter Day", "Warm layers & textures"),
    _DayPick(DayType.summer, "🌞", "Summer Day", "Lightweight breathable picks"),
    _DayPick(DayType.custom, "➕", "Custom", "Mix & match your mood"),
  ];

  @override
  void initState() {
    super.initState();
    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat(reverse: true);
    _t = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOutSine);
  }

  @override
  void dispose() {
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
          _bg(),
          _glow(),

          // ✅ Top Bar (clean, no 3D)
          Positioned(
            top: topInset + 10,
            left: 12,
            right: 12,
            child: Row(
              children: [
                _PressScale(
                  onTap: () => Navigator.pop(context),
                  child: const _TopIconPuck(icon: Icons.arrow_back_ios_new_rounded),
                ),
                const SizedBox(width: 10),
                Expanded(child: _GlassHeaderPill(t: _t.value)),
                const SizedBox(width: 10),
                const SizedBox(width: 44),
              ],
            ),
          ),

          // content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 104 + topInset, 16, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _headerCard(),
                  const SizedBox(height: 14),
                  _hardcodedDayGrid(),
                  const SizedBox(height: 12),
                  _hintCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Background ─────────────────────────

  Widget _bg() {
    return AnimatedBuilder(
      animation: _ambientCtrl,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(AppColors.bg3, AppColors.bg2, _t.value)!,
                Color.lerp(AppColors.bg3, AppColors.bg1, _t.value)!,
                AppColors.bg3,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _glow() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ambientCtrl,
        builder: (_, __) {
          final tt = _t.value;
          return Stack(
            children: [
              _GlowBlob(
                dx: lerpDouble(-50, 18, tt)!,
                dy: lerpDouble(70, 55, tt)!,
                size: 260,
                opacity: 0.12,
                a: AppColors.primary,
                b: AppColors.secondary,
              ),
              _GlowBlob(
                dx: lerpDouble(230, 290, tt)!,
                dy: lerpDouble(210, 175, tt)!,
                size: 320,
                opacity: 0.10,
                a: AppColors.secondary,
                b: AppColors.other,
              ),
            ],
          );
        },
      ),
    );
  }

  // ───────────────────────── Content ─────────────────────────

  Widget _headerCard() {
    return _GlassCard(
      floatingT: _t.value,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("What kind of day are you dressing for?", style: AppText.h2()),
          const SizedBox(height: 8),
          Text(
            "Pick a day type to open the Outfit Workshop.",
            style: AppText.body().copyWith(
              fontSize: 13,
              color: AppColors.ink.withOpacity(0.58),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hardcodedDayGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _dayPicks.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.20,
      ),
      itemBuilder: (_, i) {
        final p = _dayPicks[i];
        return _PressScale(
          onTap: () => _openWorkshop(p.dayType),
          child: _HardDayCard(pick: p, t: _t.value),
        );
      },
    );
  }

  void _openWorkshop(DayType dayType) {
    // ✅ Use demo data inventory (your Workshop expects WardrobeItem list)
    final inv = WardrobeDemoData.purchasedItems().map((e) => e.copy()).toList();

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 520),
        pageBuilder: (_, __, ___) => WardrobeWorkshopScreen(
          dayType: dayType,
          inventory: inv,
        ),
        transitionsBuilder: (_, anim, __, child) {
          final a = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(a),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _hintCard() {
    return _GlassCard(
      floatingT: _t.value * 0.7,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(Icons.tune_rounded, color: AppColors.ink.withOpacity(0.7)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "In Workshop, toggle items as ✅ Available or ⛔ Unavailable. Unavailable items are excluded from outfits.",
              style: AppText.body().copyWith(
                fontSize: 12.5,
                color: AppColors.ink.withOpacity(0.58),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────── Hardcoded Pick Model ───────────────

class _DayPick {
  final DayType dayType;
  final String emoji;
  final String title;
  final String subtitle;
  const _DayPick(this.dayType, this.emoji, this.title, this.subtitle);
}

// ─────────────── UI pieces ───────────────

class _HardDayCard extends StatelessWidget {
  final _DayPick pick;
  final double t;
  const _HardDayCard({required this.pick, required this.t});

  @override
  Widget build(BuildContext context) {
    final floatY = sin(t * pi * 2) * 2.0;

    return Transform.translate(
      offset: Offset(0, floatY),
      child: Glass(
        borderRadius: AppRadius.r18,
        sigmaX: 16,
        sigmaY: 16,
        padding: const EdgeInsets.all(14),
        color: Colors.white.withOpacity(0.62),
        borderColor: Colors.white.withOpacity(0.68),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 16),
          ),
        ],
        child: Stack(
          children: [
            Positioned(
              right: -8,
              top: -10,
              child: Opacity(
                opacity: 0.12,
                child: Icon(Icons.auto_awesome_rounded, size: 62, color: AppColors.secondary),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pick.emoji, style: const TextStyle(fontSize: 26)),
                const Spacer(),
                Text(
                  pick.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.h3().copyWith(fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  pick.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body().copyWith(
                    fontSize: 12.2,
                    color: AppColors.ink.withOpacity(0.58),
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "Open workshop",
                      style: AppText.kicker().copyWith(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink.withOpacity(0.55),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.ink.withOpacity(0.55)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
              colors: [a.withOpacity(opacity), b.withOpacity(opacity * 0.65), Colors.transparent],
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
    final floatY = sin(floatingT * pi * 2) * 3.0;
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

class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double downScale;
  const _PressScale({required this.child, required this.onTap, this.downScale = 0.972});

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

class _GlassHeaderPill extends StatelessWidget {
  final double t;
  const _GlassHeaderPill({required this.t});

  @override
  Widget build(BuildContext context) {
    final shine = (sin(t * pi * 2) * 0.5 + 0.5); // 0..1
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.60),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.72)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.ink.withOpacity(0.78)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Wardrobe",
                  style: AppText.h3().copyWith(
                    fontSize: 15.5,
                    letterSpacing: 0.2,
                    color: AppColors.ink.withOpacity(0.88),
                  ),
                ),
              ),
              Container(
                width: 36,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.secondary.withOpacity(0.18 + 0.10 * shine),
                      AppColors.primary.withOpacity(0.12 + 0.08 * shine),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.ink.withOpacity(0.55)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
