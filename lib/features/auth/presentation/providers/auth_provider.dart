import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';
import '../../data/user_model.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAnonymous extends AuthState {
  const AuthAnonymous();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final User user;
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthInitial()) {
    _bootstrap();
  }

  final AuthRepository _repo;

  /// Au démarrage : on reste anonyme (le backend n'a pas d'endpoint /auth/me).
  /// Le user devra re-login si besoin.
  Future<void> _bootstrap() async {
    state = const AuthAnonymous();
  }

  Future<String> requestOtp(String phone) async {
    state = const AuthLoading();
    try {
      final normalized = await _repo.requestOtp(phone);
      // Retour à anonymous, l'UI poussera vers l'écran OTP
      state = const AuthAnonymous();
      return normalized;
    } on AuthException catch (e) {
      state = AuthError(e.message);
      rethrow;
    }
  }

  Future<void> verifyOtp(String phone, String code, {String? name}) async {
    state = const AuthLoading();
    try {
      final result = await _repo.verifyOtp(phone, code, name: name);
      state = AuthAuthenticated(result.user);
    } on AuthException catch (e) {
      state = AuthError(e.message);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthAnonymous();
  }

  /// Met à jour le profil et pousse le user frais dans l'état.
  Future<void> updateProfile(
      {String? name, String? email, String? language}) async {
    final user =
        await _repo.updateProfile(name: name, email: email, language: language);
    state = AuthAuthenticated(user);
  }

  /// Pousse un user déjà rafraîchi (ex. après upload avatar).
  void applyUpdatedUser(User user) {
    state = AuthAuthenticated(user);
  }

  AuthRepository get repo => _repo;
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

/// Convenience : récupère l'utilisateur courant ou null
final currentUserProvider = Provider<User?>((ref) {
  final state = ref.watch(authProvider);
  return state is AuthAuthenticated ? state.user : null;
});

/// Convenience : booléen "est connecté"
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) is AuthAuthenticated;
});
