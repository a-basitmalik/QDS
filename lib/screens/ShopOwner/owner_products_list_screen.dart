// lib/screens/ShopOwner/owner_products_list_screen.dart
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'owner_product_detail_screen.dart';

class OwnerProductsListScreen extends StatefulWidget {
  final int ownerUserId;
  final int shopId;

  const OwnerProductsListScreen({
    super.key,
    required this.ownerUserId,
    required this.shopId,
  });

  @override
  State<OwnerProductsListScreen> createState() => _OwnerProductsListScreenState();
}

class _OwnerProductsListScreenState extends State<OwnerProductsListScreen>
    with TickerProviderStateMixin {
  // Theme
  static const _primary = Color(0xFF440C08);
  static const _secondary = Color(0xFF750A03);
  static const _other = Color(0xFF9B0F03);
  static const _ink = Color(0xFF140504);

  late final AnimationController _ambientCtrl;

  bool _loading = true;
  final List<ProductLite> _items = [];

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
  Future<void> _load() async {
    try {
      setState(() => _loading = true);

      final uri = Uri.parse(
        "http://31.97.190.216:10050/shop-owner/shops/${widget.shopId}/products"
            "?owner_user_id=${widget.ownerUserId}",
      );

      final res = await http.get(uri).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        String msg = "Failed to load products (${res.statusCode})";
        try {
          final err = jsonDecode(res.body);
          if (err is Map && err["error"] != null) msg = err["error"].toString();
        } catch (_) {}
        if (!mounted) return;
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        return;
      }

      final Map<String, dynamic> json = jsonDecode(res.body);
      final List list = (json["data"] as List? ?? const []);

      bool _toBool(dynamic v) {
        if (v == null) return false;
        if (v is bool) return v;
        if (v is num) return v.toInt() == 1;
        final s = v.toString().toLowerCase();
        return s == "1" || s == "true" || s == "yes";
      }

      double? _toDouble(dynamic v) {
        if (v == null) return null;
        if (v is num) return v.toDouble();
        return double.tryParse(v.toString());
      }

      int _toInt(dynamic v, {int fallback = 0}) {
        if (v == null) return fallback;
        if (v is num) return v.toInt();
        return int.tryParse(v.toString()) ?? fallback;
      }

      final items = list.map((e) {
        final m = e as Map<String, dynamic>;
        return ProductLite(
          id: _toInt(m["id"]),
          title: (m["title"] ?? "").toString(),
          description: (m["description"] ?? "").toString(),
          price: _toDouble(m["price"]) ?? 0.0,
          isOnSale: _toBool(m["is_on_sale"]),
          salePercent: _toDouble(m["sale_percent"]),
          mainImageUrl: m["main_image_url"]?.toString(),
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(items);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

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

  void _open(ProductLite p) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerProductDetailScreen(
          ownerUserId: widget.ownerUserId,
          shopId: widget.shopId,
          productId: p.id,
          // optionally pass lite to show instantly; detail screen can fetch full.
          initialLite: p,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ambientCtrl,
      builder: (context, _) {
        final t = _ambientCtrl.value;
        final float = sin(t * pi * 2);

        return Stack(
          children: [
            Positioned(
              right: -90 - float * 10,
              top: 60 + float * 6,
              child: _GlowBlob(color: _secondary.withOpacity(0.12), size: 240),
            ),
            Positioned(
              left: -90 + float * 10,
              top: 260 - float * 6,
              child: _GlowBlob(color: _other.withOpacity(0.10), size: 260),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topHeader(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _sectionHeader(
                        "Your Products",
                        "Customer-style listing view",
                        Icons.inventory_2_rounded,
                      ),
                    ),
                    _glassPill(text: "Refresh", onTap: _load),
                  ],
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: _loading
                      ? _loadingList()
                      : _items.isEmpty
                      ? _emptyState()
                      : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                    itemBuilder: (context, i) =>
                        _productCard(_items[i]),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _topHeader() {
    final r = BorderRadius.circular(24);
    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
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
                  border: Border.all(
                      color: Colors.white.withOpacity(0.25), width: 1.0),
                ),
                child: Icon(Icons.storefront_rounded,
                    color: Colors.white.withOpacity(0.92)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Shop Products",
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withOpacity(0.96),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Owner #${widget.ownerUserId} • Shop #${widget.shopId}",
                      style: GoogleFonts.manrope(
                        fontSize: 12.2,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.78),
                      ),
                    ),
                  ],
                ),
              ),
              _glassPill(
                text: "Back",
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        _floatingIcon(icon),
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

  Widget _floatingIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.70),
        border: Border.all(color: Colors.white.withOpacity(0.86), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Center(
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _primary.withOpacity(0.10),
          ),
          child: Icon(icon, size: 18, color: _primary.withOpacity(0.86)),
        ),
      ),
    );
  }

  Widget _productCard(ProductLite p) {
    final r = BorderRadius.circular(24);

    return InkWell(
      borderRadius: r,
      onTap: () => _open(p),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: r,
              color: Colors.white.withOpacity(0.72),
              border:
              Border.all(color: Colors.white.withOpacity(0.86), width: 1.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 22,
                  offset: const Offset(0, 14),
                )
              ],
            ),
            child: Row(
              children: [
                _img(p.mainImageUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              p.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                fontSize: 14.2,
                                fontWeight: FontWeight.w900,
                                color: _ink.withOpacity(0.92),
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (p.isOnSale && p.salePercent != null)
                            _saleChip("${p.salePercent!.toStringAsFixed(0)}% OFF"),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 12.4,
                          fontWeight: FontWeight.w800,
                          color: _ink.withOpacity(0.55),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            "Rs ${p.price.toStringAsFixed(0)}",
                            style: GoogleFonts.manrope(
                              fontSize: 13.6,
                              fontWeight: FontWeight.w900,
                              color: _ink.withOpacity(0.9),
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.chevron_right_rounded,
                              color: _ink.withOpacity(0.35)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _img(String? url) {
    final r = BorderRadius.circular(18);

    return ClipRRect(
      borderRadius: r,
      child: Container(
        width: 86,
        height: 86,
        color: _primary.withOpacity(0.06),
        child: url == null || url.isEmpty
            ? Icon(Icons.image_rounded, color: _primary.withOpacity(0.5))
            : Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(Icons.broken_image_rounded,
              color: _primary.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget _saleChip(String text) {
    final r = BorderRadius.circular(999);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: r,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_secondary.withOpacity(0.95), _primary.withOpacity(0.95)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.75), width: 1),
        boxShadow: [
          BoxShadow(
            color: _secondary.withOpacity(0.22),
            blurRadius: 12,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          color: Colors.white.withOpacity(0.96),
        ),
      ),
    );
  }

  Widget _glassPill({
    required String text,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    final r = BorderRadius.circular(999);

    return InkWell(
      borderRadius: r,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: r,
          gradient: filled
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _secondary.withOpacity(0.95),
              _primary.withOpacity(0.95),
            ],
          )
              : null,
          color: filled ? null : Colors.white.withOpacity(0.16),
          border: Border.all(
            color:
            filled ? Colors.white.withOpacity(0.18) : Colors.white.withOpacity(0.22),
            width: 1.1,
          ),
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

  Widget _loadingList() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => _skeletonCard(),
    );
  }

  Widget _skeletonCard() {
    final r = BorderRadius.circular(24);
    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 110,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: r,
            color: Colors.white.withOpacity(0.60),
            border: Border.all(color: Colors.white.withOpacity(0.75), width: 1.0),
          ),
          child: Row(
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: _primary.withOpacity(0.08),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: 180, color: _primary.withOpacity(0.06)),
                    const SizedBox(height: 10),
                    Container(height: 12, width: 240, color: _primary.withOpacity(0.05)),
                    const SizedBox(height: 6),
                    Container(height: 12, width: 210, color: _primary.withOpacity(0.05)),
                    const Spacer(),
                    Container(height: 14, width: 90, color: _primary.withOpacity(0.06)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    final r = BorderRadius.circular(24);
    return Center(
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: r,
              border: Border.all(color: Colors.white.withOpacity(0.86), width: 1.1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inventory_2_rounded, size: 42, color: _primary.withOpacity(0.65)),
                const SizedBox(height: 10),
                Text(
                  "No products yet",
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _ink.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Add your first product from the Products tab.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 12.6,
                    fontWeight: FontWeight.w800,
                    color: _ink.withOpacity(0.55),
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

/// What list screen needs
class ProductLite {
  final int id;
  final String title;
  final String description;
  final double price;
  final bool isOnSale;
  final double? salePercent;
  final String? mainImageUrl;

  const ProductLite({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.isOnSale,
    required this.salePercent,
    required this.mainImageUrl,
  });
}
