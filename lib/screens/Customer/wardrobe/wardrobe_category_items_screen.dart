import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:qds/screens/Customer/wardrobe/wardrobe_models.dart';

import 'package:qds/theme/app_colors.dart';
import 'package:qds/theme/app_radius.dart';
import 'package:qds/theme/app_shadows.dart';
import 'package:qds/theme/app_text.dart';
import 'package:qds/theme/app_widgets.dart';

class WardrobeCategoryItemsScreen extends StatefulWidget {
  final WardrobeCategory category;
  final List<WardrobeItem> inventory;

  const WardrobeCategoryItemsScreen({
    super.key,
    required this.category,
    required this.inventory,
  });

  @override
  State<WardrobeCategoryItemsScreen> createState() => _WardrobeCategoryItemsScreenState();
}

class _WardrobeCategoryItemsScreenState extends State<WardrobeCategoryItemsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ambientCtrl;
  late final Animation<double> _t;

  late List<WardrobeItem> _inv;

  @override
  void initState() {
    super.initState();
    _inv = widget.inventory.map((e) => e.copy()).toList();

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
    final items = _inv.where((e) => e.category == widget.category).toList();

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
              title: widget.category.label,
              subtitle: "Manage availability for outfit generation",
              onBack: () => Navigator.pop(context, _inv),
              t: _t.value,
            ),
          ),
          Positioned.fill(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, topInset + 120, 16, 28),
              children: [
                if (items.isEmpty)
                  _GlassCard(
                    floatingT: _t.value,
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "No items found in this category yet.",
                      style: AppText.body().copyWith(
                        color: AppColors.ink.withOpacity(0.62),
                      ),
                    ),
                  )
                else
                  ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ItemCard(
                      t: _t.value,
                      item: item,
                      onToggleUnavailable: () {
                        setState(() {
                          _inv = _inv.map((x) {
                            if (x.id != item.id) return x;
                            return x.copyWith(available: !x.available);
                          }).toList();
                        });
                      },
                      onRemove: () {
                        setState(() {
                          _inv.removeWhere((x) => x.id == item.id);
                        });
                      },
                    ),
                  )),
                const SizedBox(height: 10),
                _GlassCard(
                  floatingT: _t.value * 0.7,
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    "✅ Available items are used to generate outfits. ⛔ Unavailable items are skipped (but still saved in wardrobe).",
                    style: AppText.body().copyWith(
                      fontSize: 12.4,
                      color: AppColors.ink.withOpacity(0.58),
                    ),
                  ),
                ),
              ],
            ),
          ),
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

// ───────────────────────── UI ─────────────────────────

class _ItemCard extends StatelessWidget {
  final double t;
  final WardrobeItem item;
  final VoidCallback onToggleUnavailable;
  final VoidCallback onRemove;

  const _ItemCard({
    required this.t,
    required this.item,
    required this.onToggleUnavailable,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final floatY = sin(t * pi * 2) * 1.6;

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // color puck
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: item.color.withOpacity(0.92),
                border: Border.all(color: Colors.white.withOpacity(0.68)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: AppText.h3().copyWith(fontSize: 15.4)),
                  const SizedBox(height: 6),
                  Text(
                    "${item.colorName} • ${item.style.name}",
                    style: AppText.body().copyWith(
                      fontSize: 12.2,
                      color: AppColors.ink.withOpacity(0.58),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.tags
                        .take(5)
                        .map((d) => _Chip(text: "${d.emoji} ${d.label}"))
                        .toList(),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: item.available ? Icons.block_rounded : Icons.check_circle_rounded,
                          label: item.available ? "Temporarily unavailable" : "Mark available",
                          tone: item.available ? _Tone.warn : _Tone.good,
                          onTap: onToggleUnavailable,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.delete_outline_rounded,
                          label: "Remove",
                          tone: _Tone.danger,
                          onTap: onRemove,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final _Tone tone;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.tone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    switch (tone) {
      case _Tone.good:
        bg = Colors.green.withOpacity(0.10);
        border = Colors.green.withOpacity(0.18);
        break;
      case _Tone.warn:
        bg = Colors.orange.withOpacity(0.12);
        border = Colors.orange.withOpacity(0.20);
        break;
      case _Tone.danger:
        bg = Colors.red.withOpacity(0.10);
        border = Colors.red.withOpacity(0.18);
        break;
    }

    return _PressScale(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: bg,
          border: Border.all(color: border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.ink.withOpacity(0.70)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.kicker().copyWith(
                  fontSize: 11.6,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink.withOpacity(0.72),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Tone { good, warn, danger }

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.55),
        border: Border.all(color: Colors.white.withOpacity(0.70)),
      ),
      child: Text(
        text,
        style: AppText.body().copyWith(
          fontSize: 11.3,
          fontWeight: FontWeight.w700,
          color: AppColors.ink.withOpacity(0.62),
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
            child: Icon(Icons.checkroom_rounded,
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
