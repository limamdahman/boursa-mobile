import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../vehicles/data/models/vehicle.dart';

class FavoriteRepository {
  FavoriteRepository(this._dio);

  final Dio _dio;

  /// Retourne la liste des IDs favorisés (lightweight pour sync du heart state)
  Future<Set<String>> ids() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/favorites/ids');
      final list = (response.data?['data'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toSet();
      return list;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return {};
      rethrow;
    }
  }

  /// Liste des véhicules favoris avec pagination
  Future<VehiclePage> list({int page = 1, int perPage = 20}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/favorites',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return VehiclePage.fromJson(response.data!);
  }

  /// Toggle : retourne le nouvel état (true = favorisé)
  Future<bool> toggle(String vehicleId, bool currentlyFav) async {
    if (currentlyFav) {
      await _dio.delete<void>('/favorites/$vehicleId');
      return false;
    } else {
      await _dio.post<void>('/favorites/$vehicleId');
      return true;
    }
  }
}

final favoriteRepositoryProvider = Provider<FavoriteRepository>(
  (ref) => FavoriteRepository(ref.watch(apiClientProvider)),
);
