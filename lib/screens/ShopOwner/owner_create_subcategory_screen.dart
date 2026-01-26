import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'owner_create_category_screen.dart';

class OwnerCreateSubCategoryScreen extends StatefulWidget {
  /// ✅ shop-owner user id (same as your shop id concept)
  final int shopOwnerUserId;

  /// ✅ top-level parents only: [{"id":1,"name":"Men"}, ...]
  final List<Map<String, dynamic>> parents;

  const OwnerCreateSubCategoryScreen({
    super.key,
    required this.shopOwnerUserId,
    required this.parents,
  });

  @override
  State<OwnerCreateSubCategoryScreen> createState() => _OwnerCreateSubCategoryScreenState();
}

class _OwnerCreateSubCategoryScreenState extends State<OwnerCreateSubCategoryScreen> {
  static const String _baseUrl = "http://31.97.190.216:10050";

  static const _primary = Color(0xFF440C08);
  static const _secondary = Color(0xFF750A03);
  static const _ink = Color(0xFF140504);

  final _nameCtrl = TextEditingController();

  bool _saving = false;

  /// ✅ NEW fields (your error was because these didn't exist)
  bool _hasParent = true;
  int? _selectedParentId;

  Uri _createSubUri() => Uri.parse(
    "$_baseUrl/shop-owner/shops/${widget.shopOwnerUserId}/sub-categories",
  );

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: GoogleFonts.manrope(fontWeight: FontWeight.w800))),
    );
  }

  Future<void> _createParentInline() async {
    HapticFeedback.selectionClick();

    final created = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerCreateCategoryScreen(shopId: widget.shopOwnerUserId),
      ),
    );

    if (created == null) return;

    // created = {"id":..., "name":...}
    if (!mounted) return;
    setState(() {
      _hasParent = true;
      _selectedParentId = (created["id"] as num).toInt();
    });

    _toast("✅ Parent created & selected");
  }

  Future<void> _save() async {
    if (_saving) return;

    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return _toast("Please enter sub-category name.");

    if (_hasParent && _selectedParentId == null) {
      return _toast("Please select a parent category (or turn off Has Parent).");
    }

    try {
      setState(() => _saving = true);
      HapticFeedback.mediumImpact();

      final payload = {
        "name": name,
        "has_parent": _hasParent ? 1 : 0,
        "parent_category_id": _hasParent ? _selectedParentId : null,
      };

      final res = await http
          .post(
        _createSubUri(),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      )
          .timeout(const Duration(seconds: 15));

      Map<String, dynamic> decoded = {};
      try {
        decoded = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {}

      if (res.statusCode != 201) {
        _toast((decoded["error"] ?? "Failed").toString());
        setState(() => _saving = false);
        return;
      }

      if (!mounted) return;
      _toast("✅ Saved");
      Navigator.pop(context, decoded["data"]); // {id,name,parent_id}
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _toast("❌ Error: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // default select first parent if exists
    if (widget.parents.isNotEmpty) {
      _selectedParentId = (widget.parents.first["id"] as num).toInt();
    } else {
      _hasParent = false;
      _selectedParentId = null;
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
                        Icon(Icons.account_tree_rounded, color: _primary.withOpacity(0.85)),
                        const SizedBox(width: 10),
                        Text(
                          "Create Sub Category",
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

                    Text(
                      "Sub category name",
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.6,
                        color: _ink.withOpacity(0.55),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameCtrl,
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: _ink.withOpacity(0.86)),
                      decoration: InputDecoration(
                        hintText: "e.g. Oversized",
                        hintStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: _ink.withOpacity(0.35)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: _primary.withOpacity(0.12)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: _primary.withOpacity(0.12)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ✅ Has Parent Toggle
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Has Parent Category?",
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w900,
                              color: _ink.withOpacity(0.82),
                            ),
                          ),
                        ),
                        Switch(
                          value: _hasParent,
                          onChanged: (v) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _hasParent = v;
                              if (!_hasParent) _selectedParentId = null;
                              if (_hasParent && _selectedParentId == null && widget.parents.isNotEmpty) {
                                _selectedParentId = (widget.parents.first["id"] as num).toInt();
                              }
                            });
                          },
                        )
                      ],
                    ),

                    if (_hasParent) ...[
                      const SizedBox(height: 8),
                      _parentDropdown(),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _pill("Create Parent", _createParentInline),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.parents.isEmpty ? "No parents yet. Create one." : "Select from existing parents.",
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w800,
                                fontSize: 12.2,
                                color: _ink.withOpacity(0.55),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 6),
                      Text(
                        "This will be created as a top-level Category (no parent).",
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.2,
                          color: _ink.withOpacity(0.55),
                        ),
                      ),
                    ],

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
                            _saving ? "Saving..." : "Save",
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w900,
                              color: Colors.white.withOpacity(0.95),
                            ),
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

  Widget _pill(String text, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.white.withOpacity(0.66),
          border: Border.all(color: _primary.withOpacity(0.14), width: 1.1),
        ),
        child: Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 12.0,
            fontWeight: FontWeight.w900,
            color: _ink.withOpacity(0.80),
          ),
        ),
      ),
    );
  }

  Widget _parentDropdown() {
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
            border: Border.all(color: _primary.withOpacity(0.12), width: 1.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: _selectedParentId,
              isExpanded: true,
              hint: Text(
                "Select parent category",
                style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: _ink.withOpacity(0.42)),
              ),
              items: widget.parents.map((p) {
                final id = (p["id"] as num).toInt();
                final name = (p["name"] ?? "").toString();
                return DropdownMenuItem<int?>(
                  value: id,
                  child: Text(
                    name,
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: _ink.withOpacity(0.82)),
                  ),
                );
              }).toList(),
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _selectedParentId = v);
              },
            ),
          ),
        ),
      ),
    );
  }
}
