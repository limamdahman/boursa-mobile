import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../data/models/vehicle.dart';

/// VehicleCard horizontale (style mobile.de) :
///  - Card 112px de hauteur fixe
///  - Photo 100×96 à gauche
///  - Title + sub + price + meta à droite
class VehicleCard extends ConsumerWidget {
  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
    this.featured = false,
  });

  final Vehicle vehicle;
  final VoidCallback onTap;
  final bool featured;

  static const double cardHeight = 112;
  static const double photoSize = 96;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priceFmt = NumberFormat.decimalPattern('fr_FR');
    final isFav = ref.watch(isFavoriteProvider(vehicle.id));

    return Container(
      height: cardHeight,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: featured ? AppColors.primary : AppColors.border,
          width: featured ? 1.5 : 1,
        ),
        boxShadow: featured
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _Photo(
                  vehicle: vehicle,
                  featured: featured,
                  isFav: isFav,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Info(vehicle: vehicle, priceFmt: priceFmt),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({
    required this.vehicle,
    required this.featured,
    required this.isFav,
  });

  final Vehicle vehicle;
  final bool featured;
  final bool isFav;

  @override
  Widget build(BuildContext context) {
    final url = vehicle.coverUrl;

    return SizedBox(
      width: VehicleCard.photoSize,
      height: VehicleCard.photoSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url != null)
              CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppColors.surfaceMuted,
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceMuted,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.directions_car_outlined,
                    color: AppColors.textDisabled,
                  ),
                ),
              )
            else
              Container(
                color: AppColors.surfaceMuted,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.directions_car_outlined,
                  color: AppColors.textDisabled,
                ),
              ),
            if (featured)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'VEDETTE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            if (isFav)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 13,
                    color: AppColors.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.vehicle, required this.priceFmt});

  final Vehicle vehicle;
  final NumberFormat priceFmt;

  @override
  Widget build(BuildContext context) {
    final brandName = vehicle.brand.name;
    final modelName = vehicle.model.name;
    final cityName = vehicle.city?.name ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Titre + sub
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$brandName $modelName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${vehicle.year} · ${priceFmt.format(vehicle.mileageKm)} km · ${_fuelShort(vehicle.fuel)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
        // Prix + meta
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  priceFmt.format(vehicle.priceMru),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.priceColor,
                    letterSpacing: -0.2,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'MRU',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.priceColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (cityName.isNotEmpty)
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 11,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      cityName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  String _fuelShort(String fuel) {
    switch (fuel) {
      case 'gasoline':
        return 'Essence';
      case 'diesel':
        return 'Diesel';
      case 'hybrid':
        return 'Hybride';
      case 'electric':
        return 'Élec.';
      case 'gpl':
        return 'GPL';
      default:
        return fuel;
    }
  }
}
