/// Modèle dédié à GET /me/vehicles (format Eloquent brut, différent du listing public).
class MyVehicle {
  MyVehicle({
    required this.id,
    required this.brandName,
    required this.modelName,
    required this.year,
    required this.priceMru,
    required this.status,
    this.coverUrl,
  });

  final String id;
  final String brandName;
  final String modelName;
  final int year;
  final int priceMru;
  final String status;
  final String? coverUrl;

  factory MyVehicle.fromJson(Map<String, dynamic> j) {
    String? cover;
    final media = j['media'];
    if (media is List && media.isNotEmpty) {
      // photo de couverture si marquée, sinon la première
      final coverItem = media.firstWhere(
        (m) => m is Map && m['is_cover'] == true,
        orElse: () => media.first,
      ) as Map;
      cover = (coverItem['url_thumb'] ??
          coverItem['url_webp_md'] ??
          coverItem['url_original']) as String?;
    }
    final brand = j['brand'] as Map?;
    final model = j['vehicle_model'] as Map?;
    return MyVehicle(
      id: j['id'].toString(),
      brandName: (brand?['name'] ?? '') as String,
      modelName: (model?['name'] ?? '') as String,
      year: (j['year'] as num?)?.toInt() ?? 0,
      priceMru: (j['price_mru'] as num?)?.toInt() ?? 0,
      status: (j['status'] ?? '') as String,
      coverUrl: cover,
    );
  }
}
