import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/storage/locale_storage.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/ui/brand/boursa_logo.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is VehicleFilter) {
        ref.read(listingProvider.notifier).refresh(filter: extra);
      } else {
        ref.read(listingProvider.notifier).refresh();
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _BoursaHeader(
            filterCount: state.filter.activeCount,
            onFilterTap: _openFilters,
          ),
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildBody(ListingState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.cloud_off, size: 48, color: AppColors.border),
          const SizedBox(height: 12),
          Text(AppLocalizations.of(context)!.listingError,
              style: GoogleFonts.sourceSans3(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          FilledButton(onPressed: () => ref.read(listingProvider.notifier).refresh(), child: Text(AppLocalizations.of(context)!.listingRetry)),
        ]),
      );
    }
    if (state.items.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.search_off, size: 48, color: AppColors.border),
          const SizedBox(height: 12),
          Text(AppLocalizations.of(context)!.listingEmpty,
              style: GoogleFonts.sourceSans3(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          if (state.filter.activeCount > 0) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.read(listingProvider.notifier).refresh(filter: const VehicleFilter()),
              child: Text(AppLocalizations.of(context)!.listingResetFilters),
            ),
          ],
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(listingProvider.notifier).refresh(),
      color: AppColors.primary,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.60,
        ),
        itemCount: state.items.length + (state.isLoadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.border)),
            );
          }
          final v = state.items[index];
          return VehicleCard(
            vehicle: v,
            featured: index == 0 && state.filter.isEmpty,
            onTap: () => context.go('/vehicle/${v.id}'),
          );
        },
      ),
    );
  }

  Future<void> _openFilters() async {
    final current = ref.read(listingProvider).filter;
    final result = await showModalBottomSheet<VehicleFilter>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(initial: current),
    );
    if (result != null) ref.read(listingProvider.notifier).applyFilter(result);
  }
}

class _BoursaHeader extends ConsumerWidget {
  const _BoursaHeader({required this.filterCount, required this.onFilterTap});
  final int filterCount;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF064E3B), Color(0xFF052E22), Color(0xFF0A0A0A)],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Color(0x2616A34A), blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            children: [
              Row(children: [
                Expanded(child: BoursaLogo.horizontal(markHeight: 36, wordmarkSize: 26, dark: true)),
                GestureDetector(
                  onTap: () async {
                    final next = isAr ? const Locale('fr') : const Locale('ar');
                    await ref.read(localeProvider.notifier).setLocale(next);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      _LangBtn(label: 'FR', active: !isAr),
                      const SizedBox(width: 2),
                      _LangBtn(label: 'AR', active: isAr),
                    ]),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: onFilterTap,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Row(children: [
                    const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Expanded(child: Text(l.searchHint,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary))),
                    Stack(children: [
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.tune, size: 18, color: Colors.white)),
                      if (filterCount > 0)
                        Positioned(top: 0, right: 0,
                          child: Container(
                            width: 14, height: 14,
                            decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                            child: Center(child: Text('$filterCount',
                              style: const TextStyle(color: Colors.white,
                                fontSize: 9, fontWeight: FontWeight.w800))))),
                    ]),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangBtn extends StatelessWidget {
  const _LangBtn({required this.label, required this.active});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: TextStyle(
        fontSize: 13, fontWeight: FontWeight.w700,
        color: active ? Colors.white : Colors.white.withOpacity(0.6))),
    );
  }
}
