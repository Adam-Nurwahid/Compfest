import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';
import '../../../../data/models/models.dart';
import '../widgets/driver_widgets.dart';

class DriverJobHistoryPage extends StatelessWidget {
  const DriverJobHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final driverId = appState.currentUser?.id ?? '';

    // Filter jobs completed by this driver
    final completedJobs = appState.orders.where((o) =>
        o.assignedDriverId == driverId && o.status == 'Pesanan Selesai'
    ).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'Riwayat & Keuangan',
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: AppColors.secondary,
            tabs: [
              Tab(text: 'Dashboard Keuangan'),
              Tab(text: 'Riwayat Job'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              // Tab 1: Dashboard Earnings
              _buildEarningsDashboard(context, appState, completedJobs),

              // Tab 2: History List
              _buildHistoryList(context, appState, completedJobs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsDashboard(
    BuildContext context,
    AppState appState,
    List<Order> completedJobs,
  ) {
    if (completedJobs.isEmpty) {
      return const Center(
        child: EmptyState(
          title: 'Tidak Ada Pendapatan',
          message: 'Selesaikan pengiriman pertama Anda untuk melihat grafik analisis pendapatan di sini.',
          icon: Icons.bar_chart_rounded,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Graphic Card summary
          EarningSummaryCard(completedJobs: completedJobs),
          const SizedBox(height: 24),

          Text(
            'Rincian Transaksi Masuk',
            style: AppTextStyles.label.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: completedJobs.length,
            itemBuilder: (context, idx) {
              final order = completedJobs[idx];
              final earning = appState.calculateDriverEarning(order);
              
              final formattedEarning = earning
                  .toString()
                  .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

              final date = order.statusTimeline.isNotEmpty 
                  ? order.statusTimeline.last.timestamp 
                  : DateTime.now();

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                elevation: 0,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_downward, color: Colors.teal, size: 20),
                  ),
                  title: Text(
                    'Uang Masuk - ${order.id}',
                    style: AppTextStyles.label.copyWith(fontSize: 13),
                  ),
                  subtitle: Text(
                    'Selesai pada: ${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                  ),
                  trailing: Text(
                    '+Rp$formattedEarning',
                    style: AppTextStyles.label.copyWith(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    AppState appState,
    List<Order> completedJobs,
  ) {
    if (completedJobs.isEmpty) {
      return const Center(
        child: EmptyState(
          title: 'Belum Ada Pengiriman',
          message: 'Pengiriman yang Anda selesaikan akan muncul di sini sebagai arsip pekerjaan Anda.',
          icon: Icons.history_rounded,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      itemCount: completedJobs.length,
      itemBuilder: (context, idx) {
        final order = completedJobs[idx];
        final earning = appState.calculateDriverEarning(order);
        
        final formattedEarning = earning
            .toString()
            .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.id,
                      style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.neutral),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Selesai',
                        style: AppTextStyles.label.copyWith(fontSize: 9, color: const Color(0xFF065F46)),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  'Dari Toko: ${order.storeName}',
                  style: AppTextStyles.label.copyWith(fontSize: 12),
                ),
                Text(
                  'Penerima: ${order.address.receiverName}',
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Metode: ${order.deliveryMethod}',
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                    ),
                    Text(
                      'Pendapatan: Rp$formattedEarning',
                      style: AppTextStyles.label.copyWith(fontSize: 12, color: Colors.teal, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
