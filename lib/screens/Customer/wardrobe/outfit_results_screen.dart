import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:qds/theme/app_colors.dart';
import 'package:qds/theme/app_radius.dart';
import 'package:qds/theme/app_shadows.dart';
import 'package:qds/theme/app_text.dart';
import 'package:qds/theme/app_widgets.dart';
import 'wardrobe_models.dart';
import 'outfit_engine.dart';


class OutfitResultsScreen extends StatefulWidget {
  final DayType dayType;
  final List<WardrobeItem> inventory;
  final List<OutfitOption> initialOutfits;

  const OutfitResultsScreen({
    super.key,
    required this.dayType,
    required this.inventory,
    required this.initialOutfits,
  });

  @override
  State<OutfitResultsScreen> createState() => _OutfitResultsScreenState();
}

class _OutfitResultsScreenState extends State<OutfitResultsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ambientCtrl;
  late final Animation<double> _t;

  late List<OutfitOption> _outfits;
  int _seed = 0;

  @override
  void initState() {
    super.initState();
    _outfits = widget.initialOutfits;
    _ambientCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 5200))
      ..repeat(reverse: true);
    _t = CurvedAnimation(parent: _ambientCtrl, curve: Curves.easeInOutSine);
  }

  @override
  void dispose() {
    _ambientCtrl.dispose();
    super.dispose();
  }

  void _regen() {
    setState(() {
      _seed = _seed + 17;
      _outfits = OutfitEngine.generate(
        dayType: widget.dayType,
        inventory: widget.inventory,
        count: 3,
        seed: DateTime.now().millisecondsSinceEpoch + _seed,
      );
    });
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
                const _Extruded3DTitle(text: "OUTFITS"),
                const Spacer(),
                const SizedBox(width: 44),
              ],
            ),
          ),

          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 110 + topInset, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 14),

                  if (_outfits.isEmpty) _emptyState(),

                  if (_outfits.isNotEmpty)
                    ...List.generate(_outfits.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _outfitCard(_outfits[i], index: i + 1),
                      );
                    }),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          _bottomDock(),
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
                dy: lerpDouble(70, 50, tt)!,
                size: 260,
                opacity: 0.12,
                a: AppColors.primary,
                b: AppColors.secondary,
              ),
              _GlowBlob(
                dx: lerpDouble(230, 290, tt)!,
                dy: lerpDouble(230, 185, tt)!,
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

  Widget _header() {
    final availableCount = widget.inventory.where((e) => e.available).length;

    return _GlassCard(
      floatingT: _t.value,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${dayTypeEmoji(widget.dayType)} ${dayTypeTitle(widget.dayType)}", style: AppText.h2()),
          const SizedBox(height: 8),
          Text(
            "Generated using only ✅ available items ($availableCount).",
            style: AppText.body().copyWith(
              fontSize: 13,
              color: AppColors.ink.withOpacity(0.58),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return _GlassCard(
      floatingT: _t.value * 0.8,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.warning_rounded, color: AppColors.ink.withOpacity(0.7)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Not enough available items to generate a complete outfit. Make sure you have at least 1 top, 1 bottom, and 1 shoe set marked as available.",
              style: AppText.body().copyWith(
                fontSize: 12.8,
                color: AppColors.ink.withOpacity(0.58),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _outfitCard(OutfitOption o, {required int index}) {
    return _GlassCard(
      floatingT: _t.value * (0.85 + index * 0.02),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Outfit $index", style: AppText.h3()),
              const Spacer(),
              _miniPill("AI Matched", Icons.auto_awesome_rounded),
            ],
          ),
          const SizedBox(height: 12),

          _rowItem("Top", o.top),
          const SizedBox(height: 8),
          _rowItem("Bottom", o.bottom),
          const SizedBox(height: 8),
          _rowItem("Shoes", o.shoes),

          if (o.jacket != null) ...[
            const SizedBox(height: 8),
            _rowItem("Jacket", o.jacket!),
          ],
          if (o.watch != null) ...[
            const SizedBox(height: 8),
            _rowItem("Watch", o.watch!),
          ],
          if (o.glasses != null) ...[
            const SizedBox(height: 8),
            _rowItem("Glasses", o.glasses!),
          ],
          if (o.accessories.isNotEmpty) ...[
            const SizedBox(height: 8),
            _rowText("Accessories", o.accessories.map((e) => e.name).join(", ")),
          ],

          const SizedBox(height: 14),
          Text("Why this works", style: AppText.h3().copyWith(fontSize: 13.5)),
          const SizedBox(height: 6),
          Text(
            o.explanation,
            style: AppText.body().copyWith(
              fontSize: 12.8,
              height: 1.35,
              color: AppColors.ink.withOpacity(0.60),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowItem(String label, WardrobeItem i) {
    return Row(
      children: [
        _colorDot(i.color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "$label • ${i.name}",
            style: AppText.body().copyWith(
              fontSize: 13.2,
              fontWeight: FontWeight.w900,
              color: AppColors.ink.withOpacity(0.86),
            ),
          ),
        ),
        Text(
          i.colorName,
          style: AppText.kicker().copyWith(
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
            color: AppColors.ink.withOpacity(0.52),
          ),
        ),
      ],
    );
  }

  Widget _rowText(String label, String value) {
    return Row(
      children: [
        Icon(Icons.star_rounded, size: 16, color: AppColors.ink.withOpacity(0.65)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "$label • $value",
            style: AppText.body().copyWith(
              fontSize: 13.0,
              fontWeight: FontWeight.w900,
              color: AppColors.ink.withOpacity(0.86),
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniPill(String text, IconData icon) {
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

  Widget _colorDot(Color c) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c,
        boxShadow: [
          BoxShadow(
            color: c.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    );
  }

  Widget _bottomDock() {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: _PressScale(
                  onTap: () => Navigator.pop(context),
                  child: _softButton("Back to workshop"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PressScale(
                  onTap: _regen,
                  child: _primaryButton("Generate 3 more"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _softButton(String text) {
    return ClipRRect(
      borderRadius: AppRadius.r18,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: AppRadius.r18,
            color: Colors.white.withOpacity(0.58),
            border: Border.all(color: Colors.white.withOpacity(0.72)),
            boxShadow: AppShadows.soft,
          ),
          child: Text(
            text,
            style: AppText.kicker().copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.ink.withOpacity(0.82),
            ),
          ),
        ),
      ),
    );
  }

  Widget _primaryButton(String text) {
    return ClipRRect(
      borderRadius: AppRadius.r18,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: AppRadius.r18,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.92),
                AppColors.secondary.withOpacity(0.88),
                AppColors.primary.withOpacity(0.92),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.32),
                blurRadius: 34,
                offset: const Offset(0, 24),
                spreadRadius: -6,
              ),
            ],
          ),
          child: Text(
            text.toUpperCase(),
            style: AppText.kicker().copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: Colors.white.withOpacity(0.92),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────── helpers ─────────

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
