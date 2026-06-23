import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../buyer/presentation/pages/main_navigation_shell.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String _selectedRole = 'buyer'; // Default terpilah ke buyer

  @override
  Widget build(BuildContext context) {
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
                'SEAPEDIA',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1.0,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Masuk sebagai apa hari ini?',
                style: AppTextStyles.headlineLarge.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih peran Anda untuk melanjutkan aktivitas.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 32),

              // Daftar Kartu Pilihan Peran (Composition Components)
              _buildRoleCard(
                roleKey: 'buyer',
                title: 'Buyer',
                description: 'Belanja berbagai kebutuhan maritim.',
                icon: Icons.shopping_bag_outlined,
                iconColor: AppColors.primary,
                bgColor: const Color(0xFFE6F4F4),
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                roleKey: 'seller',
                title: 'Seller',
                description: 'Mulai berjualan dan kelola tokomu.',
                icon: Icons.storefront_outlined,
                iconColor: const Color(0xFF6C5CE7),
                bgColor: const Color(0xFFEFEFFA),
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                roleKey: 'driver',
                title: 'Driver',
                description: 'Kirim pesanan dan dapatkan penghasilan.',
                icon: Icons.moped_outlined,
                iconColor: AppColors.secondary,
                bgColor: const Color(0xFFFFF2EE),
              ),

              const Spacer(),

              // Tombol Konfirmasi Continue
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppButtonStyles.primary.copyWith(
                    backgroundColor: WidgetStateProperty.all(AppColors.secondary),
                  ),
                  onPressed: () {
                    // Pindah ke halaman utama aplikasi setelah memilih peran
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MainNavigationShell()),
                          (route) => false,
                    );
                  },
                  child: Text(
                    'Continue',
                    style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Informasi Footer bawah
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.neutral),
                    const SizedBox(width: 8),
                    Text(
                      'You can switch roles anytime from your profile.',
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Komponen Kartu Opsi Peran Berbasis Komposisi Widget
  Widget _buildRoleCard({
    required String roleKey,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    final isSelected = _selectedRole == roleKey;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = roleKey;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.label.copyWith(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(description, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            if (isSelected)
              const CircleAvatar(
                radius: 10,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.check, color: Colors.white, size: 12),
              ),
          ],
        ),
      ),
    );
  }
}