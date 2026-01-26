class CategoryNode {
  final int id;
  final String name;
  final List<SubCategoryLite> subCategories;

  CategoryNode({required this.id, required this.name, required this.subCategories});

  factory CategoryNode.fromJson(Map<String, dynamic> j) {
    final subs = (j["sub_categories"] as List? ?? const [])
        .map((e) => SubCategoryLite.fromJson(e as Map<String, dynamic>))
        .toList();
    return CategoryNode(
      id: (j["id"] as num).toInt(),
      name: (j["name"] ?? "").toString(),
      subCategories: subs,
    );
  }
}

class SubCategoryLite {
  final int id;
  final String name;

  SubCategoryLite({required this.id, required this.name});

  factory SubCategoryLite.fromJson(Map<String, dynamic> j) => SubCategoryLite(
    id: (j["id"] as num).toInt(),
    name: (j["name"] ?? "").toString(),
  );
}

/// For selection list (both category and subcategory in one dropdown list)
class SelectableCategory {
  final int id;
  final String title; // e.g. "Hoodies" or "Hoodies › Oversized"
  final bool isSub;

  SelectableCategory({required this.id, required this.title, required this.isSub});
}
