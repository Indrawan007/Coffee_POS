import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/user_provider.dart';
import 'user_form_dialog.dart';
import 'reset_password_dialog.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersStreamProvider);
    final authState  = ref.watch(authNotifierProvider);
    final currentUserId = authState.user?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengguna'),
        // ✅ Tombol kembali
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(AppRoutes.dashboard),
        ),
        actions: [
          // Tambah user
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Tambah Pengguna',
            onPressed: () => _showAddDialog(context, ref),
          ),
        ],
      ),
      body: usersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e'),
        ),
        data: (users) {
          if (users.isEmpty) {
            return EmptyState(
              message: 'Belum ada pengguna',
              icon: Icons.people_outline,
              action: () => _showAddDialog(context, ref),
              actionLabel: 'Tambah Pengguna',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: users.length,
            separatorBuilder: (_, __) =>
              const SizedBox(height: AppSizes.sm),
            itemBuilder: (ctx, i) => _UserCard(
              user: users[i],
              isCurrentUser: users[i].id == currentUserId,
            ),
          );
        },
      ),

      // ✅ FAB Tambah User
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (_) => const UserFormDialog(),
    );
  }
}

// ═══════════════════════════════════════════════════
// USER CARD
// ═══════════════════════════════════════════════════
class _UserCard extends ConsumerWidget {
  const _UserCard({
    required this.user,
    required this.isCurrentUser,
  });

  final UsersTableData user;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ds = ref.read(userDatasourceProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: user.role == 'admin'
                ? AppColors.primary
                : AppColors.accent,
              child: Text(
                user.name.isNotEmpty
                  ? user.name[0].toUpperCase()
                  : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(width: AppSizes.md),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment:
                  CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: AppSizes.xs),
                        Container(
                          padding:
                            const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                          decoration: BoxDecoration(
                            color: AppColors.info
                              .withOpacity(0.1),
                            borderRadius:
                              BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Anda',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.info,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Role badge
                      Container(
                        padding:
                          const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                        decoration: BoxDecoration(
                          color: user.role == 'admin'
                            ? AppColors.primary
                                .withOpacity(0.1)
                            : AppColors.accent
                                .withOpacity(0.1),
                          borderRadius:
                            BorderRadius.circular(
                              AppSizes.radiusFull,
                            ),
                        ),
                        child: Text(
                          user.role == 'admin'
                            ? 'Admin'
                            : 'Kasir',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: user.role == 'admin'
                              ? AppColors.primary
                              : AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),

                      // Status badge
                      Container(
                        padding:
                          const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                        decoration: BoxDecoration(
                          color: user.isActive
                            ? AppColors.success
                                .withOpacity(0.1)
                            : AppColors.error
                                .withOpacity(0.1),
                          borderRadius:
                            BorderRadius.circular(
                              AppSizes.radiusFull,
                            ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: user.isActive
                                  ? AppColors.success
                                  : AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.isActive
                                ? 'Aktif'
                                : 'Nonaktif',
                              style: TextStyle(
                                fontSize: 11,
                                color: user.isActive
                                  ? AppColors.success
                                  : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: AppColors.textSecondary,
              ),
              onSelected: (value) =>
                _onAction(context, ref, value),
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reset_password',
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_reset,
                        size: 18,
                        color: AppColors.accent,
                      ),
                      SizedBox(width: 8),
                      Text('Reset Password'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        user.isActive
                          ? Icons.block
                          : Icons.check_circle_outline,
                        size: 18,
                        color: user.isActive
                          ? AppColors.warning
                          : AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user.isActive
                          ? 'Nonaktifkan'
                          : 'Aktifkan',
                      ),
                    ],
                  ),
                ),
                if (!isCurrentUser)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Hapus',
                          style: TextStyle(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final ds = ref.read(userDatasourceProvider);

    switch (action) {
      case 'edit':
        showDialog(
          context: context,
          builder: (_) => UserFormDialog(user: user),
        );
        break;

      case 'reset_password':
        showDialog(
          context: context,
          builder: (_) => ResetPasswordDialog(user: user),
        );
        break;

      case 'toggle':
        if (isCurrentUser && user.isActive) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Tidak bisa menonaktifkan akun sendiri',
              ),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
        await ds.toggleActive(user.id, !user.isActive);
        break;

      case 'delete':
        final confirm = await AppDialog.confirm(
          context,
          title: 'Hapus Pengguna',
          message:
            'Hapus "${user.name}"? '
            'Data tidak bisa dikembalikan.',
          confirmLabel: 'Hapus',
          confirmColor: AppColors.error,
        );
        if (confirm == true) {
          await ds.delete(user.id);
        }
        break;
    }
  }
}