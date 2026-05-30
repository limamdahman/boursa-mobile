import 'package:dio/dio.dart';
import 'my_vehicle.dart';

class UserVehicleRepository {
  UserVehicleRepository(this._dio);
  final Dio _dio;

  Future<List<MyVehicle>> myVehicles() async {
    final res = await _dio.get('/me/vehicles');
    final raw = res.data;
    final list = raw is Map && raw['data'] is List ? raw['data'] as List : <dynamic>[];
    return list.map((e) => MyVehicle.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> delete(String id) async {
    await _dio.delete('/me/vehicles/$id');
  }

  Future<void> markSold(String id) async {
    await _dio.post('/me/vehicles/$id/sold');
  }
}
