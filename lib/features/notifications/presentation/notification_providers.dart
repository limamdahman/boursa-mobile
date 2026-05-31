import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../data/notification_models.dart';
import '../data/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.read(apiClientProvider));
});

final unreadCountProvider = FutureProvider<int>((ref) async {
  try {
    return await ref.read(notificationRepositoryProvider).unreadCount();
  } catch (_) {
    return 0;
  }
});

final recentNotificationsProvider =
    FutureProvider<List<AppNotification>>((ref) async {
  return ref.read(notificationRepositoryProvider).recent();
});
