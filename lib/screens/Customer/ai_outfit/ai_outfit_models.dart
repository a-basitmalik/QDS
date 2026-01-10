import 'dart:math';

class OutfitGenPrefs {
  final bool randomBrands;
  final Set<String> brands;
  final Map<String, Set<String>> categoryBrands; // category -> brands selected
  const OutfitGenPrefs({
    required this.randomBrands,
    required this.brands,
    required this.categoryBrands,
  });
}

class OutfitItem {
  final String category; // Shoes, Pants, Shirts, Hat, Glasses, Watch
  final String brand;
  final String name;
  final int price; // PKR
  final String image; // asset path
  const OutfitItem({
    required this.category,
    required this.brand,
    required this.name,
    required this.price,
    required this.image,
  });
}

class OutfitBundle {
  final String title;
  final List<OutfitItem> items;
  const OutfitBundle({required this.title, required this.items});
}

/// Mock generator (replace with API later)
List<OutfitBundle> mockGenerateOutfits(OutfitGenPrefs prefs) {
  final rnd = Random();

  final brandsPool = prefs.randomBrands
      ? ["Nike", "Adidas", "Zara", "Uniqlo", "Ray-Ban", "Casio", "Fossil", "Puma"]
      : (prefs.brands.isNotEmpty
      ? prefs.brands.toList()
      : ["Zara", "Uniqlo", "Nike", "Adidas"]);

  OutfitItem item(String cat, String fallbackName, String img) {
    final catSelected = prefs.categoryBrands[cat] ?? {};
    final brand = (prefs.randomBrands || catSelected.isEmpty)
        ? brandsPool[rnd.nextInt(brandsPool.length)]
        : catSelected.elementAt(rnd.nextInt(catSelected.length));
    final price = 2999 + rnd.nextInt(9000);
    final name = "$brand $fallbackName";
    return OutfitItem(category: cat, brand: brand, name: name, price: price, image: img);
  }

  return List.generate(5, (i) {
    return OutfitBundle(
      title: "Outfit ${i + 1}",
      items: [
        item("Shirts", "Premium Shirt", "assets/shops/Edited.jpg"),
        item("Pants", "Slim Fit Pants", "assets/shops/Edited.jpg"),
        item("Shoes", "Runner Shoes", "assets/shops/Edited.jpg"),
        item("Watch", "Classic Watch", "assets/shops/Edited.jpg"),
        item("Glasses", "Aero Glasses", "assets/shops/Edited.jpg"),
        item("Hat", "Urban Cap", "assets/shops/Edited.jpg"),
      ],
    );
  });
}
