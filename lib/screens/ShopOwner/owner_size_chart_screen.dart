// lib/screens/ShopOwner/owner_size_chart_screen.dart
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

/// ✅ Create / Edit Size Chart Screen (FULLY DYNAMIC)
/// Backend:
///   GET  /shop-owner/shops/<shopId>/products/<productId>/size-chart
///   POST /shop-owner/shops/<shopId>/products/<productId>/size-chart  (upsert)
///
/// Saves into:
///   size_charts(product_id,title,unit)
///   size_chart_rows(size_chart_id,size,chest,waist,length,shoulder,sort_order)
class OwnerSizeChartScreen extends StatefulWidget {
  final int ownerUserId;
  final int shopId;

  const OwnerSizeChartScreen({
    super.key,
    required this.ownerUserId,
    required this.shopId,
  });

  @override
  State<OwnerSizeChartScreen> createState() => _OwnerSizeChartScreenState();
}

class _OwnerSizeChartScreenState extends State<OwnerSizeChartScreen>
    with TickerProviderStateMixin {
  // ✅ Update if you use localhost on emulator:
  // Android emulator: http://10.0.2.2:10050
  // iOS simulator:    http://127.0.0.1:10050
  static const String _baseUrl = "http://31.97.190.216:10050";

  static const _primary = Color(0xFF440C08);
  static const _secondary = Color(0xFF750A03);
  static const _other = Color(0xFF9B0F03);
  static const _ink = Color(0xFF140504);

  late final AnimationController _ambientCtrl;

  final _titleCtrl = TextEditingController(text: "New Size Chart");
  String _unit = "cm";

  final List<_ChartRow> _rows = [
    _ChartRow(size: "S", chest: 48, waist: 40, length: 68, shoulder: 42),
    _ChartRow(size: "M", chest: 52, waist: 44, length: 70, shoulder: 44),
  ];

  bool _loading = true;
  bool _saving = false;
  int? _chartId; // returned by backend (size_charts.id)

  @override
  void initState() {
    super.initState();
    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat(reverse: true);

    _fetchExisting();
  }

  @override
  void dispose() {
    _ambientCtrl.dispose();
    _titleCtrl.dispose();
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

  Uri _getUri() => Uri.parse(
    "$_baseUrl/shop-owner/shops/${widget.ownerUserId}/size-charts",
  );


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

  Future<void> _fetchExisting() async {
    try {
      if (mounted) setState(() => _loading = true);

      final res = await http.get(_getUri()).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        setState(() => _loading = false);
        return;
      }

      final list = jsonDecode(res.body)["data"] as List;

      if (list.isEmpty) {
        setState(() => _loading = false);
        return;
      }

      // Load first chart for demo (you can later make selector screen)
      final data = list.first as Map<String, dynamic>;

      final rowsRaw = (data["rows"] as List? ?? []);
      final parsedRows = rowsRaw.map((r) {
        final m = r as Map<String, dynamic>;
        return _ChartRow(
          size: (m["size"] ?? "").toString(),
          chest: _toDouble(m["chest"]),
          waist: _toDouble(m["waist"]),
          length: _toDouble(m["length"]),
          shoulder: _toDouble(m["shoulder"]),
        );
      }).toList();

      setState(() {
        _chartId = data["id"];
        _titleCtrl.text = data["title"] ?? "New Size Chart";
        _unit = data["unit"] ?? "cm";
        _rows
          ..clear()
          ..addAll(parsedRows);
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }


  void _addRow() {
    HapticFeedback.selectionClick();
    setState(() => _rows.add(
      _ChartRow(
        size: "",
        chest: null,
        waist: null,
        length: null,
        shoulder: null,
      ),
    ));
  }

  void _removeRow(int idx) {
    HapticFeedback.lightImpact();
    setState(() => _rows.removeAt(idx));
  }

  Future<void> _saveChart() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      _toast("Please enter chart title.");
      return;
    }

    final validRows = _rows.where((r) => r.size.trim().isNotEmpty).toList();
    if (validRows.isEmpty) {
      _toast("Add at least one size row.");
      return;
    }

    final payload = {
      "chart_id": _chartId, // for update
      "title": title,
      "unit": _unit,
      "rows": validRows.map((r) => r.toJson()).toList(),
      "owner_user_id": widget.ownerUserId,
    };

    try {
      setState(() => _saving = true);

      final res = await http.post(
        _getUri(),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      final j = jsonDecode(res.body);
      _chartId = j["data"]["id"];

      setState(() => _saving = false);

      Navigator.pop(
        context,
        _SizeChartLite(
          id: _chartId!,
          title: "$title ($_unit)",
        ),
      );
    } catch (e) {
      setState(() => _saving = false);
      _toast("Error: $e");
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

        return Scaffold(
          backgroundColor: const Color(0xFFF9F6F5),
          body: Stack(
            children: [
              Positioned(
                right: -90 - float * 10,
                top: 80 + float * 6,
                child: _GlowBlob(
                  color: _secondary.withOpacity(0.12),
                  size: 240,
                ),
              ),
              Positioned(
                left: -90 + float * 10,
                top: 250 - float * 6,
                child: _GlowBlob(
                  color: _other.withOpacity(0.10),
                  size: 260,
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _topBar(),
                      const SizedBox(height: 12),
                      if (_loading) ...[
                        _glassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Loading size chart...", style: _subtle()),
                              const SizedBox(height: 10),
                              LinearProgressIndicator(
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(999),
                                backgroundColor: _primary.withOpacity(0.08),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _secondary.withOpacity(0.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _sectionHeader(
                        "Chart Info",
                        "Title + unit (cm/in)",
                        Icons.table_chart_rounded,
                      ),
                      const SizedBox(height: 12),
                      _glassCard(
                        child: Column(
                          children: [
                            _field(
                              label: "Chart title",
                              controller: _titleCtrl,
                              hint: "e.g. Men T-Shirt",
                              icon: Icons.title_rounded,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: _unitPicker()),
                                const SizedBox(width: 10),
                                _glassPill(text: "Add row", onTap: _addRow),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _chartId == null
                                        ? "New size chart"
                                        : "Editing chart #$_chartId",
                                    style: _subtle(),
                                  ),
                                ),
                                _glassPill(
                                  text: "Refresh",
                                  onTap: _fetchExisting,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _sectionHeader(
                        "Rows",
                        "Size + measurements",
                        Icons.view_list_rounded,
                      ),
                      const SizedBox(height: 12),
                      Expanded(child: _rowsList()),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _glassPill(
                              text: _saving ? "Saving..." : "Save Size Chart",
                              onTap: _saving ? () {} : _saveChart,
                              filled: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _glassPill(
                            text: "Cancel",
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
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
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 1.1,
            ),
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
                    color: Colors.white.withOpacity(0.25),
                    width: 1.0,
                  ),
                ),
                child: Icon(
                  Icons.straighten_rounded,
                  color: Colors.white.withOpacity(0.92),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Size Chart",
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
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _unitPicker() {
    final r = BorderRadius.circular(18);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Unit", style: _subtle()),
        const SizedBox(height: 6),
        ClipRRect(
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
                child: DropdownButton<String>(
                  value: _unit,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: "cm", child: Text("cm")),
                    DropdownMenuItem(value: "in", child: Text("in")),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    HapticFeedback.selectionClick();
                    setState(() => _unit = v);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _rowsList() {
    return _glassCard(
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: _rows.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final r = _rows[i];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _miniField(
                      label: "Size",
                      value: r.size,
                      hint: "S / M / L",
                      icon: Icons.straighten_rounded,
                      onChanged: (x) => setState(() => r.size = x),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _removeRow(i),
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
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: const Color(0xFFE04343).withOpacity(0.95),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _miniField(
                      label: "Chest",
                      value: _numStr(r.chest),
                      hint: "—",
                      icon: Icons.crop_free_rounded,
                      keyboardType: TextInputType.number,
                      onChanged: (x) => setState(() => r.chest = double.tryParse(x)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _miniField(
                      label: "Waist",
                      value: _numStr(r.waist),
                      hint: "—",
                      icon: Icons.crop_free_rounded,
                      keyboardType: TextInputType.number,
                      onChanged: (x) => setState(() => r.waist = double.tryParse(x)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _miniField(
                      label: "Length",
                      value: _numStr(r.length),
                      hint: "—",
                      icon: Icons.swap_vert_rounded,
                      keyboardType: TextInputType.number,
                      onChanged: (x) => setState(() => r.length = double.tryParse(x)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _miniField(
                      label: "Shoulder",
                      value: _numStr(r.shoulder),
                      hint: "—",
                      icon: Icons.swap_horiz_rounded,
                      keyboardType: TextInputType.number,
                      onChanged: (x) => setState(() => r.shoulder = double.tryParse(x)),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _numStr(double? v) => v == null
      ? ""
      : (v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1));

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
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
            color: filled
                ? Colors.white.withOpacity(0.18)
                : _primary.withOpacity(0.14),
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
            color: filled
                ? Colors.white.withOpacity(0.95)
                : _ink.withOpacity(0.80),
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

class _ChartRow {
  String size;
  double? chest;
  double? waist;
  double? length;
  double? shoulder;

  _ChartRow({
    required this.size,
    required this.chest,
    required this.waist,
    required this.length,
    required this.shoulder,
  });

  Map<String, dynamic> toJson() => {
    "size": size.trim(),
    "chest": chest,
    "waist": waist,
    "length": length,
    "shoulder": shoulder,
  };
}

/// Returned to product screen
class _SizeChartLite {
  final int id;
  final String title;
  const _SizeChartLite({required this.id, required this.title});
}
