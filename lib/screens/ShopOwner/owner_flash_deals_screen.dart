import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class OwnerFlashDealsScreen extends StatefulWidget {
  final int ownerUserId;
  final int shopId;

  const OwnerFlashDealsScreen({
    super.key,
    required this.ownerUserId,
    required this.shopId,
  });

  @override
  State<OwnerFlashDealsScreen> createState() => _OwnerFlashDealsScreenState();
}

class _OwnerFlashDealsScreenState extends State<OwnerFlashDealsScreen>
    with TickerProviderStateMixin {
  static const String _baseUrl = "http://31.97.190.216:10050";

  static const _primary = Color(0xFF440C08);
  static const _secondary = Color(0xFF750A03);
  static const _other = Color(0xFF9B0F03);
  static const _ink = Color(0xFF140504);

  late final AnimationController _ambientCtrl;

  bool _loading = true;
  List<Map<String, dynamic>> _deals = [];

  @override
  void initState() {
    super.initState();
    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat(reverse: true);

    _load();
  }

  @override
  void dispose() {
    _ambientCtrl.dispose();
    super.dispose();
  }

  Uri _listUri() => Uri.parse(
    "$_baseUrl/shop-owner/shops/${widget.shopId}/flash-deals",
  );

  Uri _deleteUri(int dealId) => Uri.parse(
    "$_baseUrl/shop-owner/shops/${widget.shopId}/flash-deals",
  );

  TextStyle _h1() => GoogleFonts.manrope(
    fontSize: 18.5,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.3,
    color: _ink.withOpacity(0.92),
  );

  TextStyle _subtle() => GoogleFonts.manrope(
    fontSize: 12.6,
    fontWeight: FontWeight.w800,
    height: 1.15,
    color: _ink.withOpacity(0.55),
  );

  Future<void> _load() async {
    try {
      setState(() => _loading = true);
      final res = await http.get(_listUri()).timeout(const Duration(seconds: 15));
      final j = jsonDecode(res.body);

      if (res.statusCode == 200 && j["ok"] == true) {
        setState(() {
          _deals = (j["data"] as List).cast<Map<String, dynamic>>();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _remove(int dealId) async {
    try {
      HapticFeedback.selectionClick();
      final res = await http.delete(_deleteUri(dealId)).timeout(const Duration(seconds: 15));
      final j = jsonDecode(res.body);

      if (res.statusCode == 200 && j["ok"] == true) {
        _toast("Removed");
        _load();
      } else {
        _toast(j["error"]?.toString() ?? "Failed (${res.statusCode})");
      }
    } catch (e) {
      _toast("Error: $e");
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: GoogleFonts.manrope(fontWeight: FontWeight.w800))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ambientCtrl,
      builder: (context, _) {
        final t = _ambientCtrl.value;
        final float = sin(t * pi * 2);

        return Scaffold(
          backgroundColor: const Color(0xFFF9F6F5),
          body: Stack(
            children: [
              Positioned(
                right: -90 - float * 10,
                top: 70 + float * 6,
                child: _GlowBlob(color: _secondary.withOpacity(0.12), size: 240),
              ),
              Positioned(
                left: -90 + float * 10,
                top: 250 - float * 6,
                child: _GlowBlob(color: _other.withOpacity(0.10), size: 260),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _topBar(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _sectionHeader(
                              "Flash Deals",
                              "Fixed 25% off products",
                              Icons.flash_on_rounded,
                            ),
                          ),
                          _glassPill(text: "Refresh", onTap: _load),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Expanded(
                        child: _loading
                            ? _glassCard(child: const LinearProgressIndicator(minHeight: 6))
                            : _deals.isEmpty
                            ? _glassCard(child: Text("No flash deals yet.", style: _subtle()))
                            : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _deals.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) => _dealCard(_deals[i]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dealCard(Map<String, dynamic> d) {
    final dealId = int.parse(d["id"].toString());
    final title = (d["title"] ?? "Product").toString();
    final pct = (d["discount_percent"] ?? "25").toString();
    final active = (d["is_active"] ?? 1).toString();

    return _glassCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFFB000).withOpacity(0.9),
                  const Color(0xFFFF6A00).withOpacity(0.9),
                ],
              ),
            ),
            child: Icon(Icons.flash_on_rounded, color: Colors.white.withOpacity(0.96)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 14.2,
                    fontWeight: FontWeight.w900,
                    color: _ink.withOpacity(0.92),
                  ),
                ),
                const SizedBox(height: 4),
                Text("Discount: $pct% • Active: $active", style: _subtle()),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _remove(dealId),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFE04343).withOpacity(0.10),
                border: Border.all(color: const Color(0xFFE04343).withOpacity(0.22), width: 1),
              ),
              child: Icon(Icons.delete_rounded, size: 18, color: const Color(0xFFE04343).withOpacity(0.95)),
            ),
          )
        ],
      ),
    );
  }

  Widget _topBar() {
    final r = BorderRadius.circular(22);
    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: r,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _primary.withOpacity(0.96),
                _secondary.withOpacity(0.92),
                _primary.withOpacity(0.94),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.1),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 26, offset: const Offset(0, 14)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.14),
                  border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.0),
                ),
                child: Icon(Icons.flash_on_rounded, color: Colors.white.withOpacity(0.92)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Flash Deals",
                        style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.96))),
                    const SizedBox(height: 4),
                    Text("Owner #${widget.ownerUserId} • Shop #${widget.shopId}",
                        style: GoogleFonts.manrope(fontSize: 12.2, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.78))),
                  ],
                ),
              ),
              _glassPill(text: "Back", onTap: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.70),
            border: Border.all(color: Colors.white.withOpacity(0.86), width: 1.1),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 10)),
            ],
          ),
          child: Center(
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(shape: BoxShape.circle, color: _primary.withOpacity(0.10)),
              child: Icon(icon, size: 18, color: _primary.withOpacity(0.86)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _h1()),
              const SizedBox(height: 3),
              Text(subtitle, style: _subtle()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _glassCard({required Widget child}) {
    final r = BorderRadius.circular(24);
    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: r,
            color: Colors.white.withOpacity(0.72),
            border: Border.all(color: Colors.white.withOpacity(0.86), width: 1.1),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 22, offset: const Offset(0, 14)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _glassPill({required String text, required VoidCallback onTap}) {
    final r = BorderRadius.circular(999);
    return InkWell(
      borderRadius: r,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: r,
          color: Colors.white.withOpacity(0.16),
          border: Border.all(color: Colors.white.withOpacity(0.22), width: 1.1),
        ),
        child: Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 12.0,
            fontWeight: FontWeight.w900,
            color: Colors.white.withOpacity(0.92),
          ),
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }
}
