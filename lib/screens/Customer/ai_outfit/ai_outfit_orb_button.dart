import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AiOutfitFabOverlay extends StatelessWidget {
  final Color primary, secondary, other, ink;
  final VoidCallback onTap;

  const AiOutfitFabOverlay({
    super.key,
    required this.primary,
    required this.secondary,
    required this.other,
    required this.ink,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final y = 64 + 12 + bottomPad + 18;

    return Positioned(
      left: 0,
      right: 0,
      bottom: y,
      child: Center(
        child: AiOrbButton(
          primary: primary,
          secondary: secondary,
          other: other,
          ink: ink,
          onTap: onTap,
        ),
      ),
    );
  }
}

class AiOrbButton extends StatefulWidget {
  final Color primary, secondary, other, ink;
  final VoidCallback onTap;

  const AiOrbButton({
    super.key,
    required this.primary,
    required this.secondary,
    required this.other,
    required this.ink,
    required this.onTap,
  });

  @override
  State<AiOrbButton> createState() => _AiOrbButtonState();
}

class _AiOrbButtonState extends State<AiOrbButton> with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _spin;
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _spin = AnimationController(vsync: this, duration: const Duration(milliseconds: 4200))..repeat();
    _press = AnimationController(vsync: this, duration: const Duration(milliseconds: 140));
  }

  @override
  void dispose() {
    _pulse.dispose();
    _spin.dispose();
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapCancel: () => _press.reverse(),
      onTapUp: (_) => _press.reverse(),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulse, _spin, _press]),
        builder: (context, _) {
          final p = _pulse.value;
          final s = _spin.value;
          final down = _press.value;

          final scale = lerpDouble(1.0, 0.965, down)!;
          final glow = lerpDouble(0.18, 0.30, p)!;

          return Transform.scale(
            scale: scale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.secondary.withOpacity(glow),
                        widget.other.withOpacity(glow * 0.7),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: s * pi * 2,
                  child: CustomPaint(
                    size: const Size(84, 84),
                    painter: _OrbitalRingPainter(
                      a: widget.secondary.withOpacity(0.55),
                      b: widget.primary.withOpacity(0.45),
                    ),
                  ),
                ),
                ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.primary.withOpacity(0.96),
                            widget.secondary.withOpacity(0.92),
                          ],
                        ),
                        border: Border.all(color: Colors.white.withOpacity(0.28), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.26),
                            blurRadius: 26,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: const Alignment(-0.6, -0.7),
                                    radius: 1.1,
                                    colors: [
                                      Colors.white.withOpacity(0.55),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.6],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome_rounded,
                                    color: Colors.white.withOpacity(0.94), size: 22),
                                const SizedBox(height: 2),
                                Text(
                                  "AI",
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11.5,
                                    color: Colors.white.withOpacity(0.92),
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: -s * pi * 2,
                  child: CustomPaint(
                    size: const Size(92, 92),
                    painter: _ScanDotsPainter(color: Colors.white.withOpacity(0.18)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OrbitalRingPainter extends CustomPainter {
  final Color a, b;
  _OrbitalRingPainter({required this.a, required this.b});

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..shader = SweepGradient(
        colors: [Colors.transparent, a, b, Colors.transparent],
        stops: const [0.0, 0.35, 0.70, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r - 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ScanDotsPainter extends CustomPainter {
  final Color color;
  _ScanDotsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    final p = Paint()..color = color;

    for (int i = 0; i < 14; i++) {
      final ang = (i / 14) * pi * 2;
      final rr = r - 4;
      final x = c.dx + cos(ang) * rr;
      final y = c.dy + sin(ang) * rr;
      canvas.drawCircle(Offset(x, y), i % 3 == 0 ? 1.6 : 1.0, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
