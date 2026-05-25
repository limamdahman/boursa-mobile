import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/locale_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/brand/boursa_logo.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/listing_providers.dart';
import '../providers/vehicle_filter.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/vehicle_card.dart';

class ListingScreen extends ConsumerStatefulWidget {
  const ListingScreen({super.key});

  @override
  ConsumerState<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends ConsumerState<ListingScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(listingProvider.notifier).refresh();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(listingProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listingProvider);
    final isAuth = ref.watch(isAuthenticatedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 12,
        title: BoursaLogo.horizontal(markHeight: 36, wordmarkSize: 22),
        actions: [
          IconButton(
            onPressed: () =>
                context.go(isAuth ? '/favorites' : '/login'),
            icon: const Icon(Icons.favorite_outline, size: 22),
            tooltip: 'Mes favoris',
          ),
          IconButton(
            onPressed: () => context.go('/profile'),
            icon: Icon(
              isAuth ? Icons.account_circle : Icons.account_circle_outlined,
              size: 22,
            ),
            tooltip: 'Mon compte',
          ),
          IconButton(
            onPressed: () => _toggleLocale(context),
            icon: const Icon(Icons.translate, size: 20),
            tooltip: 'Langue',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchController,
            filterCount: state.filter.activeCount,
            onFilterTap: _openFilters,
          ),
          _ResultCount(
            count: state.items.length,
            isLoading: state.isLoading,
            sort: state.filter.sort,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(listingProvider.notifier).refresh(),
              color: AppColors.primary,
              child: _buildBody(state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ListingState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                'Impossible de charger les véhicules',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                state.error!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    ref.read(listingProvider.notifier).refresh(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }
    if (state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off,
                  size: 56, color: AppColors.textDisabled),
              const SizedBox(height: 12),
              Text(
                'Aucun véhicule trouvé',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (state.filter.activeCount > 0) ...[
                const SizedBox(height: 6),
                Text(
                  'Essaie de modifier ou réinitialiser tes filtres',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref
                      .read(listingProvider.notifier)
                      .refresh(filter: const VehicleFilter()),
                  child: const Text('Réinitialiser les filtres'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final v = state.items[index];
        return VehicleCard(
          vehicle: v,
          featured: index == 0 && state.filter.isEmpty,
          onTap: () => context.go('/vehicle/${v.id}'),
        );
      },
    );
  }

  Future<void> _openFilters() async {
    final current = ref.read(listingProvider).filter;
    final result = await showModalBottomSheet<VehicleFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(initial: current),
    );
    if (result != null) {
      ref.read(listingProvider.notifier).applyFilter(result);
    }
  }

  Future<void> _toggleLocale(BuildContext context) async {
    final current = ref.read(localeProvider);
    final next = current.languageCode == 'fr'
        ? const Locale('ar')
        : const Locale('fr');
    await ref.read(localeProvider.notifier).setLocale(next);
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.filterCount,
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final int filterCount;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.borderStrong),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 12, right: 8),
                    child: Icon(Icons.search,
                        size: 18, color: AppColors.textMuted),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Toyota Camry, Mazda 3...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.tune,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    const Text(
                      'Filtres',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (filterCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$filterCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCount extends StatelessWidget {
  const _ResultCount({
    required this.count,
    required this.isLoading,
    required this.sort,
  });

  final int count;
  final bool isLoading;
  final String? sort;

  String _sortLabel(String? s) {
    switch (s) {
      case 'price_asc':
        return 'Prix croissant';
      case 'price_desc':
        return 'Prix décroissant';
      case 'year_desc':
        return 'Année décroissante';
      case 'mileage_asc':
        return 'Km croissant';
      case 'recent':
      case null:
      default:
        return 'Plus récents';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              children: [
                if (isLoading)
                  const TextSpan(text: 'Chargement…')
                else ...[
                  TextSpan(
                    text: '$count',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const TextSpan(text: ' véhicules'),
                ],
              ],
            ),
          ),
          Row(
            children: [
              Text(
                _sortLabel(sort),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.keyboard_arrow_down,
                  size: 14, color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }
}
