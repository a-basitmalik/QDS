// lib/models/size_chart_models.dart

class SizeChartLite {
  final int id;
  final String title;

  const SizeChartLite({
    required this.id,
    required this.title,
  });

  @override
  String toString() => "SizeChartLite(id: $id, title: $title)";
}
