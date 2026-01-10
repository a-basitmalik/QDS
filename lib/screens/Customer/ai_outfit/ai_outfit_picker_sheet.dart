// ✅ AiOutfitPickerSheet — NON-glass redesign (clean light UI)
// - "Your Favourite brands" as buttons inside a normal card
// - Each category card has a dropdown (pick ONE brand per category)
// - AI core button is CENTER (between top + bottom areas)
// - On Generate: selected brands “float into” AI core, then returns OutfitGenPrefs
//
// Uses: Flutter + GoogleFonts only.

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ai_outfit_models.dart';

class AiOutfitPickerSheet extends StatefulWidget {
  final Color primary, secondary, ink;
  const AiOutfitPickerSheet({
    super.key,
    required this.primary,
    required this.secondary,
    required this.ink,
  });

  @override
  State<AiOutfitPickerSheet> createState() => _AiOutfitPickerSheetState();
}

class _AiOutfitPickerSheetState extends State<AiOutfitPickerSheet>
    with TickerProviderStateMixin {
  bool random = true;
  bool _charging = false;

  late final AnimationController _idleCtrl;
  late final AnimationController _collectCtrl;

  // favourites (multi)
  final Set<String> favBrands = {};

  // category dropdown (single selection each)
  final List<String> categories = const ["Shoes", "Pants", "Shirts", "Hat", "Glasses", "Watch"];
  final Map<String, String?> picked = {
    "Shoes": null,
    "Pants": null,
    "Shirts": null,
    "Hat": null,
    "Glasses": null,
    "Watch": null,
  };

  final List<String> brandList = const [
    "Nike",
    "Adidas",
    "Puma",
    "Zara",
    "H&M",
    "Uniqlo",
    "Levi's",
    "Gucci",
    "Ray-Ban",
    "Casio",
    "Fossil",
    "Rolex",
  ];

  // layout keys (for floating-to-core animation)
  final GlobalKey _sheetKey = GlobalKey();
  final GlobalKey _coreKey = GlobalKey();
  final Map<String, GlobalKey> _tokenKeys = {}; // brand chip keys for favourites + category picks

  @override
  void initState() {
    super.initState();

    _idleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat();

    _collectCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 780));
  }

  @override
  void dispose() {
    _idleCtrl.dispose();
    _collectCtrl.dispose();
    super.dispose();
  }

  Offset? _centerOf(GlobalKey key) {
    final rb = key.currentContext?.findRenderObject() as RenderBox?;
    final sheet = _sheetKey.currentContext?.findRenderObject() as RenderBox?;
    if (rb == null || sheet == null) return null;
    final p = rb.localToGlobal(rb.size.center(Offset.zero));
    final s = sheet.localToGlobal(Offset.zero);
    return p - s;
  }

  // build final prefs (keeps your old model shape)
  OutfitGenPrefs _buildPrefs() {
    if (random) {
      return OutfitGenPrefs(
        randomBrands: true,
        brands: {},
        categoryBrands: categories.fold<Map<String, Set<String>>>(
          {},
              (m, c) => m..[c] = <String>{},
        ),
      );
    }

    final catSets = <String, Set<String>>{};
    for (final c in categories) {
      final v = picked[c];
      catSets[c] = v == null ? <String>{} : <String>{v};
    }

    return OutfitGenPrefs(
      randomBrands: false,
      brands: Set.of(favBrands),
      categoryBrands: catSets,
    );
  }

  List<String> _selectedAll() {
    final out = <String>[];
    out.addAll(favBrands);
    for (final c in categories) {
      final v = picked[c];
      if (v != null) out.add(v);
    }
    // unique
    return out.toSet().toList();
  }

  Future<void> _runGenerate() async {
    if (_charging) return;

    HapticFeedback.mediumImpact();
    setState(() => _charging = true);

    // run “collect into AI core”
    await _collectCtrl.forward(from: 0);

    if (!mounted) return;
    Navigator.pop(context, _buildPrefs());
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        key: _sheetKey,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F6F6),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
          border: Border.all(color: Colors.black.withOpacity(0.06), width: 1),
        ),
        child: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: Listenable.merge([_idleCtrl, _collectCtrl]),
            builder: (context, _) {
              final t = _idleCtrl.value; // idle
              final cT = Curves.easeInOut.transform(_collectCtrl.value); // collect progress

              final corePos = _centerOf(_coreKey);
              final selected = _selectedAll();

              // compute token positions for floating
              final tokenPos = <String, Offset>{};
              for (final b in selected) {
                final k = _tokenKeys[b];
                if (k != null) {
                  final p = _centerOf(k);
                  if (p != null) tokenPos[b] = p;
                }
              }

              return Stack(
                children: [
                  // ✅ Floating brand tokens into AI core (only while collecting)
                  if (cT > 0.001 && corePos != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _CollectToCorePainter(
                            t: cT,
                            core: corePos,
                            tokens: tokenPos,
                            primary: widget.primary,
                            ink: widget.ink,
                          ),
                        ),
                      ),
                    ),

                  // ✅ Main content
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: widget.primary.withOpacity(0.85)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "AI Outfit Generator",
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16.5,
                                  color: widget.ink.withOpacity(0.92),
                                ),
                              ),
                            ),
                            _ModeToggle(
                              value: random,
                              primary: widget.primary,
                              ink: widget.ink,
                              onTap: _charging
                                  ? null
                                  : () => setState(() => random = !random),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        Text(
                          random
                              ? "Random mode: AI will pick everything."
                              : "Custom mode: pick favourites + per-category brand.",
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.2,
                            color: widget.ink.withOpacity(0.60),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ✅ Top area: favourites card
                        _PlainCard(
                          title: "Your Favourite Brands",
                          subtitle: "Tap to select (optional)",
                          ink: widget.ink,
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: brandList.map((b) {
                              final on = favBrands.contains(b);
                              final k = _tokenKeys.putIfAbsent(b, () => GlobalKey());
                              return _BrandButton(
                                key: k,
                                text: b,
                                on: on,
                                enabled: !random && !_charging,
                                primary: widget.primary,
                                ink: widget.ink,
                                onTap: () => setState(() {
                                  on ? favBrands.remove(b) : favBrands.add(b);
                                }),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ✅ CENTER AI core that “collects” everything
                        Center(
                          child: _AiCoreCenter(
                            key: _coreKey,
                            primary: widget.primary,
                            secondary: widget.secondary,
                            ink: widget.ink,
                            idleT: t,
                            charging: _charging,
                            progress: cT,
                            onTap: (_charging) ? null : _runGenerate,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ✅ Bottom area: category cards with dropdowns
                        _PlainCard(
                          title: "Category Brands",
                          subtitle: "Pick one brand per category (optional)",
                          ink: widget.ink,
                          child: Column(
                            children: categories.map((c) {
                              final v = picked[c];
                              // create key for selected brand token (so it can fly in)
                              if (v != null) {
                                _tokenKeys.putIfAbsent(v, () => GlobalKey());
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _CategoryDropdownCard(
                                  category: c,
                                  value: v,
                                  items: brandList,
                                  enabled: !random && !_charging,
                                  primary: widget.primary,
                                  ink: widget.ink,
                                  tokenKeyForValue: v == null ? null : _tokenKeys[v],
                                  onChanged: (nv) => setState(() => picked[c] = nv),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _ActionBtn(
                                text: "Cancel",
                                filled: false,
                                primary: widget.primary,
                                ink: widget.ink,
                                onTap: _charging ? null : () => Navigator.pop(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ActionBtn(
                                text: _charging ? "Collecting..." : "Generate",
                                filled: true,
                                primary: widget.primary,
                                ink: widget.ink,
                                onTap: _charging ? null : _runGenerate,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ✅ Collect animation painter (brands float into AI core)
// ─────────────────────────────────────────────────────────────

class _CollectToCorePainter extends CustomPainter {
  final double t; // 0..1
  final Offset core;
  final Map<String, Offset> tokens;
  final Color primary;
  final Color ink;

  _CollectToCorePainter({
    required this.t,
    required this.core,
    required this.tokens,
    required this.primary,
    required this.ink,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (tokens.isEmpty) return;

    // subtle core aura
    final aura = Paint()
      ..color = primary.withOpacity(0.10 + 0.18 * t)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(core, 34 + 18 * t, aura);

    for (final entry in tokens.entries) {
      final from = entry.value;

      // curved “magnetic” path
      final mid = Offset((from.dx + core.dx) / 2, (from.dy + core.dy) / 2);
      final bend = 18.0 + (from.dx - core.dx).abs() * 0.02;

      final c1 = Offset(
        from.dx + (mid.dx - from.dx) * 0.35,
        from.dy + (mid.dy - from.dy) * 0.35 - bend,
      );
      final c2 = Offset(
        from.dx + (mid.dx - from.dx) * 0.75,
        from.dy + (mid.dy - from.dy) * 0.75 + bend * 0.35,
      );

      // current position along cubic (simple lerp-ish)
      Offset cubic(double u) {
        // cubic bezier formula
        final p0 = from;
        final p1 = c1;
        final p2 = c2;
        final p3 = core;
        final one = 1 - u;
        final x = one * one * one * p0.dx +
            3 * one * one * u * p1.dx +
            3 * one * u * u * p2.dx +
            u * u * u * p3.dx;
        final y = one * one * one * p0.dy +
            3 * one * one * u * p1.dy +
            3 * one * u * u * p2.dy +
            u * u * u * p3.dy;
        return Offset(x, y);
      }

      final u = Curves.easeInOut.transform(t);
      final pos = cubic(u);

      // trail
      final trail = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..color = primary.withOpacity(0.08 + 0.24 * t);

      final path = Path()
        ..moveTo(from.dx, from.dy)
        ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, core.dx, core.dy);

      // draw partial trail
      final pm = path.computeMetrics().first;
      final seg = pm.extractPath(0, pm.length * u, startWithMoveTo: true);
      canvas.drawPath(seg, trail);

      // token “dot” (shrinks into core)
      final dotOuter = Paint()
        ..color = primary.withOpacity(0.38 * (1 - t) + 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      final dotInner = Paint()
        ..color = Colors.white.withOpacity(0.65 * (1 - t) + 0.10);

      final r = 7.0 * (1 - t) + 2.2;
      canvas.drawCircle(pos, r + 3.2, dotOuter);
      canvas.drawCircle(pos, r, dotInner);
    }

    // “snap” flash
    if (t > 0.92) {
      final flash = Paint()
        ..color = Colors.white.withOpacity((t - 0.92) * 3.0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.drawCircle(core, 22 + (t - 0.92) * 120, flash);
    }
  }

  @override
  bool shouldRepaint(covariant _CollectToCorePainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.core != core ||
        oldDelegate.tokens.length != tokens.length ||
        oldDelegate.primary != primary ||
        oldDelegate.ink != ink;
  }
}

// ─────────────────────────────────────────────────────────────
// ✅ UI helpers (non-glass, clean)
// ─────────────────────────────────────────────────────────────

class _PlainCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color ink;
  final Widget child;

  const _PlainCard({
    required this.title,
    required this.subtitle,
    required this.ink,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w900,
              fontSize: 13.2,
              color: ink.withOpacity(0.90),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w800,
              fontSize: 11.4,
              color: ink.withOpacity(0.55),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _BrandButton extends StatelessWidget {
  final String text;
  final bool on;
  final bool enabled;
  final Color primary;
  final Color ink;
  final VoidCallback onTap;

  const _BrandButton({
    super.key,
    required this.text,
    required this.on,
    required this.enabled,
    required this.primary,
    required this.ink,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: GestureDetector(
        onTap: enabled ? () { HapticFeedback.selectionClick(); onTap(); } : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: on ? primary.withOpacity(0.10) : const Color(0xFFF4F2F2),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: on ? primary.withOpacity(0.26) : Colors.black.withOpacity(0.06),
              width: 1,
            ),
          ),
          child: Text(
            text,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w900,
              fontSize: 12.0,
              color: (on ? primary : ink).withOpacity(0.86),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryDropdownCard extends StatelessWidget {
  final String category;
  final String? value;
  final List<String> items;
  final bool enabled;
  final Color primary;
  final Color ink;
  final GlobalKey? tokenKeyForValue;
  final ValueChanged<String?> onChanged;

  const _CategoryDropdownCard({
    super.key,
    required this.category,
    required this.value,
    required this.items,
    required this.enabled,
    required this.primary,
    required this.ink,
    required this.tokenKeyForValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withOpacity(0.10),
              border: Border.all(color: primary.withOpacity(0.18), width: 1),
            ),
            child: Icon(Icons.category_rounded, size: 18, color: primary.withOpacity(0.85)),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w900,
                    fontSize: 12.8,
                    color: ink.withOpacity(0.88),
                  ),
                ),
                const SizedBox(height: 6),
                Opacity(
                  opacity: enabled ? 1.0 : 0.55,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: value,
                      hint: Text(
                        "Select brand (optional)",
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.0,
                          color: ink.withOpacity(0.45),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text("None"),
                        ),
                        ...items.map((b) => DropdownMenuItem<String>(
                          value: b,
                          child: Text(b),
                        )),
                      ],
                      onChanged: enabled ? (v) { HapticFeedback.selectionClick(); onChanged(v); } : null,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Selected brand badge (for “float into AI”)
          if (value != null)
            Container(
              key: tokenKeyForValue,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: primary.withOpacity(0.22), width: 1),
              ),
              child: Text(
                value!,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w900,
                  fontSize: 11.2,
                  color: primary.withOpacity(0.90),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AiCoreCenter extends StatelessWidget {
  final Color primary;
  final Color secondary;
  final Color ink;
  final double idleT;
  final bool charging;
  final double progress;
  final VoidCallback? onTap;

  const _AiCoreCenter({
    super.key,
    required this.primary,
    required this.secondary,
    required this.ink,
    required this.idleT,
    required this.charging,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final breathe = 1.0 + 0.035 * sin(idleT * pi * 2);
    final glow = 0.10 + 0.22 * progress;

    return GestureDetector(
      onTap: onTap,
      child: Transform.scale(
        scale: breathe,
        child: Container(
          width: 220,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(glow),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      primary.withOpacity(0.95),
                      secondary.withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  charging ? Icons.bolt_rounded : Icons.auto_awesome_rounded,
                  color: Colors.white.withOpacity(0.95),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      charging ? "Collecting brands…" : "AI Core",
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.6,
                        color: ink.withOpacity(0.90),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      charging ? "Pulling selections into AI" : "Tap to generate",
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        fontSize: 11.6,
                        color: ink.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final bool value;
  final Color primary;
  final Color ink;
  final VoidCallback? onTap;

  const _ModeToggle({
    required this.value,
    required this.primary,
    required this.ink,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.65 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: value ? const Color(0xFFF1EEEE) : primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(value ? Icons.shuffle_rounded : Icons.tune_rounded, size: 16, color: primary.withOpacity(0.85)),
              const SizedBox(width: 6),
              Text(
                value ? "Random" : "Custom",
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w900,
                  fontSize: 11.6,
                  color: ink.withOpacity(0.86),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String text;
  final bool filled;
  final Color primary;
  final Color ink;
  final VoidCallback? onTap;

  const _ActionBtn({
    required this.text,
    required this.filled,
    required this.primary,
    required this.ink,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.65 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: filled ? primary : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: filled ? primary.withOpacity(0.10) : Colors.black.withOpacity(0.06),
              width: 1,
            ),
            boxShadow: [
              if (filled)
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w900,
                fontSize: 12.8,
                color: filled ? Colors.white.withOpacity(0.94) : ink.withOpacity(0.88),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
