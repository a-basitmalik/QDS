import 'package:flutter/material.dart';

enum DayType {
  office,
  university,
  party,
  dayOut,
  casualHome,
  casual, // ✅ exists to avoid switch exhaustiveness errors
  rainy,
  winter,
  summer,
  custom,
}

enum WardrobeCategory {
  shirts,
  pants,
  shoes,
  jackets,
  watches,
  glasses,
  accessories,
}

enum WardrobeStyle {
  formal,
  semiFormal,
  casual,
  street,
  sporty,
}

/// Single wardrobe item (mutable availability because you toggle it in UI)
class WardrobeItem {
  final String id;
  final String name;

  final WardrobeCategory category;

  final Color color;
  final String colorName;

  final WardrobeStyle style;

  /// Which day types this item fits
  final List<DayType> tags;

  bool available;

  WardrobeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.colorName,
    required this.style,
    required this.tags,
    this.available = true,
  });

  /// handy for demo/clone flows
  WardrobeItem copy() => WardrobeItem(
    id: id,
    name: name,
    category: category,
    color: color,
    colorName: colorName,
    style: style,
    tags: List<DayType>.from(tags),
    available: available,
  );
}

/// Outfit output model
class OutfitOption {
  final WardrobeItem top;
  final WardrobeItem bottom;
  final WardrobeItem shoes;

  final WardrobeItem? jacket;
  final WardrobeItem? watch;
  final WardrobeItem? glasses;
  final List<WardrobeItem> accessories;

  final String explanation;

  OutfitOption({
    required this.top,
    required this.bottom,
    required this.shoes,
    this.jacket,
    this.watch,
    this.glasses,
    this.accessories = const [],
    this.explanation = "",
  });
}

// ───────────────────────── Helpers used in UI ─────────────────────────

String dayTypeTitle(DayType d) {
  switch (d) {
    case DayType.office:
      return "Office Day";
    case DayType.university:
      return "University Day";
    case DayType.party:
      return "Party / Event";
    case DayType.dayOut:
      return "Day Out";
    case DayType.casualHome:
      return "Casual / Home";
    case DayType.casual:
      return "Casual";
    case DayType.rainy:
      return "Rainy Day";
    case DayType.winter:
      return "Winter Day";
    case DayType.summer:
      return "Summer Day";
    case DayType.custom:
      return "Custom";
  }
}

String dayTypeEmoji(DayType d) {
  switch (d) {
    case DayType.office:
      return "🏢";
    case DayType.university:
      return "🎓";
    case DayType.party:
      return "🎉";
    case DayType.dayOut:
      return "🌇";
    case DayType.casualHome:
      return "🧘";
    case DayType.casual:
      return "🙂";
    case DayType.rainy:
      return "🌧️";
    case DayType.winter:
      return "❄️";
    case DayType.summer:
      return "🌞";
    case DayType.custom:
      return "➕";
  }
}

String catTitle(WardrobeCategory c) {
  switch (c) {
    case WardrobeCategory.shirts:
      return "Tops";
    case WardrobeCategory.pants:
      return "Bottoms";
    case WardrobeCategory.shoes:
      return "Shoes";
    case WardrobeCategory.jackets:
      return "Jackets";
    case WardrobeCategory.watches:
      return "Watches";
    case WardrobeCategory.glasses:
      return "Glasses";
    case WardrobeCategory.accessories:
      return "Accessories";
  }
}

IconData catIcon(WardrobeCategory c) {
  switch (c) {
    case WardrobeCategory.shirts:
      return Icons.checkroom_rounded;
    case WardrobeCategory.pants:
      return Icons.shopping_bag_rounded;
    case WardrobeCategory.shoes:
      return Icons.directions_walk_rounded;
    case WardrobeCategory.jackets:
      return Icons.umbrella_rounded;
    case WardrobeCategory.watches:
      return Icons.watch_rounded;
    case WardrobeCategory.glasses:
      return Icons.visibility_rounded;
    case WardrobeCategory.accessories:
      return Icons.auto_awesome_rounded;
  }
}

String styleLabel(WardrobeStyle s) {
  switch (s) {
    case WardrobeStyle.formal:
      return "Formal";
    case WardrobeStyle.semiFormal:
      return "Semi-Formal";
    case WardrobeStyle.casual:
      return "Casual";
    case WardrobeStyle.street:
      return "Street";
    case WardrobeStyle.sporty:
      return "Sporty";
  }
}
