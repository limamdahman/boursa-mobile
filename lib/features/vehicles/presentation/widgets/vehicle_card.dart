import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/vehicle.dart';

class VehicleCard extends StatelessWidget {
  const VehicleCard({super.key, required this.vehicle, required this.onTap});

  final Vehicle vehicle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final priceFmt = NumberFormat.decimalPattern('fr_FR');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: vehicle.coverUrl != null
                  ? CachedNetworkImage(
                      imageUrl: vehicle.coverUrl!,
                      fit: BoxFit.cover,
                      placeholder: (c, _) => Container(color: AppColors.border),
                      errorWidget: (c, _, __) => Container(
                        color: AppColors.border,
                        child: const Icon(Icons.directions_car, size: 40),
                      ),
                    )
                  : Container(
                      color: AppColors.border,
                      child: const Icon(Icons.directions_car, size: 40),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${priceFmt.format(vehicle.priceMru)} MRU',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _Chip(label: '${vehicle.year}'),
                      const SizedBox(width: 6),
                      _Chip(label: '${priceFmt.format(vehicle.mileageKm)} km'),
                      const SizedBox(width: 6),
                      _Chip(label: vehicle.fuel),
                    ],
                  ),
                  if (vehicle.city != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          vehicle.city!.name,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}
