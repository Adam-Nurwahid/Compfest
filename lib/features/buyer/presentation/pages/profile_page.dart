import 'package:compfest/features/auth/presentation/pages/role_selection_page.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _activeRole = 'Buyer'; // Simulasi peran aktif saat ini [cite: 120]

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'SEAPEDIA',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
            letterSpacing: 1.0,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Avatar dengan Badge Terverifikasi
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 54,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    // Menggunakan ikon jangkar sebagai placeholder avatar maritim
                    child: Icon(Icons.anchor, size: 50, color: Colors.white),
                  ),
                ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Info Nama & Username
            Text(
              'Budi Samudra',
              style: AppTextStyles.headlineMedium.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              '@budisea',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral),
            ),
            const SizedBox(height: 16),

            // 3. Indikator Peran Aktif & Tombol Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Active Role: $_activeRole',
                        style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    // Navigasi ke halaman pemilihan peran yang sudah dibuat sebelumnya
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
                    );
                  },
                  child: Text(
                    'Switch Role',
                    style: AppTextStyles.label.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Tombol Tab Seleksi Peran Cepat
            Row(
              children: [
                _buildRoleTab('Buyer', Icons.shopping_cart, _activeRole == 'Buyer'),
                const SizedBox(width: 8),
                _buildRoleTab('Seller', Icons.storefront, _activeRole == 'Seller'),
                const SizedBox(width: 8),
                _buildRoleTab('Driver', Icons.moped, _activeRole == 'Driver'),
              ],
            ),
            const SizedBox(height: 24),

            // 5. Kartu Informasi Keuangan (Total Balance)
            _buildBalanceCard(),
            const SizedBox(height: 32),

            // 6. Section Account Settings
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Account Settings',
                style: AppTextStyles.label.copyWith(color: AppColors.neutral, fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),

            // Daftar Menu Pengaturan (Composition Menu Tiles)
            _buildMenuTile(Icons.edit_outlined, 'Edit Profile'),
            _buildMenuTile(Icons.location_on_outlined, 'Addresses'),
            _buildMenuTile(Icons.security, 'Security & Password'),
            _buildMenuTile(Icons.notifications_none, 'Notifications'),
            _buildMenuTile(Icons.help_outline, 'Help Center'),

            // Tombol Logout Khusus
            _buildMenuTile(
              Icons.logout,
              'Logout',
              textColor: AppColors.danger,
              iconColor: AppColors.danger,
              showTrailing: false,
            ),
          ],
        ),
      ),
    );
  }

  // Komponen Tab Peran
  Widget _buildRoleTab(String role, IconData icon, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.tertiary.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : AppColors.textPrimary, size: 18),
            const SizedBox(width: 8),
            Text(
              role,
              style: AppTextStyles.label.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Komponen Ringkasan Saldo Finansial
  Widget _buildBalanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL BALANCE',
                  style: AppTextStyles.label.copyWith(color: AppColors.neutral, fontSize: 13, letterSpacing: 0.5),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_balance_wallet, color: AppColors.secondary, size: 20),
                )
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Rp 2.500.000',
              style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary, fontSize: 28),
            ),
            const SizedBox(height: 20),

            // Sub-Balance Breakdowns
            _buildSubBalanceItem('Wallet', 'Rp 500.000'),
            const SizedBox(height: 12),
            _buildSubBalanceItem('Seller Income', 'Rp 1.200.000'),
            const SizedBox(height: 12),
            _buildSubBalanceItem('Driver Earnings', 'Rp 800.000'),
          ],
        ),
      ),
    );
  }

  Widget _buildSubBalanceItem(String label, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
          Text(amount, style: AppTextStyles.label.copyWith(fontSize: 15)),
        ],
      ),
    );
  }

  // Komponen Menu Pengaturan (List Tile Custom)
  Widget _buildMenuTile(
      IconData leadingIcon,
      String title, {
        Color? textColor,
        Color? iconColor,
        bool showTrailing = true,
      }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withOpacity(0.4)),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.background,
            child: Icon(leadingIcon, color: iconColor ?? AppColors.primary, size: 20),
          ),
          title: Text(
            title,
            style: AppTextStyles.label.copyWith(
              color: textColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          trailing: showTrailing
              ? const Icon(Icons.chevron_right, color: AppColors.neutral, size: 20)
              : null,
          onTap: () {
            // Logika aksi menu
          },
        ),
      ),
    );
  }
}