import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../models/vehicle.dart';

class VehicleRepository {
  VehicleRepository(this._dio);

  final Dio _dio;

  Future<VehiclePage> list({
    int page = 1,
    int perPage = 20,
    int? brandId,
    int? modelId,
    int? cityId,
    String? agencyId,
    int? yearMin,
    int? yearMax,
    int? priceMin,
    int? priceMax,
    int? mileageMax,
    String? fuel,
    String? transmission,
    String? bodyType,
    String? condition,
    double? lat,
    double? lng,
    int? radiusKm,
    String? sort,
    bool? isDeal,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/vehicles',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (brandId != null) 'brand_id': brandId,
        if (modelId != null) 'vehicle_model_id': modelId,
        if (cityId != null) 'city_id': cityId,
        if (agencyId != null) 'agency_id': agencyId,
        if (yearMin != null) 'year_min': yearMin,
        if (yearMax != null) 'year_max': yearMax,
        if (priceMin != null) 'price_min': priceMin,
        if (priceMax != null) 'price_max': priceMax,
        if (mileageMax != null) 'mileage_max': mileageMax,
        if (fuel != null) 'fuel': fuel,
        if (transmission != null) 'transmission': transmission,
        if (bodyType != null) 'body_type': bodyType,
        if (condition != null) 'condition': condition,
        if (lat != null) 'lat': lat,
        if (isDeal == true) 'is_deal': '1',
        if (lng != null) 'lng': lng,
        if (radiusKm != null) 'radius_km': radiusKm,
        if (sort != null) 'sort': sort,
      },
    );
    return VehiclePage.fromJson(response.data!);
  }

  Future<Vehicle> detail(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/vehicles/$id');
    final payload = response.data!['data'] as Map<String, dynamic>?;
    return Vehicle.fromJson(payload ?? response.data!);
  }

  Future<List<Vehicle>> similar(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/vehicles/$id/similar');
    final list = response.data!['data'] as List<dynamic>? ?? [];
    return list.map((e) => Vehicle.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> trackView(String id) async {
    try {
      await _dio.post<void>('/vehicles/$id/track-view');
    } catch (_) {
      // tracking ne doit jamais bloquer l'UI
    }
  }
}

final vehicleRepositoryProvider = Provider<VehicleRepository>(
  (ref) => VehicleRepository(ref.watch(apiClientProvider)),
);
