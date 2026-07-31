import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../domain/entities/user_entity.dart';

part 'auth_provider.g.dart';

// ✅ DB PROVIDER - gunakan singleton, TIDAK buat baru
@riverpod
AppDatabase appDatabase(Ref ref) {
  return AppDatabase.instance;
  // ❌ HAPUS: ref.onDispose(db.close);
  // Database singleton tidak boleh di-close
}

// ✅ DATASOURCE - keepAlive agar tidak rebuild
@riverpod
AuthLocalDatasource authDatasource(Ref ref) {
  return AuthLocalDatasource(
    ref.watch(appDatabaseProvider),
  );
}

// ✅ HAS USERS - cache result
final hasUsersProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.hasUsers();
});

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
    } catch (e) {
      debugPrint('Load session error: $e');
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

      ref.invalidate(hasUsersProvider);
      state = AuthState(user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan: $e',
      );
    }
  }

  Future<void> register({
    required String storeName,
    required String name,
    required String username,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );
    try {
      final user = await ref
        .read(authDatasourceProvider)
        .register(
          storeName: storeName,
          name: name,
          username: username,
          password: password,
        );

      ref.invalidate(hasUsersProvider);
      await Future.delayed(
        const Duration(milliseconds: 100),
      );
      state = AuthState(user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal mendaftar: $e',
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