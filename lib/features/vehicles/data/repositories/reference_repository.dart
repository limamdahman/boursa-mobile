import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../models/reference.dart';

class ReferenceRepository {
  ReferenceRepository(this._dio);

  final Dio _dio;

  Future<List<BrandRef>> brands() async {
    final response = await _dio.get<Map<String, dynamic>>('/brands');
    final list = response.data!['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => BrandRef.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<VehicleModelRef>> modelsByBrand(int brandId) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/brands/$brandId/models');
    final list = response.data!['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => VehicleModelRef.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CityRef>> cities() async {
    final response = await _dio.get<Map<String, dynamic>>('/cities');
    final list = response.data!['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => CityRef.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final referenceRepositoryProvider = Provider<ReferenceRepository>(
  (ref) => ReferenceRepository(ref.watch(apiClientProvider)),
);

/// Providers cachés via autoDispose-keepAlive (rechargés rarement)
final brandsListProvider = FutureProvider<List<BrandRef>>((ref) async {
  return ref.watch(referenceRepositoryProvider).brands();
});

final citiesListProvider = FutureProvider<List<CityRef>>((ref) async {
  return ref.watch(referenceRepositoryProvider).cities();
});

final modelsForBrandProvider =
    FutureProvider.family<List<VehicleModelRef>, int>((ref, brandId) async {
  return ref.watch(referenceRepositoryProvider).modelsByBrand(brandId);
});
