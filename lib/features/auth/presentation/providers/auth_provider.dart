import 'package:flutter/foundation.dart';
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
  return AuthLocalDatasource(
    ref.watch(appDatabaseProvider),
  );
}

// ─── HAS USERS PROVIDER ───────────────────────────
// ✅ Cek apakah sudah ada user terdaftar
@riverpod
Future<bool> hasUsers(Ref ref) async {
  return ref.watch(appDatabaseProvider).hasUsers();
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

      state = AuthState(user: user);
    } catch (e) {
      debugPrint('Login error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan: $e',
      );
    }
  }

  // ✅ Register admin pertama kali
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

      state = AuthState(user: user);
    } catch (e) {
      debugPrint('Register error: $e');
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