import 'package:dio/dio.dart';
import 'notification_models.dart';

class NotificationRepository {
  NotificationRepository(this._dio);
  final Dio _dio;

  Future<List<AppNotification>> recent() async {
    final res = await _dio.get('/me/notifications/recent');
    final raw = res.data;
    final list = raw is Map && raw['data'] is List ? raw['data'] as List : <dynamic>[];
    return list.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<int> unreadCount() async {
    final res = await _dio.get('/me/notifications/unread-count');
    final raw = res.data;
    return raw is Map ? (raw['count'] as num?)?.toInt() ?? 0 : 0;
  }

  Future<void> markAsRead(String id) async {
    await _dio.post('/me/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _dio.post('/me/notifications/read-all');
  }
}
