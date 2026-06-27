import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../../data/dummy/app_state.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';

class ManageRolesSection extends StatelessWidget {
  final EdgeInsetsGeometry? padding;

  const ManageRolesSection({super.key, this.padding});

  static const _allRoles = ['Buyer', 'Seller', 'Driver'];

  static IconData _roleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'buyer':
        return Icons.shopping_bag_outlined;
      case 'seller':
        return Icons.storefront_outlined;
      case 'driver':
        return Icons.moped_outlined;
      default:
        return Icons.person_outline;
    }
  }

  static String _roleRoute(String role) {
    switch (role.toLowerCase()) {
      case 'seller':
        return '/seller/dashboard';
      case 'driver':
        return '/driver/find-jobs';
      case 'admin':
        return '/admin/dashboard';
      default:
        return '/landing';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    if (user == null) return const SizedBox.shrink();

    final ownedRoles = user.roles;
    final activeRole = appState.activeRole;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Role
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Role Aktif Sesi Ini:',
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  activeRole,
                  style: AppTextStyles.label.copyWith(fontSize: 11, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // Owned Roles
          Text(
            'Role yang Dimiliki:',
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 8),
          if (ownedRoles.isEmpty)
            Text(
              'Belum memiliki role',
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 11, color: AppColors.neutral),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ownedRoles.map((role) {
                final isActive = role == activeRole;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_roleIcon(role), size: 14, color: isActive ? Colors.white : AppColors.primary),
                      const SizedBox(width: 4),
                      Text(role),
                    ],
                  ),
                  selected: isActive,
                  onSelected: isActive ? null : (selected) {
                    if (!isActive) {
                      _switchRole(context, role);
                    }
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.border.withOpacity(0.3),
                  labelStyle: AppTextStyles.label.copyWith(
                    fontSize: 11,
                    color: isActive ? Colors.white : AppColors.textPrimary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isActive ? AppColors.primary : AppColors.border,
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 12),

          // Add Role button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _showAddRoleDialog(context, appState, ownedRoles),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Tambah Role Baru'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppColors.primary, style: BorderStyle.solid),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _switchRole(BuildContext context, String targetRole) {
    final appState = Provider.of<AppState>(context, listen: false);
    if (targetRole.toLowerCase() == appState.activeRole.toLowerCase()) return;

    context.read<AuthBloc>().add(RoleSelected(targetRole: targetRole.toLowerCase()));
    appState.setActiveRole(targetRole);
    ScaffoldMessenger.of(context).clearSnackBars();
    final route = _roleRoute(targetRole);
    context.go(route);
  }

  Future<void> _showAddRoleDialog(BuildContext context, AppState appState, List<String> ownedRoles) async {
    final ownedLower = ownedRoles.map((r) => r.toLowerCase()).toSet();
    final available = _allRoles.where((r) => !ownedLower.contains(r.toLowerCase())).toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Anda sudah memiliki semua role yang tersedia!'),
          backgroundColor: AppColors.neutral,
        ),
      );
      return;
    }

    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tambah Role Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: available.map((role) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: AppColors.tertiary,
              child: Icon(_roleIcon(role), color: AppColors.primary, size: 20),
            ),
            title: Text(role, style: AppTextStyles.label),
            trailing: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
            onTap: () => Navigator.pop(ctx, role),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: AppTextStyles.label.copyWith(color: AppColors.neutral)),
          ),
        ],
      ),
    );

    if (selected == null || !context.mounted) return;

    final user = appState.currentUser;
    if (user == null) return;

    // Update Supabase profiles.owned_roles
    try {
      final supabase = Supabase.instance.client;
      final profile = await supabase
          .from('profiles')
          .select('owned_roles')
          .eq('id', user.id)
          .maybeSingle();

      List<String> currentRoles = [];
      if (profile != null && profile['owned_roles'] != null) {
        currentRoles = List<String>.from(profile['owned_roles']);
      }

      if (!currentRoles.contains(selected.toLowerCase())) {
        currentRoles.add(selected.toLowerCase());
        await supabase
            .from('profiles')
            .update({'owned_roles': currentRoles})
            .eq('id', user.id);
      }
    } catch (_) {}

    // Update local state and switch to new role
    appState.addRoleLocallyAndSwitch(selected);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text('Role $selected berhasil ditambahkan!'),
        backgroundColor: AppColors.primary,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );

    // Update AuthBloc and navigate
    context.read<AuthBloc>().add(RoleSelected(targetRole: selected.toLowerCase()));
    final route = _roleRoute(selected);
    context.go(route);
  }
}
