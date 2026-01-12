import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:qds/screens/Customer/wardrobe/wardrobe_demo_data.dart';
import 'package:qds/screens/Customer/wardrobe/wardrobe_models.dart';
import 'package:qds/screens/Customer/wardrobe/wardrobe_category_items_screen.dart';
import 'package:qds/screens/Customer/wardrobe/wardrobe_outfit_results_screen.dart';

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

  /// ✅ Single source of truth in this flow (demo now, DB later)
  late List<WardrobeItem> _inventory;

  @override
  void initState() {
    super.initState();
    _inventory = WardrobeDemoData.purchasedItems().map((e) => e.copy()).toList();

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

          // ✅ Mahogany header bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _MahoganyHeader(
              topInset: topInset,
              title: "Wardrobe",
              subtitle: "Your purchased items, neatly organized",
              onBack: () => Navigator.pop(context),
              t: _t.value,
            ),
          ),

          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, topInset + 120, 16, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _generateNowCard(),
                  const SizedBox(height: 14),
                  Text("Categories", style: AppText.h2().copyWith(fontSize: 18)),
                  const SizedBox(height: 10),
                  _categoriesGrid(),
                  const SizedBox(height: 14),
                  _availabilityHint(),
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
                dx: lerpDouble(-60, 22, tt)!,
                dy: lerpDouble(90, 70, tt)!,
                size: 260,
                opacity: 0.12,
                a: AppColors.primary,
                b: AppColors.secondary,
              ),
              _GlowBlob(
                dx: lerpDouble(230, 295, tt)!,
                dy: lerpDouble(250, 205, tt)!,
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

  // ───────────────────────── UI ─────────────────────────

  Widget _generateNowCard() {
    return _GlassCard(
      floatingT: _t.value,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.20),
                      AppColors.secondary.withOpacity(0.12),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.auto_awesome_rounded,
                    color: AppColors.ink.withOpacity(0.78)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Generate my Outfit now", style: AppText.h2()),
                    const SizedBox(height: 2),
                    Text(
                      "Uses only items marked ✅ available.",
                      style: AppText.body().copyWith(
                        fontSize: 12.7,
                        color: AppColors.ink.withOpacity(0.58),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PressScale(
            onTap: _openDayPickerSheet,
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.primary.withOpacity(0.10),
                border: Border.all(color: Colors.white.withOpacity(0.75)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Text(
                    "Choose day/event & generate",
                    style: AppText.kicker().copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink.withOpacity(0.72),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_rounded,
                      size: 18, color: AppColors.ink.withOpacity(0.72)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoriesGrid() {
    final cats = WardrobeCategory.values;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (_, i) {
        final c = cats[i];
        final count = _inventory.where((x) => x.category == c).length;

        return _PressScale(
          onTap: () async {
            final updated = await Navigator.push<List<WardrobeItem>>(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 420),
                pageBuilder: (_, __, ___) => WardrobeCategoryItemsScreen(
                  category: c,
                  inventory: _inventory,
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

            if (updated != null) setState(() => _inventory = updated);
          },
          child: _CategoryCard(
            t: _t.value,
            title: c.label,
            count: count,
            icon: _iconForCategory(c),
          ),
        );
      },
    );
  }

  IconData _iconForCategory(WardrobeCategory c) {
    switch (c) {
      case WardrobeCategory.shalwarKameez:
        return Icons.checkroom_rounded;
      case WardrobeCategory.pants:
        return Icons.work_rounded;
      case WardrobeCategory.shirts:
        return Icons.style_rounded;
      case WardrobeCategory.kurtas:
        return Icons.local_mall_rounded;
      case WardrobeCategory.pajamas:
        return Icons.nightlight_round;
      case WardrobeCategory.bridalwear:
        return Icons.auto_awesome_rounded;
      case WardrobeCategory.others:
        return Icons.category_rounded;
    }
  }

  Widget _availabilityHint() {
    final availableCount = _inventory.where((e) => e.available).length;
    final totalCount = _inventory.length;

    return _GlassCard(
      floatingT: _t.value * 0.7,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(Icons.verified_rounded, color: AppColors.ink.withOpacity(0.7)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$availableCount / $totalCount items are available for generation. Mark items ⛔ temporarily unavailable from inside a category.",
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

  // ───────────────────────── Bottom sheet + generation ─────────────────────────

  void _openDayPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DayPickerSheet(
        inventory: _inventory,
        onGenerate: (dayType, outfits) {
          Navigator.pop(context);

          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (_, __, ___) => WardrobeOutfitResultsScreen(
                dayType: dayType,
                inventory: _inventory,
                initialOutfits: outfits,
              ),
              transitionsBuilder: (_, anim, __, child) {
                final a = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
                return FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.04),
                      end: Offset.zero,
                    ).animate(a),
                    child: child,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ───────────────────────── Service: Outfit Generation ─────────────────────────

class WardrobeOutfitService {
  static final _rng = Random();

  static List<List<WardrobeItem>> generateOutfits({
    required List<WardrobeItem> inventory,
    required DayType dayType,
    int outfitCount = 3,
  }) {
    final pool = inventory
        .where((e) => e.available)
        .where((e) => dayType == DayType.custom || e.tags.contains(dayType))
        .toList();

    // Fallback: if too strict, allow any available item
    final safePool = pool.isNotEmpty ? pool : inventory.where((e) => e.available).toList();

    List<WardrobeItem> byCat(WardrobeCategory c) =>
        safePool.where((e) => e.category == c).toList();

    WardrobeItem? pick(List<WardrobeItem> list, Set<String> usedIds) {
      final candidates = list.where((e) => !usedIds.contains(e.id)).toList();
      if (candidates.isEmpty) return null;
      return candidates[_rng.nextInt(candidates.length)];
    }

    final outfits = <List<WardrobeItem>>[];

    for (int i = 0; i < outfitCount; i++) {
      final used = <String>{};
      final outfit = <WardrobeItem>[];

      // Prefer logic depending on day/event
      bool preferTraditional = {
        DayType.function,
        DayType.marriage,
      }.contains(dayType);

      bool preferBridal = dayType == DayType.marriage;

      // 1) Primary piece
      if (preferBridal) {
        final bridal = pick(byCat(WardrobeCategory.bridalwear), used);
        if (bridal != null) {
          outfit.add(bridal);
          used.add(bridal.id);
        }
      }

      // 2) Traditional set OR top
      final sk = pick(byCat(WardrobeCategory.shalwarKameez), used);
      if (sk != null && (preferTraditional || _rng.nextBool())) {
        outfit.add(sk);
        used.add(sk.id);
      } else {
        // pick shirt/kurta as top
        final tops = [
          ...byCat(WardrobeCategory.shirts),
          ...byCat(WardrobeCategory.kurtas),
        ];
        final top = pick(tops, used);
        if (top != null) {
          outfit.add(top);
          used.add(top.id);
        }
      }

      // 3) Bottom (pants/pajama) unless already a full shalwar kameez set (still okay to add accessory)
      final bottom = pick([
        ...byCat(WardrobeCategory.pants),
        ...byCat(WardrobeCategory.pajamas),
      ], used);
      if (bottom != null && outfit.length < 3) {
        outfit.add(bottom);
        used.add(bottom.id);
      }

      // 4) Accessory/others
      final other = pick(byCat(WardrobeCategory.others), used);
      if (other != null) {
        outfit.add(other);
        used.add(other.id);
      }

      // Ensure at least 3 items if possible
      while (outfit.length < 3 && safePool.isNotEmpty) {
        final extra = pick(safePool, used);
        if (extra == null) break;
        outfit.add(extra);
        used.add(extra.id);
      }

      outfits.add(outfit);
    }

    return outfits;
  }
}

// ───────────────────────── UI pieces ─────────────────────────

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
    final shine = (sin(t * pi * 2) * 0.5 + 0.5); // 0..1

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
                      fontSize: 18.5,
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

class _CategoryCard extends StatelessWidget {
  final double t;
  final String title;
  final int count;
  final IconData icon;

  const _CategoryCard({
    required this.t,
    required this.title,
    required this.count,
    required this.icon,
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
              right: -10,
              top: -10,
              child: Opacity(
                opacity: 0.10,
                child: Icon(icon, size: 72, color: AppColors.secondary),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppColors.ink.withOpacity(0.78), size: 24),
                const Spacer(),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.h3().copyWith(fontSize: 15.2),
                ),
                const SizedBox(height: 6),
                Text(
                  "$count items",
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
                      "Open",
                      style: AppText.kicker().copyWith(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink.withOpacity(0.55),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_rounded,
                        size: 18, color: AppColors.ink.withOpacity(0.55)),
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

class _DayPickerSheet extends StatelessWidget {
  final List<WardrobeItem> inventory;
  final void Function(DayType dayType, List<List<WardrobeItem>> outfits) onGenerate;

  const _DayPickerSheet({
    required this.inventory,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    final picks = <DayType>[
      DayType.university,
      DayType.office,
      DayType.daily,
      DayType.home,
      DayType.party,
      DayType.function,
      DayType.marriage,
      DayType.rainy,
      DayType.winter,
      DayType.summer,
      DayType.custom,
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(12, top + 8, 12, bottom + 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.75)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.black.withOpacity(0.12),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text("Select day / event",
                        style: AppText.h2().copyWith(fontSize: 16.5)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: picks.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.7,
                  ),
                  itemBuilder: (_, i) {
                    final d = picks[i];
                    return _PressScale(
                      onTap: () {
                        final outfits = WardrobeOutfitService.generateOutfits(
                          inventory: inventory,
                          dayType: d,
                          outfitCount: 3,
                        );
                        onGenerate(d, outfits);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white.withOpacity(0.55),
                          border: Border.all(color: Colors.white.withOpacity(0.72)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Text(d.emoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                d.label,
                                style: AppText.body().copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink.withOpacity(0.78),
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_rounded,
                                size: 16, color: AppColors.ink.withOpacity(0.55)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  "Tip: If you marked many items ⛔ unavailable, generation may use fewer options.",
                  style: AppText.body().copyWith(
                    fontSize: 12,
                    color: AppColors.ink.withOpacity(0.56),
                  ),
                ),
              ],
            ),
          ),
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
              colors: [
                a.withOpacity(opacity),
                b.withOpacity(opacity * 0.65),
                Colors.transparent
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
  const _PressScale({
    required this.child,
    required this.onTap,
    this.downScale = 0.972,
  });

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
