import 'dart:math';
import 'package:flutter/material.dart';
import 'wardrobe_models.dart';

class OutfitEngine {
  /// Generates 1–3 outfit options using ONLY available items.
  static List<OutfitOption> generate({
    required DayType dayType,
    required List<WardrobeItem> inventory,
    int count = 3,
    int seed = 0,
  }) {
    final rnd = Random(seed == 0 ? DateTime.now().millisecondsSinceEpoch : seed);

    // only available items
    final available = inventory.where((e) => e.available).toList();

    // categorize
    final tops =
    available.where((e) => e.category == WardrobeCategory.shirts).toList();
    final bottoms =
    available.where((e) => e.category == WardrobeCategory.pants).toList();
    final shoes =
    available.where((e) => e.category == WardrobeCategory.shoes).toList();
    final jackets =
    available.where((e) => e.category == WardrobeCategory.jackets).toList();
    final watches =
    available.where((e) => e.category == WardrobeCategory.watches).toList();
    final glasses =
    available.where((e) => e.category == WardrobeCategory.glasses).toList();
    final accessories = available
        .where((e) => e.category == WardrobeCategory.accessories)
        .toList();

    if (tops.isEmpty || bottoms.isEmpty || shoes.isEmpty) return [];

    // prefer items that match dayType tags
    int scoreItem(WardrobeItem i) {
      int s = 0;
      if (i.tags.contains(dayType)) s += 12;
      s += _styleFit(dayType, i.style);
      if (_isNeutral(i.color)) s += 3;
      return s;
    }

    int scoreCombo(WardrobeItem top, WardrobeItem bottom, WardrobeItem shoe) {
      int s = 0;
      s += scoreItem(top) + scoreItem(bottom) + scoreItem(shoe);

      // harmony
      s += _colorHarmony(top.color, bottom.color);
      s += _colorHarmony(bottom.color, shoe.color);

      // style compatibility
      s += _styleCompat(top.style, bottom.style);
      s += _styleCompat(bottom.style, shoe.style);

      return s;
    }

    // Build candidates
    final candidates = <_Candidate>[];
    for (final t in tops) {
      for (final b in bottoms) {
        for (final sh in shoes) {
          final s = scoreCombo(t, b, sh);
          candidates.add(_Candidate(top: t, bottom: b, shoes: sh, score: s));
        }
      }
    }

    candidates.sort((a, b) => b.score.compareTo(a.score));
    if (candidates.isEmpty) return [];

    // pick diverse options
    final picked = <OutfitOption>[];
    final usedTopIds = <String>{};
    final usedBottomIds = <String>{};

    for (final c in candidates.take(18)) {
      if (picked.length >= count) break;

      if (usedTopIds.contains(c.top.id) && usedBottomIds.contains(c.bottom.id)) {
        continue;
      }

      final jacket = _maybePick(dayType, jackets, rnd);
      final watch = _maybePick(dayType, watches, rnd);
      final glass = _maybePick(dayType, glasses, rnd);

      final acc = <WardrobeItem>[];
      if (accessories.isNotEmpty) {
        final k = rnd.nextInt(3); // 0-2
        final shuffled = [...accessories]..shuffle(rnd);
        acc.addAll(shuffled.take(k));
      }

      final explanation = _explain(
        dayType,
        c.top,
        c.bottom,
        c.shoes,
        jacket: jacket,
        watch: watch,
        glasses: glass,
        accessories: acc,
      );

      picked.add(
        OutfitOption(
          top: c.top,
          bottom: c.bottom,
          shoes: c.shoes,
          jacket: jacket,
          watch: watch,
          glasses: glass,
          accessories: acc,
          explanation: explanation,
        ),
      );

      usedTopIds.add(c.top.id);
      usedBottomIds.add(c.bottom.id);
    }

    if (picked.isNotEmpty) return picked;

    // fallback
    final best = candidates.first;
    return [
      OutfitOption(
        top: best.top,
        bottom: best.bottom,
        shoes: best.shoes,
        explanation: _explain(dayType, best.top, best.bottom, best.shoes),
      ),
    ];
  }

  static WardrobeItem? _maybePick(DayType d, List<WardrobeItem> items, Random rnd) {
    if (items.isEmpty) return null;

    final tagged = items.where((e) => e.tags.contains(d)).toList();
    final pool = tagged.isNotEmpty ? tagged : items;

    final chance = (d == DayType.party || d == DayType.office) ? 0.85 : 0.65;
    if (rnd.nextDouble() > chance) return null;

    final sorted = [...pool]
      ..sort((a, b) => _scorePick(d, b).compareTo(_scorePick(d, a)));

    final topN = min(3, sorted.length);
    return sorted[rnd.nextInt(topN)];
  }

  static int _scorePick(DayType d, WardrobeItem i) {
    int s = 0;
    if (i.tags.contains(d)) s += 10;
    s += _styleFit(d, i.style);
    if (_isNeutral(i.color)) s += 2;
    return s;
  }

  static int _styleFit(DayType d, WardrobeStyle s) {
    switch (d) {
      case DayType.office:
        return (s == WardrobeStyle.formal)
            ? 8
            : (s == WardrobeStyle.semiFormal ? 6 : 1);

      case DayType.university:
        return (s == WardrobeStyle.casual)
            ? 6
            : (s == WardrobeStyle.semiFormal ? 5 : 2);

      case DayType.party:
        return (s == WardrobeStyle.formal)
            ? 7
            : (s == WardrobeStyle.street ? 5 : 3);

      case DayType.dayOut:
        return (s == WardrobeStyle.street)
            ? 6
            : (s == WardrobeStyle.casual ? 5 : 3);

      case DayType.casualHome:
      case DayType.casual: // ✅ treat same as casualHome
        return (s == WardrobeStyle.casual)
            ? 7
            : (s == WardrobeStyle.sporty ? 6 : 1);

      case DayType.rainy:
        return (s == WardrobeStyle.semiFormal)
            ? 6
            : (s == WardrobeStyle.casual ? 5 : 2);

      case DayType.winter:
        return (s == WardrobeStyle.street)
            ? 6
            : (s == WardrobeStyle.semiFormal ? 5 : 3);

      case DayType.summer:
        return (s == WardrobeStyle.casual)
            ? 7
            : (s == WardrobeStyle.street ? 5 : 2);

      case DayType.custom:
        return 4;
    }
  }

  static int _styleCompat(WardrobeStyle a, WardrobeStyle b) {
    if (a == b) return 5;

    if ((a == WardrobeStyle.formal && b == WardrobeStyle.semiFormal) ||
        (a == WardrobeStyle.semiFormal && b == WardrobeStyle.formal)) {
      return 4;
    }

    if ((a == WardrobeStyle.casual && b == WardrobeStyle.street) ||
        (a == WardrobeStyle.street && b == WardrobeStyle.casual)) {
      return 4;
    }

    if ((a == WardrobeStyle.casual && b == WardrobeStyle.sporty) ||
        (a == WardrobeStyle.sporty && b == WardrobeStyle.casual)) {
      return 3;
    }

    return 1;
  }

  static bool _isNeutral(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.saturation < 0.12 || hsl.lightness < 0.12 || hsl.lightness > 0.88;
  }

  static int _colorHarmony(Color a, Color b) {
    if (_isNeutral(a) || _isNeutral(b)) return 5;

    final ha = HSLColor.fromColor(a).hue;
    final hb = HSLColor.fromColor(b).hue;
    final diff = (ha - hb).abs();
    final d = min(diff, 360 - diff);

    if (d < 25) return 5;
    if (d < 55) return 4;
    if (d > 150 && d < 220) return 4;
    return 2;
  }

  static String _explain(
      DayType d,
      WardrobeItem top,
      WardrobeItem bottom,
      WardrobeItem shoes, {
        WardrobeItem? jacket,
        WardrobeItem? watch,
        WardrobeItem? glasses,
        List<WardrobeItem> accessories = const [],
      }) {
    final day = dayTypeTitle(d);

    final topLine =
        "${top.colorName} ${top.name} pairs well with ${bottom.colorName.toLowerCase()} ${bottom.name.toLowerCase()} for a clean $day look.";
    final shoeLine =
        "${shoes.colorName} ${shoes.name.toLowerCase()} keeps it ${_comfortTone(d)} while staying style-consistent.";

    final extras = <String>[];
    if (jacket != null) extras.add("The ${jacket.name.toLowerCase()} adds depth and polish.");
    if (watch != null) extras.add("The ${watch.colorName.toLowerCase()} ${watch.name.toLowerCase()} adds a premium touch.");
    if (glasses != null) extras.add("The ${glasses.name.toLowerCase()} finishes the look with a modern edge.");
    if (accessories.isNotEmpty) {
      extras.add("Accessories like ${accessories.map((e) => e.name).join(", ")} complete the outfit.");
    }

    return [topLine, shoeLine, if (extras.isNotEmpty) extras.join(" ")].join(" ");
  }

  static String _comfortTone(DayType d) {
    switch (d) {
      case DayType.university:
        return "comfortable for long hours";
      case DayType.office:
        return "sharp and professional";
      case DayType.dayOut:
        return "easy and versatile";
      case DayType.party:
        return "event-ready";
      case DayType.casualHome:
      case DayType.casual:
        return "relaxed";
      case DayType.rainy:
        return "practical";
      case DayType.winter:
        return "warm and layered";
      case DayType.summer:
        return "light and breathable";
      case DayType.custom:
        return "balanced";
    }
  }
}

class _Candidate {
  final WardrobeItem top;
  final WardrobeItem bottom;
  final WardrobeItem shoes;
  final int score;

  _Candidate({
    required this.top,
    required this.bottom,
    required this.shoes,
    required this.score,
  });
}
