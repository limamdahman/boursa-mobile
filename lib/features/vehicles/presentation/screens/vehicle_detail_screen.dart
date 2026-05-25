import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Détails'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: () {},
            tooltip: 'Partager',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: asyncVehicle.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.listingError}: $e')),
        data: (vehicle) => _DetailBody(vehicle: vehicle, vehicleId: id),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.vehicle, required this.vehicleId});

  final Vehicle vehicle;
  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priceFmt = NumberFormat.decimalPattern('fr_FR');
    final isFav = ref.watch(isFavoriteProvider(vehicleId));
    final isAuth = ref.watch(isAuthenticatedProvider);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PhotoHero(
                vehicle: vehicle,
                isFav: isFav,
                onFavTap: () => _handleFavTap(context, ref, isAuth, vehicleId),
              ),
              _PriceBlock(vehicle: vehicle, priceFmt: priceFmt),
              const SizedBox(height: 8),
              _KeyFacts(vehicle: vehicle, priceFmt: priceFmt),
              if (vehicle.agency != null) ...[
                const SizedBox(height: 8),
                _DealerCard(vehicle: vehicle),
              ],
              if (vehicle.description != null &&
                  vehicle.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _DescriptionBlock(text: vehicle.description!),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _CtaDock(vehicle: vehicle),
        ),
      ],
    );
  }

  Future<void> _handleFavTap(
      BuildContext context, WidgetRef ref, bool isAuth, String vehicleId) async {
    if (!isAuth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connectez-vous pour sauvegarder ce véhicule'),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 600));
      if (context.mounted) context.go('/login');
      return;
    }
    try {
      await ref.read(favoritesProvider.notifier).toggle(vehicleId);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }
}

class _PhotoHero extends StatelessWidget {
  const _PhotoHero({
    required this.vehicle,
    required this.isFav,
    required this.onFavTap,
  });

  final Vehicle vehicle;
  final bool isFav;
  final VoidCallback onFavTap;

  @override
  Widget build(BuildContext context) {
    final hasMedia = vehicle.media.isNotEmpty;

    return SizedBox(
      height: 240,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasMedia)
            PageView.builder(
              itemCount: vehicle.media.length,
              itemBuilder: (c, i) => _SafeImage(url: vehicle.media[i].bestUrl),
            )
          else
            const _NoImagePlaceholder(),
          Positioned(
            top: 12,
            right: 12,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 1,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onFavTap,
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? AppColors.error : AppColors.primary,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
          if (hasMedia)
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.image_outlined,
                        color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      '1/${vehicle.media.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
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

class _SafeImage extends StatelessWidget {
  const _SafeImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        color: AppColors.surfaceMuted,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (_, __, ___) => const _NoImagePlaceholder(),
    );
  }
}

class _NoImagePlaceholder extends StatelessWidget {
  const _NoImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceMuted,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.directions_car_outlined,
            size: 56,
            color: AppColors.textDisabled,
          ),
          SizedBox(height: 8),
          Text(
            'Pas de photo',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({required this.vehicle, required this.priceFmt});

  final Vehicle vehicle;
  final NumberFormat priceFmt;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${vehicle.brand.name} ${vehicle.model.name}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${_bodyType(vehicle.bodyType)} · ${vehicle.year} · ${priceFmt.format(vehicle.mileageKm)} km',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                priceFmt.format(vehicle.priceMru),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.priceColor,
                  letterSpacing: -0.4,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'MRU',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.priceColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.brand100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_down, size: 12, color: AppColors.brand700),
                SizedBox(width: 4),
                Text(
                  'Bon prix · sous le marché',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brand700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _bodyType(String s) {
    switch (s) {
      case 'sedan':
        return 'Berline';
      case 'suv':
        return 'SUV';
      case 'hatchback':
        return 'Compacte';
      case 'pickup':
        return 'Pickup';
      case 'van':
        return 'Utilitaire';
      case 'coupe':
        return 'Coupé';
      default:
        return s.isEmpty ? 'Véhicule' : s;
    }
  }
}

class _KeyFacts extends StatelessWidget {
  const _KeyFacts({required this.vehicle, required this.priceFmt});

  final Vehicle vehicle;
  final NumberFormat priceFmt;

  @override
  Widget build(BuildContext context) {
    final facts = <(String, String)>[
      ('Année', '${vehicle.year}'),
      ('Carburant', _fuel(vehicle.fuel)),
      ('Km', priceFmt.format(vehicle.mileageKm)),
      ('Boîte', _trans(vehicle.transmission)),
      ('Carrosserie', vehicle.bodyType),
      if (vehicle.city != null) ('Ville', vehicle.city!.name),
    ];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 5.5,
          crossAxisSpacing: 16,
        ),
        itemCount: facts.length,
        itemBuilder: (context, index) {
          final (label, value) = facts[index];
          return Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderSubtle),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _fuel(String s) {
    const map = {
      'gasoline': 'Essence',
      'diesel': 'Diesel',
      'hybrid': 'Hybride',
      'electric': 'Élec.',
      'gpl': 'GPL',
    };
    return map[s] ?? s;
  }

  String _trans(String s) =>
      s == 'manual' ? 'Manuelle' : (s == 'automatic' ? 'Auto.' : s);
}

class _DealerCard extends StatelessWidget {
  const _DealerCard({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final ag = vehicle.agency!;
    final initials = ag.name
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        ag.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.brand100,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        'VÉRIFIÉ',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brand700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Row(
                  children: [
                    Icon(Icons.star, size: 11, color: AppColors.rating),
                    SizedBox(width: 2),
                    Text(
                      '4.8',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '· Agence vérifiée',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 18,
            color: AppColors.textDisabled,
          ),
        ],
      ),
    );
  }
}

class _DescriptionBlock extends StatelessWidget {
  const _DescriptionBlock({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaDock extends StatelessWidget {
  const _CtaDock({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final phone = vehicle.agency?.phone;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.fromLTRB(
        12,
        10,
        12,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          _CtaButton.icon(
            icon: Icons.mail_outline,
            color: AppColors.primary,
            outlined: true,
            onTap: phone == null ? null : () {},
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _CtaButton.text(
              icon: Icons.chat_bubble_outline,
              label: 'WhatsApp',
              color: AppColors.whatsapp,
              onTap: phone == null ? null : () => _openWhatsApp(phone, vehicle),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _CtaButton.text(
              icon: Icons.phone,
              label: 'Appel',
              color: AppColors.primary,
              onTap: phone == null ? null : () => _call(phone),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsApp(String phone, Vehicle vehicle) async {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final msg = Uri.encodeComponent(
      'Bonjour, je suis intéressé par votre ${vehicle.brand.name} ${vehicle.model.name} ${vehicle.year}. Toujours disponible ?',
    );
    final uri = Uri.parse('https://wa.me/$clean?text=$msg');
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

class _CtaButton extends StatelessWidget {
  const _CtaButton.text({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : outlined = false;

  const _CtaButton.icon({
    required this.icon,
    required this.color,
    required this.onTap,
    this.outlined = true,
  }) : label = null;

  final String? label;
  final IconData icon;
  final Color color;
  final bool outlined;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isIconOnly = label == null;

    final content = SizedBox(
      height: 46,
      width: isIconOnly ? 46 : null,
      child: Row(
        mainAxisSize: isIconOnly ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: outlined ? color : Colors.white, size: 18),
          if (label != null) ...[
            const SizedBox(width: 6),
            Text(
              label!,
              style: TextStyle(
                color: outlined ? color : Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );

    return Material(
      color: outlined ? AppColors.surface : color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: outlined ? Border.all(color: color, width: 1.5) : null,
          ),
          child: content,
        ),
      ),
    );
  }
}
