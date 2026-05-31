import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/storage/locale_storage.dart';
import '../../data/followed_seller.dart';
import '../follow_providers.dart';

class MyFollowsScreen extends ConsumerWidget {
  const MyFollowsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final async = ref.watch(myFollowsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(isAr ? 'متابَعاتي' : 'Mes suivis')),
      body: async.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (follows) {
          if (follows.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_add_alt_1_outlined,
                        size: 56, color: Color(0xFFCBD5E1)),
                    const SizedBox(height: 16),
                    Text(
                      isAr
                          ? 'لا تتابع أي بائع حاليا'
                          : 'Vous ne suivez aucun vendeur pour le moment',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.sourceSans3(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isAr
                          ? 'تابع بائعيك المفضلين لمعرفة كل إعلاناتهم الجديدة'
                          : 'Suivez vos vendeurs préférés pour ne rien manquer de leurs annonces',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.sourceSans3(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => context.go('/vehicules'),
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary),
                      child: Text(isAr ? 'تصفح السيارات' : 'Parcourir les véhicules'),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myFollowsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: follows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _FollowCard(seller: follows[i], isAr: isAr),
            ),
          );
        },
      ),
    );
  }
}

class _FollowCard extends StatelessWidget {
  const _FollowCard({required this.seller, required this.isAr});
  final FollowedSeller seller;
  final bool isAr;

  void _openSeller(BuildContext context) {
    if (seller.isAgency && seller.sellerSlug != null) {
      context.push('/agences/${seller.sellerSlug}');
    }
    // (page profil particulier : à venir)
  }

  @override
  Widget build(BuildContext context) {
    final initials = seller.sellerName
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
        .join();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _openSeller(context),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: seller.sellerLogoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: seller.sellerLogoUrl!, fit: BoxFit.cover)
                        : Container(
                            color: const Color(0xFF0F172A),
                            alignment: Alignment.center,
                            child: Text(initials,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(seller.sellerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.sourceSans3(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary)),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: seller.isAgency
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              seller.isAgency
                                  ? (isAr ? 'وكالة' : 'Agence')
                                  : (isAr ? 'فرد' : 'Particulier'),
                              style: GoogleFonts.sourceSans3(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: seller.isAgency
                                      ? const Color(0xFF166534)
                                      : AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${seller.activeVehiclesCount} ${isAr ? 'إعلان نشط' : 'annonces actives'}',
                        style: GoogleFonts.sourceSans3(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
          if (seller.recentVehicles.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: seller.recentVehicles.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final v = seller.recentVehicles[i];
                  return GestureDetector(
                    onTap: () => context.push('/vehicle/${v.id}'),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 100,
                        height: 70,
                        child: v.coverUrl != null
                            ? CachedNetworkImage(
                                imageUrl: v.coverUrl!, fit: BoxFit.cover)
                            : Container(
                                color: AppColors.background,
                                child: const Icon(Icons.directions_car_outlined,
                                    color: AppColors.textMuted)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
