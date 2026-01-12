import 'package:flutter/material.dart';
import 'wardrobe_models.dart';

class WardrobeDemoData {
  static List<WardrobeItem> purchasedItems() {
    return [
      // ───────────────── Shirts / Tops ─────────────────
      WardrobeItem(
        id: "top_1",
        name: "Light Blue Shirt",
        category: WardrobeCategory.shirts,
        style: WardrobeStyle.semiFormal,
        color: const Color(0xFF8EC5FF),
        colorName: "Light Blue",
        available: true,
        tags: <DayType>[
          DayType.university,
          DayType.office,
          DayType.dayOut,
        ],
      ),
      WardrobeItem(
        id: "top_2",
        name: "Black T-Shirt",
        category: WardrobeCategory.shirts,
        style: WardrobeStyle.casual,
        color: const Color(0xFF121212),
        colorName: "Black",
        available: true,
        tags: <DayType>[
          DayType.dayOut,
          DayType.casualHome,
          DayType.summer,
        ],
      ),
      WardrobeItem(
        id: "top_3",
        name: "White Shirt",
        category: WardrobeCategory.shirts,
        style: WardrobeStyle.semiFormal,
        color: const Color(0xFFF5F5F5),
        colorName: "White",
        available: true,
        tags: <DayType>[
          DayType.office,
          DayType.party,
          DayType.custom,
        ],
      ),
      WardrobeItem(
        id: "top_4",
        name: "Maroon Polo",
        category: WardrobeCategory.shirts,
        style: WardrobeStyle.casual,
        color: const Color(0xFF7A0B12),
        colorName: "Maroon",
        available: true,
        tags: <DayType>[
          DayType.university,
          DayType.dayOut,
          DayType.winter,
        ],
      ),
      WardrobeItem(
        id: "top_5",
        name: "Olive Tee",
        category: WardrobeCategory.shirts,
        style: WardrobeStyle.casual,
        color: const Color(0xFF6B7B3E),
        colorName: "Olive",
        available: true,
        tags: <DayType>[
          DayType.casualHome,
          DayType.rainy,
          DayType.winter,
        ],
      ),

      // ───────────────── More Tops to help generator ─────────────────
      WardrobeItem(
        id: "top_6",
        name: "Navy Shirt",
        category: WardrobeCategory.shirts,
        style: WardrobeStyle.semiFormal,
        color: const Color(0xFF1D2B4F),
        colorName: "Navy",
        available: true,
        tags: <DayType>[
          DayType.office,
          DayType.university,
          DayType.winter,
        ],
      ),
      WardrobeItem(
        id: "top_7",
        name: "Beige Tee",
        category: WardrobeCategory.shirts,
        style: WardrobeStyle.casual,
        color: const Color(0xFFE7D8C6),
        colorName: "Beige",
        available: true,
        tags: <DayType>[
          DayType.summer,
          DayType.dayOut,
          DayType.custom,
        ],
      ),
      WardrobeItem(
        id: "top_8",
        name: "Charcoal Shirt",
        category: WardrobeCategory.shirts,
        style: WardrobeStyle.semiFormal,
        color: const Color(0xFF2B2B2B),
        colorName: "Charcoal",
        available: true,
        tags: <DayType>[
          DayType.office,
          DayType.party,
          DayType.custom,
        ],
      ),
    ];
  }
}
