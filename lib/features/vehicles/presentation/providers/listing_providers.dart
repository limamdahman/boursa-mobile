import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/vehicle.dart';
import '../../data/repositories/vehicle_repository.dart';
import 'vehicle_filter.dart';

class ListingState {
  ListingState({
    this.items = const [],
    this.currentPage = 0,
    this.lastPage = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.filter = const VehicleFilter(),
  });

  final List<Vehicle> items;
  final int currentPage;
  final int lastPage;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final VehicleFilter filter;

  bool get hasMore => currentPage < lastPage;

  ListingState copyWith({
    List<Vehicle>? items,
    int? currentPage,
    int? lastPage,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    VehicleFilter? filter,
    bool clearError = false,
  }) =>
      ListingState(
        items: items ?? this.items,
        currentPage: currentPage ?? this.currentPage,
        lastPage: lastPage ?? this.lastPage,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        error: clearError ? null : (error ?? this.error),
        filter: filter ?? this.filter,
      );
}

class ListingNotifier extends StateNotifier<ListingState> {
  ListingNotifier(this._repo) : super(ListingState());

  final VehicleRepository _repo;

  Future<void> refresh({VehicleFilter? filter}) async {
    state = ListingState(
      isLoading: true,
      filter: filter ?? state.filter,
    );
    await _loadPage(1, append: false);
  }

  Future<void> applyFilter(VehicleFilter filter) async {
    await refresh(filter: filter);
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    await _loadPage(state.currentPage + 1, append: true);
  }

  Future<void> _loadPage(int page, {required bool append}) async {
    try {
      final f = state.filter;
      final result = await _repo.list(
        page: page,
        perPage: 20,
        brandId: f.brandId,
        modelId: f.modelId,
        cityId: f.cityId,
        yearMin: f.yearMin,
        yearMax: f.yearMax,
        priceMin: f.priceMin,
        priceMax: f.priceMax,
        fuel: f.fuel,
        transmission: f.transmission,
        bodyType: f.bodyType,
        isDeal: f.isDeal,
        sort: f.sort,
      );

      state = state.copyWith(
        items: append ? [...state.items, ...result.items] : result.items,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        isLoading: false,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }
}

final listingProvider = StateNotifierProvider<ListingNotifier, ListingState>(
  (ref) => ListingNotifier(ref.watch(vehicleRepositoryProvider)),
);

final vehicleDetailProvider =
    FutureProvider.family.autoDispose<Vehicle, String>((ref, id) async {
  final repo = ref.watch(vehicleRepositoryProvider);
  unawaitedTrackView(repo, id);
  return repo.detail(id);
});

void unawaitedTrackView(VehicleRepository repo, String id) {
  // ignore: unawaited_futures
  repo.trackView(id);
}

final vehicleSimilarProvider =
    FutureProvider.family.autoDispose<List<Vehicle>, String>((ref, id) async {
  final repo = ref.watch(vehicleRepositoryProvider);
  return repo.similar(id);
});

// Provider deals — Les meilleures affaires
final dealsProvider = FutureProvider<List<Vehicle>>((ref) async {
  final repo = ref.read(vehicleRepositoryProvider);
  final page = await repo.list(page: 1, perPage: 6, isDeal: true);
  return page.items;
});

// Provider récents — dernières annonces
final recentVehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final repo = ref.read(vehicleRepositoryProvider);
  final page = await repo.list(page: 1, perPage: 6);
  return page.items;
});

final agencyVehiclesProvider = FutureProvider.family<List<Vehicle>, ({String agencyId, String excludeId})>((ref, args) async {
  final repo = ref.read(vehicleRepositoryProvider);
  final result = await repo.list(page: 1, perPage: 8, agencyId: args.agencyId);
  return result.items.where((v) => v.id != args.excludeId).toList();
});
