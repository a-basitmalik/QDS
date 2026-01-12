import 'package:flutter/material.dart';
import 'wardrobe_models.dart';

class WardrobeDemoData {
  /// ✅ Your purchased inventory (demo) – replace with DB later
  static List<WardrobeItem> purchasedItems() {
    return [
      // Shalwar Kameez
      WardrobeItem(
        id: "sk_1",
        name: "Classic White Shalwar Kameez",
        category: WardrobeCategory.shalwarKameez,
        style: WardrobeStyle.traditional,
        color: const Color(0xFFF4F4F4),
        colorName: "White",
        available: true,
        tags: {DayType.daily, DayType.university, DayType.function, DayType.marriage},
      ),
      WardrobeItem(
        id: "sk_2",
        name: "Navy Shalwar Kameez",
        category: WardrobeCategory.shalwarKameez,
        style: WardrobeStyle.traditional,
        color: const Color(0xFF1C2A44),
        colorName: "Navy",
        available: true,
        tags: {DayType.office, DayType.daily, DayType.function},
      ),

      // Pants
      WardrobeItem(
        id: "p_1",
        name: "Charcoal Chinos",
        category: WardrobeCategory.pants,
        style: WardrobeStyle.semiFormal,
        color: const Color(0xFF2F2F34),
        colorName: "Charcoal",
        available: true,
        tags: {DayType.office, DayType.daily, DayType.university},
      ),
      WardrobeItem(
        id: "p_2",
        name: "Light Denim Jeans",
        category: WardrobeCategory.pants,
        style: WardrobeStyle.casual,
        color: const Color(0xFF7AA6D6),
        colorName: "Denim Blue",
        available: true,
        tags: {DayType.party, DayType.daily, DayType.university},
      ),

      // Shirts
      WardrobeItem(
        id: "s_1",
        name: "Light Blue Oxford Shirt",
        category: WardrobeCategory.shirts,
        style: WardrobeStyle.semiFormal,
        color: const Color(0xFF8EC5FF),
        colorName: "Light Blue",
        available: true,
        tags: {DayType.office, DayType.university, DayType.daily},
      ),
      WardrobeItem(
        id: "s_2",
        name: "Black T-Shirt",
        category: WardrobeCategory.shirts,
        style: WardrobeStyle.casual,
        color: const Color(0xFF121212),
        colorName: "Black",
        available: true,
        tags: {DayType.party, DayType.home, DayType.daily, DayType.summer},
      ),

      // Kurtas
      WardrobeItem(
        id: "k_1",
        name: "Beige Kurta",
        category: WardrobeCategory.kurtas,
        style: WardrobeStyle.traditional,
        color: const Color(0xFFE7D8C6),
        colorName: "Beige",
        available: true,
        tags: {DayType.function, DayType.daily, DayType.marriage},
      ),
      WardrobeItem(
        id: "k_2",
        name: "Emerald Kurta",
        category: WardrobeCategory.kurtas,
        style: WardrobeStyle.traditional,
        color: const Color(0xFF0F8A6B),
        colorName: "Emerald",
        available: true,
        tags: {DayType.party, DayType.function, DayType.marriage},
      ),

      // Pajamas
      WardrobeItem(
        id: "pj_1",
        name: "Comfort Pajama Set",
        category: WardrobeCategory.pajamas,
        style: WardrobeStyle.casual,
        color: const Color(0xFFB9C1CC),
        colorName: "Grey",
        available: true,
        tags: {DayType.home, DayType.winter, DayType.daily},
      ),

      // Bridalwear
      WardrobeItem(
        id: "b_1",
        name: "Maroon Bridal Sherwani",
        category: WardrobeCategory.bridalwear,
        style: WardrobeStyle.bridal,
        color: const Color(0xFF5B0A14),
        colorName: "Maroon",
        available: true,
        tags: {DayType.marriage, DayType.function},
      ),
      WardrobeItem(
        id: "b_2",
        name: "Golden Wedding Kurta",
        category: WardrobeCategory.bridalwear,
        style: WardrobeStyle.bridal,
        color: const Color(0xFFD6B25E),
        colorName: "Gold",
        available: true,
        tags: {DayType.marriage, DayType.function, DayType.party},
      ),

      // Others
      WardrobeItem(
        id: "o_1",
        name: "Neutral Shawl",
        category: WardrobeCategory.others,
        style: WardrobeStyle.traditional,
        color: const Color(0xFFCFC7B8),
        colorName: "Stone",
        available: true,
        tags: {DayType.winter, DayType.rainy, DayType.function, DayType.daily},
      ),
    ];
  }
}
