import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ai_outfit_models.dart';
import 'ai_outfit_generating_dialog.dart';
import 'ai_outfit_tryon_screen.dart';

class AiOutfitResultsScreen extends StatefulWidget {
  final Color primary, secondary, other, ink;
  final List<OutfitBundle> initialOutfits;
  final OutfitGenPrefs prefs;

  // pass these from home.dart
  final Widget Function() fullScreenGlassSheet;
  final Widget Function(String text, {double fontSize, FontWeight fontWeight}) title3d;
  final Widget Function(String image, {BoxFit fit}) imgBuilder;

  const AiOutfitResultsScreen({
    super.key,
    required this.primary,
    required this.secondary,
    required this.other,
    required this.ink,
    required this.initialOutfits,
    required this.prefs,
    required this.fullScreenGlassSheet,
    required this.title3d,
    required this.imgBuilder,
  });

  @override
  State<AiOutfitResultsScreen> createState() => _AiOutfitResultsScreenState();
}

class _AiOutfitResultsScreenState extends State<AiOutfitResultsScreen> with TickerProviderStateMixin {
  late List<OutfitBundle> _outfits;
  int _index = 0;

  late final AnimationController _enter;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _outfits = List.of(widget.initialOutfits);

    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    _fade = CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic);
    _slide = Tween(begin: const Offset(0, 0.03), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic));
    _enter.forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  void _next() {
    HapticFeedback.selectionClick();
    setState(() => _index = (_index + 1) % _outfits.length);
  }

  Future<void> _generateNew() async {
    HapticFeedback.mediumImpact();
    final outfits = await showDialog<List<OutfitBundle>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AiGeneratingDialog(
        primary: widget.primary,
        secondary: widget.secondary,
        other: widget.other,
        ink: widget.ink,
        prefs: widget.prefs,
      ),
    );

    if (!mounted) return;
    if (outfits == null || outfits.isEmpty) return;

    setState(() {
      _outfits = outfits;
      _index = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    const bg1 = Color(0xFFF9F6F5);
    const bg2 = Color(0xFFF4EEED);

    final outfit = _outfits[_index];
    final total = outfit.items.fold<int>(0, (s, x) => s + x.price);

    return Scaffold(
      backgroundColor: bg1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("AI Outfit Results", style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: widget.ink)),
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
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          widget.fullScreenGlassSheet(),
          SafeArea(
            child: SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _fade,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                  children: [
                    widget.title3d("Outfit ${_index + 1} of ${_outfits.length}", fontSize: 18.5, fontWeight: FontWeight.w900),
                    const SizedBox(height: 8),
                    Text("Total: Rs.$total", style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: widget.ink.withOpacity(0.70))),
                    const SizedBox(height: 14),

                    _OutfitPreviewCard(
                      primary: widget.primary,
                      secondary: widget.secondary,
                      ink: widget.ink,
                      outfit: outfit,
                      img: widget.imgBuilder,
                    ),

                    const SizedBox(height: 14),

                    ...outfit.items.map((it) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OutfitItemRowCard(
                        primary: widget.primary,
                        secondary: widget.secondary,
                        ink: widget.ink,
                        item: it,
                        img: widget.imgBuilder,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TryOn2DScreen(
                                primary: widget.primary,
                                secondary: widget.secondary,
                                other: widget.other,
                                ink: widget.ink,
                                outfit: outfit,
                                focusedCategory: it.category,
                                fullScreenGlassSheet: widget.fullScreenGlassSheet,
                                title3d: widget.title3d,
                                imgBuilder: widget.imgBuilder,
                              ),
                            ),
                          );
                        },
                      ),
                    )),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(child: _BigActionButton(text: "Generate 5 new", filled: false, primary: widget.primary, ink: widget.ink, onTap: _generateNew)),
                        const SizedBox(width: 12),
                        Expanded(child: _BigActionButton(text: "Next", filled: true, primary: widget.primary, ink: widget.ink, onTap: _next)),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _BigActionButton(
                      text: "Try this outfit",
                      filled: true,
                      primary: widget.secondary,
                      ink: widget.ink,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TryOn2DScreen(
                              primary: widget.primary,
                              secondary: widget.secondary,
                              other: widget.other,
                              ink: widget.ink,
                              outfit: outfit,
                              focusedCategory: null,
                              fullScreenGlassSheet: widget.fullScreenGlassSheet,
                              title3d: widget.title3d,
                              imgBuilder: widget.imgBuilder,
                            ),
                          ),
                        );
                      },
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
}

// ---- local UI cards

class _OutfitPreviewCard extends StatelessWidget {
  final Color primary, secondary, ink;
  final OutfitBundle outfit;
  final Widget Function(String image, {BoxFit fit}) img;

  const _OutfitPreviewCard({
    required this.primary,
    required this.secondary,
    required this.ink,
    required this.outfit,
    required this.img,
  });

  @override
  Widget build(BuildContext context) {
    final first = outfit.items.isEmpty ? null : outfit.items.first;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.76),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.86), width: 1.1),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 22, offset: const Offset(0, 14))],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(width: 90, height: 90, child: first == null ? Container(color: primary.withOpacity(0.08)) : img(first.image, fit: BoxFit.cover)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(outfit.title, style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 14.6, color: ink.withOpacity(0.90))),
                    const SizedBox(height: 6),
                    Text("${outfit.items.length} items • Tap an item to try it",
                        style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 12.2, color: ink.withOpacity(0.58))),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.auto_awesome_rounded, color: secondary.withOpacity(0.78)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutfitItemRowCard extends StatelessWidget {
  final Color primary, secondary, ink;
  final OutfitItem item;
  final VoidCallback onTap;
  final Widget Function(String image, {BoxFit fit}) img;

  const _OutfitItemRowCard({
    required this.primary,
    required this.secondary,
    required this.ink,
    required this.item,
    required this.onTap,
    required this.img,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                ClipRRect(borderRadius: BorderRadius.circular(14), child: SizedBox(width: 54, height: 54, child: img(item.image, fit: BoxFit.cover))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.category, style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 11.8, color: primary.withOpacity(0.82))),
                      const SizedBox(height: 4),
                      Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 13.4, color: ink.withOpacity(0.88))),
                      const SizedBox(height: 4),
                      Text("Rs.${item.price}", style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 12.6, color: ink.withOpacity(0.70))),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: ink.withOpacity(0.40)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BigActionButton extends StatelessWidget {
  final String text;
  final bool filled;
  final Color primary;
  final Color ink;
  final VoidCallback onTap;

  const _BigActionButton({required this.text, required this.filled, required this.primary, required this.ink, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: filled ? primary : Colors.white.withOpacity(0.72),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: filled ? Colors.white.withOpacity(0.18) : Colors.white.withOpacity(0.86), width: 1.1),
          boxShadow: [if (filled) BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 18, offset: const Offset(0, 12))],
        ),
        child: Center(
          child: Text(text, style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 12.8, color: filled ? Colors.white.withOpacity(0.94) : ink.withOpacity(0.86))),
        ),
      ),
    );
  }
}
