import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class OwnerPromotionsScreen extends StatefulWidget {
  final int ownerUserId;
  final int shopId;

  const OwnerPromotionsScreen({
    super.key,
    required this.ownerUserId,
    required this.shopId,
  });

  @override
  State<OwnerPromotionsScreen> createState() => _OwnerPromotionsScreenState();
}

class _OwnerPromotionsScreenState extends State<OwnerPromotionsScreen>
    with TickerProviderStateMixin {
  static const String _baseUrl = "http://31.97.190.216:10050";

  static const _primary = Color(0xFF440C08);
  static const _secondary = Color(0xFF750A03);
  static const _other = Color(0xFF9B0F03);
  static const _ink = Color(0xFF140504);

  late final AnimationController _ambientCtrl;
  late final TabController _tabCtrl;

  bool _loadingPromos = true;
  bool _loadingDeals = true;

  List<Map<String, dynamic>> _promos = [];
  List<Map<String, dynamic>> _deals = [];

  // For flash deal picker
  bool _loadingProducts = true;
  List<Map<String, dynamic>> _products = [];
  int? _selectedProductId;

  // tier prices shown (UI only)
  final Map<String, int> _tierPricesPerDay = const {
    "MAIN": 2000,
    "SECOND": 1200,
    "THIRD": 700,
  };

  @override
  void initState() {
    super.initState();
    _ambientCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 6000))
      ..repeat(reverse: true);

    _tabCtrl = TabController(length: 2, vsync: this);

    _loadAll();
  }

  @override
  void dispose() {
    _ambientCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
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

  Future<void> _loadAll() async {
    await Future.wait([
      _loadPromos(),
      _loadDeals(),
      _loadProducts(),
    ]);
  }

// ✅ Promotions
  Uri _promoListUri() => Uri.parse("$_baseUrl/shop-owner/shops/promotions")
      .replace(queryParameters: {
    "owner_user_id": "${widget.ownerUserId}",
  });

  Uri _promoCreateUri() => Uri.parse("$_baseUrl/shop-owner/shops/promotions");

// ✅ Flash Deals
  Uri _dealsListUri() => Uri.parse("$_baseUrl/shop-owner/shops/flash-deals")
      .replace(queryParameters: {
    "owner_user_id": "${widget.ownerUserId}",
  });

  Uri _dealCreateUri() => Uri.parse("$_baseUrl/shop-owner/shops/flash-deals");

  Uri _dealDeleteUri(int dealId) => Uri.parse(
    "$_baseUrl/shop-owner/flash-deals/$dealId",
  ).replace(queryParameters: {
    "owner_user_id": "${widget.ownerUserId}",
  });

// ✅ Owner products (for selecting product to apply deal)
  Uri _productsUri() => Uri.parse("$_baseUrl/shop-owner/shops/products")
      .replace(queryParameters: {
    "owner_user_id": "${widget.ownerUserId}",
  });
  Future<void> _loadPromos() async {
    try {
      setState(() => _loadingPromos = true);
      final res = await http.get(_promoListUri()).timeout(const Duration(seconds: 15));
      final j = jsonDecode(res.body);

      if (res.statusCode == 200 && j["ok"] == true) {
        setState(() {
          _promos = (j["data"] as List).cast<Map<String, dynamic>>();
          _loadingPromos = false;
        });
      } else {
        setState(() => _loadingPromos = false);
      }
    } catch (_) {
      setState(() => _loadingPromos = false);
    }
  }

  Future<void> _loadDeals() async {
    try {
      setState(() => _loadingDeals = true);
      final res = await http.get(_dealsListUri()).timeout(const Duration(seconds: 15));
      final j = jsonDecode(res.body);

      if (res.statusCode == 200 && j["ok"] == true) {
        setState(() {
          _deals = (j["data"] as List).cast<Map<String, dynamic>>();
          _loadingDeals = false;
        });
      } else {
        setState(() => _loadingDeals = false);
      }
    } catch (_) {
      setState(() => _loadingDeals = false);
    }
  }

  Future<void> _loadProducts() async {
    try {
      setState(() => _loadingProducts = true);
      final res = await http.get(_productsUri()).timeout(const Duration(seconds: 15));
      final j = jsonDecode(res.body);

      if (res.statusCode == 200 && j["ok"] == true) {
        final items = (j["data"] as List).cast<Map<String, dynamic>>();
        setState(() {
          _products = items;
          _loadingProducts = false;
          if (_products.isNotEmpty) {
            _selectedProductId ??= int.tryParse(_products.first["id"].toString());
          }
        });
      } else {
        setState(() => _loadingProducts = false);
      }
    } catch (_) {
      setState(() => _loadingProducts = false);
    }
  }

  Future<void> _createPromotion(String tier, int days) async {
    try {
      HapticFeedback.mediumImpact();
      final payload = {
        "owner_user_id": widget.ownerUserId,
        "tier": tier,
        "days": days,
      };

      final res = await http.post(
        _promoCreateUri(),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 20));

      final j = jsonDecode(res.body);
      if (res.statusCode == 201 && j["ok"] == true) {
        _toast("✅ Shop promoted ($tier)");
        _loadPromos();
      } else {
        _toast(j["error"]?.toString() ?? "Failed (${res.statusCode})");
      }
    } catch (e) {
      _toast("Error: $e");
    }
  }

  Future<void> _addToFlashDeals(int productId, int days) async {
    try {
      HapticFeedback.mediumImpact();
      final payload = {
        "owner_user_id": widget.ownerUserId,
        "product_id": productId,
        "days": days,
      };

      final res = await http.post(
        _dealCreateUri(),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 20));

      final j = jsonDecode(res.body);
      if (res.statusCode == 201 && j["ok"] == true) {
        _toast("⚡ Added to Flash Deals (25% OFF)");
        _loadDeals();
      } else {
        _toast(j["error"]?.toString() ?? "Failed (${res.statusCode})");
      }
    } catch (e) {
      _toast("Error: $e");
    }
  }

  Future<void> _removeDeal(int dealId) async {
    try {
      HapticFeedback.selectionClick();
      final res = await http.delete(_dealDeleteUri(dealId)).timeout(const Duration(seconds: 15));
      final j = jsonDecode(res.body);

      if (res.statusCode == 200 && j["ok"] == true) {
        _toast("Removed");
        _loadDeals();
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
                      _glassCard(
                        child: TabBar(
                          controller: _tabCtrl,
                          labelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w900),
                          indicatorColor: _secondary.withOpacity(0.85),
                          tabs: const [
                            Tab(text: "Promote Shop"),
                            Tab(text: "Flash Deals (25%)"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: TabBarView(
                          controller: _tabCtrl,
                          children: [
                            _promoteShopTab(),
                            _flashDealsTab(),
                          ],
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

  Widget _promoteShopTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Promote your shop", "Pick MAIN / SECOND / THIRD", Icons.campaign_rounded),
          const SizedBox(height: 12),

          _glassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Prices per day", style: _subtle()),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _tierPricesPerDay.entries.map((e) {
                    return _tierCard(e.key, e.value);
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          _sectionHeader("Your promotion history", "Latest first", Icons.history_rounded),
          const SizedBox(height: 12),

          if (_loadingPromos)
            _glassCard(child: const LinearProgressIndicator(minHeight: 6))
          else if (_promos.isEmpty)
            _glassCard(child: Text("No promotions yet.", style: _subtle()))
          else
            ..._promos.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _promoRow(p),
            )),
        ],
      ),
    );
  }

  Widget _tierCard(String tier, int pricePerDay) {
    final r = BorderRadius.circular(20);

    return InkWell(
      borderRadius: r,
      onTap: () => _openDaysDialog(
        title: "Promote as $tier",
        subtitle: "Rs $pricePerDay per day",
        onConfirm: (days) => _createPromotion(tier, days),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          borderRadius: r,
          color: Colors.white.withOpacity(0.66),
          border: Border.all(color: _primary.withOpacity(0.10), width: 1.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tier, style: GoogleFonts.manrope(fontSize: 14.5, fontWeight: FontWeight.w900, color: _ink.withOpacity(0.9))),
            const SizedBox(height: 4),
            Text("Rs $pricePerDay / day", style: _subtle()),
            const SizedBox(height: 10),
            Text("Tap to promote", style: GoogleFonts.manrope(fontSize: 12.2, fontWeight: FontWeight.w900, color: _secondary.withOpacity(0.85))),
          ],
        ),
      ),
    );
  }

  Widget _promoRow(Map<String, dynamic> p) {
    return _glassCard(
      child: Row(
        children: [
          Icon(Icons.verified_rounded, color: _secondary.withOpacity(0.85)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tier: ${p["tier"]}", style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text("Status: ${p["status"]} • Paid: Rs ${p["price_paid"]}", style: _subtle()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _flashDealsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Flash Deals", "Fixed 25% OFF products", Icons.flash_on_rounded),
          const SizedBox(height: 12),

          _glassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Select a product", style: _subtle()),
                const SizedBox(height: 10),
                _loadingProducts
                    ? const LinearProgressIndicator(minHeight: 6)
                    : _productDropdown(),
                const SizedBox(height: 10),
                _pillButton(
                  text: "Add to Flash Deals (25% OFF)",
                  onTap: (_selectedProductId == null)
                      ? null
                      : () => _openDaysDialog(
                    title: "Flash Deal (25% OFF)",
                    subtitle: "Pick duration (days)",
                    onConfirm: (days) => _addToFlashDeals(_selectedProductId!, days),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          _sectionHeader("Active / past deals", "You can remove anytime", Icons.local_offer_rounded),
          const SizedBox(height: 12),

          if (_loadingDeals)
            _glassCard(child: const LinearProgressIndicator(minHeight: 6))
          else if (_deals.isEmpty)
            _glassCard(child: Text("No flash deals yet.", style: _subtle()))
          else
            ..._deals.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _dealRow(d),
            )),
        ],
      ),
    );
  }

  Widget _productDropdown() {
    final r = BorderRadius.circular(18);

    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: r,
            color: Colors.white.withOpacity(0.66),
            border: Border.all(color: _primary.withOpacity(0.10), width: 1.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedProductId,
              isExpanded: true,
              items: _products.map((p) {
                final id = int.parse(p["id"].toString());
                return DropdownMenuItem<int>(
                  value: id,
                  child: Text(
                    p["title"]?.toString() ?? "Product $id",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v == null) return;
                HapticFeedback.selectionClick();
                setState(() => _selectedProductId = v);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _dealRow(Map<String, dynamic> d) {
    final dealId = int.parse(d["id"].toString());
    final title = d["title"]?.toString() ?? "Product";
    final pct = d["discount_percent"]?.toString() ?? "25";

    return _glassCard(
      child: Row(
        children: [
          Icon(Icons.flash_on_rounded, color: const Color(0xFFFFB000).withOpacity(0.9)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text("Discount: $pct% • Active: ${d["is_active"]}", style: _subtle()),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _removeDeal(dealId),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
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

  Future<void> _openDaysDialog({
    required String title,
    required String subtitle,
    required ValueChanged<int> onConfirm,
  }) async {
    int days = 7;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(subtitle, style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: "Days (e.g. 7)"),
                onChanged: (v) => days = int.tryParse(v) ?? days,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                onConfirm(days);
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
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
                child: Icon(Icons.campaign_rounded, color: Colors.white.withOpacity(0.92)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Promotions",
                        style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.96))),
                    const SizedBox(height: 4),
                    Text("Owner #${widget.ownerUserId} • Shop #${widget.shopId}",
                        style: GoogleFonts.manrope(fontSize: 12.2, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.78))),
                  ],
                ),
              ),
              _pillButton(text: "Back", onTap: () => Navigator.pop(context), invert: true),
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 10))],
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 22, offset: const Offset(0, 14))],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _pillButton({
    required String text,
    required VoidCallback? onTap,
    bool invert = false,
  }) {
    final r = BorderRadius.circular(999);
    return InkWell(
      borderRadius: r,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: r,
          color: invert ? Colors.white.withOpacity(0.16) : Colors.white.withOpacity(0.66),
          border: Border.all(color: invert ? Colors.white.withOpacity(0.22) : _primary.withOpacity(0.14), width: 1.1),
        ),
        child: Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 12.0,
            fontWeight: FontWeight.w900,
            color: invert ? Colors.white.withOpacity(0.92) : _ink.withOpacity(0.80),
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
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, Colors.transparent])),
      ),
    );
  }
}
