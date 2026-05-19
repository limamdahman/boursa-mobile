import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/favorite_repository.dart';

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier(this._repo) : super(<String>{});

  final FavoriteRepository _repo;

  /// Synchronise depuis le backend (appelé au login)
  Future<void> sync() async {
    try {
      final ids = await _repo.ids();
      state = ids;
    } catch (_) {
      // En cas d'erreur réseau, on garde l'état local
    }
  }

  /// Vide les favoris (appelé au logout)
  void clear() {
    state = <String>{};
  }

  /// Toggle un favori avec optimistic update
  Future<bool> toggle(String vehicleId) async {
    final wasFav = state.contains(vehicleId);

    // Optimistic update
    if (wasFav) {
      state = {...state}..remove(vehicleId);
    } else {
      state = {...state, vehicleId};
    }

    try {
      final nowFav = await _repo.toggle(vehicleId, wasFav);
      // Cas où le backend retourne quelque chose d'inattendu
      if (nowFav != !wasFav) {
        // Réconcilie
        if (nowFav) {
          state = {...state, vehicleId};
        } else {
          state = {...state}..remove(vehicleId);
        }
      }
      return nowFav;
    } catch (e) {
      // Rollback en cas d'erreur
      if (wasFav) {
        state = {...state, vehicleId};
      } else {
        state = {...state}..remove(vehicleId);
      }
      rethrow;
    }
  }

  bool isFavorite(String vehicleId) => state.contains(vehicleId);
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  final notifier = FavoritesNotifier(ref.watch(favoriteRepositoryProvider));

  // Auto-sync au login et clear au logout
  ref.listen<AuthState>(authProvider, (previous, next) {
    if (next is AuthAuthenticated) {
      notifier.sync();
    } else if (next is AuthAnonymous && previous is AuthAuthenticated) {
      notifier.clear();
    }
  });

  return notifier;
});

/// Helper : un véhicule est-il favorisé ?
final isFavoriteProvider = Provider.family<bool, String>((ref, vehicleId) {
  return ref.watch(favoritesProvider).contains(vehicleId);
});
