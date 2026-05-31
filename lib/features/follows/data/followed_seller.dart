import '../../vehicles/data/models/vehicle.dart';

class FollowedSeller {
  FollowedSeller({
    required this.id,
    required this.sellerType,
    required this.sellerId,
    required this.sellerName,
    required this.activeVehiclesCount,
    this.sellerSlug,
    this.sellerLogoUrl,
    this.recentVehicles = const [],
  });

  final String id;
  final String sellerType; // 'agency' | 'user'
  final String sellerId;
  final String sellerName;
  final int activeVehiclesCount;
  final String? sellerSlug;
  final String? sellerLogoUrl;
  final List<Vehicle> recentVehicles;

  bool get isAgency => sellerType == 'agency';

  factory FollowedSeller.fromJson(Map<String, dynamic> j) {
    final recent = j['recent_vehicles'];
    final list = recent is List
        ? recent
            .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
            .toList()
        : <Vehicle>[];
    return FollowedSeller(
      id: j['id'].toString(),
      sellerType: (j['seller_type'] ?? 'user') as String,
      sellerId: (j['seller_id'] ?? '').toString(),
      sellerName: (j['seller_name'] ?? '—') as String,
      sellerSlug: j['seller_slug'] as String?,
      sellerLogoUrl: j['seller_logo_url'] as String?,
      activeVehiclesCount: (j['active_vehicles_count'] as num?)?.toInt() ?? 0,
      recentVehicles: list,
    );
  }
}
