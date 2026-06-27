import 'package:compfest/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:compfest/features/auth/presentation/bloc/auth_event.dart';
import 'package:compfest/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String? _selectedRole; // Menyimpan role yang di-klik pengguna

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              final appState = Provider.of<AppState>(context, listen: false);
              appState.setLoggedInUser(
                state.user.id,
                state.user.username,
                '${state.user.username}@seapedia.com',
                state.user.ownedRoles,
                state.activeRole,
              );

              final role = state.activeRole.toLowerCase();
              if (role == 'seller') {
                context.go('/seller/dashboard');
              } else if (role == 'driver') {
                context.go('/driver/find-jobs');
              } else if (role == 'admin') {
                context.go('/admin/dashboard');
              } else {
                context.go('/landing');
              }
            }
            if (state is AuthUnauthenticated) {
              final appState = Provider.of<AppState>(context, listen: false);
              appState.logout();
              context.go('/login');
            }
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(duration: const Duration(seconds: 2), content: Text(state.message), backgroundColor: AppColors.danger),
              );
            }
          },
            // PERBAIKAN PADA METHOD BUILDER DI role_selection_page.dart
            builder: (context, state) {
              List<String> ownedRoles = [];

              // Ambil data peran secara aman dari state yang valid
              if (state is AuthNeedsRoleSelection) {
                ownedRoles = state.user.ownedRoles;
              } else if (state is AuthAuthenticated) {
                ownedRoles = state.user.ownedRoles;
              }

              // Tampilkan indikator loading jika data peran belum siap
              if (state is AuthLoading || ownedRoles.isEmpty) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              // Memastikan _selectedRole selalu tervalidasi dengan daftar peran asli milik user
              if (_selectedRole == null || !ownedRoles.contains(_selectedRole)) {
                if (state is AuthAuthenticated && ownedRoles.contains(state.activeRole)) {
                  _selectedRole = state.activeRole;
                } else {
                  _selectedRole = ownedRoles.first;
                }
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Masuk sebagai apa hari ini?',
                      style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih peran Anda untuk melanjutkan aktivitas.',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 32),

                    // DAFTAR KARTU PERAN DISAJIKAN SECARA AMAN & DINAMIS
                    Expanded(
                      child: ListView(
                        children: [
                          if (ownedRoles.contains('buyer')) ...[
                            _buildRoleCard(
                              title: 'Buyer',
                              description: 'Belanja berbagai kebutuhan maritim.',
                              icon: Icons.shopping_bag_outlined,
                              isActive: _selectedRole == 'buyer',
                              onTap: () => setState(() => _selectedRole = 'buyer'),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (ownedRoles.contains('seller')) ...[
                            _buildRoleCard(
                              title: 'Seller',
                              description: 'Mulai berjualan dan kelola tokomu.',
                              icon: Icons.storefront_outlined,
                              isActive: _selectedRole == 'seller',
                              onTap: () => setState(() => _selectedRole = 'seller'),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (ownedRoles.contains('driver')) ...[
                            _buildRoleCard(
                              title: 'Driver',
                              description: 'Kirim pesanan dan dapatkan penghasilan.',
                              icon: Icons.moped_outlined,
                              isActive: _selectedRole == 'driver',
                              onTap: () => setState(() => _selectedRole = 'driver'),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),

                    // TOMBOL SUBMIT
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: AppButtonStyles.primary.copyWith(
                          backgroundColor: WidgetStateProperty.all(AppColors.secondary),
                        ),
                        onPressed: () {
                          context.read<AuthBloc>().add(
                            RoleSelected(targetRole: _selectedRole!),
                          );
                        },
                        child: Text('Continue', style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // TOMBOL KELUAR
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: AppButtonStyles.outlined,
                        onPressed: () {
                          context.read<AuthBloc>().add(LogoutRequested());
                        },
                        child: Text(
                          'Keluar Akun',
                          style: AppTextStyles.label.copyWith(color: AppColors.danger),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
        ),
      ),
    );
  }

  // Komponen Helper untuk merender struktur Item Kartu Peran
  Widget _buildRoleCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      color: isActive ? AppColors.tertiary.withOpacity(0.4) : AppColors.surface,
      radius: 20,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.tertiary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 28,
              color: isActive ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.label.copyWith(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isActive)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}