import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';
import '../../../../data/dummy/dummy_data.dart';
import 'seller_widgets.dart';

class SellerDashboardPage extends StatelessWidget {
  const SellerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final myStore = appState.currentUserStore;

    // 1. If seller does not have a store, display "Buat Toko Dulu" Call To Action page
    if (myStore == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const SellerAppBar(title: 'Dashboard Seller'),
        body: EmptyState(
          title: 'Belum Memiliki Toko',
          message: 'Anda terdaftar sebagai Seller, namun belum memiliki Toko aktif. Silakan buat toko Anda terlebih dahulu untuk mengelola produk dan melayani pembeli.',
          icon: Icons.storefront_outlined,
          buttonText: 'Buat Toko Sekarang',
          onButtonPressed: () {
            context.push('/seller/store');
          },
        ),
      );
    }

    // 2. Calculate Stats
    final myProducts = dummyProducts.where((p) => p.storeId == myStore.id).toList();
    final myOrders = appState.orders.where((o) => o.storeId == myStore.id).toList();

    final activeProductsCount = myProducts.length;
    final pendingOrdersCount = myOrders.where((o) => o.status == 'Sedang Dikemas').length;
    final processedOrdersCount = myOrders.where((o) => o.status == 'Menunggu Pengirim').length;

    // Revenue calculation (exclude 'Dikembalikan' / refund)
    final completedOrders = myOrders.where((o) => o.status == 'Pesanan Selesai').toList();
    final totalIncome = completedOrders.fold<int>(0, (sum, o) {
      // Sum only items price
      return sum + o.finalTotal;
    });

    final formattedIncome = totalIncome
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    // Chart data for monthly income (Jan - Jun)
    // Add current completed revenue to June or current month
    final List<double> chartValues = [1500000, 2800000, 1900000, 3500000, 4200000, totalIncome.toDouble()];
    final List<String> chartLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SellerAppBar(
        title: 'Dashboard Seller',
        store: myStore,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Text
              Text(
                'Selamat Datang Kembali,',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral),
              ),
              const SizedBox(height: 4),
              Text(
                '${appState.currentUser?.name ?? 'Seller'} 👋',
                style: AppTextStyles.headlineMedium.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 24),

              // Statistics Cards Grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.8,
                children: [
                  StatCard(
                    title: 'Produk Aktif',
                    value: '$activeProductsCount',
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.primary,
                    onTap: () => context.go('/seller/products'),
                  ),
                  StatCard(
                    title: 'Pesanan Masuk',
                    value: '$pendingOrdersCount',
                    icon: Icons.inventory_2_outlined, // using appropriate icon
                    color: AppColors.secondary,
                    onTap: () => context.go('/seller/orders'),
                  ),
                  StatCard(
                    title: 'Menunggu Kirim',
                    value: '$processedOrdersCount',
                    icon: Icons.local_shipping_outlined,
                    color: Colors.blue,
                    onTap: () => context.go('/seller/orders'),
                  ),
                  StatCard(
                    title: 'Total Pendapatan',
                    value: 'Rp$formattedIncome',
                    icon: Icons.monetization_on_outlined,
                    color: Colors.green,
                    onTap: () => context.go('/seller/report'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Aksi Cepat',
                style: AppTextStyles.label.copyWith(fontSize: 16, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      context,
                      label: 'Tambah\nProduk',
                      icon: Icons.add_circle_outline_rounded,
                      color: AppColors.primary,
                      onTap: () => context.push('/seller/product/add'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionButton(
                      context,
                      label: 'Pesanan\nMasuk',
                      icon: Icons.receipt_long_outlined,
                      color: AppColors.secondary,
                      onTap: () => context.go('/seller/orders'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionButton(
                      context,
                      label: 'Laporan\nKeuangan',
                      icon: Icons.bar_chart_rounded,
                      color: Colors.teal,
                      onTap: () => context.go('/seller/report'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Income Chart
              CustomDashboardChart(
                values: chartValues,
                labels: chartLabels,
                title: 'Tren Pendapatan Bulanan (Rupiah)',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      radius: 16,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: AppTextStyles.label.copyWith(fontSize: 12, height: 1.2),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
