import 'package:dio/dio.dart';

class FollowRepository {
  FollowRepository(this._dio);
  final Dio _dio;

  /// Suit / ne suit plus. Retourne le nouvel état (true = suivi).
  Future<bool> toggle(String sellerType, String sellerId) async {
    final res = await _dio.post('/seller-follows/toggle', data: {
      'seller_type': sellerType,
      'seller_id': sellerId,
    });
    final raw = res.data;
    return raw is Map ? (raw['following'] as bool? ?? false) : false;
  }

  Future<bool> isFollowing(String sellerType, String sellerId) async {
    final res = await _dio.get('/seller-follows/is-following', queryParameters: {
      'seller_type': sellerType,
      'seller_id': sellerId,
    });
    final raw = res.data;
    return raw is Map ? (raw['following'] as bool? ?? false) : false;
  }

  Future<int> followersCount(String sellerType, String sellerId) async {
    final res = await _dio.get('/sellers/$sellerType/$sellerId/followers-count');
    final raw = res.data;
    return raw is Map ? (raw['count'] as num?)?.toInt() ?? 0 : 0;
  }
}
