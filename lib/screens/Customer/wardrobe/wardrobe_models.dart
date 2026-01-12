import 'package:flutter/material.dart';

/// ✅ Day / Event types used by generator & UI
enum DayType {
  university,
  office,
  daily,
  home,
  party,
  function,
  marriage,
  rainy,
  winter,
  summer,
  custom,
}

/// ✅ Categories you asked for (plus "others")
enum WardrobeCategory {
  shalwarKameez,
  pants,
  shirts,
  kurtas,
  pajamas,
  bridalwear,
  others,
}

/// ✅ Styles (optional but useful for better generation)
enum WardrobeStyle {
  casual,
  semiFormal,
  formal,
  traditional,
  bridal,
}

class WardrobeItem {
  final String id;
  final String name;
  final WardrobeCategory category;
  final WardrobeStyle style;

  /// UI metadata
  final Color color;
  final String colorName;

  /// If false -> excluded from outfit generation
  final bool available;

  /// Tags decide which day/event the item suits
  final Set<DayType> tags;

  const WardrobeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.style,
    required this.color,
    required this.colorName,
    required this.available,
    required this.tags,
  });

  WardrobeItem copyWith({
    String? id,
    String? name,
    WardrobeCategory? category,
    WardrobeStyle? style,
    Color? color,
    String? colorName,
    bool? available,
    Set<DayType>? tags,
  }) {
    return WardrobeItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      style: style ?? this.style,
      color: color ?? this.color,
      colorName: colorName ?? this.colorName,
      available: available ?? this.available,
      tags: tags ?? this.tags,
    );
  }

  /// Convenience clone (your older code called `copy()`)
  WardrobeItem copy() => copyWith();
}

/// Helpers for pretty text in UI
extension WardrobeCategoryLabel on WardrobeCategory {
  String get label {
    switch (this) {
      case WardrobeCategory.shalwarKameez:
        return "Shalwar Kameez";
      case WardrobeCategory.pants:
        return "Pants";
      case WardrobeCategory.shirts:
        return "Shirts";
      case WardrobeCategory.kurtas:
        return "Kurtas";
      case WardrobeCategory.pajamas:
        return "Pajamas";
      case WardrobeCategory.bridalwear:
        return "Bridalwear";
      case WardrobeCategory.others:
        return "Others";
    }
  }
}

extension DayTypeLabel on DayType {
  String get label {
    switch (this) {
      case DayType.university:
        return "University";
      case DayType.office:
        return "Office";
      case DayType.daily:
        return "Daily Wear";
      case DayType.home:
        return "Home";
      case DayType.party:
        return "Party";
      case DayType.function:
        return "Function";
      case DayType.marriage:
        return "Marriage";
      case DayType.rainy:
        return "Rainy";
      case DayType.winter:
        return "Winter";
      case DayType.summer:
        return "Summer";
      case DayType.custom:
        return "Custom";
    }
  }

  String get emoji {
    switch (this) {
      case DayType.university:
        return "🎓";
      case DayType.office:
        return "🏢";
      case DayType.daily:
        return "🧩";
      case DayType.home:
        return "🧘";
      case DayType.party:
        return "🎉";
      case DayType.function:
        return "✨";
      case DayType.marriage:
        return "💍";
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
}
