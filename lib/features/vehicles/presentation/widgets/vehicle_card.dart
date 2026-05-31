import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/striped_placeholder.dart';
import '../../../../core/ui/icons/boursa_icons.dart';
import '../../../../core/utils/number_formatters.dart';
import '../../../../core/storage/locale_storage.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../data/models/vehicle.dart';

/// Card véhicule — fidèle au web Boursa.
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(isFavoriteProvider(vehicle.id));
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final l = AppLocalizations.of(context)!;
    final isSold = vehicle.isSold;
    final isDeal = vehicle.isDeal;

    // Ville : nom AR si dispo
    final cityName = isAr
        ? (vehicle.city?.nameAr ?? vehicle.city?.name ?? '')
        : (vehicle.city?.name ?? '');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(
              color: featured ? AppColors.primary : AppColors.border,
              width: featured ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [AppColors.cardShadow],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image + badges ──────────────────────────────────────────
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: _buildImage()),

                    // Badge DEAL — rouge pill avec icône tag (fidèle web)
                    if (isDeal && !isSold)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: _DealBadge(),
                      ),

                    // Badge VEDETTE
                    if (featured && !isDeal && !isSold)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: _PillBadge(
                          text: l.featuredLabel,
                          color: AppColors.primary,
                        ),
                      ),

                    // Overlay VENDU
                    if (isSold)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.6),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              isAr ? 'تم البيع' : 'VENDU',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Bouton favori
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _FavButton(
                        active: isFav,
                        onTap: () => ref
                            .read(favoritesProvider.notifier)
                            .toggle(vehicle.id),
                      ),
                    ),

                    // Compteur photos
                    if ((vehicle.mediaCount ?? 0) > 0)
                      Positioned(
                        bottom: 6,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.image,
                                  size: 9, color: Colors.white),
                              const SizedBox(width: 3),
                              Text(
                                '1/${vehicle.mediaCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Infos ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Text(
                      vehicle.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Année · km · carburant — toujours LTR
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        [
                          if (vehicle.year != null) '${vehicle.year}',
                          '${NumberFormatters.formatKm(vehicle.mileageKm)} km',
                          if (vehicle.fuel.isNotEmpty) vehicle.fuel,
                        ].join(' · '),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Prix barré si réduction
                    if (vehicle.originalPrice != null &&
                        vehicle.originalPrice! > vehicle.priceMru) ...[
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          '${NumberFormatters.formatPrice(vehicle.originalPrice!)} ${isAr ? "أوقية" : "MRU"}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    // Prix — LTR
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: NumberFormatters.formatPrice(
                                  vehicle.priceMru),
                              style: TextStyle(
                                color: isDeal
                                    ? const Color(0xFFDC2626)
                                    : AppColors.priceColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                              ),
                            ),
                            TextSpan(
                              text: ' ${isAr ? 'أوقية' : 'MRU'}',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Négociable
                    if (vehicle.priceNegotiable) ...[
                      const SizedBox(height: 4),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.handshake_outlined,
                            size: 11, color: AppColors.primary),
                        const SizedBox(width: 3),
                        Text(isAr ? 'قابل للتفاوض' : 'Négociable',
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                      ]),
                    ],
                    // Ville
                    if (cityName.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const BoursaPinIcon(
                              size: 10, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              cityName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildImage() {
    final url = vehicle.coverUrl;
    if (url == null || url.isEmpty) return const StripedPlaceholder();
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => const StripedPlaceholder(),
      errorWidget: (_, __, ___) => const StripedPlaceholder(),
    );
  }
}

// ── Badge DEAL rouge pill avec icône tag SVG (fidèle web) ─────────────────────
class _DealBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [
          BoxShadow(
              color: Color(0x44EF4444), blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CustomPaint(painter: _TagIconPainter()),
          ),
          const SizedBox(width: 4),
          const Text(
            'DEAL',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    // Tag shape (simplified from web SVG)
    path.moveTo(size.width * 0.4, size.width * 0.08);
    path.lineTo(size.width * 0.17, size.width * 0.08);
    path.arcToPoint(Offset(size.width * 0.08, size.width * 0.17),
        radius: Radius.circular(size.width * 0.1));
    path.lineTo(size.width * 0.08, size.width * 0.46);
    path.lineTo(size.width * 0.52, size.width * 0.83);
    path.arcToPoint(Offset(size.width * 0.64, size.width * 0.83),
        radius: Radius.circular(size.width * 0.08));
    path.lineTo(size.width * 0.86, size.width * 0.62);
    path.arcToPoint(Offset(size.width * 0.86, size.width * 0.5),
        radius: Radius.circular(size.width * 0.08));
    path.close();
    canvas.drawPath(path, paint);

    // Dot
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.29, size.width * 0.29),
        size.width * 0.1, dotPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [
          BoxShadow(
              color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _FavButton extends StatelessWidget {
  const _FavButton({required this.active, required this.onTap});
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 1,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Center(
            child: BoursaHeartIcon(
              size: 18,
              filled: active,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
