import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../domain/entities/user_entity.dart';

part 'auth_provider.g.dart';

// ─── DB PROVIDER ─────────────────────────────────
@riverpod
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

// ─── DATASOURCE PROVIDER ─────────────────────────
@riverpod
AuthLocalDatasource authDatasource(Ref ref) {
  return AuthLocalDatasource(ref.watch(appDatabaseProvider));
}

// ─── AUTH STATE ───────────────────────────────────
class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  final UserEntity? user;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError
        ? null
        : (errorMessage ?? this.errorMessage),
    );
  }
}

// ─── AUTH NOTIFIER ────────────────────────────────
@riverpod
class AuthNotifier extends _$AuthNotifier {

  @override
  AuthState build() {
    Future.microtask(_loadSession);
    return const AuthState();
  }

  Future<void> _loadSession() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await ref
        .read(authDatasourceProvider)
        .getSession();

      state = state.copyWith(
        user: user,
        isLoading: false,
      );
    } catch (_) {
      state = const AuthState();
    }
  }

  Future<void> login(
    String username,
    String password,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final user = await ref
        .read(authDatasourceProvider)
        .login(username.trim(), password.trim());

      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Username atau password salah',
        );
        return;
      }

      state = AuthState(user: user);

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan. Coba lagi.',
      );
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(authDatasourceProvider).logout();
    } catch (_) {}
    state = const AuthState();
  }
}