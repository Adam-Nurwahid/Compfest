import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';
import '../widgets/driver_widgets.dart';

class DriverFindJobsPage extends StatelessWidget {
  const DriverFindJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isOnline = appState.isDriverOnline;

    // Filter jobs that are 'Menunggu Pengirim' and not yet assigned to any driver
    final availableJobs = appState.orders.where((o) =>
        o.status == 'Menunggu Pengirim' && o.assignedDriverId == null
    ).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DriverAppBar(title: 'Cari Lowongan Job'),
      body: SafeArea(
        child: Column(
          children: [
            // Promotional banner or operational instructions
            if (isOnline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xFFF1F5F9),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pilih job di bawah ini sesuai rute dan ambil untuk memulai pengiriman.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 11,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: !isOnline
                  ? const Center(
                      child: EmptyState(
                        title: 'Anda Sedang Offline',
                        message: 'Ubah status tombol di kanan atas menjadi "Online" untuk melihat pengiriman yang tersedia di dermaga/toko.',
                        icon: Icons.portable_wifi_off_rounded,
                      ),
                    )
                  : availableJobs.isEmpty
                      ? const Center(
                          child: EmptyState(
                            title: 'Tidak Ada Lowongan',
                            message: 'Semua pesanan saat ini sudah terambil atau masih dalam proses pengemasan seller. Coba periksa lagi nanti.',
                            icon: Icons.search_off_rounded,
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            // Dummy simulation refresh delay
                            await Future.delayed(const Duration(milliseconds: 800));
                            if (context.mounted) {
                              // Triggers provider refresh
                              appState.triggerRefresh();
                            }
                          },
                          color: AppColors.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                            itemCount: availableJobs.length,
                            itemBuilder: (context, idx) {
                              final order = availableJobs[idx];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: JobCard(
                                  order: order,
                                  onTap: () {
                                    context.push('/driver/job/${order.id}');
                                  },
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
