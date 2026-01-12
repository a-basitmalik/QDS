import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';
import '../../theme/app_widgets.dart';

/// ✅ ArticlesScreen (content-only)
/// - Add / Edit / Delete articles
/// - Search
/// - Low stock badge
/// - ✅ Image picker (web + mobile) using image_picker -> stores bytes (Uint8List)
class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  final List<Article> _articles = [
    Article(id: "A1", name: "Black T-Shirt", price: 1299, qty: 24),
    Article(id: "A2", name: "Light Blue Shirt", price: 2199, qty: 8),
    Article(id: "A3", name: "Formal Pants", price: 2499, qty: 3),
    Article(id: "A4", name: "Hoodie", price: 2799, qty: 16),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Article> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _articles;
    return _articles.where((a) => a.name.toLowerCase().contains(q)).toList();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _openAdd() async {
    HapticFeedback.selectionClick();
    final created = await showModalBottomSheet<Article>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (_) => const ArticleEditorSheet(title: "Add Article"),
    );

    if (created == null) return;

    setState(() => _articles.insert(0, created));
    _toast("Article added: ${created.name}");
  }

  Future<void> _openEdit(Article a) async {
    HapticFeedback.selectionClick();
    final updated = await showModalBottomSheet<Article>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (_) => ArticleEditorSheet(
        title: "Edit Article",
        initial: a,
      ),
    );

    if (updated == null) return;

    setState(() {
      final idx = _articles.indexWhere((x) => x.id == a.id);
      if (idx != -1) _articles[idx] = updated;
    });
    _toast("Updated: ${updated.name}");
  }

  Future<void> _confirmDelete(Article a) async {
    HapticFeedback.selectionClick();
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Glass(
            borderRadius: AppRadius.r24,
            sigmaX: 22,
            sigmaY: 22,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            color: Colors.white.withOpacity(0.86),
            borderColor: Colors.white.withOpacity(0.92),
            shadows: AppShadows.shadowLg,
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Delete article?", style: AppText.h2()),
                  const SizedBox(height: 8),
                  Text(
                    "Delete “${a.name}”? This cannot be undone.",
                    style: AppText.body(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: PressScale(
                          borderRadius: AppRadius.pill(),
                          onTap: () => Navigator.pop(context, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.62),
                              borderRadius: AppRadius.pill(),
                              border: Border.all(
                                color: AppColors.divider.withOpacity(0.55),
                                width: 1.05,
                              ),
                            ),
                            child: Center(
                              child: Text("Cancel", style: AppText.button()),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: PressScale(
                          borderRadius: AppRadius.pill(),
                          onTap: () => Navigator.pop(context, true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.danger,
                                  AppColors.danger.withOpacity(0.88),
                                ],
                              ),
                              borderRadius: AppRadius.pill(),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                                width: 1.1,
                              ),
                              boxShadow: AppShadows.soft,
                            ),
                            child: Center(
                              child: Text(
                                "Delete",
                                style: AppText.button().copyWith(
                                  color: Colors.white.withOpacity(0.95),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ) ??
        false;

    if (!ok) return;

    setState(() => _articles.removeWhere((x) => x.id == a.id));
    _toast("Deleted: ${a.name}");
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Column(
      children: [
        // Header
        Glass(
          borderRadius: AppRadius.r22,
          sigmaX: 18,
          sigmaY: 18,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          color: Colors.white.withOpacity(0.72),
          borderColor: Colors.white.withOpacity(0.86),
          shadows: AppShadows.soft,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.brandLinear,
                  borderRadius: AppRadius.r16,
                  boxShadow: AppShadows.soft,
                ),
                child: Icon(Icons.inventory_2_rounded,
                    color: Colors.white.withOpacity(0.96)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Articles / Inventory", style: AppText.h2()),
                    const SizedBox(height: 4),
                    Text("Add & edit products (price, stock, image).",
                        style: AppText.subtle()),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.pill(),
                  color: Colors.white.withOpacity(0.68),
                  border: Border.all(
                    color: AppColors.divider.withOpacity(0.55),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  "${_articles.length}",
                  style: AppText.kicker().copyWith(
                    color: AppColors.ink.withOpacity(0.72),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Search + Add
        Glass(
          borderRadius: AppRadius.r22,
          sigmaX: 18,
          sigmaY: 18,
          padding: const EdgeInsets.all(12),
          color: Colors.white.withOpacity(0.70),
          borderColor: Colors.white.withOpacity(0.86),
          shadows: AppShadows.soft,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.pill(),
                    color: Colors.white.withOpacity(0.62),
                    border: Border.all(
                      color: AppColors.divider.withOpacity(0.50),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded,
                          size: 18, color: AppColors.ink.withOpacity(0.55)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (_) => setState(() {}),
                          style: AppText.body(),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: "Search articles…",
                            hintStyle: AppText.subtle(),
                          ),
                        ),
                      ),
                      if (_searchCtrl.text.trim().isNotEmpty)
                        PressScale(
                          borderRadius: AppRadius.pill(),
                          downScale: 0.97,
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              borderRadius: AppRadius.pill(),
                              color: Colors.white.withOpacity(0.55),
                              border: Border.all(
                                color: AppColors.divider.withOpacity(0.45),
                                width: 1.0,
                              ),
                            ),
                            child: Icon(Icons.close_rounded,
                                size: 16,
                                color: AppColors.ink.withOpacity(0.62)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              BrandButton(
                text: "Add",
                onTap: _openAdd,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // List
        Expanded(
          child: Glass(
            borderRadius: AppRadius.r24,
            sigmaX: 18,
            sigmaY: 18,
            padding: const EdgeInsets.all(14),
            color: Colors.white.withOpacity(0.66),
            borderColor: Colors.white.withOpacity(0.84),
            shadows: AppShadows.shadowLg,
            child: list.isEmpty
                ? Center(child: Text("No articles found", style: AppText.h3()))
                : ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final a = list[i];
                return _ArticleCard(
                  article: a,
                  onEdit: () => _openEdit(a),
                  onDelete: () => _confirmDelete(a),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ArticleCard({
    required this.article,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final low = article.qty <= 5;

    return Glass(
      borderRadius: AppRadius.r22,
      sigmaX: 18,
      sigmaY: 18,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      color: Colors.white.withOpacity(0.72),
      borderColor: Colors.white.withOpacity(0.86),
      shadows: AppShadows.soft,
      child: Row(
        children: [
          // Image
          _ArticleThumb(bytes: article.imageBytes),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.name, style: AppText.h3()),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Chip(text: "Rs ${article.price.toStringAsFixed(0)}"),
                    const SizedBox(width: 8),
                    _Chip(text: "Qty ${article.qty}"),
                    const SizedBox(width: 8),
                    if (low)
                      _Chip(
                        text: "Low",
                        tint: AppColors.warning,
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Actions
          PressScale(
            borderRadius: AppRadius.pill(),
            downScale: 0.97,
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.62),
                borderRadius: AppRadius.pill(),
                border: Border.all(
                  color: AppColors.divider.withOpacity(0.55),
                  width: 1.05,
                ),
              ),
              child: Icon(Icons.edit_rounded,
                  size: 18.5, color: AppColors.ink.withOpacity(0.75)),
            ),
          ),
          const SizedBox(width: 8),
          PressScale(
            borderRadius: AppRadius.pill(),
            downScale: 0.97,
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.62),
                borderRadius: AppRadius.pill(),
                border: Border.all(
                  color: AppColors.danger.withOpacity(0.25),
                  width: 1.05,
                ),
              ),
              child: Icon(Icons.delete_rounded,
                  size: 18.5, color: AppColors.danger.withOpacity(0.90)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleThumb extends StatelessWidget {
  final Uint8List? bytes;
  const _ArticleThumb({required this.bytes});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.r16,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.16),
              AppColors.secondary.withOpacity(0.10),
            ],
          ),
          borderRadius: AppRadius.r16,
          border: Border.all(color: Colors.white.withOpacity(0.62), width: 1.0),
        ),
        child: bytes == null
            ? Icon(Icons.image_rounded, color: AppColors.ink.withOpacity(0.55))
            : Image.memory(bytes!, fit: BoxFit.cover),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color? tint;

  const _Chip({required this.text, this.tint});

  @override
  Widget build(BuildContext context) {
    final c = tint ?? AppColors.ink;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: AppRadius.pill(),
        color: (tint == null
            ? Colors.white.withOpacity(0.60)
            : c.withOpacity(0.12)),
        border: Border.all(
          color: (tint == null
              ? AppColors.divider.withOpacity(0.48)
              : c.withOpacity(0.22)),
          width: 1.0,
        ),
      ),
      child: Text(
        text,
        style: AppText.kicker().copyWith(
          color: tint == null ? AppColors.ink.withOpacity(0.72) : c,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

/// ✅ BottomSheet editor with IMAGE PICKER
class ArticleEditorSheet extends StatefulWidget {
  final String title;
  final Article? initial;

  const ArticleEditorSheet({super.key, required this.title, this.initial});

  @override
  State<ArticleEditorSheet> createState() => _ArticleEditorSheetState();
}

class _ArticleEditorSheetState extends State<ArticleEditorSheet> {
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _qty;

  Uint8List? _imageBytes;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name ?? "");
    _price = TextEditingController(
      text: widget.initial == null ? "" : widget.initial!.price.toStringAsFixed(0),
    );
    _qty = TextEditingController(
      text: widget.initial == null ? "" : widget.initial!.qty.toString(),
    );
    _imageBytes = widget.initial?.imageBytes;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _qty.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    HapticFeedback.selectionClick();
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 1400,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes = bytes);
    } catch (_) {
      // ignore; you can toast if you want
    }
  }

  void _removeImage() {
    HapticFeedback.selectionClick();
    setState(() => _imageBytes = null);
  }

  Article _buildResult() {
    final id = widget.initial?.id ?? "A${DateTime.now().millisecondsSinceEpoch}";
    final name = _name.text.trim();
    final price = double.tryParse(_price.text.trim()) ?? 0;
    final qty = int.tryParse(_qty.text.trim()) ?? 0;

    return Article(
      id: id,
      name: name.isEmpty ? "Untitled" : name,
      price: price,
      qty: qty,
      imageBytes: _imageBytes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPad),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          child: Glass(
            borderRadius: AppRadius.r24,
            sigmaX: 22,
            sigmaY: 22,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            color: Colors.white.withOpacity(0.86),
            borderColor: Colors.white.withOpacity(0.92),
            shadows: AppShadows.shadowLg,
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: AppText.h2()),
                  const SizedBox(height: 12),

                  // Image picker row
                  Text("Picture", style: AppText.kicker()),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: AppRadius.r18,
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.62),
                            borderRadius: AppRadius.r18,
                            border: Border.all(
                              color: AppColors.divider.withOpacity(0.50),
                              width: 1.0,
                            ),
                          ),
                          child: _imageBytes == null
                              ? Icon(Icons.image_rounded,
                              color: AppColors.ink.withOpacity(0.55))
                              : Image.memory(_imageBytes!, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: [
                            BrandButton(
                              text: _imageBytes == null ? "Choose Image" : "Change Image",
                              onTap: _pickImage,
                            ),
                            const SizedBox(height: 8),
                            if (_imageBytes != null)
                              PressScale(
                                borderRadius: AppRadius.pill(),
                                onTap: _removeImage,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.62),
                                    borderRadius: AppRadius.pill(),
                                    border: Border.all(
                                      color: AppColors.danger.withOpacity(0.25),
                                      width: 1.05,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Remove",
                                      style: AppText.button().copyWith(
                                        color: AppColors.danger.withOpacity(0.92),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _Field(label: "Name", controller: _name, hint: "e.g. Black T-Shirt"),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          label: "Price (Rs)",
                          controller: _price,
                          hint: "1299",
                          keyboard: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Field(
                          label: "Quantity",
                          controller: _qty,
                          hint: "20",
                          keyboard: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: PressScale(
                          borderRadius: AppRadius.pill(),
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.62),
                              borderRadius: AppRadius.pill(),
                              border: Border.all(
                                color: AppColors.divider.withOpacity(0.55),
                                width: 1.05,
                              ),
                            ),
                            child: Center(
                              child: Text("Cancel", style: AppText.button()),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: BrandButton(
                          text: "Save",
                          onTap: () => Navigator.pop(context, _buildResult()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboard;

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.kicker()),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: AppRadius.r18,
            color: Colors.white.withOpacity(0.62),
            border: Border.all(
              color: AppColors.divider.withOpacity(0.50),
              width: 1.0,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            style: AppText.body(),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: AppText.subtle(),
            ),
          ),
        ),
      ],
    );
  }
}

/// ✅ Public article model (so you can reuse later easily)
class Article {
  final String id;
  final String name;
  final double price;
  final int qty;
  final Uint8List? imageBytes;

  Article({
    required this.id,
    required this.name,
    required this.price,
    required this.qty,
    this.imageBytes,
  });
}
