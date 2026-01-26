import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class OwnerCreateCategoryScreen extends StatefulWidget {
  final int shopId;
  const OwnerCreateCategoryScreen({super.key, required this.shopId});

  @override
  State<OwnerCreateCategoryScreen> createState() => _OwnerCreateCategoryScreenState();
}

class _OwnerCreateCategoryScreenState extends State<OwnerCreateCategoryScreen> {
  static const String _baseUrl = "http://31.97.190.216:10050";

  static const _primary = Color(0xFF440C08);
  static const _secondary = Color(0xFF750A03);
  static const _ink = Color(0xFF140504);

  final _nameCtrl = TextEditingController();
  bool _saving = false;

  Uri _createCategoryUri() => Uri.parse("$_baseUrl/shop-owner/shops/${widget.shopId}/categories");

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: GoogleFonts.manrope(fontWeight: FontWeight.w800))),
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return _toast("Please enter category name.");

    try {
      setState(() => _saving = true);
      HapticFeedback.mediumImpact();

      final res = await http
          .post(
        _createCategoryUri(),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name}),
      )
          .timeout(const Duration(seconds: 15));

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 201) {
        _toast((decoded["error"] ?? "Failed").toString());
        setState(() => _saving = false);
        return;
      }

      if (!mounted) return;
      _toast("✅ Category created");
      Navigator.pop(context, decoded["data"]); // return created {id,name}
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _toast("❌ Error: $e");
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(22);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: ClipRRect(
            borderRadius: r,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: r,
                  color: Colors.white.withOpacity(0.78),
                  border: Border.all(color: Colors.white.withOpacity(0.86), width: 1.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 26,
                      offset: const Offset(0, 14),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.category_rounded, color: _primary.withOpacity(0.85)),
                        const SizedBox(width: 10),
                        Text(
                          "Create Category",
                          style: GoogleFonts.manrope(
                            fontSize: 16.2,
                            fontWeight: FontWeight.w900,
                            color: _ink.withOpacity(0.92),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Back", style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text("Category name", style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 12.6, color: _ink.withOpacity(0.55))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameCtrl,
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: _ink.withOpacity(0.86)),
                      decoration: InputDecoration(
                        hintText: "e.g. Hoodies",
                        hintStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: _ink.withOpacity(0.35)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.7),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: _primary.withOpacity(0.12))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: _primary.withOpacity(0.12))),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: _saving ? () {} : _save,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_secondary.withOpacity(0.95), _primary.withOpacity(0.95)],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _saving ? "Saving..." : "Save Category",
                            style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.95)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
