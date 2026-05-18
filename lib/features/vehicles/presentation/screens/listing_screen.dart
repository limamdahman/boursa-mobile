import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/locale_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
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
      ref.read(listingProvider.notifier).refresh();
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
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(listingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            onPressed: () => _toggleLocale(context),
            icon: const Icon(Icons.translate),
            tooltip: l10n.languageLabel,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(listingProvider.notifier).refresh(),
        child: _buildBody(state, l10n),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openFilters,
        backgroundColor: state.filter.activeCount > 0
            ? AppColors.accent
            : AppColors.primary,
        foregroundColor: state.filter.activeCount > 0
            ? AppColors.textPrimary
            : Colors.white,
        icon: const Icon(Icons.tune),
        label: Text(
          state.filter.activeCount > 0
              ? 'Filtres (${state.filter.activeCount})'
              : 'Filtres',
        ),
      ),
    );
  }

  Widget _buildBody(ListingState state, AppLocalizations l10n) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.items.isEmpty) {
      return _ErrorView(
        message: l10n.listingError,
        onRetry: () => ref.read(listingProvider.notifier).refresh(),
        retryLabel: l10n.listingRetry,
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(l10n.listingEmpty,
                style: Theme.of(context).textTheme.bodyMedium),
            if (state.filter.activeCount > 0) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref
                    .read(listingProvider.notifier)
                    .refresh(filter: const VehicleFilter()),
                child: const Text('Réinitialiser les filtres'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final vehicle = state.items[index];
        return VehicleCard(
          vehicle: vehicle,
          onTap: () => context.go('/vehicle/${vehicle.id}'),
        );
      },
    );
  }

  Future<void> _openFilters() async {
    final current = ref.read(listingProvider).filter;
    final result = await showModalBottomSheet(
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.retryLabel,
  });

  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 56, color: AppColors.error),
          const SizedBox(height: 12),
          Text(message, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: Text(retryLabel)),
        ],
      ),
    );
  }
}
