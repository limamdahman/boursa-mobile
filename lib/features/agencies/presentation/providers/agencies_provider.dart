import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/agency.dart';
import '../../data/repositories/agency_repository.dart';

final agencyRepositoryProvider = Provider<AgencyRepository>((ref) {
  return AgencyRepository(ref.read(apiClientProvider) as Dio);
});

class AgenciesState {
  final List<Agency> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final int page;

  const AgenciesState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.page = 1,
  });

  AgenciesState copyWith({
    List<Agency>? items, bool? isLoading, bool? isLoadingMore,
    bool? hasMore, String? error, int? page,
  }) => AgenciesState(
    items: items ?? this.items,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasMore: hasMore ?? this.hasMore,
    error: error,
    page: page ?? this.page,
  );
}

class AgenciesNotifier extends StateNotifier<AgenciesState> {
  final AgencyRepository _repo;
  AgenciesNotifier(this._repo) : super(const AgenciesState());

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null, page: 1);
    try {
      final items = await _repo.listAgencies(page: 1);
      state = state.copyWith(
        items: items, isLoading: false,
        hasMore: items.length >= 20, page: 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final next = state.page + 1;
      final items = await _repo.listAgencies(page: next);
      state = state.copyWith(
        items: [...state.items, ...items],
        isLoadingMore: false,
        hasMore: items.length >= 20,
        page: next,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final agenciesProvider = StateNotifierProvider<AgenciesNotifier, AgenciesState>((ref) {
  return AgenciesNotifier(ref.read(agencyRepositoryProvider));
});

final agencyDetailProvider = FutureProvider.family<Agency, String>((ref, slug) {
  return ref.read(agencyRepositoryProvider).getAgency(slug);
});
