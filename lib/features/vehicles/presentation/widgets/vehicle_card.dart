import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../data/models/vehicle.dart';

class VehicleCard extends ConsumerWidget {
  const VehicleCard({super.key, required this.vehicle, required this.onTap, this.featured = false});
  final Vehicle vehicle;
  final VoidCallback onTap;
  final bool featured;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(isFavoriteProvider(vehicle.id));

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: featured ? AppColors.primary : AppColors.border, width: featured ? 1.5 : 1),
            boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 12, offset: Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _ImageHeader(vehicle: vehicle, featured: featured, isFavorite: isFav,
                  onFavoriteTap: () => ref.read(favoritesProvider.notifier).toggle(vehicle.id)),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(vehicle.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.sourceSans3(fontSize: 15, fontWeight: FontWeight.w600, height: 1.2, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    // Ville • km
                    Row(children: [
                      const Icon(Icons.place_outlined, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      if (vehicle.city != null)
                        Flexible(child: Text(vehicle.city!.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.sourceSans3(fontSize: 13, color: AppColors.textSecondary))),
                      Text('  •  ', style: GoogleFonts.sourceSans3(fontSize: 13, color: AppColors.textSecondary)),
                      Text(_formatKm(vehicle.mileageKm),
                          style: GoogleFonts.sourceSans3(fontSize: 13, color: AppColors.textSecondary)),
                    ]),
                    const SizedBox(height: 10),
                    // Prix
                    Text(_formatPrice(vehicle.priceMru), maxLines: 1,
                        style: GoogleFonts.sourceSans3(fontSize: 17, fontWeight: FontWeight.w700, height: 1.0, color: AppColors.priceColor)),
                    // Badge prix juste
                    if (vehicle.priceRating != null && vehicle.priceRatingLabel != null) ...[
                      const SizedBox(height: 5),
                      _PriceRatingBadge(label: vehicle.priceRatingLabel!, color: _ratingColor(vehicle.priceRating!)),
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
}

class _ImageHeader extends StatelessWidget {
  const _ImageHeader({required this.vehicle, required this.featured, required this.isFavorite, required this.onFavoriteTap});
  final Vehicle vehicle;
  final bool featured;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final url = vehicle.coverUrl;
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(fit: StackFit.expand, children: [
        // Image ou placeholder rayé diagonal
        url != null
            ? CachedNetworkImage(imageUrl: url, fit: BoxFit.cover,
                placeholder: (_, __) => const _StripedPlaceholder(),
                errorWidget: (_, __, ___) => const _StripedPlaceholder())
            : const _StripedPlaceholder(),
        // Voile sombre bas
        const DecoratedBox(decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x18000000)]))),
        // Badge VENDU
        if (vehicle.isSold)
          Container(color: Colors.black54, alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
                child: const Text('VENDU', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
              )),
        // Badge DEAL / VEDETTE
        if (!vehicle.isSold && (vehicle.isDeal || featured))
          Positioned(top: 10, left: 10,
              child: _Badge(label: vehicle.isDeal ? 'DEAL' : 'VEDETTE',
                  color: vehicle.isDeal ? AppColors.primary : AppColors.priceColor)),
        // Favori
        Positioned(top: 8, right: 8,
            child: Material(color: Colors.white, shape: const CircleBorder(), clipBehavior: Clip.antiAlias, elevation: 1,
                child: InkWell(onTap: onFavoriteTap,
                    child: Padding(padding: const EdgeInsets.all(6),
                        child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, size: 16,
                            color: isFavorite ? AppColors.primary : AppColors.textSecondary))))),
      ]),
    );
  }
}

/// Placeholder rayé diagonal comme dans le mockup HTML
class _StripedPlaceholder extends StatelessWidget {
  const _StripedPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEF2F6), Color(0xFFE6EBF1)],
        ),
      ),
      child: CustomPaint(
        painter: _StripePainter(),
        child: const Center(
          child: Icon(Icons.directions_car_outlined, size: 40, color: Color(0xFFCBD5E1)),
        ),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDDE3EA)
      ..strokeWidth = 10;
    for (double i = -size.height; i < size.width + size.height; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2))]),
      child: Text(label, style: GoogleFonts.sourceSans3(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: Colors.white)),
    );
  }
}

class _PriceRatingBadge extends StatelessWidget {
  const _PriceRatingBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(5)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.trending_down, size: 11, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

Color _ratingColor(String r) => switch (r) {
  'very_good' => const Color(0xFF16A34A),
  'good'      => const Color(0xFF84CC16),
  'fair'      => const Color(0xFFEAB308),
  'high'      => const Color(0xFFF97316),
  'very_high' => const Color(0xFFDC2626),
  _           => AppColors.textMuted,
};

String _formatPrice(int v) => '${_g(v)} MRU';
String _formatKm(int v) => '${_g(v)} km';
String _g(int v) {
  final s = v.abs().toString();
  final b = StringBuffer(v < 0 ? '-' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('\u202F');
    b.write(s[i]);
  }
  return b.toString();
}
