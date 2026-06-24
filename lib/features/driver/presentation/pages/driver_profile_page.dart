import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';

class DriverProfilePage extends StatelessWidget {
  const DriverProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Profil Driver')),
        body: Center(
          child: EmptyState(
            title: 'Belum Masuk',
            message: 'Silakan masuk ke akun Anda.',
            icon: Icons.account_circle,
            buttonText: 'Login',
            onButtonPressed: () => context.go('/login'),
          ),
        ),
      );
    }

    final driverJobs = appState.orders.where((o) =>
        o.assignedDriverId == user.id && o.status == 'Pesanan Selesai'
    ).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Profil Kurir Laut',
          style: AppTextStyles.headlineMedium.copyWith(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFF334155), height: 1.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            children: [
              // User header card
              AppCard(
                radius: 20,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.tertiary,
                      child: const Icon(Icons.delivery_dining, size: 40, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: AppTextStyles.label.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Mode: Driver',
                              style: AppTextStyles.label.copyWith(fontSize: 11, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Operational Stats Card
              AppCard(
                radius: 20,
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.teal,
                      value: '${driverJobs.length}',
                      label: 'Job Selesai',
                    ),
                    Container(width: 1, height: 40, color: AppColors.border),
                    _buildStatColumn(
                      icon: Icons.star_rounded,
                      iconColor: Colors.amber,
                      value: '4.9',
                      label: 'Rating Kurir',
                    ),
                    Container(width: 1, height: 40, color: AppColors.border),
                    _buildStatColumn(
                      icon: Icons.verified_user_outlined,
                      iconColor: AppColors.primary,
                      value: 'Aktif',
                      label: 'Status Akun',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Menu Options
              AppCard(
                radius: 20,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    // Online Toggle switch inside list tile
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.tertiary.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          appState.isDriverOnline ? Icons.wifi : Icons.wifi_off,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Status Online/Offline',
                        style: AppTextStyles.label.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        appState.isDriverOnline ? 'Menerima order pengiriman baru' : 'Sedang istirahat / tidak menerima order',
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                      ),
                      trailing: Switch(
                        value: appState.isDriverOnline,
                        onChanged: (val) {
                          appState.toggleDriverOnline();
                        },
                        activeColor: AppColors.primary,
                      ),
                    ),
                    
                    if (user.roles.length > 1) ...[
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.tertiary.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.swap_horiz, color: AppColors.primary, size: 20),
                        ),
                        title: Text(
                          'Ganti Mode Peran',
                          style: AppTextStyles.label.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Pindah ke dashboard Buyer atau Seller',
                          style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.neutral),
                        onTap: () {
                          context.push('/role-selection');
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Logout Button
              AppButton(
                text: 'Keluar dari Akun',
                styleType: ButtonStyleType.outlined,
                onPressed: () {
                  appState.logout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Berhasil keluar.')),
                  );
                  context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.label.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
