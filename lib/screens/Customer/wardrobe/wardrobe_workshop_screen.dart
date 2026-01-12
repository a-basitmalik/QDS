import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qds/theme/app_colors.dart';
import 'package:qds/theme/app_radius.dart';
import 'package:qds/theme/app_shadows.dart' show AppShadows;
import 'package:qds/theme/app_text.dart';
import 'package:qds/theme/app_widgets.dart';
import 'outfit_results_screen.dart';

import 'wardrobe_models.dart';
import 'outfit_engine.dart';

class WardrobeWorkshopScreen extends StatefulWidget {
  final DayType dayType;
  final List<WardrobeItem> inventory;

  const WardrobeWorkshopScreen({
    super.key,
    required this.dayType,
    required this.inventory,
  });

  @override
  State<WardrobeWorkshopScreen> createState() => _WardrobeWorkshopScreenState();
}

class _WardrobeWorkshopScreenState extends State<WardrobeWorkshopScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ambientCtrl;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _ambientCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 5200))
      ..repeat(reverse: true);
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
            top: topInset + 10,
            left: 12,
            right: 12,
            child: Row(
              children: [
                _PressScale(
                  onTap: () => Navigator.pop(context),
                  child: const _TopIconPuck(icon: Icons.arrow_back_ios_new_rounded),
                ),
                const Spacer(),
                _Extruded3DTitle(text: "OUTFIT WORKSHOP"),
                const Spacer(),
                const SizedBox(width: 44),
              ],
            ),
          ),

          Positioned.fill(
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeIn),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 110 + topInset, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topInfo(),
                    const SizedBox(height: 14),

                    ...WardrobeCategory.values.map((c) => _categorySection(c)),

                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ),

          _bottomGenerateDock(),
        ],
      ),
    );
  }

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
                dx: lerpDouble(-42, 18, tt)!,
                dy: lerpDouble(80, 55, tt)!,
                size: 260,
                opacity: 0.12,
                a: AppColors.primary,
                b: AppColors.secondary,
              ),
              _GlowBlob(
                dx: lerpDouble(220, 300, tt)!,
                dy: lerpDouble(230, 180, tt)!,
                size: 340,
                opacity: 0.10,
                a: AppColors.secondary,
                b: AppColors.other,
              ),
              _GlowBlob(
                dx: lerpDouble(100, 150, tt)!,
                dy: lerpDouble(560, 610, tt)!,
                size: 260,
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

  Widget _topInfo() {
    final activeCount = widget.inventory.where((e) => e.available).length;
    final total = widget.inventory.length;

    return _GlassCard(
      floatingT: _t.value,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${dayTypeEmoji(widget.dayType)} ${dayTypeTitle(widget.dayType)}", style: AppText.h2()),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "Available today: $activeCount / $total",
                style: AppText.body().copyWith(
                  fontSize: 13,
                  color: AppColors.ink.withOpacity(0.58),
                ),
              ),
              const Spacer(),
              _miniPill(
                text: "Tap items to toggle",
                icon: Icons.check_circle_outline_rounded,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Only items relevant to the selected day are highlighted. Unavailable items are excluded from outfit generation.",
            style: AppText.body().copyWith(
              fontSize: 12.8,
              color: AppColors.ink.withOpacity(0.58),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categorySection(WardrobeCategory c) {
    final items = widget.inventory.where((e) => e.category == c).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(c),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.98,
            ),
            itemBuilder: (_, i) => _itemCard(items[i]),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(WardrobeCategory c) {
    return Row(
      children: [
        Icon(catIcon(c), color: AppColors.ink.withOpacity(0.72)),
        const SizedBox(width: 8),
        Text(catTitle(c), style: AppText.h3()),
      ],
    );
  }

  Widget _itemCard(WardrobeItem item) {
    final isRelevant = item.tags.contains(widget.dayType) || widget.dayType == DayType.custom;
    final fade = isRelevant ? 1.0 : 0.35;

    final disabled = !item.available;

    return _PressScale(
      onTap: () {
        setState(() {
          item.available = !item.available;
        });
      },
      child: Opacity(
        opacity: fade,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          scale: disabled ? 0.985 : 1.0,
          child: Glass(
            borderRadius: AppRadius.r18,
            sigmaX: 16,
            sigmaY: 16,
            padding: const EdgeInsets.all(12),
            color: Colors.white.withOpacity(disabled ? 0.42 : 0.62),
            borderColor: Colors.white.withOpacity(disabled ? 0.50 : 0.68),
            shadows: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 22,
                offset: const Offset(0, 16),
              ),
            ],
            child: Stack(
              children: [
                // background icon
                Positioned(
                  right: -12,
                  bottom: -16,
                  child: Opacity(
                    opacity: 0.10,
                    child: Icon(catIcon(item.category), size: 64, color: AppColors.secondary),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _itemThumb(item, disabled: disabled),
                    const SizedBox(height: 10),
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.h3().copyWith(fontSize: 13.5),
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        _colorDot(item.color, disabled: disabled),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "${item.colorName} • ${styleLabel(item.style)}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.body().copyWith(
                              fontSize: 11.8,
                              color: AppColors.ink.withOpacity(disabled ? 0.42 : 0.58),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),
                    _availabilityPill(item.available),
                  ],
                ),

                // grey overlay for unavailable
                if (disabled)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.r18,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.10),
                              Colors.white.withOpacity(0.04),
                            ],
                          ),
                        ),
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

  Widget _itemThumb(WardrobeItem item, {required bool disabled}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item.color.withOpacity(disabled ? 0.10 : 0.18),
                Colors.white.withOpacity(disabled ? 0.10 : 0.16),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(disabled ? 0.40 : 0.62)),
          ),
          child: Center(
            child: Icon(
              catIcon(item.category),
              size: 26,
              color: AppColors.ink.withOpacity(disabled ? 0.35 : 0.70),
            ),
          ),
        ),
      ),
    );
  }

  Widget _colorDot(Color c, {required bool disabled}) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: disabled ? c.withOpacity(0.35) : c,
        boxShadow: [
          BoxShadow(
            color: c.withOpacity(disabled ? 0.10 : 0.18),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    );
  }

  Widget _availabilityPill(bool available) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: AppRadius.pill(),
        color: Colors.white.withOpacity(available ? 0.62 : 0.46),
        border: Border.all(color: Colors.white.withOpacity(available ? 0.72 : 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            available ? Icons.check_circle_rounded : Icons.block_rounded,
            size: 16,
            color: AppColors.ink.withOpacity(available ? 0.85 : 0.55),
          ),
          const SizedBox(width: 6),
          Text(
            available ? "Available" : "Unavailable",
            style: AppText.kicker().copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.ink.withOpacity(available ? 0.85 : 0.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniPill({required String text, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: AppRadius.pill(),
        color: Colors.white.withOpacity(0.58),
        border: Border.all(color: Colors.white.withOpacity(0.70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.ink.withOpacity(0.72)),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppText.kicker().copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              color: AppColors.ink.withOpacity(0.72),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomGenerateDock() {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _PressScale(
            onTap: () {
              final outfits = OutfitEngine.generate(
                dayType: widget.dayType,
                inventory: widget.inventory,
                count: 3,
              );

              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 520),
                  pageBuilder: (_, __, ___) => OutfitResultsScreen(
                    dayType: widget.dayType,
                    inventory: widget.inventory,
                    initialOutfits: outfits,
                  ),
                  transitionsBuilder: (_, anim, __, child) {
                    final a = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
                    return FadeTransition(
                      opacity: a,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(a),
                        child: child,
                      ),
                    );
                  },
                ),
              );
            },
            downScale: 0.985,
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
                    border: Border.all(color: Colors.white.withOpacity(0.14), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.34),
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
                        color: Colors.white.withOpacity(0.18),
                        blurRadius: 24,
                        offset: const Offset(0, -14),
                        spreadRadius: -18,
                        blurStyle: BlurStyle.inner,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white.withOpacity(0.12),
                          border: Border.all(color: Colors.white.withOpacity(0.14)),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.auto_awesome_rounded, color: Colors.white.withOpacity(0.92)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "GENERATE OUTFIT",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: Colors.white.withOpacity(0.92),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Uses only ✅ available items",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.white.withOpacity(0.78),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.92)),
                    ],
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

// ───────────── helpers ─────────────

class _GlowBlob extends StatelessWidget {
  final double dx, dy, size, opacity;
  final Color a, b;
  const _GlowBlob({required this.dx, required this.dy, required this.size, required this.opacity, required this.a, required this.b});

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

  const _GlassCard({required this.child, required this.floatingT, required this.padding});

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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: AppColors.ink,
            height: 1.0,
            shadows: [
              Shadow(blurRadius: 18, offset: const Offset(0, 10), color: AppColors.secondary.withOpacity(0.14)),
              Shadow(blurRadius: 10, offset: const Offset(0, 6), color: Colors.black.withOpacity(0.10)),
            ],
          ),
        ),
      ],
    );
  }
}
