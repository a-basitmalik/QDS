// lib/screens/ShopOwner/owner_product_detail_screen.dart
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'owner_products_list_screen.dart';

class OwnerProductDetailScreen extends StatefulWidget {
  final int ownerUserId;
  final int shopId;
  final int productId;
  final ProductLite? initialLite;

  const OwnerProductDetailScreen({
    super.key,
    required this.ownerUserId,
    required this.shopId,
    required this.productId,
    this.initialLite,
  });

  @override
  State<OwnerProductDetailScreen> createState() =>
      _OwnerProductDetailScreenState();
}

class _OwnerProductDetailScreenState extends State<OwnerProductDetailScreen>
    with TickerProviderStateMixin {
  // Theme
  static const _primary = Color(0xFF440C08);
  static const _secondary = Color(0xFF750A03);
  static const _other = Color(0xFF9B0F03);
  static const _ink = Color(0xFF140504);

  late final AnimationController _ambientCtrl;

  bool _loading = true;
  ProductDetail? _data;

  @override
  void initState() {
    super.initState();
    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat(reverse: true);

    _fetch();
  }

  @override
  void dispose() {
    _ambientCtrl.dispose();
    super.dispose();
  }

  // ✅ text helpers (fixes _h1 / _subtle error)
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

  // ✅ Fully dynamic fetch using YOUR route
  Future<void> _fetch() async {
    try {
      if (mounted) setState(() => _loading = true);

      final uri = Uri.parse(
        "http://31.97.190.216:10050/shop-owner/shops/${widget.shopId}/products/${widget.productId}",
      );

      final res = await http.get(uri).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        String msg = "Failed to load product (${res.statusCode})";
        try {
          final err = jsonDecode(res.body);
          if (err is Map && err["error"] != null) {
            msg = err["error"].toString();
          }
        } catch (_) {}

        if (!mounted) return;
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        return;
      }

      final Map<String, dynamic> data =
      jsonDecode(res.body) as Map<String, dynamic>;

      final product = (data["product"] ?? {}) as Map<String, dynamic>;

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

      bool _toBool(dynamic v) {
        if (v == null) return false;
        if (v is bool) return v;
        if (v is num) return v.toInt() == 1;
        final s = v.toString().toLowerCase();
        return s == "1" || s == "true" || s == "yes";
      }

      final images = (data["images"] as List? ?? const [])
          .map((e) => e.toString())
          .toList();

      final variants = (data["variants"] as List? ?? const []).map((v) {
        final m = v as Map<String, dynamic>;
        return Variant(
          size: (m["size"] ?? "").toString(),
          stockQty: _toInt(m["stock_qty"]),
        );
      }).toList();

      SizeChartDetail? chart;
      final sc = data["size_chart"];
      if (sc != null && sc is Map<String, dynamic>) {
        final rowsRaw = (sc["rows"] as List? ?? const []);
        chart = SizeChartDetail(
          title: (sc["title"] ?? "").toString(),
          unit: (sc["unit"] ?? "cm").toString(),
          rows: rowsRaw.map((r) {
            final m = r as Map<String, dynamic>;
            return SizeChartRow(
              size: (m["size"] ?? "").toString(),
              chest: _toDouble(m["chest"]),
              waist: _toDouble(m["waist"]),
              length: _toDouble(m["length"]),
              shoulder: _toDouble(m["shoulder"]),
            );
          }).toList(),
        );
      }

      final reviews = (data["reviews"] as List? ?? const []).map((r) {
        final m = r as Map<String, dynamic>;
        return Review(
          userName: (m["user_name"] ?? "Guest").toString(),
          rating: _toInt(m["rating"]),
          text: (m["review_text"] ?? "").toString(),
        );
      }).toList();

      final detail = ProductDetail(
        id: _toInt(product["id"], fallback: widget.productId),
        title: (product["title"] ?? "").toString(),
        description: (product["description"] ?? "").toString(),
        price: _toDouble(product["price"]) ?? 0.0,
        isOnSale: _toBool(product["is_on_sale"]),
        salePercent: _toDouble(product["sale_percent"]),
        mainImageUrl: product["main_image_url"]?.toString(),
        images: images,
        variants: variants,
        sizeChart: chart,
        reviews: reviews,
      );

      if (!mounted) return;
      setState(() {
        _data = detail;
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

  // ✅ IMPORTANT: build method (fixes "missing build" error)
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
                top: 80 + float * 6,
                child:
                _GlowBlob(color: _secondary.withOpacity(0.12), size: 240),
              ),
              Positioned(
                left: -90 + float * 10,
                top: 260 - float * 6,
                child: _GlowBlob(color: _other.withOpacity(0.10), size: 260),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                  child: _loading ? _skeleton() : _content(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _content() {
    final d = _data!;
    final salePrice = (d.isOnSale && d.salePercent != null)
        ? (d.price * (1 - (d.salePercent! / 100.0)))
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _topHeader(),
        const SizedBox(height: 14),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heroImage(d.mainImageUrl),
                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        d.title,
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: _ink.withOpacity(0.92),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (d.isOnSale && d.salePercent != null)
                      _saleChip("${d.salePercent!.toStringAsFixed(0)}% OFF"),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  d.description,
                  style: GoogleFonts.manrope(
                    fontSize: 12.8,
                    fontWeight: FontWeight.w800,
                    color: _ink.withOpacity(0.58),
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 12),
                _glassCard(
                  child: Row(
                    children: [
                      Text(
                        salePrice == null
                            ? "Rs ${d.price.toStringAsFixed(0)}"
                            : "Rs ${salePrice.toStringAsFixed(0)}",
                        style: GoogleFonts.manrope(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: _ink.withOpacity(0.92),
                        ),
                      ),
                      if (salePrice != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          "Rs ${d.price.toStringAsFixed(0)}",
                          style: GoogleFonts.manrope(
                            fontSize: 12.6,
                            fontWeight: FontWeight.w900,
                            color: _ink.withOpacity(0.42),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      const Spacer(),
                      _pillIcon(Icons.refresh_rounded, onTap: _fetch),
                    ],
                  ),
                ),

                const SizedBox(height: 18),
                _sectionHeader("Gallery", "product_images", Icons.photo_library_rounded),
                const SizedBox(height: 12),
                _gallery(d.images),

                const SizedBox(height: 18),
                _sectionHeader("Sizes & Stock", "product_variants", Icons.straighten_rounded),
                const SizedBox(height: 12),
                _variants(d.variants),

                const SizedBox(height: 18),
                _sectionHeader("Size Chart", "size_charts + size_chart_rows", Icons.table_chart_rounded),
                const SizedBox(height: 12),
                d.sizeChart == null
                    ? _emptyBlock("No size chart attached.")
                    : _sizeChart(d.sizeChart!),

                const SizedBox(height: 18),
                _sectionHeader("Reviews", "product_reviews", Icons.star_rounded),
                const SizedBox(height: 12),
                _reviews(d.reviews),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ],
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
                  border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.0),
                ),
                child: Icon(Icons.inventory_2_rounded, color: Colors.white.withOpacity(0.92)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Product Detail",
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withOpacity(0.96),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Product #${widget.productId} • Shop #${widget.shopId}",
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

  Widget _heroImage(String? url) {
    final r = BorderRadius.circular(26);
    return ClipRRect(
      borderRadius: r,
      child: Container(
        height: 240,
        width: double.infinity,
        color: _primary.withOpacity(0.06),
        child: (url == null || url.isEmpty)
            ? Icon(Icons.image_rounded, size: 44, color: _primary.withOpacity(0.5))
            : Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(Icons.broken_image_rounded, size: 44, color: _primary.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget _gallery(List<String> images) {
    if (images.isEmpty) return _emptyBlock("No sub images.");
    return SizedBox(
      height: 92,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final r = BorderRadius.circular(18);
          return ClipRRect(
            borderRadius: r,
            child: Container(
              width: 92,
              height: 92,
              color: _primary.withOpacity(0.06),
              child: Image.network(
                images[i],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.broken_image_rounded, color: _primary.withOpacity(0.5)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _variants(List<Variant> variants) {
    if (variants.isEmpty) return _emptyBlock("No variants added.");
    return _glassCard(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: variants.map((v) {
          final out = v.stockQty <= 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Colors.white.withOpacity(0.66),
              border: Border.all(
                color: out
                    ? const Color(0xFFE04343).withOpacity(0.22)
                    : _primary.withOpacity(0.10),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  out ? Icons.remove_circle_rounded : Icons.check_circle_rounded,
                  size: 18,
                  color: out
                      ? const Color(0xFFE04343).withOpacity(0.9)
                      : const Color(0xFF2FB06B).withOpacity(0.9),
                ),
                const SizedBox(width: 8),
                Text(
                  "${v.size} • Stock ${v.stockQty}",
                  style: GoogleFonts.manrope(
                    fontSize: 12.2,
                    fontWeight: FontWeight.w900,
                    color: _ink.withOpacity(0.82),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sizeChart(SizeChartDetail chart) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${chart.title} • ${chart.unit}",
            style: GoogleFonts.manrope(
              fontSize: 13.4,
              fontWeight: FontWeight.w900,
              color: _ink.withOpacity(0.86),
            ),
          ),
          const SizedBox(height: 10),
          _tableHeader(),
          const SizedBox(height: 8),
          ...chart.rows.map((r) => _tableRow(r)).toList(),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Row(
      children: [
        _th("Size", flex: 2),
        _th("Chest", flex: 2),
        _th("Waist", flex: 2),
        _th("Length", flex: 2),
        _th("Shoulder", flex: 2),
      ],
    );
  }

  Widget _th(String t, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        t,
        style: GoogleFonts.manrope(
          fontSize: 11.6,
          fontWeight: FontWeight.w900,
          color: _ink.withOpacity(0.55),
        ),
      ),
    );
  }

  Widget _tableRow(SizeChartRow r) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _td(r.size, flex: 2),
          _td(_num(r.chest), flex: 2),
          _td(_num(r.waist), flex: 2),
          _td(_num(r.length), flex: 2),
          _td(_num(r.shoulder), flex: 2),
        ],
      ),
    );
  }

  Widget _td(String t, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        t,
        style: GoogleFonts.manrope(
          fontSize: 12.2,
          fontWeight: FontWeight.w900,
          color: _ink.withOpacity(0.82),
        ),
      ),
    );
  }

  String _num(double? v) => v == null
      ? "—"
      : (v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1));

  Widget _reviews(List<Review> reviews) {
    if (reviews.isEmpty) return _emptyBlock("No reviews yet.");
    return Column(
      children: reviews
          .map(
            (r) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _reviewCard(r),
        ),
      )
          .toList(),
    );
  }

  Widget _reviewCard(Review r) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                r.userName,
                style: GoogleFonts.manrope(
                  fontSize: 13.2,
                  fontWeight: FontWeight.w900,
                  color: _ink.withOpacity(0.86),
                ),
              ),
              const Spacer(),
              _stars(r.rating),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            r.text,
            style: GoogleFonts.manrope(
              fontSize: 12.6,
              fontWeight: FontWeight.w800,
              color: _ink.withOpacity(0.58),
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stars(int rating) {
    rating = rating.clamp(0, 5);
    return Row(
      children: List.generate(5, (i) {
        final on = i < rating;
        return Icon(
          on ? Icons.star_rounded : Icons.star_border_rounded,
          size: 18,
          color: on
              ? const Color(0xFFFFB000).withOpacity(0.95)
              : _ink.withOpacity(0.30),
        );
      }),
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
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 22,
                offset: const Offset(0, 14),
              )
            ],
          ),
          child: child,
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

  Widget _pillIcon(IconData icon, {VoidCallback? onTap}) {
    final r = BorderRadius.circular(999);
    return InkWell(
      borderRadius: r,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: r,
          color: Colors.white.withOpacity(0.66),
          border: Border.all(color: _primary.withOpacity(0.10), width: 1.0),
        ),
        child: Icon(icon, size: 18, color: _ink.withOpacity(0.7)),
      ),
    );
  }

  Widget _glassPill({required String text, required VoidCallback onTap}) {
    final r = BorderRadius.circular(999);
    return InkWell(
      borderRadius: r,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
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

  Widget _emptyBlock(String text) {
    return _glassCard(
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 12.6,
          fontWeight: FontWeight.w800,
          color: _ink.withOpacity(0.55),
        ),
      ),
    );
  }

  Widget _skeleton() {
    return Column(
      children: [
        _topHeader(),
        const SizedBox(height: 14),
        _glassCard(
          child: Container(height: 240, color: _primary.withOpacity(0.06)),
        ),
        const SizedBox(height: 12),
        _glassCard(
          child: Container(height: 80, color: _primary.withOpacity(0.05)),
        ),
        const SizedBox(height: 12),
        _glassCard(
          child: Container(height: 120, color: _primary.withOpacity(0.05)),
        ),
      ],
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

// -------- Models --------

class ProductDetail {
  final int id;
  final String title;
  final String description;
  final double price;
  final bool isOnSale;
  final double? salePercent;
  final String? mainImageUrl;

  final List<String> images;
  final List<Variant> variants;
  final SizeChartDetail? sizeChart;
  final List<Review> reviews;

  const ProductDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.isOnSale,
    required this.salePercent,
    required this.mainImageUrl,
    required this.images,
    required this.variants,
    required this.sizeChart,
    required this.reviews,
  });
}

class Variant {
  final String size;
  final int stockQty;
  const Variant({required this.size, required this.stockQty});
}

class SizeChartDetail {
  final String title;
  final String unit;
  final List<SizeChartRow> rows;
  const SizeChartDetail({
    required this.title,
    required this.unit,
    required this.rows,
  });
}

class SizeChartRow {
  final String size;
  final double? chest;
  final double? waist;
  final double? length;
  final double? shoulder;
  const SizeChartRow({
    required this.size,
    required this.chest,
    required this.waist,
    required this.length,
    required this.shoulder,
  });
}

class Review {
  final String userName;
  final int rating;
  final String text;
  const Review({required this.userName, required this.rating, required this.text});
}
