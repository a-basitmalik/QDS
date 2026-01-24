// lib/screens/ShopOwner/owner_add_product_screen.dart
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'owner_size_chart_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


/// ✅ Add Product Screen
/// - Uses your premium glass theme
/// - Supports: title, description, price, sale, sale %, main image, 3 sub images
/// - Variants: sizes + stock per size (like product_variants table)
/// - Size chart: pick existing OR create new (opens OwnerSizeChartScreen)
/// - Replace the _submit() section with your real API calls + DB inserts.
class OwnerAddProductScreen extends StatefulWidget {
  final int ownerUserId;
  final int shopId; // you can pass from prefs / login response

  const OwnerAddProductScreen({
    super.key,
    required this.ownerUserId,
    required this.shopId,
  });

  @override
  State<OwnerAddProductScreen> createState() => _OwnerAddProductScreenState();
}

class _OwnerAddProductScreenState extends State<OwnerAddProductScreen>
    with TickerProviderStateMixin {
  // Theme
  static const _primary = Color(0xFF440C08);
  static const _secondary = Color(0xFF750A03);
  static const _other = Color(0xFF9B0F03);
  static const _ink = Color(0xFF140504);

  // Ambient
  late final AnimationController _ambientCtrl;

  // Form controllers
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _salePctCtrl = TextEditingController();

  // Images (urls for now - you can integrate picker later)
  final _mainImageCtrl = TextEditingController();
  final _sub1Ctrl = TextEditingController();
  final _sub2Ctrl = TextEditingController();
  final _sub3Ctrl = TextEditingController();

  // Sale
  bool _onSale = false;

  // Variants (size+stock)
  final List<_VariantRow> _variants = [
    _VariantRow(size: "S", stock: 10),
    _VariantRow(size: "M", stock: 8),
  ];

  // Size charts (mock list - load from API by owner/shop)
  final List<_SizeChartLite> _charts = [
    _SizeChartLite(id: 1, title: "Men T-Shirt (cm)"),
    _SizeChartLite(id: 2, title: "Women Kurti (cm)"),
  ];
  int? _selectedChartId;

  @override
  void initState() {
    super.initState();
    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat(reverse: true);

    // Defaults
    _priceCtrl.text = "0";
    _salePctCtrl.text = "10";
  }

  @override
  void dispose() {
    _ambientCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _salePctCtrl.dispose();
    _mainImageCtrl.dispose();
    _sub1Ctrl.dispose();
    _sub2Ctrl.dispose();
    _sub3Ctrl.dispose();
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

  Future<void> _openCreateSizeChart() async {
    HapticFeedback.selectionClick();
    final created = await Navigator.push<_SizeChartLite>(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerSizeChartScreen(
          ownerUserId: widget.ownerUserId,
          shopId: widget.shopId,
        ),
      ),
    );

    // If screen returns a created chart, add it and select
    if (created != null) {
      setState(() {
        _charts.insert(0, created);
        _selectedChartId = created.id;
      });
    }
  }

  void _addVariant() {
    HapticFeedback.selectionClick();
    setState(() => _variants.add(_VariantRow(size: "", stock: 0)));
  }

  void _removeVariant(int idx) {
    HapticFeedback.lightImpact();
    setState(() => _variants.removeAt(idx));
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final salePct = double.tryParse(_salePctCtrl.text.trim()) ?? 0;

    final mainImg = _mainImageCtrl.text.trim();
    final subs = [
      _sub1Ctrl.text.trim(),
      _sub2Ctrl.text.trim(),
      _sub3Ctrl.text.trim(),
    ].where((e) => e.isNotEmpty).toList();

    final variants = _variants
        .where((v) => v.size.trim().isNotEmpty)
        .map((v) => {"size": v.size.trim(), "stock_qty": v.stock})
        .toList();

    if (title.isEmpty) return _toast("Please enter product title.");
    if (price <= 0) return _toast("Price must be greater than 0.");
    if (_onSale && salePct <= 0) return _toast("Sale percent must be > 0.");
    if (variants.isEmpty) return _toast("Add at least one size/stock variant.");

    try {
      HapticFeedback.mediumImpact();

      final uri = Uri.parse(
        "http://31.97.190.216:10050/shop-owner/shops/${widget.shopId}/products/full",
      );

      final payload = {
        "owner_user_id": widget.ownerUserId,
        "title": title,
        "description": desc,
        "price": price,
        "is_on_sale": _onSale ? 1 : 0,
        "sale_percent": _onSale ? salePct : null,
        "main_image_url": mainImg.isEmpty ? null : mainImg,
        "sub_images": subs,
        "variants": variants,
        "size_chart_id": _selectedChartId,
      };

      final res = await http
          .post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      )
          .timeout(const Duration(seconds: 20));

      final decoded = jsonDecode(res.body);

      if (res.statusCode != 201) {
        final msg = (decoded is Map && decoded["error"] != null)
            ? decoded["error"].toString()
            : "Save failed (${res.statusCode})";
        _toast(msg);
        return;
      }

      _toast("✅ Product saved");
      if (!mounted) return;

      // Return to previous screen (and refresh list there)
      Navigator.pop(context, true);
    } catch (e) {
      _toast("❌ Error: $e");
    }
  }


  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
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
            // ambient subtle overlay
            Positioned(
              right: -90 - float * 10,
              top: 40 + float * 6,
              child: _GlowBlob(color: _secondary.withOpacity(0.12), size: 240),
            ),
            Positioned(
              left: -90 + float * 10,
              top: 220 - float * 6,
              child: _GlowBlob(color: _other.withOpacity(0.10), size: 260),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(
                          "Product Details",
                          "Title, description, pricing & sale",
                          Icons.inventory_2_rounded,
                        ),
                        const SizedBox(height: 12),
                        _glassCard(
                          child: Column(
                            children: [
                              _field(
                                label: "Product title",
                                controller: _titleCtrl,
                                hint: "e.g. Premium Hoodie",
                                icon: Icons.title_rounded,
                              ),
                              const SizedBox(height: 10),
                              _field(
                                label: "Description",
                                controller: _descCtrl,
                                hint: "Write product description…",
                                icon: Icons.notes_rounded,
                                maxLines: 4,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _field(
                                      label: "Price (Rs)",
                                      controller: _priceCtrl,
                                      hint: "e.g. 2500",
                                      icon: Icons.payments_rounded,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _saleToggle(),
                                ],
                              ),
                              if (_onSale) ...[
                                const SizedBox(height: 10),
                                _field(
                                  label: "Sale percent (%)",
                                  controller: _salePctCtrl,
                                  hint: "e.g. 15",
                                  icon: Icons.local_offer_rounded,
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),
                        _sectionHeader(
                          "Images",
                          "Main image + up to 3 sub images",
                          Icons.image_rounded,
                        ),
                        const SizedBox(height: 12),
                        _glassCard(
                          child: Column(
                            children: [
                              _field(
                                label: "Main image url",
                                controller: _mainImageCtrl,
                                hint: "https://...",
                                icon: Icons.image_outlined,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _field(
                                      label: "Sub image 1",
                                      controller: _sub1Ctrl,
                                      hint: "https://...",
                                      icon: Icons.photo_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _field(
                                      label: "Sub image 2",
                                      controller: _sub2Ctrl,
                                      hint: "https://...",
                                      icon: Icons.photo_rounded,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _field(
                                label: "Sub image 3",
                                controller: _sub3Ctrl,
                                hint: "https://...",
                                icon: Icons.photo_rounded,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),
                        _sectionHeader(
                          "Sizes & Stock",
                          "Stock per size (product_variants)",
                          Icons.straighten_rounded,
                          actionText: "Add size",
                          onAction: _addVariant,
                        ),
                        const SizedBox(height: 12),
                        _variantsCard(),

                        const SizedBox(height: 18),
                        _sectionHeader(
                          "Size Chart",
                          "Select existing or create a new one",
                          Icons.table_chart_rounded,
                        ),
                        const SizedBox(height: 12),
                        _sizeChartCard(),

                        const SizedBox(height: 18),
                        _glassPill(
                          text: "Save Product",
                          onTap: () => _submit(),
                          filled: true,
                        ),
                        const SizedBox(height: 22),
                      ],
                    ),
                  ),
                ),
              ],
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
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            children: [
              _circleIcon(Icons.add_business_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Add Product",
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

  Widget _circleIcon(IconData icon) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.14),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.0),
      ),
      child: Icon(icon, color: Colors.white.withOpacity(0.92)),
    );
  }

  Widget _sectionHeader(
      String title,
      String subtitle,
      IconData icon, {
        String? actionText,
        VoidCallback? onAction,
      }) {
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
        if (actionText != null && onAction != null)
          _glassPill(text: actionText, onTap: onAction),
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

  Widget _glassCard({required Widget child}) {
    final r = BorderRadius.circular(24);
    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
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

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final r = BorderRadius.circular(18);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _subtle()),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: r,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: r,
                color: Colors.white.withOpacity(0.66),
                border: Border.all(color: _primary.withOpacity(0.10), width: 1.0),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Icon(icon, size: 18, color: _primary.withOpacity(0.78)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      maxLines: maxLines,
                      keyboardType: keyboardType,
                      style: GoogleFonts.manrope(
                        fontSize: 13.2,
                        fontWeight: FontWeight.w900,
                        color: _ink.withOpacity(0.86),
                      ),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: GoogleFonts.manrope(
                          fontSize: 12.6,
                          fontWeight: FontWeight.w800,
                          color: _ink.withOpacity(0.35),
                        ),
                        border: InputBorder.none,
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _saleToggle() {
    final r = BorderRadius.circular(999);
    final chip = _onSale ? const Color(0xFF2FB06B) : const Color(0xFF7A7A7A);

    return InkWell(
      borderRadius: r,
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _onSale = !_onSale);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: r,
          color: Colors.white.withOpacity(0.66),
          border: Border.all(color: _primary.withOpacity(0.10), width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_offer_rounded,
                size: 18, color: chip.withOpacity(0.95)),
            const SizedBox(width: 8),
            Text(
              _onSale ? "On Sale" : "No Sale",
              style: GoogleFonts.manrope(
                fontSize: 12.2,
                fontWeight: FontWeight.w900,
                color: _ink.withOpacity(0.80),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _variantsCard() {
    return _glassCard(
      child: Column(
        children: [
          ...List.generate(_variants.length, (i) {
            final v = _variants[i];
            return Padding(
              padding: EdgeInsets.only(bottom: i == _variants.length - 1 ? 0 : 10),
              child: Row(
                children: [
                  Expanded(
                    child: _miniField(
                      label: "Size",
                      value: v.size,
                      hint: "e.g. M",
                      icon: Icons.straighten_rounded,
                      onChanged: (x) => setState(() => v.size = x),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _miniField(
                      label: "Stock",
                      value: v.stock.toString(),
                      hint: "0",
                      icon: Icons.inventory_2_rounded,
                      keyboardType: TextInputType.number,
                      onChanged: (x) => setState(() => v.stock = int.tryParse(x) ?? 0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _removeVariant(i),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFFE04343).withOpacity(0.10),
                        border: Border.all(
                          color: const Color(0xFFE04343).withOpacity(0.22),
                          width: 1,
                        ),
                      ),
                      child: Icon(Icons.close_rounded,
                          size: 18, color: const Color(0xFFE04343).withOpacity(0.95)),
                    ),
                  )
                ],
              ),
            );
          }),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: _glassPill(text: "Add another size", onTap: _addVariant),
          ),
        ],
      ),
    );
  }

  Widget _miniField({
    required String label,
    required String value,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required ValueChanged<String> onChanged,
  }) {
    final r = BorderRadius.circular(18);
    final ctrl = TextEditingController(text: value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _subtle()),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: r,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: r,
                color: Colors.white.withOpacity(0.66),
                border: Border.all(color: _primary.withOpacity(0.10), width: 1.0),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Icon(icon, size: 18, color: _primary.withOpacity(0.78)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      keyboardType: keyboardType,
                      style: GoogleFonts.manrope(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w900,
                        color: _ink.withOpacity(0.86),
                      ),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: GoogleFonts.manrope(
                          fontSize: 12.4,
                          fontWeight: FontWeight.w800,
                          color: _ink.withOpacity(0.35),
                        ),
                        border: InputBorder.none,
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: onChanged,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sizeChartCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Attach size chart (optional)", style: _subtle()),
          const SizedBox(height: 10),

          // dropdown + create new
          Row(
            children: [
              Expanded(child: _chartDropdown()),
              const SizedBox(width: 10),
              _glassPill(text: "Create new", onTap: _openCreateSizeChart),
            ],
          ),

          const SizedBox(height: 10),
          Text(
            _selectedChartId == null
                ? "No size chart selected."
                : "Selected: ${_charts.firstWhere((c) => c.id == _selectedChartId).title}",
            style: GoogleFonts.manrope(
              fontSize: 12.2,
              fontWeight: FontWeight.w900,
              color: _ink.withOpacity(0.70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartDropdown() {
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
            child: DropdownButton<int?>(
              value: _selectedChartId,
              isExpanded: true,
              hint: Text(
                "Select size chart",
                style: GoogleFonts.manrope(
                  fontSize: 12.6,
                  fontWeight: FontWeight.w900,
                  color: _ink.withOpacity(0.42),
                ),
              ),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(
                    "None",
                    style: GoogleFonts.manrope(
                      fontSize: 12.8,
                      fontWeight: FontWeight.w900,
                      color: _ink.withOpacity(0.80),
                    ),
                  ),
                ),
                ..._charts.map((c) {
                  return DropdownMenuItem<int?>(
                    value: c.id,
                    child: Text(
                      c.title,
                      style: GoogleFonts.manrope(
                        fontSize: 12.8,
                        fontWeight: FontWeight.w900,
                        color: _ink.withOpacity(0.80),
                      ),
                    ),
                  );
                }).toList(),
              ],
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _selectedChartId = v);
              },
            ),
          ),
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
          color: filled ? null : Colors.white.withOpacity(0.66),
          border: Border.all(
            color:
            filled ? Colors.white.withOpacity(0.18) : _primary.withOpacity(0.14),
            width: 1.1,
          ),
          boxShadow: filled
              ? [
            BoxShadow(
              color: _secondary.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            )
          ]
              : null,
        ),
        child: Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 12.0,
            fontWeight: FontWeight.w900,
            color: filled ? Colors.white.withOpacity(0.95) : _ink.withOpacity(0.80),
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

class _VariantRow {
  String size;
  int stock;
  _VariantRow({required this.size, required this.stock});
}

class _SizeChartLite {
  final int id;
  final String title;
  const _SizeChartLite({required this.id, required this.title});
}
