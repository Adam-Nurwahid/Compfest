import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';
import '../widgets/driver_widgets.dart';

class DriverActiveJobPage extends StatelessWidget {
  const DriverActiveJobPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final driverId = appState.currentUser?.id ?? '';

    // Find the single active delivery assigned to this driver
    final activeJobs = appState.orders.where((o) =>
        o.assignedDriverId == driverId && o.status == 'Sedang Dikirim'
    ).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DriverAppBar(title: 'Pengiriman Aktif', showSwitch: false),
      body: SafeArea(
        child: activeJobs.isEmpty
            ? const Center(
                child: EmptyState(
                  title: 'Tidak Ada Pengiriman Aktif',
                  message: 'Saat ini Anda tidak sedang menjalankan tugas pengiriman. Silakan ambil pesanan di tab "Cari Job".',
                  icon: Icons.local_shipping_outlined,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    ActiveJobCard(
                      order: activeJobs.first,
                      onComplete: () {
                        final order = activeJobs.first;
                        appState.completeJob(order.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Pesanan ${order.id} berhasil diselesaikan!'),
                            backgroundColor: Colors.teal,
                          ),
                        );
                        // Redirect to history-earnings tab (index 2)
                        context.go('/driver/history-earnings');
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
