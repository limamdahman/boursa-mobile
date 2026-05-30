import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/storage/locale_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/ui/icons/boursa_icons.dart';
import '../../../../core/ui/striped_placeholder.dart';
import '../../../../core/utils/number_formatters.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../data/models/vehicle.dart';
import '../providers/listing_providers.dart';
import '../../../vehicles/presentation/providers/listing_providers.dart';

class VehicleDetailScreen extends ConsumerWidget {
  const VehicleDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVehicle = ref.watch(vehicleDetailProvider(id));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: asyncVehicle.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Impossible de charger ce véhicule.\n$e',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ),
        ),
        data: (vehicle) => _DetailBody(vehicle: vehicle, vehicleId: id),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BODY
// ═══════════════════════════════════════════════════════════════════════════

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.vehicle, required this.vehicleId});
  final Vehicle vehicle;
  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(isFavoriteProvider(vehicleId));
    final isAuth = ref.watch(isAuthenticatedProvider);
    final isSold = vehicle.isSold;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(bottom: isSold ? 24 : 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Banner agence (si disponible) ──────────────────────────
              if (vehicle.agency?.bannerUrl != null)
                _AgencyBanner(vehicle: vehicle),

              // ── Galerie ────────────────────────────────────────────────
              _Gallery(
                vehicle: vehicle,
                isFav: isFav,
                showBack: vehicle.agency?.bannerUrl == null,
                onFavTap: () => _handleFavTap(context, ref, isAuth, vehicleId),
                onBack: () => context.canPop() ? context.pop() : context.go('/'),
              ),

              // ── Price block ────────────────────────────────────────────
              _PriceBlock(vehicle: vehicle),

              // ── Agency card ────────────────────────────────────────────
              _AgencyCard(vehicle: vehicle),

              // ── Specs ──────────────────────────────────────────────────
              _SpecsGrid(vehicle: vehicle),

              // ── Description ────────────────────────────────────────────
              _DescriptionBlock(text: vehicle.description),

              // ── Grid toutes les photos ─────────────────────────────────
              if (vehicle.media.length > 1)
                _AllPhotosGrid(media: vehicle.media),

              // ── Section agence complète ────────────────────────────────
              if (vehicle.agency != null)
                _AgencySection(agency: vehicle.agency!),

              // ── Reviews ───────────────────────────────────────────────
              if (vehicle.agency != null || vehicle.user != null)
                _ReviewsSection(
                  vehicleId: vehicleId,
                  sellerId: vehicle.agency?.id ?? vehicle.user!.id,
                  sellerType: vehicle.agency != null ? 'agency' : 'user',
                ),

              // ── Autres véhicules agence ────────────────────────────────
              if (vehicle.agency != null)
                _OtherAgencyVehicles(
                  agencyId: vehicle.agency!.id,
                  excludeId: vehicleId,
                  agencyName: vehicle.agency!.name,
                ),

              // ── Véhicules similaires ───────────────────────────────────
              _SimilarVehicles(vehicleId: vehicleId),

              // ── Véhicule vendu ─────────────────────────────────────────
              if (isSold) _SoldBlock(),

              const SizedBox(height: 24),
            ],
          ),
        ),
        if (!isSold)
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _CtaDock(vehicle: vehicle),
          ),
        // Bouton retour si banner présente
        if (vehicle.agency?.bannerUrl != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 14,
            child: _RoundIconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
              onTap: () => context.canPop() ? context.pop() : context.go('/'),
            ),
          ),
      ],
    );
  }

  Future<void> _handleFavTap(BuildContext context, WidgetRef ref,
      bool isAuth, String vehicleId) async {
    if (!isAuth) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.authConnectForVehicle)));
      await Future.delayed(const Duration(milliseconds: 600));
      if (context.mounted) context.go('/login');
      return;
    }
    try {
      await ref.read(favoritesProvider.notifier).toggle(vehicleId);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')));
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BANNER AGENCE
// ═══════════════════════════════════════════════════════════════════════════

class _AgencyBanner extends StatelessWidget {
  const _AgencyBanner({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final agency = vehicle.agency!;
    final l = AppLocalizations.of(context)!;
    return SizedBox(
      height: 180,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: agency.bannerUrl!,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: const Color(0xFF0F172A)),
            errorWidget: (_, __, ___) => Container(color: const Color(0xFF0F172A)),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x80000000)],
              ),
            ),
          ),
          Positioned(
            bottom: 16, left: 16, right: 16,
            child: Row(
              children: [
                if (agency.logoUrl != null)
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(agency.logoUrl!, fit: BoxFit.cover),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.announcedBy,
                        style: const TextStyle(color: Colors.white70,
                          fontSize: 10, fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                      Text(agency.name,
                        style: const TextStyle(color: Colors.white,
                          fontSize: 17, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GALERIE
// ═══════════════════════════════════════════════════════════════════════════

class _Gallery extends StatefulWidget {
  const _Gallery({
    required this.vehicle, required this.isFav, required this.showBack,
    required this.onFavTap, required this.onBack,
  });
  final Vehicle vehicle;
  final bool isFav;
  final bool showBack;
  final VoidCallback onFavTap;
  final VoidCallback onBack;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  int _idx = 0;
  late final PageController _ctrl;

  @override
  void initState() { super.initState(); _ctrl = PageController(); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final media = widget.vehicle.media;
    final hasMedia = media.isNotEmpty;

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        children: [
          Positioned.fill(
            child: hasMedia
              ? PageView.builder(
                  controller: _ctrl,
                  itemCount: media.length,
                  onPageChanged: (i) => setState(() => _idx = i),
                  itemBuilder: (_, i) => CachedNetworkImage(
                    imageUrl: media[i].bestUrl, fit: BoxFit.cover,
                    placeholder: (_, __) => const StripedPlaceholder(),
                    errorWidget: (_, __, ___) => const StripedPlaceholder(),
                  ),
                )
              : const StripedPlaceholder(iconSize: 60),
          ),
          // Overlay vendu
          if (widget.vehicle.isSold)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text('VENDU',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
                        letterSpacing: 1, color: AppColors.textPrimary)),
                  ),
                ),
              ),
            ),
          if (widget.showBack)
            Positioned(
              top: MediaQuery.of(context).padding.top + 14, left: 16,
              child: _RoundIconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
                onTap: widget.onBack,
              ),
            ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 14, right: 16,
            child: _RoundIconButton(
              icon: BoursaHeartIcon(size: 20, filled: widget.isFav,
                activeColor: AppColors.primary, inactiveColor: AppColors.textSecondary),
              onTap: widget.onFavTap,
            ),
          ),
          if (hasMedia && media.length > 1)
            Positioned(
              left: 0, right: 0, bottom: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(media.length, (i) {
                  final active = i == _idx;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 6, height: 6,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white60,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),

        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white, shape: const CircleBorder(),
      elevation: 2, shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(), onTap: onTap,
        child: SizedBox(width: 40, height: 40, child: Center(child: icon)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PRICE BLOCK
// ═══════════════════════════════════════════════════════════════════════════

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final rating = _resolveRating(vehicle, context);
    final isDeal = vehicle.isDeal;
    final hasDiscount = vehicle.originalPrice != null &&
        vehicle.originalPrice! > vehicle.priceMru;

    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(
            color: Color(0x140F172A), blurRadius: 20, offset: Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre + ville + badge rating
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vehicle.title,
                        style: const TextStyle(fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary, height: 1.2)),
                      const SizedBox(height: 6),
                      // Sous-titre: body_type · year · km
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          [
                            if (vehicle.bodyType.isNotEmpty) vehicle.bodyType,
                            '${vehicle.year}',
                            '${NumberFormatters.formatKm(vehicle.mileageKm)} km',
                          ].join(' · '),
                          style: const TextStyle(fontSize: 12,
                            color: AppColors.textSecondary),
                        ),
                      ),
                      if (vehicle.city != null) ...[
                        const SizedBox(height: 4),
                        Row(children: [
                          const BoursaPinIcon(size: 13,
                            color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            isAr
                              ? (vehicle.city!.nameAr ?? vehicle.city!.name)
                              : (vehicle.city!.nameFr ?? vehicle.city!.name),
                            style: const TextStyle(fontSize: 13,
                              color: AppColors.textSecondary)),
                        ]),
                      ],
                    ],
                  ),
                ),
                if (rating != null) ...[
                  const SizedBox(width: 10),
                  _RatingBadge(rating: rating),
                ],
              ],
            ),
            const SizedBox(height: 14),
            // Badge DEAL
            if (isDeal) ...[
              _DealBadgeRow(),
              const SizedBox(height: 8),
            ],
            // Prix barré si réduction
            if (hasDiscount)
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '${NumberFormatters.formatPrice(vehicle.originalPrice!)} ${isAr ? 'أوقية' : 'MRU'}',
                  style: const TextStyle(fontSize: 14,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough),
                ),
              ),
            // Prix principal
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    NumberFormatters.formatPrice(vehicle.priceMru),
                    style: TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w800,
                      color: isDeal
                        ? const Color(0xFFDC2626)
                        : AppColors.priceColor,
                      height: 1.0, letterSpacing: -0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isAr ? 'أوقية' : 'MRU',
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: isDeal
                        ? const Color(0xFFDC2626)
                        : AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            // Prix négociable
            if (vehicle.priceNegotiable) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.string(_negotiableSvg,
                      width: 16, height: 16,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary, BlendMode.srcIn)),
                    const SizedBox(width: 4),
                    Text(l.priceNegotiable,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static const _negotiableSvg = '<svg viewBox="0 0 146 146" xmlns="http://www.w3.org/2000/svg"><path d="M56.19,55.79l4-5a1.58,1.58,0,0,1,.9-0.57l13.5-2.82a8,8,0,0,1,5.9.07l16.67,7.17,6-1.78,1.27-.49,8.86,23.12-4.93,3-1.6,5.6L88.07,73.64l0.06-.3a14.38,14.38,0,0,1-5.4-2.3,15.12,15.12,0,0,1-6-9.6h-10a11.36,11.36,0,0,1-17.2,2.8Z" fill="currentColor"/><path d="M76.54,104.17l-0.13.25a6.6,6.6,0,0,1-.88,5.82l0,0.06a5.24,5.24,0,0,1-6.57,1.38c-2.07-1.06-2.86-1.43-5.92-3L65.28,106a4.61,4.61,0,0,0-.66-6.41l-0.1-.08-0.08-.07a4.6,4.6,0,0,0-6.42.39l-0.46.54-0.51-.43A5,5,0,0,0,56.33,93l-0.1-.09-0.09-.07a5,5,0,0,0-6.94.42L49,93.48l-0.69-.58a5.21,5.21,0,1,0-7.43-7.25l-0.31-.26,0.38-.45A4.26,4.26,0,0,0,40.33,79l-0.09-.07-0.07-.06a4.26,4.26,0,0,0-5.94.36l-0.5.58-0.6-.5-6.47-.86,8.5-26.5,5.42,1.71,15.61.54-6.66,10a11.36,11.36,0,0,0,17.2-2.8h10a15.12,15.12,0,0,0,6,9.6,14.38,14.38,0,0,0,5.4,2.3l-0.06.3L106.73,84.1a5.61,5.61,0,0,1-4.52,10.26l-2.77-1.44a6.78,6.78,0,0,1-.71,5.71l0,0.07a5.28,5.28,0,0,1-6.82,1.62L89,98.84l-0.22.43a7.74,7.74,0,0,1-1.23,6.17l0,0a4.85,4.85,0,0,1-6.06,1.23Z" fill="currentColor"/></svg>';

  _Rating? _resolveRating(Vehicle v, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (v.priceRating == null || v.priceRating!.isEmpty) return null;
    Color color; Color bg;
    switch (v.priceRating) {
      case 'very_good': color = const Color(0xFF15803D); bg = const Color(0x1F16A34A); break;
      case 'good':      color = const Color(0xFF4D7C0F); bg = const Color(0x1F84CC16); break;
      case 'fair':      color = const Color(0xFFB45309); bg = const Color(0x1FEAB308); break;
      case 'high':      color = const Color(0xFFC2410C); bg = const Color(0x1FF97316); break;
      case 'very_high': color = const Color(0xFFB91C1C); bg = const Color(0x1AEF4444); break;
      default:          color = const Color(0xFF15803D); bg = const Color(0x1F16A34A);
    }
    final label = switch (v.priceRating) {
      'very_good' => l.priceRatingVeryGood,
      'good'      => l.priceRatingGood,
      'fair'      => l.priceRatingFair,
      'high'      => l.priceRatingHigh,
      'very_high' => l.priceRatingVeryHigh,
      _           => v.priceRating!,
    };
    return _Rating(label: label, color: color, bg: bg);
  }
}

class _DealBadgeRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.string(
            '<svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M9.5 2H4a2 2 0 0 0-2 2v5.5L12.5 20a2 2 0 0 0 2.83 0l5.17-5.17a2 2 0 0 0 0-2.83Z"/><circle cx="7" cy="7" r="1.5" fill="white" stroke="none"/></svg>',
            width: 13, height: 13,
          ),
          const SizedBox(width: 5),
          const Text('DEAL',
            style: TextStyle(color: Colors.white,
              fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _Rating {
  const _Rating({required this.label, required this.color, required this.bg});
  final String label;
  final Color color;
  final Color bg;
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});
  final _Rating rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: rating.bg, borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.star, size: 14, color: rating.color),
        const SizedBox(width: 5),
        Text(rating.label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
            color: rating.color)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// AGENCY CARD — fidèle au web
// ═══════════════════════════════════════════════════════════════════════════

class _AgencyCard extends StatelessWidget {
  const _AgencyCard({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final agency = vehicle.agency;
    final user = vehicle.user;
    final name = agency?.name ?? user?.name ?? l.vehicleSellerPrivate;
    final city = vehicle.city?.name ?? '';
    final isBusiness = agency?.subscriptionTier == 'business';
    final isPrivate = agency == null;

    final initials = name.trim().split(RegExp(r'\s+')).take(2)
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase()).join();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar — logo carré ou initiales
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: (agency?.logoUrl ?? user?.avatarUrl) != null
              ? Image.network((agency?.logoUrl ?? user?.avatarUrl)!, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(initials,
                      style: const TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w800, fontSize: 15))))
              : Center(child: Text(initials,
                  style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w800, fontSize: 15))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Flexible(child: Text(name,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary))),
                  if (isPrivate) ...[const SizedBox(width: 5),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(100)),
                      child: const Text('Particulier', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary)))],
                if (agency != null) ...[
                    const SizedBox(width: 5),
                    // Badge vérifié — gold pour business, vert sinon
                    Icon(Icons.verified,
                      size: 16,
                      color: isBusiness
                        ? const Color(0xFFF59E0B)
                        : AppColors.primary),
                  ],
                ]),
                const SizedBox(height: 2),
                Text(
                  agency != null
                    ? (city.isEmpty
                        ? l.verifiedAgencyDot
                        : '${l.verifiedAgencyDot} · $city')
                    : (city.isEmpty ? 'Particulier' : 'Particulier · $city'),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12,
                    color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (agency?.phone != null && agency!.phone!.isNotEmpty)
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse('tel:${agency.phone}');
                if (await canLaunchUrl(uri)) launchUrl(uri);
              },
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0x1F16A34A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.phone,
                  color: AppColors.primary, size: 20),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SPECS GRID — 6 facts comme le web
// ═══════════════════════════════════════════════════════════════════════════

class _SpecsGrid extends StatelessWidget {
  const _SpecsGrid({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final specs = [
      _Spec(Icons.calendar_today_outlined, '${vehicle.year}', l.vehicleYearLabel),
      _Spec(Icons.speed_outlined,
        '${NumberFormatters.formatKm(vehicle.mileageKm)} km', 'km'),
      _Spec(Icons.local_gas_station_outlined,
        _fuelLabel(vehicle.fuel, l), l.vehicleFuelLabel),
      _Spec(Icons.settings_outlined,
        _transLabel(vehicle.transmission, l), l.vehicleTransmission),
      _Spec(Icons.directions_car_outlined,
        vehicle.bodyType.isNotEmpty ? vehicle.bodyType : '—',
        l.vehicleBodyType),
      if (vehicle.city != null)
        _Spec(Icons.location_on_outlined,
          isAr
            ? (vehicle.city!.nameAr ?? vehicle.city!.name)
            : (vehicle.city!.nameFr ?? vehicle.city!.name),
          l.vehicleCityLabel),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 10,
          crossAxisSpacing: 10, childAspectRatio: 1.1,
        ),
        itemCount: specs.length,
        itemBuilder: (_, i) => _SpecCard(spec: specs[i]),
      ),
    );
  }

  String _fuelLabel(String s, AppLocalizations l) {
    return {
      'gasoline': l.fuelGasoline, 'diesel': l.fuelDiesel,
      'hybrid': l.fuelHybrid, 'electric': l.fuelElectric, 'gpl': l.fuelGpl,
    }[s] ?? (s.isEmpty ? '—' : s);
  }

  String _transLabel(String s, AppLocalizations l) {
    return {
      'manual': l.transmissionManual,
      'automatic': l.transmissionAutomatic,
    }[s] ?? (s.isEmpty ? '—' : s);
  }
}

class _Spec {
  const _Spec(this.icon, this.value, this.label);
  final IconData icon;
  final String value;
  final String label;
}

class _SpecCard extends StatelessWidget {
  const _SpecCard({required this.spec});
  final _Spec spec;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(spec.icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(spec.value, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(spec.label, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DESCRIPTION
// ═══════════════════════════════════════════════════════════════════════════

class _DescriptionBlock extends StatelessWidget {
  const _DescriptionBlock({required this.text});
  final String? text;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final body = (text == null || text!.trim().isEmpty)
        ? 'Aucune description fournie par le vendeur.'
        : text!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.vehicleDescriptionTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(body,
            style: const TextStyle(fontSize: 14,
              color: AppColors.textSecondary, height: 1.55)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VENDU BLOCK
// ═══════════════════════════════════════════════════════════════════════════

class _SoldBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(l.vehicleSold,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
          color: AppColors.textSecondary)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CTA DOCK
// ═══════════════════════════════════════════════════════════════════════════

class _CtaDock extends ConsumerWidget {
  const _CtaDock({required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final phone = vehicle.agency?.phoneWhatsapp ?? vehicle.agency?.phone
        ?? vehicle.user?.phoneWhatsapp ?? vehicle.user?.phoneCall;
    final hasPhone = phone != null && phone.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.fromLTRB(
        12, 12, 12, 12 + MediaQuery.of(context).padding.bottom),
      child: Row(
        children: [
          // Chat
          GestureDetector(
            onTap: vehicle.agency == null ? null : () async {
              try {
                final repo = ref.read(chatRepositoryProvider);
                final conv = await repo.getOrCreateConversation(vehicle.agency!.id);
                if (context.mounted) {
                  context.push('/chat/${conv.id}', extra: vehicle.agency!.name);
                }
              } catch (_) {}
            },
            child: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.primary, width: 1.5),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const BoursaChatIcon(
                size: 20, color: AppColors.primary, strokeWidth: 2),
            ),
          ),
          const SizedBox(width: 8),
          // WhatsApp
          Expanded(
            child: GestureDetector(
              onTap: hasPhone ? () => _openWhatsApp(phone, vehicle, isAr) : null,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: hasPhone ? const Color(0xFF25D366) : AppColors.border,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const BoursaChatIcon(size: 18, color: Colors.white,
                      filled: false, strokeWidth: 2),
                    const SizedBox(width: 6),
                    Text(l.contactWhatsApp,
                      style: const TextStyle(color: Colors.white,
                        fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Appel
          Expanded(
            child: GestureDetector(
              onTap: hasPhone ? () => _call(phone) : null,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: hasPhone ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: hasPhone ? [BoxShadow(
                    color: AppColors.primary.withOpacity(0.28),
                    blurRadius: 14, offset: const Offset(0, 4))] : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(l.contactCall,
                      style: const TextStyle(color: Colors.white,
                        fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsApp(String phone, Vehicle v, bool isAr) async {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final msg = isAr
      ? 'مرحباً، أنا مهتم بسيارتك ${v.brand.name} ${v.model.name} ${v.year}. هل لا تزال متوفرة؟'
      : 'Bonjour, je suis intéressé par votre ${v.brand.name} ${v.model.name} ${v.year}. Toujours disponible ?';
    final uri = Uri.parse('https://wa.me/$clean?text=${Uri.encodeComponent(msg)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// THUMBNAILS + ALL PHOTOS GRID
// ═══════════════════════════════════════════════════════════════════════════

class _AllPhotosGrid extends StatelessWidget {
  const _AllPhotosGrid({required this.media});
  final List<VehicleMedia> media;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.photo_library_outlined,
              size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text('${l.allPhotos} (${media.length})',
              style: const TextStyle(fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, mainAxisSpacing: 6,
              crossAxisSpacing: 6, childAspectRatio: 1.2,
            ),
            itemCount: media.length,
            itemBuilder: (_, i) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: media[i].bestThumb,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.border),
                errorWidget: (_, __, ___) => Container(color: AppColors.border),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// AGENCY SECTION COMPLÈTE
// ═══════════════════════════════════════════════════════════════════════════

class _AgencySection extends StatelessWidget {
  const _AgencySection({required this.agency});
  final AgencyLite agency;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isBusiness = agency.subscriptionTier == 'business';
    final initials = agency.name.trim().split(RegExp(r'\s+')).take(2)
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase()).join();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Text(l.aboutAgency,
                  style: const TextStyle(fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
                const Spacer(),
                if (isBusiness)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text('BUSINESS',
                      style: TextStyle(color: Colors.white,
                        fontSize: 9, fontWeight: FontWeight.w800)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Logo + nom + stats
                Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: agency.logoUrl != null
                        ? Image.network(agency.logoUrl!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(initials,
                                style: const TextStyle(color: Colors.white,
                                  fontWeight: FontWeight.w800, fontSize: 18))))
                        : Center(child: Text(initials,
                            style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w800, fontSize: 18))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Flexible(child: Text(agency.name,
                              style: const TextStyle(fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary))),
                            const SizedBox(width: 5),
                            Icon(Icons.verified, size: 16,
                              color: isBusiness
                                ? const Color(0xFFF59E0B)
                                : AppColors.primary),
                          ]),
                          if (agency.vehiclesCount != null)
                            Text('${agency.vehiclesCount} ${l.agencyActiveListings}',
                              style: const TextStyle(fontSize: 12,
                                color: AppColors.textSecondary)),
                          if (agency.city != null)
                            Text(agency.city!,
                              style: const TextStyle(fontSize: 12,
                                color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                // Description
                if (agency.description != null &&
                    agency.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(agency.description!,
                    style: const TextStyle(fontSize: 13,
                      color: AppColors.textSecondary, height: 1.5)),
                ],
                // Adresse
                if (agency.address != null &&
                    agency.address!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                      size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Flexible(child: Text(agency.address!,
                      style: const TextStyle(fontSize: 12,
                        color: AppColors.textSecondary))),
                  ]),
                ],
                // Email
                if (agency.email != null && agency.email!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.email_outlined,
                      size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Flexible(child: Text(agency.email!,
                      style: const TextStyle(fontSize: 12,
                        color: AppColors.textSecondary))),
                  ]),
                ],
              ],
            ),
          ),
          // Carte si lat/lng disponibles
          if (agency.lat != null && agency.lng != null) ...[
            const Divider(height: 1),
            _AgencyMap(lat: agency.lat!, lng: agency.lng!, name: agency.name, address: agency.address),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VÉHICULES SIMILAIRES
// ═══════════════════════════════════════════════════════════════════════════

class _SimilarVehicles extends ConsumerWidget {
  const _SimilarVehicles({required this.vehicleId});
  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final similar = ref.watch(vehicleSimilarProvider(vehicleId));

    return similar.when(
      loading: () => const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator(
          color: AppColors.primary, strokeWidth: 2))),
      error: (_, __) => const SizedBox.shrink(),
      data: (vehicles) {
        if (vehicles.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.similarVehicles,
                style: const TextStyle(fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary, letterSpacing: -0.3)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 12,
                  crossAxisSpacing: 12, childAspectRatio: 0.72,
                ),
                itemCount: vehicles.length > 6 ? 6 : vehicles.length,
                itemBuilder: (ctx, i) {
                  final v = vehicles[i];
                  return GestureDetector(
                    onTap: () => context.push('/vehicle/${v.id}'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 4 / 3,
                            child: v.coverUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: v.coverUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: AppColors.border),
                                  errorWidget: (_, __, ___) => Container(
                                    color: AppColors.border))
                              : Container(color: AppColors.border),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(v.title, maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                                const SizedBox(height: 3),
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    '${v.year} · ${NumberFormatters.formatKm(v.mileageKm)} km',
                                    style: const TextStyle(fontSize: 10,
                                      color: AppColors.textSecondary)),
                                ),
                                const SizedBox(height: 6),
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    '${NumberFormatters.formatPrice(v.priceMru)} MRU',
                                    style: const TextStyle(fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.priceColor)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CARTE LOCALISATION
// ═══════════════════════════════════════════════════════════════════════════

class _AgencyMap extends StatelessWidget {
  const _AgencyMap({required this.lat, required this.lng, required this.name, this.address});
  final double lat;
  final double lng;
  final String name;
  final String? address;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final locationLabel = isAr ? 'موقع الوكالة' : "Position de l'agence";
    final directionsLabel = isAr ? 'الاتجاهات' : 'Itinéraire';
    final fullAddress = [address, ''].where((s) => s != null && s.isNotEmpty).join(', ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.map_outlined, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(l.agencyLocation,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(lat, lng),
                      initialZoom: 16,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.boursa.mobile',
                      ),
                      MarkerLayer(markers: [
                        Marker(
                          point: LatLng(lat, lng),
                          width: 34, height: 42,
                          alignment: Alignment.topCenter,
                          child: SvgPicture.string(
                            '<svg xmlns="http://www.w3.org/2000/svg" width="34" height="42" viewBox="0 0 34 42"><path d="M17 0C7.6 0 0 7.6 0 17c0 12.5 17 25 17 25s17-12.5 17-25c0-9.4-7.6-17-17-17z" fill="#16A34A" stroke="white" stroke-width="2.5"/><circle cx="17" cy="17" r="6" fill="white"/></svg>',
                          ),
                        ),
                      ]),
                    ],
                  ),
                  // Popup style web — centré
                  Positioned(
                    top: 10, left: 0, right: 0,
                    child: Center(
                      child: Container(
                      constraints: const BoxConstraints(maxWidth: 220),
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [BoxShadow(
                          color: Color(0x33000000), blurRadius: 8,
                          offset: Offset(0, 2))],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📍 $locationLabel',
                            style: const TextStyle(fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          Text(name,
                            style: const TextStyle(fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary)),
                          if (address != null && address!.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(address!,
                              style: const TextStyle(fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.4)),
                          ],
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              final uri = Uri.parse(
                                'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
                              if (await canLaunchUrl(uri)) {
                                launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.arrow_forward,
                                    color: Colors.white, size: 12),
                                  const SizedBox(width: 5),
                                  Text(directionsLabel,
                                    style: const TextStyle(color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

// ═══════════════════════════════════════════════════════════════════════════
// AUTRES VÉHICULES DE L'AGENCE (scroll horizontal)
// ═══════════════════════════════════════════════════════════════════════════

class _OtherAgencyVehicles extends ConsumerWidget {
  const _OtherAgencyVehicles({required this.agencyId, required this.excludeId, required this.agencyName});
  final String agencyId;
  final String excludeId;
  final String agencyName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final async = ref.watch(agencyVehiclesProvider((agencyId: agencyId, excludeId: excludeId)));

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (vehicles) {
        if (vehicles.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.otherVehicles,
                      style: const TextStyle(fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary, letterSpacing: -0.3)),
                    Text('$agencyName · ${vehicles.length} ${l.agencyActiveListings}',
                      style: const TextStyle(fontSize: 12,
                        color: AppColors.textSecondary)),
                  ],
                ),
              ),
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: vehicles.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (ctx, i) {
                    final v = vehicles[i];
                    return GestureDetector(
                      onTap: () => context.push('/vehicle/${v.id}'),
                      child: SizedBox(
                        width: 160,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AspectRatio(
                                aspectRatio: 4 / 3,
                                child: v.coverUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: v.coverUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(color: AppColors.border),
                                      errorWidget: (_, __, ___) => Container(color: AppColors.border))
                                  : Container(color: AppColors.border),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(v.title, maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary)),
                                    const SizedBox(height: 2),
                                    Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Text(
                                        '${v.year} · ${NumberFormatters.formatKm(v.mileageKm)} km',
                                        style: const TextStyle(fontSize: 10,
                                          color: AppColors.textSecondary)),
                                    ),
                                    const SizedBox(height: 4),
                                    Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Text(
                                        '${NumberFormatters.formatPrice(v.priceMru)} ${isAr ? 'أوقية' : 'MRU'}',
                                        style: const TextStyle(fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.priceColor)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// REVIEWS SECTION
// ═══════════════════════════════════════════════════════════════════════════

final _reviewSummaryProvider = FutureProvider.family<Map<String, dynamic>, ({String sellerId, String sellerType})>((ref, args) async {
  final dio = ref.read(apiClientProvider);
  final path = args.sellerType == 'user' ? '/sellers/users/${args.sellerId}/rating-summary' : '/sellers/agencies/${args.sellerId}/rating-summary';
  final r = await dio.get(path);
  return r.data as Map<String, dynamic>;
});

final _reviewListProvider = FutureProvider.family<List<dynamic>, ({String sellerId, String sellerType})>((ref, args) async {
  final dio = ref.read(apiClientProvider);
  final path = args.sellerType == 'user' ? '/sellers/users/${args.sellerId}/reviews' : '/sellers/agencies/${args.sellerId}/reviews';
  final r = await dio.get(path);
  final data = r.data;
  if (data is Map) return (data['data'] as List?) ?? [];
  return [];
});

final _canReviewProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, vehicleId) async {
  try {
    final dio = ref.read(apiClientProvider);
    final r = await dio.get('/vehicles/$vehicleId/can-review');
    return r.data as Map<String, dynamic>;
  } catch (_) {
    return {'can_review': false, 'reason': 'unauthenticated'};
  }
});

class _ReviewsSection extends ConsumerStatefulWidget {
  const _ReviewsSection({required this.vehicleId, required this.sellerId, required this.sellerType});
  final String vehicleId;
  final String sellerId;
  final String sellerType;

  @override
  ConsumerState<_ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends ConsumerState<_ReviewsSection> {
  bool _showForm = false;
  int _rating = 5;
  final _commentCtrl = TextEditingController();
  bool _submitting = false;
  String _error = '';
  String _success = '';

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations l) async {
    setState(() { _submitting = true; _error = ''; _success = ''; });
    try {
      final dio = ref.read(apiClientProvider);
      await dio.post('/reviews', data: {
        'vehicle_id': widget.vehicleId,
        'rating': _rating,
        if (_commentCtrl.text.trim().isNotEmpty)
          'comment': _commentCtrl.text.trim(),
      });
      setState(() { _success = l.reviewsSuccess; _showForm = false; });
      ref.invalidate(_reviewSummaryProvider((sellerId: widget.sellerId, sellerType: widget.sellerType)));
      ref.invalidate(_reviewListProvider((sellerId: widget.sellerId, sellerType: widget.sellerType)));
      ref.invalidate(_canReviewProvider(widget.vehicleId));
    } catch (e) {
      setState(() => _error = l.reviewsError);
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isAuth = ref.watch(isAuthenticatedProvider);
    final summary = ref.watch(_reviewSummaryProvider((sellerId: widget.sellerId, sellerType: widget.sellerType)));
    final reviews = ref.watch(_reviewListProvider((sellerId: widget.sellerId, sellerType: widget.sellerType)));
    final canReview = ref.watch(_canReviewProvider(widget.vehicleId));

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.reviewsTitle,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary)),
          const SizedBox(height: 12),

          // Résumé
          summary.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (s) {
              final count = (s['count'] as num?)?.toInt() ?? 0;
              final avg = (s['average'] as num?)?.toDouble() ?? 0.0;
              if (count == 0) return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text(l.reviewsNone,
                  style: const TextStyle(fontSize: 13,
                    color: AppColors.textSecondary))),
              );
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  Text(avg.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _StarRow(value: avg.round()),
                    const SizedBox(height: 2),
                    Text('${l.reviewsBasedOn} $count ${l.reviewsCount(count)}',
                      style: const TextStyle(fontSize: 12,
                        color: AppColors.textSecondary)),
                  ]),
                ]),
              );
            },
          ),
          const SizedBox(height: 12),

          // Bouton laisser un avis
          if (isAuth)
            canReview.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (cr) {
                if (cr['can_review'] == true && !_showForm)
                  return Column(children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => setState(() => _showForm = true),
                        icon: const Icon(Icons.edit, size: 14),
                        label: Text(cr['existing_review'] != null
                          ? l.reviewsEdit : l.reviewsLeave),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ]);

                if (!cr['can_review'] && cr['reason'] == 'no_lead')
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline,
                        size: 14, color: Color(0xFF92400E)),
                      const SizedBox(width: 6),
                      Flexible(child: Text(l.reviewsNoLead,
                        style: const TextStyle(fontSize: 12,
                          color: Color(0xFF92400E)))),
                    ]),
                  );

                return const SizedBox.shrink();
              },
            )
          else
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline,
                  size: 14, color: Color(0xFF0369A1)),
                const SizedBox(width: 6),
                Flexible(child: Text(l.reviewsLogin,
                  style: const TextStyle(fontSize: 12,
                    color: Color(0xFF0369A1)))),
              ]),
            ),

          // Formulaire
          if (_showForm) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(_error,
                        style: const TextStyle(fontSize: 12,
                          color: Color(0xFF991B1B))),
                    ),
                  Text(l.reviewsRating,
                    style: const TextStyle(fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  _StarRatingInput(
                    value: _rating,
                    onChange: (v) => setState(() => _rating = v),
                  ),
                  const SizedBox(height: 12),
                  Text(l.reviewsComment,
                    style: const TextStyle(fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _commentCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l.reviewsCommentHint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _submitting ? null
                          : () => setState(() {
                            _showForm = false; _error = '';
                          }),
                        child: Text(l.reviewsCancel),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: _submitting ? null : () => _submit(l),
                        child: Text(_submitting
                          ? l.reviewsSubmitting : l.reviewsSubmit),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Succès
          if (_success.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                border: Border.all(color: const Color(0xFFBBF7D0)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(_success,
                style: const TextStyle(fontSize: 12,
                  color: AppColors.primary)),
            ),

          // Liste reviews
          reviews.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (list) => Column(
              children: list.map<Widget>((r) {
                final name = (r['reviewer']?['name'] ?? '?') as String;
                final rating = (r['rating'] as num?)?.toInt() ?? 0;
                final comment = r['comment'] as String?;
                final date = r['created_at'] as String? ?? '';
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primary,
                              child: Text(name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white,
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 8),
                            Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                  style: const TextStyle(fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                                if (date.isNotEmpty)
                                  Text(date.substring(0, 7),
                                    style: const TextStyle(fontSize: 11,
                                      color: AppColors.textSecondary)),
                              ]),
                          ]),
                          _StarRow(value: rating),
                        ],
                      ),
                      if (comment != null && comment.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(comment,
                          style: const TextStyle(fontSize: 13,
                            color: AppColors.textSecondary, height: 1.5)),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.value});
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => Icon(
        i < value ? Icons.star : Icons.star_border,
        size: 14,
        color: const Color(0xFFF59E0B),
      )),
    );
  }
}

class _StarRatingInput extends StatelessWidget {
  const _StarRatingInput({required this.value, required this.onChange});
  final int value;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => GestureDetector(
        onTap: () => onChange(i + 1),
        child: Icon(
          i < value ? Icons.star : Icons.star_border,
          size: 28,
          color: const Color(0xFFF59E0B),
        ),
      )),
    );
  }
}
