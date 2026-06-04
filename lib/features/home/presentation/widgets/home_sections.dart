import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/number_formatters.dart';
import '../../../../core/storage/locale_storage.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../agencies/data/models/agency.dart';
import '../../../agencies/presentation/providers/agencies_provider.dart';
import '../../../vehicles/presentation/providers/vehicle_filter.dart';
import '../../../vehicles/data/repositories/reference_repository.dart';
import '../../../vehicles/data/repositories/vehicle_repository.dart';
import '../../../vehicles/data/models/reference.dart';

const _popularBrandOrder = [
  'toyota',
  'hyundai',
  'nissan',
  'mercedes',
  'kia',
  'renault',
  'peugeot',
  'mitsubishi',
  'ford',
  'jetour',
];

String _normBrand(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

List<BrandRef> _sortPopularBrands(List<BrandRef> brands) {
  int rank(BrandRef b) {
    final n = _normBrand(b.slug ?? b.name);
    final i =
        _popularBrandOrder.indexWhere((p) => n.contains(p) || p.contains(n));
    return i == -1 ? 999 : i;
  }

  final sorted = [...brands];
  sorted.sort((a, b) {
    final ra = rank(a), rb = rank(b);
    if (ra != rb) return ra.compareTo(rb);
    return a.name.compareTo(b.name);
  });
  return sorted;
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION CATÉGORIES
// ═══════════════════════════════════════════════════════════════════════════════

class SectionCategories extends ConsumerWidget {
  const SectionCategories({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final isAr = ref.watch(localeProvider).languageCode == 'ar';

    final cats = [
      _Cat('sedan', l.catSedan, Icons.directions_car,
          const VehicleFilter(bodyType: 'sedan')),
      _Cat('suv', l.catSuv, Icons.directions_car_filled,
          const VehicleFilter(bodyType: 'suv')),
      _Cat('pickup', l.catPickup, Icons.local_shipping,
          const VehicleFilter(bodyType: 'pickup')),
      _Cat('van', l.catVan, Icons.airport_shuttle,
          const VehicleFilter(bodyType: 'van')),
      _Cat('hatchback', l.catHatchback, Icons.directions_car_outlined,
          const VehicleFilter(bodyType: 'hatchback')),
      _Cat('electric', l.catElectric, Icons.bolt,
          const VehicleFilter(fuel: 'hybrid')),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
                child: Text(l.categoriesTitle,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3))),
            GestureDetector(
              onTap: () => context.go('/vehicules'),
              child: Text(l.categoriesViewAll,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ),
          ]),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.1,
              ),
              itemCount: cats.length,
              itemBuilder: (context, i) => _CatCell(
                cat: cats[i],
                isLast: i == cats.length - 1,
                ref: ref,
                onTap: () => context.go('/vehicules', extra: cats[i].filter),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Cat {
  const _Cat(this.key, this.label, this.icon, this.filter);
  final String key;
  final String label;
  final IconData icon;
  final VehicleFilter filter;
}

class _CatCell extends ConsumerStatefulWidget {
  const _CatCell(
      {required this.cat,
      required this.isLast,
      required this.ref,
      required this.onTap});
  final _Cat cat;
  final bool isLast;
  final WidgetRef ref;
  final VoidCallback onTap;
  @override
  ConsumerState<_CatCell> createState() => _CatCellState();
}

class _CatCellState extends ConsumerState<_CatCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(_catCountProvider(widget.cat.filter));
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _hovered = true),
        onTapUp: (_) => setState(() => _hovered = false),
        onTapCancel: () => setState(() => _hovered = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFFF0FDF4) : Colors.transparent,
            border: Border(
              right: BorderSide(color: AppColors.border),
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CategorySvgIcon(
                      name: widget.cat.key,
                      size: 32,
                      color: _hovered
                          ? AppColors.primary
                          : const Color(0xFF0F172A),
                    ),
                    const SizedBox(height: 6),
                    Text(widget.cat.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _hovered
                                ? AppColors.primary
                                : AppColors.textPrimary)),
                  ],
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: count.when(
                  data: (n) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text('$n',
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary)),
                  ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final _catCountProvider =
    FutureProvider.family<int, VehicleFilter>((ref, filter) async {
  try {
    final repo = ref.read(vehicleRepositoryProvider);
    final result = await repo.list(
      page: 1,
      perPage: 5,
      bodyType: filter.bodyType,
      fuel: filter.fuel,
    );
    return result.total;
  } catch (_) {
    return 0;
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION MARQUES
// ═══════════════════════════════════════════════════════════════════════════════

class SectionBrands extends ConsumerWidget {
  const SectionBrands({super.key});

  static const _slugOverrides = {
    'mercedes': 'mercedes-benz',
    'landrover': 'land-rover',
    'vw': 'volkswagen',
    'citroen': 'citroen',
    'citroën': 'citroen',
  };

  static String logoUrl(String slug) {
    final s = (_slugOverrides[slug.toLowerCase()] ?? slug.toLowerCase())
        .replaceAll(' ', '-');
    // Plusieurs sources de fallback
    return 'https://www.carlogos.org/car-logos/\$s-logo.png';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final brands = ref.watch(brandsListProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.brandsTitle,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3)),
                const SizedBox(height: 2),
                Text(l.brandsSubtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            )),
            GestureDetector(
              onTap: () => context.go('/vehicules'),
              child: Text(l.brandsViewAll,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ),
          ]),
          const SizedBox(height: 12),
          brands.when(
            loading: () => const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2)),
            error: (_, __) => const SizedBox(),
            data: (rawList) {
              final list = _sortPopularBrands(rawList);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.0,
                ),
                itemCount: list.length > 12 ? 12 : list.length,
                itemBuilder: (context, i) {
                  final brand = list[i];
                  final url = logoUrl(brand.slug ?? brand.name.toLowerCase());
                  return GestureDetector(
                    onTap: () => context.go('/vehicules',
                        extra: VehicleFilter(brandId: brand.id)),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: _BrandLogo(
                              name: brand.name,
                              slug: brand.slug ?? brand.name.toLowerCase(),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(brand.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION LIFESTYLE
// ═══════════════════════════════════════════════════════════════════════════════

class SectionLifestyle extends ConsumerWidget {
  const SectionLifestyle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;

    final cats = [
      _LifeCat(l.lifeFamilyTitle, l.lifeFamilyDesc, l.lifeFamilyBadge,
          const Color(0xFF16A34A), const VehicleFilter(bodyType: 'suv')),
      _LifeCat(l.lifePremiumTitle, l.lifePremiumDesc, l.lifePremiumBadge,
          const Color(0xFF0F172A), const VehicleFilter(priceMin: 3000000)),
      _LifeCat(l.lifeFirstTitle, l.lifeFirstDesc, l.lifeFirstBadge,
          const Color(0xFFD97706), const VehicleFilter(priceMax: 800000)),
      _LifeCat(l.lifePickupTitle, l.lifePickupDesc, l.lifePickupBadge,
          const Color(0xFF15803D), const VehicleFilter(bodyType: 'pickup')),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.lifestyleTitle,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3)),
          const SizedBox(height: 2),
          Text(l.lifestyleSubtitle,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.78,
            ),
            itemCount: cats.length,
            itemBuilder: (ctx, i) => _LifeCard(cat: cats[i], ref: ref),
          ),
        ],
      ),
    );
  }
}

class _LifeCat {
  const _LifeCat(this.title, this.desc, this.badge, this.color, this.filter);
  final String title, desc, badge;
  final Color color;
  final VehicleFilter filter;
}

class _LifeCard extends ConsumerWidget {
  const _LifeCard({required this.cat, required this.ref});
  final _LifeCat cat;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef r) {
    final l = AppLocalizations.of(context)!;
    final data = r.watch(_lifestyleProvider(cat.filter));

    return GestureDetector(
      onTap: () => context.go('/vehicules', extra: cat.filter),
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
            // Image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  data.when(
                    data: (d) => d.cover != null
                        ? Image.network(d.cover!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _darkBg())
                        : _darkBg(),
                    loading: () => _darkBg(),
                    error: (_, __) => _darkBg(),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x66000000)],
                      ),
                    ),
                  ),
                  // Badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: cat.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(cat.badge,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4)),
                    ),
                  ),
                  // Count
                  data.when(
                    data: (d) => Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text('${d.count} ${l.lifestyleVehicles}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cat.title,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(cat.desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          height: 1.3)),
                  const SizedBox(height: 6),
                  const Divider(height: 1),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: data.when(
                          data: (d) => Text(
                              '${l.lifestyleFrom} ${NumberFormatters.formatPrice(d.minPrice)} MRU',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFD97706),
                                  fontWeight: FontWeight.w700)),
                          loading: () => const SizedBox(),
                          error: (_, __) => const SizedBox(),
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0FDF4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward,
                            size: 12, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _darkBg() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1f2937), Color(0xFF0f172a)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );
}

class _LifeData {
  const _LifeData({this.cover, required this.count, required this.minPrice});
  final String? cover;
  final int count;
  final int minPrice;
}

final _lifestyleProvider =
    FutureProvider.family<_LifeData, VehicleFilter>((ref, filter) async {
  try {
    final repo = ref.read(vehicleRepositoryProvider);
    final result = await repo.list(
      page: 1,
      perPage: 5,
      bodyType: filter.bodyType,
      fuel: filter.fuel,
      priceMin: filter.priceMin,
      priceMax: filter.priceMax,
    );
    final first = result.items.isNotEmpty ? result.items.first : null;
    return _LifeData(
      cover: first?.coverUrl,
      count: result.total,
      minPrice: first?.priceMru ?? 0,
    );
  } catch (_) {
    return const _LifeData(count: 0, minPrice: 0);
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION AGENCY CTA
// ═══════════════════════════════════════════════════════════════════════════════

class SectionAgencyCta extends StatelessWidget {
  const SectionAgencyCta({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final stats = [
      ('142', l.agencyStatPartners),
      ('2 470', l.agencyStatListings),
      ('12k+', l.agencyStatVisitors),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.agencyCtaTitle,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2)),
            const SizedBox(height: 6),
            Text(l.agencyCtaSubtitle,
                style: TextStyle(
                    fontSize: 12, color: Colors.white.withOpacity(0.7))),
            const SizedBox(height: 16),
            Row(
              children: stats
                  .map((s) => Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(s.$1,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary)),
                            ),
                            Text(s.$2,
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.6),
                                    letterSpacing: 0.3)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push('/tarifs'),
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: Text(l.agencyCtaButton),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION TRUST BAR
// ═══════════════════════════════════════════════════════════════════════════════

class SectionTrustBar extends StatelessWidget {
  const SectionTrustBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final items = [
      (Icons.verified_outlined, l.trustVerifiedTitle, l.trustVerifiedDesc),
      (Icons.sell_outlined, l.trustPricesTitle, l.trustPricesDesc),
      (Icons.chat_outlined, l.trustContactTitle, l.trustContactDesc),
      (Icons.location_on_outlined, l.trustLocalTitle, l.trustLocalDesc),
    ];

    return Container(
      margin: const EdgeInsets.only(top: 28),
      decoration: const BoxDecoration(
        border:
            Border.symmetric(horizontal: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: items
            .map((item) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.brand100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            Icon(item.$1, size: 18, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.$2,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                            Text(item.$3,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ── Logo marque avec fallback initiale ────────────────────────────────────────
class _BrandLogo extends StatefulWidget {
  const _BrandLogo({required this.name, required this.slug});
  final String name;
  final String slug;

  static const _domains = {
    'toyota': 'toyota.com',
    'hyundai': 'hyundai.com',
    'kia': 'kia.com',
    'nissan': 'nissan.com',
    'honda': 'honda.com',
    'ford': 'ford.com',
    'renault': 'renault.com',
    'peugeot': 'peugeot.com',
    'bmw': 'bmw.com',
    'mercedes-benz': 'mercedes-benz.com',
    'audi': 'audi.com',
    'volkswagen': 'volkswagen.com',
    'mitsubishi': 'mitsubishi.com',
    'suzuki': 'suzuki.com',
    'mazda': 'mazda.com',
    'fiat': 'fiat.com',
    'citroen': 'citroen.com',
    'dacia': 'dacia.com',
    'isuzu': 'isuzu.com',
    'land-rover': 'landrover.com',
    'lexus': 'lexus.com',
    'opel': 'opel.com',
    'geely': 'geely.com',
    'byd': 'byd.com',
    'chery': 'chery.com',
  };
  static const _overrides = {
    'mercedes': 'mercedes-benz',
    'landrover': 'land-rover',
    'vw': 'volkswagen',
    'citroen': 'citroen',
    'citroën': 'citroen',
  };
  // Normalise un nom de marque en slug de fichier : minuscules, accents retirés,
  // espaces -> tirets. Couvre les marques présentes ET futures sans étendre _overrides.
  static String _slugify(String raw) {
    var v = (_overrides[raw.toLowerCase()] ?? raw.toLowerCase());
    const accents = {
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ä': 'a',
      'ã': 'a',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'ö': 'o',
      'õ': 'o',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'ñ': 'n',
      'š': 's',
      'ž': 'z',
    };
    accents.forEach((k, val) => v = v.replaceAll(k, val));
    return v.replaceAll(' ', '-');
  }

  String get logoUrl {
    final s = _slugify(slug);
    return 'https://www.carlogos.org/car-logos/\$s-logo.png';
  }

  @override
  State<_BrandLogo> createState() => _BrandLogoState();
}

class _BrandLogoState extends State<_BrandLogo> {
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    if (_error) return _fallback();
    final s = _BrandLogo._slugify(widget.slug);
    return Image.asset(
      'assets/brand_logos/$s.png',
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Image.network(
        widget.logoUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _error = true);
          });
          return _fallback();
        },
      ),
    );
  }

  Widget _fallback() => Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            widget.name[0].toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
}

// ── SVG icônes catégories — paths exacts du web Boursa ───────────────────────
class _CategorySvgIcon extends StatelessWidget {
  const _CategorySvgIcon(
      {required this.name,
      this.size = 36,
      this.color = const Color(0xFF0F172A)});
  final String name;
  final double size;
  final Color color;

  static const _svgs = {
    'car':
        '<svg viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg"><path fill="currentColor" d="M511.902,350.788l-5.404-84.4c-0.803-12.679-6.509-23.651-16.048-30.899c-7.732-5.876-17.189-8.489-27.191-7.917l24.261-24.507c3.633-3.66,3.597-9.585-0.073-13.218c-3.66-3.624-9.576-3.606-13.218,0.073l-24.607,24.856l-14.343-62.876c-5.577-24.5-29.676-43.688-54.861-43.688H131.582c-25.176,0-49.284,19.188-54.87,43.688l-14.003,61.415l-23.177-23.405c-3.642-3.66-9.548-3.688-13.227-0.064c-3.66,3.633-3.697,9.557-0.064,13.227l24.476,24.717c-10.724-1.077-20.981,1.467-29.232,7.734c-9.503,7.23-15.18,18.183-15.993,30.854v0.009l-5.395,84.4c-0.803,12.524,3.377,24.354,11.766,33.291c6.556,6.99,15.071,11.438,24.473,13.1v38.192c0,5.167,4.181,9.347,9.347,9.347h84.126c5.167,0,9.347-4.181,9.347-9.347v-37.389h233.684v37.389c0,5.167,4.181,9.347,9.347,9.347h84.126c5.167,0,9.347-4.181,9.347-9.347v-38.19c9.415-1.657,17.933-6.098,24.491-13.084C508.534,375.161,512.706,363.331,511.902,350.788z M424.252,267.118c23.195,0,42.063,18.868,42.063,42.063s-18.868,42.063-42.063,42.063s-42.063-18.868-42.063-42.063S401.057,267.118,424.252,267.118z M87.747,267.118c23.195,0,42.063,18.868,42.063,42.063s-18.868,42.063-42.063,42.063s-42.063-18.868-42.063-42.063S64.552,267.118,87.747,267.118z"/></svg>',
    'suv':
        '<svg viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg"><path fill="currentColor" d="M503.467,340.418h-8.533c0-37.642-30.617-68.267-68.25-68.267h-62.791L323.5,183.289c-1.383-3.05-4.417-5.004-7.767-5.004H153.6h-17.067H76.8c-4.717,0-8.533,3.821-8.533,8.533v85.333H51.2c-4.717,0-8.533,3.821-8.533,8.533v59.733H8.533C3.817,340.418,0,344.239,0,348.952v51.2c0,4.713,3.817,8.533,8.533,8.533h51.971c4.082,24.176,25.109,42.667,50.429,42.667s46.347-18.491,50.429-42.667h189.275c4.082,24.176,25.109,42.667,50.429,42.667s46.347-18.491,50.429-42.667h51.971c4.717,0,8.533-3.821,8.533-8.533v-51.2C512,344.239,508.183,340.418,503.467,340.418z M110.933,434.285c-18.825,0-34.133-15.312-34.133-34.133s15.308-34.133,34.133-34.133s34.133,15.312,34.133,34.133S129.758,434.285,110.933,434.285z M401.067,434.285c-18.825,0-34.133-15.312-34.133-34.133s15.308-34.133,34.133-34.133c18.825,0,34.133,15.312,34.133,34.133S419.892,434.285,401.067,434.285z"/></svg>',
    'pickup':
        '<svg viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg"><path fill="currentColor" d="M503.018,340.37H476.07v-35.912c0-6.884-2.047-13.259-5.422-18.73c3.186-1.379,5.422-4.538,5.422-8.235v-44.895c0-6.884-2.047-13.259-5.422-18.73c3.186-1.379,5.422-4.538,5.422-8.235v-44.895c0-19.824-16.158-35.947-36.009-35.947H305.483c-19.851,0-36.009,16.123-36.009,35.947v44.895c0,3.696,2.235,6.855,5.422,8.234c-3.374,5.471-5.422,11.846-5.422,18.731v44.895c0,3.696,2.235,6.855,5.422,8.234c-3.374,5.471-5.422,11.846-5.422,18.731v35.912h-71.859v-53.895c0-4.965-4.018-8.982-8.982-8.982H98.808c-4.009,0-7.535,2.658-8.64,6.517l-16.097,56.36h-6.746c-31.737,0-59.903,25.693-62.772,57.28l-4.517,49.693c-0.228,2.518,0.614,5.009,2.316,6.877c1.702,1.86,4.105,2.921,6.632,2.921h27.693c2.64,0,5.149-1.167,6.86-3.184c1.702-2.017,2.439-4.684,2-7.289c-0.412-2.447-0.623-4.974-0.623-7.491c0-24.763,20.149-44.912,44.912-44.912s44.912,20.149,44.912,44.912c0,2.518-0.211,5.044-0.623,7.491c-0.439,2.605,0.298,5.272,2,7.289c1.71,2.017,4.219,3.184,6.86,3.184h45.658h180.394c2.64,0,5.149-1.167,6.86-3.184c1.702-2.017,2.439-4.684,2-7.289c-0.412-2.447-0.623-4.974-0.623-7.491c0-24.763,20.149-44.912,44.912-44.912s44.912,20.149,44.912,44.912c0,2.518-0.211,5.044-0.623,7.491c-0.439,2.605,0.298,5.272,2,7.289c1.71,2.017,4.219,3.184,6.86,3.184h27.693c4.965,0,8.982-4.018,8.982-8.982v-98.807C512,344.388,507.983,340.37,503.018,340.37z"/></svg>',
    'van':
        '<svg viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg"><path fill="currentColor" d="M493.714,217.142v-82.286c0-2.455-0.986-4.808-2.741-6.527c-1.75-1.719-4.018-2.621-6.58-2.616l-179.924,3.509c-1.509,0.031-2.986,0.433-4.304,1.174l-40.442,22.746H9.143C4.094,153.142,0,157.236,0,162.285v201.143c0,5.049,4.094,9.143,9.143,9.143h64.924c4.248,20.839,22.715,36.571,44.79,36.571s40.542-15.732,44.79-36.571h110.638c5.049,0,9.143-4.094,9.143-9.143V226.285h201.143C489.62,226.285,493.714,222.191,493.714,217.142z M118.857,390.856c-15.125,0-27.429-12.304-27.429-27.429s12.304-27.429,27.429-27.429s27.429,12.304,27.429,27.429C146.286,378.553,133.982,390.856,118.857,390.856z"/><path fill="currentColor" d="M510.642,358.638L437.5,239.781c-1.665-2.705-4.612-4.353-7.786-4.353h-128c-5.049,0-9.143,4.094-9.143,9.143v118.857c0,5.049,4.094,9.143,9.143,9.143h55.781c4.248,20.839,22.715,36.571,44.79,36.571c22.075,0,40.542-15.732,44.79-36.571h55.781c3.312,0,6.366-1.79,7.982-4.683C512.455,364.995,512.379,361.459,510.642,358.638z M402.285,390.856c-15.125,0-27.429-12.304-27.429-27.429s12.304-27.429,27.429-27.429c15.125,0,27.429,12.304,27.429,27.429C429.714,378.553,417.41,390.856,402.285,390.856z"/></svg>',
    'moto':
        '<svg viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg"><path fill="currentColor" d="M512,354.207c0-38.94-31.664-70.621-70.586-70.621H378.81l-72.828-72.828c-3.448-3.448-9.035-3.448-12.483,0c-3.448,3.448-3.448,9.035,0,12.483l60.345,60.345H158.896v-26.483h-17.655v26.483H36.293c-4.138,0-7.72,2.871-8.616,6.914L0.211,414.086c-0.582,2.612,0.056,5.345,1.728,7.44c1.677,2.086,4.211,3.302,6.888,3.302h36.108c4.222,25.01,25.975,44.138,52.168,44.138s47.946-19.128,52.168-44.138h195.802c4.222,25.01,25.975,44.138,52.168,44.138c26.371,0,48.236-19.388,52.246-44.648C484.617,420.248,512,390.371,512,354.207z M97.103,451.311c-19.47,0-35.31-15.836-35.31-35.31s15.84-35.31,35.31-35.31s35.31,15.836,35.31,35.31S116.573,451.311,97.103,451.311z M397.241,451.311c-19.47,0-35.31-15.836-35.31-35.31s15.84-35.31,35.31-35.31c19.47,0,35.31,15.836,35.31,35.31S416.711,451.311,397.241,451.311z"/></svg>',
    'bolt':
        '<svg viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg"><path fill="currentColor" d="M503.467,385.066h-8.533c0-37.642-30.617-68.267-68.25-68.267h-62.791L323.5,227.937c-1.383-3.05-4.417-5.004-7.767-5.004H153.6h-17.067H76.8c-4.717,0-8.533,3.821-8.533,8.533V316.8H51.2c-4.717,0-8.533,3.821-8.533,8.533v59.733H8.533C3.817,385.066,0,388.887,0,393.6v51.2c0,4.713,3.817,8.533,8.533,8.533h51.971C64.586,477.509,85.613,496,110.933,496s46.347-18.491,50.429-42.667h189.275C354.719,477.509,375.747,496,401.067,496s46.347-18.491,50.429-42.667h51.971c4.717,0,8.533-3.821,8.533-8.533v-51.2C512,388.887,508.183,385.066,503.467,385.066z M110.933,478.933c-18.825,0-34.133-15.312-34.133-34.133s15.308-34.133,34.133-34.133s34.133,15.312,34.133,34.133S129.758,478.933,110.933,478.933z M401.067,478.933c-18.825,0-34.133-15.312-34.133-34.133s15.308-34.133,34.133-34.133c18.825,0,34.133,15.312,34.133,34.133S419.892,478.933,401.067,478.933z"/><path fill="currentColor" d="M388.883,196.366l53.492,5.258l-24.433,64.017c-1.675,4.4,0.533,9.333,4.933,11.012c1,0.383,2.025,0.567,3.042,0.567c3.433-0.004,6.675-2.092,7.975-5.496l28.417-74.458c0.95-2.483,0.683-5.271-0.717-7.533c-1.4-2.263-3.775-3.742-6.425-4l-53.908-5.3l19.6-57.675c1.517-4.463-0.875-9.308-5.342-10.825c-4.467-1.521-9.308,0.879-10.825,5.333l-23.058,67.862c-0.833,2.467-0.5,5.179,0.908,7.371C383.958,194.687,386.292,196.112,388.883,196.366z"/></svg>',
  };

  @override
  Widget build(BuildContext context) {
    final svg = _svgs[name] ?? _svgs['car']!;
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
