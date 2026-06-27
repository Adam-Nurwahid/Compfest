import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../core/widgets/manage_roles_section.dart';
import '../../../../data/dummy/app_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // If not logged in, show Guest login prompt
    if (!appState.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Profil Saya', style: AppTextStyles.headlineMedium.copyWith(fontSize: 20)),
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: AppColors.border, height: 1.0),
          ),
        ),
        body: EmptyState(
          title: 'Belum Masuk Akun',
          message: 'Silakan masuk ke akun SEAPEDIA Anda untuk mengelola alamat, pesanan, dan wallet.',
          icon: Icons.account_circle_outlined,
          buttonText: 'Masuk Akun',
          onButtonPressed: () {
            context.go('/login');
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profil Saya', style: AppTextStyles.headlineMedium.copyWith(fontSize: 20)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(duration: const Duration(seconds: 2), content: Text('Fitur Pengaturan dinonaktifkan di demo ini.')),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            children: [
              // 1. User Header card
              _buildUserCard(context, appState),
              const SizedBox(height: 20),

              // 2. Manage Roles Section
              Text(
                'Peran & Akses',
                style: AppTextStyles.label.copyWith(fontSize: 14, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              AppCard(
                radius: 16,
                padding: const EdgeInsets.all(16),
                child: ManageRolesSection(),
              ),
              const SizedBox(height: 24),

              // 3. Wallet Card
              _buildWalletCard(context, appState),
              const SizedBox(height: 28),

              // 3. Menu list
              _buildMenuSection(context, appState),
              const SizedBox(height: 32),

              // 4. Logout Button
              AppButton(
                text: 'Keluar dari Akun',
                styleType: ButtonStyleType.outlined,
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                  appState.logout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(duration: const Duration(seconds: 2), content: Text('Logout berhasil.')),
                  );
                  context.go('/landing');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, AppState appState) {
    final username = appState.currentUser?.username ?? 'Guest';
    final ownedRoles = appState.availableRoles;

    return AppCard(
      radius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.tertiary,
                child: const Icon(Icons.person, size: 36, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: AppTextStyles.label.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Peran yang Dimiliki: ${ownedRoles.join(", ")}',
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
        ],
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, AppState appState) {
    final formattedBalance = appState.walletBalance
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'SEA-Wallet Saldo',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              InkWell(
                onTap: () => context.push('/wallet'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Detail',
                    style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Rp$formattedBalance',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gunakan saldo untuk transaksi kelautan instan tanpa biaya admin.',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, AppState appState) {
    return AppCard(
      radius: 20,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Daftar Alamat Pengiriman',
            subtitle: 'Atur alamat utama dan sekunder Anda',
            onTap: () => context.push('/addresses'),
          ),
          const Divider(height: 1, indent: 56),
          _buildMenuItem(
            icon: Icons.history_rounded,
            title: 'Riwayat Pesanan',
            subtitle: 'Pantau pengiriman dan status transaksi',
            onTap: () => context.push('/orders'),
          ),
          const Divider(height: 1, indent: 56),
          _buildMenuItem(
            icon: Icons.bar_chart_rounded,
            title: 'Laporan Pengeluaran',
            subtitle: 'Analisis dan grafik pengeluaran bulanan',
            onTap: () => context.push('/report'),
          ),
          const Divider(height: 1, indent: 56),
          _buildMenuItem(
            icon: Icons.rate_review_outlined,
            title: 'Beri Ulasan Aplikasi',
            subtitle: 'Beri masukan demi perkembangan SEAPEDIA',
            onTap: () => context.push('/submit-review'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.tertiary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.label.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.neutral),
      onTap: onTap,
    );
  }
}