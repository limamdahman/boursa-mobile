import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../vehicles/data/models/vehicle.dart';
import '../../data/favorite_repository.dart';
import '../providers/favorites_provider.dart';

/// Future provider pour charger la liste paginée des favoris
final favoriteListProvider = FutureProvider.autoDispose<List<Vehicle>>((ref) async {
  // Ré-fetch quand le Set d'IDs change
  ref.watch(favoritesProvider);
  final repo = ref.watch(favoriteRepositoryProvider);
  final page = await repo.list(page: 1, perPage: 50);
  return page.items;
});

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(favoriteListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes favoris'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: list.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 56, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Erreur : $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(favoriteListProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite_border,
                        size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    Text(
                      'Aucun favori pour le moment',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Appuyez sur le ♥ depuis une fiche véhicule pour ajouter à vos favoris',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.search),
                      label: const Text('Parcourir les véhicules'),
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.72,
            ),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final v = vehicles[index];
              return _FavoriteTile(vehicle: v);
            },
          );
        },
      ),
    );
  }
}

class _FavoriteTile extends ConsumerWidget {
  const _FavoriteTile({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priceFmt = NumberFormat.decimalPattern('fr_FR');
    final cover = vehicle.coverUrl;

    return InkWell(
      onTap: () => context.go('/vehicle/${vehicle.id}'),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (cover != null)
                      CachedNetworkImage(
                        imageUrl: cover,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.border,
                          child: const Center(
                            child: SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.border,
                          child: const Icon(Icons.directions_car,
                              color: AppColors.textMuted),
                        ),
                      )
                    else
                      Container(
                        color: AppColors.border,
                        child: const Icon(Icons.directions_car,
                            color: AppColors.textMuted),
                      ),
                    // Heart icon (toujours filled puisque c'est un favori)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Material(
                        color: Colors.white.withOpacity(0.9),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () async {
                            await ref
                                .read(favoritesProvider.notifier)
                                .toggle(vehicle.id);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.favorite,
                                color: AppColors.error, size: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehicle.brand.name} ${vehicle.model.name}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${priceFmt.format(vehicle.priceMru)} MRU',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${vehicle.year} · ${priceFmt.format(vehicle.mileageKm)} km',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
