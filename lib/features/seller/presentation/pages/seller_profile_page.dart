import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';
import 'seller_widgets.dart';

class SellerProfilePage extends StatelessWidget {
  const SellerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final store = appState.currentUserStore;

    // Guard: not logged in
    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const SellerAppBar(title: 'Profil Seller'),
        body: EmptyState(
          title: 'Belum Masuk Akun',
          message: 'Silakan masuk ke akun SEAPEDIA Anda terlebih dahulu.',
          icon: Icons.account_circle_outlined,
          buttonText: 'Masuk Akun',
          onButtonPressed: () => context.go('/login'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SellerAppBar(title: 'Profil Seller'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. User Info Header Card
              AppCard(
                radius: 20,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.tertiary,
                      child: const Icon(Icons.storefront, size: 36, color: AppColors.primary),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Active Role & Available Roles Badge section
              Text(
                'Peran & Akses',
                style: AppTextStyles.label.copyWith(fontSize: 14, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              AppCard(
                radius: 16,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            'Seller Mode',
                            style: AppTextStyles.label.copyWith(fontSize: 11, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Daftar Role yang Dimiliki:',
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: user.roles.map((role) {
                        final isActive = role == appState.activeRole;
                        return Chip(
                          label: Text(role),
                          backgroundColor: isActive ? AppColors.primary.withOpacity(0.1) : AppColors.border.withOpacity(0.5),
                          labelStyle: AppTextStyles.label.copyWith(
                            fontSize: 11,
                            color: isActive ? AppColors.primary : AppColors.neutral,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isActive ? AppColors.primary : Colors.transparent,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Store Overview Card
              Text(
                'Informasi Toko Anda',
                style: AppTextStyles.label.copyWith(fontSize: 14, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              store != null
                  ? AppCard(
                      onTap: () => context.push('/seller/store'),
                      radius: 16,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              store.logoUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 50,
                                height: 50,
                                color: AppColors.tertiary.withOpacity(0.3),
                                child: const Icon(Icons.storefront, color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  store.name,
                                  style: AppTextStyles.label.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 12, color: AppColors.neutral),
                                    const SizedBox(width: 2),
                                    Text(
                                      store.location,
                                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${store.rating}',
                                      style: AppTextStyles.label.copyWith(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 16, color: AppColors.neutral),
                        ],
                      ),
                    )
                  : AppCard(
                      onTap: () => context.push('/seller/store'),
                      radius: 16,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Belum memiliki Toko',
                                style: AppTextStyles.label.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Mulai buat Toko untuk menjual produk',
                                style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                          const Icon(Icons.add_box_outlined, color: AppColors.primary),
                        ],
                      ),
                    ),
              const SizedBox(height: 32),

              // 4. Role Switch Action (for multi-role user)
              if (user.roles.length > 1) ...[
                AppButton(
                  text: 'Beralih Ke Mode Pembeli (Buyer)',
                  icon: Icons.swap_horiz,
                  onPressed: () {
                    appState.setActiveRole('Buyer');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Switched to Buyer Mode')),
                    );
                    context.go('/landing');
                  },
                ),
                const SizedBox(height: 16),
              ],

              // 5. Logout Action
              AppButton(
                text: 'Keluar dari Akun',
                styleType: ButtonStyleType.outlined,
                onPressed: () {
                  appState.logout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logout berhasil.')),
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
}
