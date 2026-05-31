import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/storage/locale_storage.dart';
import '../../../../core/utils/number_formatters.dart';
import '../../data/my_vehicle.dart';
import '../my_listings_providers.dart';
import '../../../../core/theme/app_font.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final async = ref.watch(myVehiclesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(isAr ? 'إعلاناتي' : 'Mes annonces')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push('/publier'),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(isAr ? 'نشر' : 'Publier',
            style: const TextStyle(color: Colors.white)),
      ),
      body: async.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.directions_car_outlined,
                      size: 56, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(isAr ? 'لا توجد إعلانات' : 'Aucune annonce',
                      style: appFont(context,
                          fontSize: 15, color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myVehiclesProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) =>
                  _ListingCard(vehicle: items[i], isAr: isAr),
            ),
          );
        },
      ),
    );
  }
}

class _ListingCard extends ConsumerWidget {
  const _ListingCard({required this.vehicle, required this.isAr});
  final MyVehicle vehicle;
  final bool isAr;

  (String, Color) _statusBadge() {
    switch (vehicle.status) {
      case 'active':
        return (isAr ? 'منشور' : 'Publié', AppColors.primary);
      case 'pending':
        return (isAr ? 'قيد المراجعة' : 'En attente', const Color(0xFFD97706));
      case 'sold':
        return (isAr ? 'مباع' : 'Vendu', AppColors.textMuted);
      case 'rejected':
        return (isAr ? 'مرفوض' : 'Refusé', const Color(0xFFEF4444));
      default:
        return (vehicle.status ?? '—', AppColors.textSecondary);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (label, color) = _statusBadge();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(12)),
            child: SizedBox(
              width: 96,
              height: 96,
              child: vehicle.coverUrl != null
                  ? CachedNetworkImage(
                      imageUrl: vehicle.coverUrl!, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.background,
                      child: const Icon(Icons.directions_car_outlined,
                          color: AppColors.textMuted)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(label,
                            style: appFont(context,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: color)),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onSelected: (v) async {
                          final repo = ref.read(userVehicleRepositoryProvider);
                          if (v == 'delete') {
                            await repo.delete(vehicle.id);
                          } else if (v == 'sold') {
                            await repo.markSold(vehicle.id);
                          }
                          ref.invalidate(myVehiclesProvider);
                        },
                        itemBuilder: (_) => [
                          if (vehicle.status != 'sold')
                            PopupMenuItem(
                                value: 'sold',
                                child:
                                    Text(isAr ? 'تم البيع' : 'Marquer vendu')),
                          PopupMenuItem(
                              value: 'delete',
                              child: Text(isAr ? 'حذف' : 'Supprimer')),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    '${vehicle.brandName} ${vehicle.modelName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: appFont(context,
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${NumberFormatters.formatPrice(vehicle.priceMru)} ${isAr ? "أوقية" : "MRU"}',
                    style: appFont(context,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.priceColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
