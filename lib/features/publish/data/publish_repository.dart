import 'package:dio/dio.dart';

class PublishRepository {
  PublishRepository(this._dio);
  final Dio _dio;

  Future<String> create(Map<String, dynamic> payload) async {
    final res = await _dio.post('/me/vehicles', data: payload);
    final data = res.data is Map ? (res.data['data'] as Map?) : null;
    return (data?['id'] ?? '').toString();
  }

  Future<void> uploadPhoto(String vehicleId, List<int> bytes, String filename,
      {bool isCover = false}) async {
    final form = FormData.fromMap({
      'photo': MultipartFile.fromBytes(bytes, filename: filename),
      'is_cover': isCover ? 1 : 0,
    });
    await _dio.post('/me/vehicles/$vehicleId/media', data: form);
  }
}
