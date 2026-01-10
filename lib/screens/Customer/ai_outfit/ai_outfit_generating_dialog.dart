import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ai_outfit_models.dart';

class AiGeneratingDialog extends StatefulWidget {
  final Color primary, secondary, other, ink;
  final OutfitGenPrefs prefs;

  const AiGeneratingDialog({
    super.key,
    required this.primary,
    required this.secondary,
    required this.other,
    required this.ink,
    required this.prefs,
  });

  @override
  State<AiGeneratingDialog> createState() => _AiGeneratingDialogState();
}

class _AiGeneratingDialogState extends State<AiGeneratingDialog> with TickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();

    Future.delayed(const Duration(milliseconds: 2100), () {
      if (!mounted) return;
      Navigator.pop(context, mockGenerateOutfits(widget.prefs));
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: min(MediaQuery.of(context).size.width * 0.88, 420),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.82),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.1),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 26, offset: const Offset(0, 14))],
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                final t = _ctrl.value;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Generating outfits",
                        style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 14.6, color: widget.ink.withOpacity(0.88))),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CustomPaint(
                        painter: _AiBurstPainter(t: t, a: widget.secondary, b: widget.primary, c: widget.other),
                        child: Center(
                          child: ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(colors: [widget.primary.withOpacity(0.96), widget.secondary.withOpacity(0.92)]),
                                  border: Border.all(color: Colors.white.withOpacity(0.26), width: 1.1),
                                ),
                                child: Icon(Icons.auto_awesome_rounded, color: Colors.white.withOpacity(0.94), size: 26),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("Mixing brands • matching colors • styling…",
                        style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 12.0, color: widget.ink.withOpacity(0.55))),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AiBurstPainter extends CustomPainter {
  final double t;
  final Color a, b, c;
  _AiBurstPainter({required this.t, required this.a, required this.b, required this.c});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseR = min(size.width, size.height) * 0.38;

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..color = Colors.black.withOpacity(0.06);
    canvas.drawCircle(center, baseR, ring);

    for (int i = 0; i < 7; i++) {
      final ang = (i / 7) * pi * 2 + t * pi * 2;
      final pulse = (sin((t * pi * 2) + i) * 0.5 + 0.5);
      final rr = lerpDouble(baseR * 0.52, baseR * 1.05, pulse)!;
      final x = center.dx + cos(ang) * rr;
      final y = center.dy + sin(ang) * rr;

      final col = (i % 3 == 0 ? a : i % 3 == 1 ? b : c).withOpacity(0.16 + pulse * 0.10);

      final p = Paint()
        ..color = col
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(Offset(x, y), 10 + pulse * 6, p);

      final dot = Paint()..color = Colors.white.withOpacity(0.22 + pulse * 0.12);
      canvas.drawCircle(Offset(x, y), 2.2 + pulse * 1.6, dot);
    }

    final aura = Paint()
      ..shader = RadialGradient(
        colors: [a.withOpacity(0.10), b.withOpacity(0.06), Colors.transparent],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: baseR * 1.25));
    canvas.drawCircle(center, baseR * 1.2, aura);
  }

  @override
  bool shouldRepaint(covariant _AiBurstPainter oldDelegate) => oldDelegate.t != t;
}
