import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text.dart';

class ShopListingScreen extends StatelessWidget {
  final String category;

  const ShopListingScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _appBar(context),
      body: Column(
        children: [
          _sortBar(context),
          Expanded(child: _list()),
        ],
      ),
    );
  }

  // ───────────────────── AppBar ─────────────────────

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.white,
      title: Text(
        category,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.tune_rounded),
          splashRadius: 22,
          onPressed: () => _openFilters(context),
        ),
      ],
    );
  }

  // ───────────────────── Sort Bar ─────────────────────

  Widget _sortBar(BuildContext context) {
    final sorts = [
      "Nearest",
      "Fastest",
      "Popular",
    ];

    return SizedBox(
      height: 54,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: sorts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final active = i == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AppColors.textDark : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r22),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              sorts[i],
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: active ? Colors.white : AppColors.textDark,
              ),
            ),
          );
        },
      ),
    );
  }

  // ───────────────────── List ─────────────────────

  Widget _list() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => _shopCard(),
    );
  }

  Widget _shopCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r18),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.softCard,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.chipFill,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.store_mall_directory_outlined),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Urban Style Store",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "1.2 km • 25–35 min",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMid,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      "4.8",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Open now",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }

  // ───────────────────── Filters ─────────────────────

  void _openFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _FiltersSheet(),
    );
  }
}

// ───────────────────── Filters Sheet ─────────────────────

class _FiltersSheet extends StatelessWidget {
  const _FiltersSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _handle(),
          const SizedBox(height: 18),

          _title("Filters"),

          _section("Distance"),
          _chips(["< 2 km", "2–5 km", "5+ km"]),

          _section("Rating"),
          _chips(["4★+", "3★+", "All"]),

          _section("Price range"),
          _chips(["₨", "₨₨", "₨₨₨"]),

          const SizedBox(height: 10),

          _toggle("Open now"),

          const SizedBox(height: 20),

          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r22),
                ),
              ),
              child: const Text(
                "Apply filters",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _handle() {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  Widget _title(String text) {
    return Text(
      text,
      style: AppText.h18,
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.textMid,
        ),
      ),
    );
  }

  Widget _chips(List<String> items) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((e) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.r22),
            border: Border.all(color: AppColors.divider),
          ),
          child: Text(
            e,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _toggle(String label) {
    return Row(
      children: [
        Switch(value: true, onChanged: (_) {}),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
