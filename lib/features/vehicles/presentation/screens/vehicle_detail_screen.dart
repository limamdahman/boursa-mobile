import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/vehicle.dart';
import '../providers/listing_providers.dart';

class VehicleDetailScreen extends ConsumerWidget {
  const VehicleDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncVehicle = ref.watch(vehicleDetailProvider(id));

    return Scaffold(
      body: asyncVehicle.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.listingError}: $e')),
        data: (vehicle) => _DetailBody(vehicle: vehicle),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final priceFmt = NumberFormat.decimalPattern('fr_FR');

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: vehicle.media.isNotEmpty
                ? PageView.builder(
                    itemCount: vehicle.media.length,
                    itemBuilder: (c, i) => CachedNetworkImage(
                      imageUrl: vehicle.media[i].bestUrl,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(color: AppColors.border),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  '${priceFmt.format(vehicle.priceMru)} MRU',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontSize: 28,
                      ),
                ),
                const SizedBox(height: 20),
                _SpecRow(label: 'Année', value: '${vehicle.year}'),
                _SpecRow(label: 'Kilométrage', value: '${priceFmt.format(vehicle.mileageKm)} km'),
                _SpecRow(label: 'Carburant', value: vehicle.fuel),
                _SpecRow(label: 'Boite', value: vehicle.transmission),
                _SpecRow(label: 'Carrosserie', value: vehicle.bodyType),
                if (vehicle.city != null)
                  _SpecRow(label: 'Ville', value: vehicle.city!.name),
                const SizedBox(height: 24),
                if (vehicle.description != null && vehicle.description!.isNotEmpty) ...[
                  Text(l10n.vehicleDescriptionTitle,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(vehicle.description!,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                ],
                if (vehicle.agency != null) ...[
                  Text(l10n.vehicleAgencyTitle,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(vehicle.agency!.name,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
                const SizedBox(height: 32),
                _ContactBar(vehicle: vehicle),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _ContactBar extends StatelessWidget {
  const _ContactBar({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phone = vehicle.agency?.phone;

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: phone == null ? null : () => _openWhatsApp(phone, vehicle),
            icon: const Icon(Icons.chat),
            label: Text(l10n.contactWhatsApp),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton.icon(
            onPressed: phone == null ? null : () => _call(phone),
            icon: const Icon(Icons.phone),
            label: Text(l10n.contactCall),
          ),
        ),
      ],
    );
  }

  Future<void> _openWhatsApp(String phone, Vehicle vehicle) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final msg = Uri.encodeComponent(
      'Bonjour, je suis intéressé par votre ${vehicle.title} (${vehicle.year}). Est-il toujours disponible ?',
    );
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
