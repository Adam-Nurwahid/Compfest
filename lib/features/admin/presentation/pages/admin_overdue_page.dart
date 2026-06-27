import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';
import '../../../../data/models/models.dart';

class AdminOverduePage extends StatefulWidget {
  const AdminOverduePage({super.key});

  @override
  State<AdminOverduePage> createState() => _AdminOverduePageState();
}

class _AdminOverduePageState extends State<AdminOverduePage> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final orders = appState.orders;
    final simulatedNow = appState.simulatedDateTime;

    // Define SLA durations by delivery method
    Duration getSlaDuration(String method) {
      switch (method.toLowerCase()) {
        case 'instant':
          return const Duration(hours: 3);
        case 'next day':
          return const Duration(hours: 24);
        case 'regular':
        default:
          return const Duration(hours: 48);
      }
    }

    // Determine if an order is overdue
    // Overdue if order status is not finished/refunded AND simulated time exceeds expected delivery time
    final List<Map<String, dynamic>> overdueList = [];

    for (var order in orders) {
      final orderCreatedTime = order.statusTimeline.isNotEmpty
          ? order.statusTimeline.first.timestamp
          : DateTime.now();

      final sla = getSlaDuration(order.deliveryMethod);
      final expectedDeliveryTime = orderCreatedTime.add(sla);
      
      final isCompletedOrRefunded = order.status == 'Pesanan Selesai' || order.status == 'Dikembalikan';
      final isOverdue = simulatedNow.isAfter(expectedDeliveryTime);

      // We show orders in this page if they are:
      // 1. Currently overdue (exceeded expected time and not completed/refunded)
      // 2. Or they were refunded ('Dikembalikan') which indicates they were processed here
      if ((isOverdue && !isCompletedOrRefunded) || order.status == 'Dikembalikan') {
        overdueList.add({
          'order': order,
          'expectedTime': expectedDeliveryTime,
          'createdTime': orderCreatedTime,
          'isRefunded': order.status == 'Dikembalikan',
        });
      }
    }

    final pendingRefundsCount = overdueList.where((o) => !o['isRefunded']).length;
    final totalRefundedCount = overdueList.where((o) => o['isRefunded']).length;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Simulation Control Card
          AppCard(
            color: AppColors.tertiary.withOpacity(0.3),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time_filled, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Waktu Simulasi Sistem',
                            style: AppTextStyles.label.copyWith(fontSize: 16, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('dd MMMM yyyy, HH:mm').format(simulatedNow),
                        style: AppTextStyles.headlineLarge.copyWith(fontSize: 26, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Majukan hari untuk mensimulasikan paket yang melampaui batas waktu jaminan kirim (SLA).',
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                
                // Simulation Button
                ElevatedButton.icon(
                  onPressed: () {
                    appState.simulateNextDay();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Simulasi hari berhasil dimajukan ke: ${DateFormat('dd MMMM yyyy').format(appState.simulatedDateTime)}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.fast_forward, color: Colors.white),
                  label: const Text('Simulate Next Day'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Overview metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Menunggu Pengembalian Dana',
                  value: pendingRefundsCount.toString(),
                  icon: Icons.pending_actions_rounded,
                  color: AppColors.secondaryDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  title: 'Sudah Dikembalikan (Refunded)',
                  value: totalRefundedCount.toString(),
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Table
          Expanded(
            child: AppCard(
              padding: const EdgeInsets.all(0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Table Header
                    Container(
                      color: AppColors.tertiary.withOpacity(0.4),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text('Order ID', style: AppTextStyles.label)),
                          Expanded(flex: 2, child: Text('Layanan (SLA)', style: AppTextStyles.label)),
                          Expanded(flex: 3, child: Text('Batas Waktu Kirim', style: AppTextStyles.label)),
                          Expanded(flex: 3, child: Text('Simulasi Sekarang', style: AppTextStyles.label)),
                          Expanded(flex: 2, child: Text('Status Hasil', style: AppTextStyles.label)),
                          Expanded(flex: 2, child: Text('Tindakan', style: AppTextStyles.label)),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Table Body
                    Expanded(
                      child: overdueList.isEmpty
                          ? const Center(
                              child: EmptyState(
                                title: 'Tidak Ada Pesanan Terlambat (Overdue)',
                                message: 'Semua pengiriman masih berjalan sesuai SLA. Klik "Simulate Next Day" untuk mempercepat waktu.',
                                icon: Icons.sentiment_satisfied_alt_rounded,
                              ),
                            )
                          : ListView.separated(
                              itemCount: overdueList.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = overdueList[index];
                                final Order order = item['order'];
                                final DateTime expected = item['expectedTime'];
                                final bool isRefunded = item['isRefunded'];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  child: Row(
                                    children: [
                                      // ID
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          order.id,
                                          style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.primary),
                                        ),
                                      ),

                                      // SLA Method
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          '${order.deliveryMethod} (${getSlaDuration(order.deliveryMethod).inHours} Jam)',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                        ),
                                      ),

                                      // Expected
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              DateFormat('dd MMM yyyy, HH:mm').format(expected),
                                              style: const TextStyle(fontSize: 13),
                                            ),
                                            Text(
                                              'Order: ${DateFormat('dd/MM HH:mm').format(item['createdTime'])}',
                                              style: TextStyle(fontSize: 11, color: AppColors.neutral.withOpacity(0.6)),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Simulated Now
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          DateFormat('dd MMM yyyy, HH:mm').format(simulatedNow),
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),

                                      // Result Status
                                      Expanded(
                                        flex: 2,
                                        child: isRefunded
                                            ? Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: const Text(
                                                  'Sudah Dikembalikan',
                                                  style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                                                ),
                                              )
                                            : Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: AppColors.danger.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: const Text(
                                                  'Belum Diproses',
                                                  style: TextStyle(fontSize: 11, color: AppColors.danger, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                      ),

                                      // Action button
                                      Expanded(
                                        flex: 2,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: isRefunded
                                              ? const OutlinedButton(
                                                  onPressed: null,
                                                  child: Text('Selesai'),
                                                )
                                              : ElevatedButton(
                                                  onPressed: () => _confirmRefundDialog(context, appState, order),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppColors.primary,
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                  child: const Text('Refund Dana', style: TextStyle(fontSize: 12)),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRefundDialog(BuildContext context, AppState appState, Order order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Konfirmasi Pengembalian Dana'),
          content: Text(
            'Apakah Anda yakin ingin memproses pengembalian dana (refund) untuk Order ${order.id} sebesar Rp${order.finalTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}?\n\nTindakan ini akan membatalkan transaksi dan mengembalikan dana ke saldo wallet pembeli.',
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await appState.processRefund(order.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(duration: const Duration(seconds: 2), content: Text('Refund berhasil diproses untuk Order ${order.id}!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya, Refund Dana'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(title, style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.neutral)),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
