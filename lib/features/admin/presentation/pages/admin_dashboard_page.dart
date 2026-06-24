import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';
import '../../../../data/dummy/dummy_data.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final totalUsers = dummyUsers.length;
    final totalStores = dummyStores.length;
    final totalProducts = dummyProducts.length;
    
    final orders = appState.orders;
    final totalOrders = orders.length;
    
    // Status counts
    final packagingCount = orders.where((o) => o.status == 'Sedang Dikemas').length;
    final waitingCourierCount = orders.where((o) => o.status == 'Menunggu Pengirim').length;
    final shippingCount = orders.where((o) => o.status == 'Sedang Dikirim').length;
    final completedCount = orders.where((o) => o.status == 'Pesanan Selesai').length;
    final returnedCount = orders.where((o) => o.status == 'Dikembalikan').length;

    // Overdue count (Instant or Next Day orders that are not finished and started > 12 hours ago)
    final overdueOrders = orders.where((o) {
      if (o.status == 'Pesanan Selesai' || o.status == 'Dikembalikan') return false;
      final isExpress = o.deliveryMethod == 'Instant' || o.deliveryMethod == 'Next Day';
      return isExpress; // For mock purposes, express orders not finished are overdue
    }).toList();
    final totalOverdue = overdueOrders.length;

    final totalActiveVouchers = appState.vouchers.where((v) => v.quotaRemaining > 0 && v.expiryDate.isAfter(DateTime.now())).length;
    final totalActivePromos = appState.promos.where((p) => p.expiryDate.isAfter(DateTime.now())).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Key Stats
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 768 ? 2 : 1);
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.0,
                children: [
                  _buildStatCard(
                    title: 'Total Pengguna',
                    value: totalUsers.toString(),
                    icon: Icons.people_rounded,
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    title: 'Total Toko',
                    value: totalStores.toString(),
                    icon: Icons.storefront_rounded,
                    color: Colors.purple,
                  ),
                  _buildStatCard(
                    title: 'Total Produk',
                    value: totalProducts.toString(),
                    icon: Icons.inventory_2_rounded,
                    color: AppColors.primary,
                  ),
                  _buildStatCard(
                    title: 'Voucher & Promo Aktif',
                    value: '${totalActiveVouchers}V / ${totalActivePromos}P',
                    icon: Icons.card_membership_rounded,
                    color: AppColors.secondary,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Row 2: Order Status Summary
          Text('Status Pesanan', style: AppTextStyles.label.copyWith(fontSize: 18, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1200 ? 5 : (constraints.maxWidth > 768 ? 3 : 2);
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.5,
                children: [
                  _buildMiniStatusCard('Sedang Dikemas', packagingCount, AppColors.primary),
                  _buildMiniStatusCard('Menunggu Pengirim', waitingCourierCount, Colors.amber),
                  _buildMiniStatusCard('Sedang Dikirim', shippingCount, Colors.blue),
                  _buildMiniStatusCard('Pesanan Selesai', completedCount, Colors.green),
                  _buildMiniStatusCard('Dikembalikan (Refund)', returnedCount, AppColors.danger),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // Row 3: Tables Grid
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 1024) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildRecentOrdersTable(orders, context)),
                    const SizedBox(width: 24),
                    Expanded(flex: 2, child: _buildOverdueSummaryTable(overdueOrders, context)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildRecentOrdersTable(orders, context),
                    const SizedBox(height: 24),
                    _buildOverdueSummaryTable(overdueOrders, context),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMiniStatusCard(String status, int count, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              status,
              style: AppTextStyles.label.copyWith(fontSize: 12, color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              count.toString(),
              style: AppTextStyles.label.copyWith(color: color, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRecentOrdersTable(List<dynamic> orders, BuildContext context) {
    // Limit to latest 5 orders
    final recentOrders = orders.take(5).toList();

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Orders', style: AppTextStyles.label.copyWith(fontSize: 16)),
              TextButton(
                onPressed: () {
                  context.go('/admin/orders');
                },
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recentOrders.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: Text('Belum ada pesanan')),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                headingRowHeight: 40,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 56,
                columns: const [
                  DataColumn(label: Text('Order ID')),
                  DataColumn(label: Text('Toko')),
                  DataColumn(label: Text('Total')),
                  DataColumn(label: Text('Status')),
                ],
                rows: recentOrders.map((o) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          o.id,
                          style: AppTextStyles.label.copyWith(fontSize: 12, color: AppColors.primary),
                        ),
                      ),
                      DataCell(Text(o.storeName, style: const TextStyle(fontSize: 12))),
                      DataCell(
                        Text(
                          'Rp${o.finalTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataCell(StatusBadge(status: o.status)),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverdueSummaryTable(List<dynamic> overdueOrders, BuildContext context) {
    final recentOverdue = overdueOrders.take(5).toList();

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Recent Overdue', style: AppTextStyles.label.copyWith(fontSize: 16)),
                  if (overdueOrders.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        overdueOrders.length.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ]
                ],
              ),
              TextButton(
                onPressed: () {
                  context.go('/admin/overdue');
                },
                child: const Text('Detail SLA'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recentOverdue.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: Text('Tidak ada pesanan overdue')),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                headingRowHeight: 40,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 56,
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Layanan')),
                  DataColumn(label: Text('Status')),
                ],
                rows: recentOverdue.map((o) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          o.id,
                          style: AppTextStyles.label.copyWith(fontSize: 12, color: AppColors.danger),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(o.deliveryMethod, style: const TextStyle(fontSize: 11, color: AppColors.secondaryDark)),
                        ),
                      ),
                      DataCell(StatusBadge(status: o.status)),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
