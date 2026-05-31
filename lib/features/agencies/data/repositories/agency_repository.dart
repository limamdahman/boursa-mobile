import 'package:dio/dio.dart';
import '../models/agency.dart';

class AgencyRepository {
  final Dio _dio;
  AgencyRepository(this._dio);

  Future<List<Agency>> listAgencies(
      {int page = 1, int perPage = 20, String? cityId}) async {
    final params = <String, dynamic>{'page': page, 'per_page': perPage};
    if (cityId != null) params['city_id'] = cityId;
    final res = await _dio.get('/agencies', queryParameters: params);
    final data = res.data['data'] as List;
    return data.map((e) => Agency.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Agency> getAgency(String slug) async {
    final res = await _dio.get('/agencies/$slug');
    final d = res.data['data'] ?? res.data;
    return Agency.fromJson(d as Map<String, dynamic>);
  }
}
