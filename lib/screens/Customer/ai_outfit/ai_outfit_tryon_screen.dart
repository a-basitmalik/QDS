import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ai_outfit_models.dart';

class TryOn2DScreen extends StatefulWidget {
  final Color primary, secondary, other, ink;
  final OutfitBundle outfit;
  final String? focusedCategory;

  final Widget Function() fullScreenGlassSheet;
  final Widget Function(String text, {double fontSize, FontWeight fontWeight}) title3d;
  final Widget Function(String image, {BoxFit fit}) imgBuilder;

  const TryOn2DScreen({
    super.key,
    required this.primary,
    required this.secondary,
    required this.other,
    required this.ink,
    required this.outfit,
    required this.focusedCategory,
    required this.fullScreenGlassSheet,
    required this.title3d,
    required this.imgBuilder,
  });

  @override
  State<TryOn2DScreen> createState() => _TryOn2DScreenState();
}

class _TryOn2DScreenState extends State<TryOn2DScreen> with TickerProviderStateMixin {
  late String _selectedCat;
  final Set<int> _cartIdx = {};

  late final AnimationController _pulse;
  bool _showFullOutfit = true; // ✅ Full outfit preview toggle

  @override
  void initState() {
    super.initState();
    _selectedCat = widget.focusedCategory ?? widget.outfit.items.first.category;
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  int _totalPriceAll() {
    int sum = 0;
    for (final it in widget.outfit.items) {
      sum += (it.price is int) ? it.price as int : int.tryParse("${it.price}") ?? 0;
    }
    return sum;
  }

  int _totalPriceCart() {
    int sum = 0;
    for (final idx in _cartIdx) {
      final it = widget.outfit.items[idx];
      sum += (it.price is int) ? it.price as int : int.tryParse("${it.price}") ?? 0;
    }
    return sum;
  }

  void _toggleCart(int idx) {
    HapticFeedback.mediumImpact();
    setState(() {
      _cartIdx.contains(idx) ? _cartIdx.remove(idx) : _cartIdx.add(idx);
    });
  }

  void _addAll() {
    HapticFeedback.mediumImpact();
    setState(() {
      _cartIdx.addAll(List.generate(widget.outfit.items.length, (i) => i));
    });
  }

  void _removeAll() {
    HapticFeedback.mediumImpact();
    setState(() => _cartIdx.clear());
  }

  @override
  Widget build(BuildContext context) {
    const bg1 = Color(0xFFF9F6F5);
    const bg2 = Color(0xFFF4EEED);

    final cats = widget.outfit.items.map((e) => e.category).toSet().toList();
    final items = widget.outfit.items;
    final cartTotal = _totalPriceCart();
    final outfitTotal = _totalPriceAll();

    return Scaffold(
      backgroundColor: bg1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Try-on (2D)", style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: widget.ink)),
        iconTheme: IconThemeData(color: widget.ink),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [bg1, bg2, Colors.white],
                  stops: const [0, .6, 1],
                ),
              ),
            ),
          ),
          widget.fullScreenGlassSheet(),

          ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            children: [
              widget.title3d("Virtual Try-On", fontSize: 18.5, fontWeight: FontWeight.w900),
              const SizedBox(height: 10),

              // ✅ Top summary / actions bar
              _CartSummaryBar(
                primary: widget.primary,
                secondary: widget.secondary,
                ink: widget.ink,
                itemsCount: items.length,
                inCartCount: _cartIdx.length,
                cartTotal: cartTotal,
                outfitTotal: outfitTotal,
                onAddAll: _addAll,
                onRemoveAll: _removeAll,
              ),

              const SizedBox(height: 12),

              // ✅ Preview mode toggle
              Row(
                children: [
                  Expanded(
                    child: _ModePill(
                      text: "Full Outfit",
                      on: _showFullOutfit,
                      primary: widget.primary,
                      ink: widget.ink,
                      onTap: () => setState(() => _showFullOutfit = true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ModePill(
                      text: "Single Category",
                      on: !_showFullOutfit,
                      primary: widget.primary,
                      ink: widget.ink,
                      onTap: () => setState(() => _showFullOutfit = false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ✅ Preview Card
              // ✅ Preview Card (FIXED HEIGHT, never blank)
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) {
                  final glow = lerpDouble(0.08, 0.14, _pulse.value)!;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        height: 320, // ✅ important (gives preview a bound)
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.76),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white.withOpacity(0.86), width: 1.1),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: const Alignment(-0.5, -0.6),
                                    radius: 1.2,
                                    colors: [
                                      widget.secondary.withOpacity(glow),
                                      widget.primary.withOpacity(glow * .85),
                                      Colors.transparent
                                    ],
                                    stops: const [0, .45, 1],
                                  ),
                                ),
                              ),
                            ),

                            // ✅ Safe: no Expanded required
                            _showFullOutfit
                                ? _FullOutfitPreviewFixed(
                              primary: widget.primary,
                              ink: widget.ink,
                              outfit: widget.outfit,
                              imgBuilder: widget.imgBuilder,
                              onTapCategory: (cat) {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedCat = cat;
                                  _showFullOutfit = false;
                                });
                              },
                            )
                                : _SingleCategoryPreview(
                              primary: widget.primary,
                              ink: widget.ink,
                              category: _selectedCat,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),


              const SizedBox(height: 14),

              // ✅ Category chips (only meaningful in Single mode, but still visible)
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: cats.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final c = cats[i];
                    final on = c == _selectedCat;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedCat = c;
                          _showFullOutfit = false; // ✅ tapping category auto switches to single preview
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: on ? widget.primary.withOpacity(0.10) : Colors.white.withOpacity(0.72),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: on ? widget.primary.withOpacity(0.26) : Colors.white.withOpacity(0.86),
                            width: 1.1,
                          ),
                        ),
                        child: Text(
                          c,
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: (on ? widget.primary : widget.ink).withOpacity(0.82),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ✅ ALL ITEMS list (not filtered)
              ...items.asMap().entries.map((entry) {
                final idx = entry.key;
                final it = entry.value;
                final inCart = _cartIdx.contains(idx);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.74),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withOpacity(0.86), width: 1.1),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: SizedBox(
                                width: 58,
                                height: 58,
                                child: widget.imgBuilder(it.image, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    it.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w900,
                                      color: widget.ink.withOpacity(0.88),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "${it.brand} • ${it.category} • Rs.${it.price}",
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: widget.ink.withOpacity(0.58),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _toggleCart(idx),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: inCart
                                      ? widget.primary.withOpacity(0.14)
                                      : widget.secondary.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: (inCart ? widget.primary : widget.secondary).withOpacity(0.18),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  inCart ? "Remove" : "Add",
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11.6,
                                    color: (inCart ? widget.primary : widget.secondary).withOpacity(0.90),
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
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Widgets ─────────────────────────

class _CartSummaryBar extends StatelessWidget {
  final Color primary, secondary, ink;
  final int itemsCount;
  final int inCartCount;
  final int cartTotal;
  final int outfitTotal;
  final VoidCallback onAddAll;
  final VoidCallback onRemoveAll;

  const _CartSummaryBar({
    required this.primary,
    required this.secondary,
    required this.ink,
    required this.itemsCount,
    required this.inCartCount,
    required this.cartTotal,
    required this.outfitTotal,
    required this.onAddAll,
    required this.onRemoveAll,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.74),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.86), width: 1.1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Outfit total: Rs.$outfitTotal",
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: ink.withOpacity(0.86),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "In cart: $inCartCount / $itemsCount • Rs.$cartTotal",
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: ink.withOpacity(0.56),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  GestureDetector(
                    onTap: onAddAll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: primary.withOpacity(0.20), width: 1),
                      ),
                      child: Text(
                        "Add All",
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w900,
                          fontSize: 11.8,
                          color: primary.withOpacity(0.92),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onRemoveAll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: secondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: secondary.withOpacity(0.18), width: 1),
                      ),
                      child: Text(
                        "Clear",
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w900,
                          fontSize: 11.8,
                          color: secondary.withOpacity(0.92),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  final String text;
  final bool on;
  final Color primary;
  final Color ink;
  final VoidCallback onTap;

  const _ModePill({
    required this.text,
    required this.on,
    required this.primary,
    required this.ink,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: on ? primary.withOpacity(0.12) : Colors.white.withOpacity(0.70),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: on ? primary.withOpacity(0.24) : Colors.white.withOpacity(0.86),
            width: 1.1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: (on ? primary : ink).withOpacity(0.84),
            ),
          ),
        ),
      ),
    );
  }
}

class _SingleCategoryPreview extends StatelessWidget {
  final Color primary;
  final Color ink;
  final String category;

  const _SingleCategoryPreview({
    required this.primary,
    required this.ink,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checkroom_rounded, size: 56, color: primary.withOpacity(0.70)),
          const SizedBox(height: 10),
          Text(
            "Previewing: $category",
            style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: ink.withOpacity(0.80)),
          ),
        ],
      ),
    );
  }
}
class _FullOutfitPreviewFixed extends StatelessWidget {
  final Color primary;
  final Color ink;
  final OutfitBundle outfit;
  final Widget Function(String image, {BoxFit fit}) imgBuilder;
  final void Function(String category) onTapCategory;

  const _FullOutfitPreviewFixed({
    required this.primary,
    required this.ink,
    required this.outfit,
    required this.imgBuilder,
    required this.onTapCategory,
  });

  @override
  Widget build(BuildContext context) {
    final items = outfit.items;
    if (items.isEmpty) {
      return Center(
        child: Text(
          "No items in this outfit",
          style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: ink.withOpacity(0.7)),
        ),
      );
    }

    // Collage: show up to 6 items
    final show = items.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Full Outfit Preview",
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w900,
            fontSize: 13.2,
            color: ink.withOpacity(0.86),
          ),
        ),
        const SizedBox(height: 10),

        // ✅ fixed-height grid inside fixed-height preview card
        SizedBox(
          height: 220,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: show.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, i) {
              final it = show[i];
              return GestureDetector(
                onTap: () => onTapCategory(it.category),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Positioned.fill(child: imgBuilder(it.image, fit: BoxFit.cover)),
                      Positioned(
                        left: 8,
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.82),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            it.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w900,
                              fontSize: 10.8,
                              color: primary.withOpacity(0.92),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),
        Text(
          "Tap any tile to open Single Category preview",
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            fontSize: 11.2,
            color: ink.withOpacity(0.55),
          ),
        ),
      ],
    );
  }
}
