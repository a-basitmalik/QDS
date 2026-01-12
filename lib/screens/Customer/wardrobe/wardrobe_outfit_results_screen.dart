import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:qds/screens/Customer/wardrobe/wardrobe_models.dart';
import 'package:qds/screens/Customer/wardrobe/wardrobe_interior_screen.dart' show WardrobeOutfitService;

import 'package:qds/theme/app_colors.dart';
import 'package:qds/theme/app_radius.dart';
import 'package:qds/theme/app_shadows.dart';
import 'package:qds/theme/app_text.dart';
import 'package:qds/theme/app_widgets.dart';

class WardrobeOutfitResultsScreen extends StatefulWidget {
  final DayType dayType;
  final List<WardrobeItem> inventory;
  final List<List<WardrobeItem>> initialOutfits;

  const WardrobeOutfitResultsScreen({
    super.key,
    required this.dayType,
    required this.inventory,
    required this.initialOutfits,
  });

  @override
  State<WardrobeOutfitResultsScreen> createState() => _WardrobeOutfitResultsScreenState();
}

class _WardrobeOutfitResultsScreenState extends State<WardrobeOutfitResultsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ambientCtrl;
  late final Animation<double> _t;

  late DayType _dayType;
  late List<List<WardrobeItem>> _outfits;

  @override
  void initState() {
    super.initState();
    _dayType = widget.dayType;
    _outfits = widget.initialOutfits;

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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _MahoganyHeader(
              topInset: topInset,
              title: "Generated Outfits",
              subtitle: "${_dayType.emoji} ${_dayType.label} • 3 outfit ideas",
              onBack: () => Navigator.pop(context),
              t: _t.value,
            ),
          ),
          Positioned.fill(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, topInset + 120, 16, 26),
              children: [
                _controls(),
                const SizedBox(height: 12),
                ...List.generate(_outfits.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _OutfitCard(
                      t: _t.value,
                      index: i + 1,
                      items: _outfits[i],
                    ),
                  );
                }),
                const SizedBox(height: 6),
                _generateAgainButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _controls() {
    final availableCount = widget.inventory.where((e) => e.available).length;
    return _GlassCard(
      floatingT: _t.value,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Using $availableCount available items.\nWant different results? Tap Generate Again.",
              style: AppText.body().copyWith(
                fontSize: 12.6,
                color: AppColors.ink.withOpacity(0.60),
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Colors.white.withOpacity(0.55),
              border: Border.all(color: Colors.white.withOpacity(0.70)),
            ),
            child: Text(
              "${_dayType.emoji} ${_dayType.label}",
              style: AppText.kicker().copyWith(
                fontSize: 11.4,
                fontWeight: FontWeight.w900,
                color: AppColors.ink.withOpacity(0.70),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _generateAgainButton() {
    return _PressScale(
      onTap: () {
        setState(() {
          _outfits = WardrobeOutfitService.generateOutfits(
            inventory: widget.inventory,
            dayType: _dayType,
            outfitCount: 3,
          );
        });
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.16),
              AppColors.secondary.withOpacity(0.12),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.75)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 14),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.ink.withOpacity(0.78)),
            const SizedBox(width: 10),
            Text(
              "Generate again",
              style: AppText.kicker().copyWith(
                fontSize: 12.8,
                fontWeight: FontWeight.w900,
                color: AppColors.ink.withOpacity(0.78),
              ),
            ),
            const Spacer(),
            Icon(Icons.refresh_rounded, color: AppColors.ink.withOpacity(0.70)),
          ],
        ),
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
                dx: lerpDouble(-55, 18, tt)!,
                dy: lerpDouble(85, 62, tt)!,
                size: 260,
                opacity: 0.12,
                a: AppColors.primary,
                b: AppColors.secondary,
              ),
              _GlowBlob(
                dx: lerpDouble(220, 292, tt)!,
                dy: lerpDouble(240, 200, tt)!,
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
}

// ───────────────────────── UI pieces ─────────────────────────

class _OutfitCard extends StatelessWidget {
  final double t;
  final int index;
  final List<WardrobeItem> items;

  const _OutfitCard({
    required this.t,
    required this.index,
    required this.items,
  });

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
        borderColor: Colors.white.withOpacity(0.70),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 16),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Outfit #$index", style: AppText.h3().copyWith(fontSize: 15.4)),
                const Spacer(),
                Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.ink.withOpacity(0.55)),
              ],
            ),
            const SizedBox(height: 10),
            ...items.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: e.color.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white.withOpacity(0.70)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "${e.category.label}: ${e.name}",
                      style: AppText.body().copyWith(
                        fontSize: 12.8,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink.withOpacity(0.74),
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 6),
            Text(
              "Tip: mark items ⛔ unavailable in categories to avoid them.",
              style: AppText.body().copyWith(
                fontSize: 12.0,
                color: AppColors.ink.withOpacity(0.52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MahoganyHeader extends StatelessWidget {
  final double topInset;
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final double t;

  const _MahoganyHeader({
    required this.topInset,
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final shine = (sin(t * pi * 2) * 0.5 + 0.5);

    return Container(
      padding: EdgeInsets.fromLTRB(12, topInset + 10, 12, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.98),
            AppColors.secondary.withOpacity(0.96),
            AppColors.primary.withOpacity(0.94),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          _PressScale(
            onTap: onBack,
            child: const _TopIconPuck(icon: Icons.arrow_back_ios_new_rounded),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppText.h2().copyWith(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: 18.2,
                    )),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppText.body().copyWith(
                      color: Colors.white.withOpacity(0.74),
                      fontSize: 12.2,
                    )),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Colors.white.withOpacity(0.14 + 0.06 * shine),
              border: Border.all(color: Colors.white.withOpacity(0.24)),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.auto_awesome_rounded,
                size: 18, color: Colors.white.withOpacity(0.86)),
          ),
        ],
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
            color: Colors.white.withOpacity(0.18),
            border: Border.all(color: Colors.white.withOpacity(0.28)),
            boxShadow: AppShadows.puck,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: Colors.white.withOpacity(0.92)),
        ),
      ),
    );
  }
}
