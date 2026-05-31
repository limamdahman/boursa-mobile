import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/storage/locale_storage.dart';
import '../../data/notification_models.dart';
import '../notification_providers.dart';
import '../../../../core/theme/app_font.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  // Titre + message composés selon le type (aligné sur le web, bilingue inline)
  static (String, String) _texts(AppNotification n, bool isAr) {
    final brand = n.brand ?? '';
    final model = n.model ?? '';
    final lead = n.leadName ?? '';
    switch (n.type) {
      case 'vehicle_approved':
        return isAr
            ? (
                'تمت الموافقة على الإعلان',
                'تمت الموافقة على $brand $model ونشره'
              )
            : (
                'Annonce approuvée',
                'Votre $brand $model a été approuvée et publiée'
              );
      case 'vehicle_rejected':
        return isAr
            ? ('تم رفض الإعلان', 'تم رفض $brand $model')
            : ('Annonce refusée', 'Votre $brand $model a été refusée');
      case 'new_lead':
        return isAr
            ? ('اتصال جديد', '$lead مهتم بـ $brand $model')
            : (
                'Nouveau contact',
                '$lead est intéressé par votre $brand $model'
              );
      default:
        return (n.type, '');
    }
  }

  static String _relative(DateTime? dt, bool isAr) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return isAr ? 'الآن' : "à l'instant";
    if (diff.inMinutes < 60) {
      return isAr
          ? 'منذ ${diff.inMinutes} دقيقة'
          : 'il y a ${diff.inMinutes} min';
    }
    if (diff.inHours < 24) {
      return isAr ? 'منذ ${diff.inHours} ساعة' : 'il y a ${diff.inHours} h';
    }
    return isAr ? 'منذ ${diff.inDays} يوم' : 'il y a ${diff.inDays} j';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final async = ref.watch(recentNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isAr ? 'الإشعارات' : 'Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).markAllAsRead();
              ref.invalidate(recentNotificationsProvider);
              ref.invalidate(unreadCountProvider);
            },
            child: Text(isAr ? 'تعليم الكل كمقروء' : 'Tout marquer lu',
                style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text(isAr ? 'لا توجد إشعارات' : 'Aucune notification',
                  style: appFont(context,
                      fontSize: 15, color: AppColors.textSecondary)),
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, i) {
              final n = items[i];
              final (title, msg) = _texts(n, isAr);
              return ListTile(
                tileColor: n.isRead ? null : const Color(0xFFF0FDF4),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: Icon(
                    n.type == 'vehicle_rejected'
                        ? Icons.cancel_outlined
                        : n.type == 'new_lead'
                            ? Icons.person_outline
                            : Icons.check_circle_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                title: Text(title,
                    style: appFont(context,
                        fontSize: 14, fontWeight: FontWeight.w700)),
                subtitle: Text(msg,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: appFont(context,
                        fontSize: 13, color: AppColors.textSecondary)),
                trailing: Text(_relative(n.createdAt, isAr),
                    style: appFont(context,
                        fontSize: 11, color: AppColors.textMuted)),
                onTap: () async {
                  if (!n.isRead) {
                    await ref
                        .read(notificationRepositoryProvider)
                        .markAsRead(n.id);
                    ref.invalidate(recentNotificationsProvider);
                    ref.invalidate(unreadCountProvider);
                  }
                  if (n.vehicleId != null && context.mounted) {
                    context.push('/vehicle/${n.vehicleId}');
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
