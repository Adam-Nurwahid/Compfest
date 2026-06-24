import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // Redirect to login if user somehow navigates here without logging in
    if (!appState.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Pilih Role Anda',
                style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                'Akun Anda memiliki akses ke beberapa peran. Silakan pilih untuk masuk ke dashboard yang sesuai.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 32),

              // Role Options
              Expanded(
                child: ListView(
                  children: [
                    if (appState.availableRoles.contains('Admin')) ...[
                      _buildRoleCard(
                        context,
                        title: 'Admin (Sistem)',
                        description: 'Kelola data SEAPEDIA secara menyeluruh: pantau pengguna, toko, produk, pesanan, voucher, promo, dan pesanan overdue.',
                        icon: Icons.admin_panel_settings_outlined,
                        isActive: appState.activeRole == 'Admin',
                        onTap: () {
                          appState.setActiveRole('Admin');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Masuk sebagai Admin')),
                          );
                          context.go('/admin/dashboard');
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (appState.availableRoles.contains('Buyer')) ...[
                      _buildRoleCard(
                        context,
                        title: 'Buyer (Pembeli)',
                        description: 'Mencari perlengkapan laut premium, nelayan pancing, berlayar, checkout produk dari seller terpercaya.',
                        icon: Icons.shopping_bag_outlined,
                        isActive: appState.activeRole == 'Buyer',
                        onTap: () {
                          appState.setActiveRole('Buyer');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Masuk sebagai Pembeli')),
                          );
                          context.go('/landing');
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (appState.availableRoles.contains('Seller')) ...[
                      _buildRoleCard(
                        context,
                        title: 'Seller (Penjual)',
                        description: 'Kelola toko laut Anda, update inventaris produk pancing/berlayar, kelola pesanan masuk dari pembeli.',
                        icon: Icons.storefront_outlined,
                        isActive: appState.activeRole == 'Seller',
                        onTap: () {
                          appState.setActiveRole('Seller');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Masuk sebagai Penjual (Seller Mode)')),
                          );
                          context.go('/seller/dashboard');
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (appState.availableRoles.contains('Driver')) ...[
                      _buildRoleCard(
                        context,
                        title: 'Driver / Kurir Laut',
                        description: 'Terima penugasan pengiriman barang kelautan antar pulau/dermaga. Pantau rute logistik.',
                        icon: Icons.sailing_outlined,
                        isActive: appState.activeRole == 'Driver',
                        onTap: () {
                          appState.setActiveRole('Driver');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Masuk sebagai Driver')),
                          );
                          context.go('/driver/find-jobs');
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),

              // Footer Logout
              AppButton(
                text: 'Keluar Akun',
                styleType: ButtonStyleType.outlined,
                onPressed: () {
                  appState.logout();
                  context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
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
          // Icon Container
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
          // Content text
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