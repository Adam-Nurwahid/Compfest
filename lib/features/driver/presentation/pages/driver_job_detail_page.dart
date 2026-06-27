import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';
import '../../../../data/models/models.dart';

class DriverJobDetailPage extends StatelessWidget {
  final String orderId;

  const DriverJobDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final driverId = appState.currentUser?.id ?? '';

    // Retrieve order
    Order? order;
    try {
      order = appState.orders.firstWhere((o) => o.id == orderId);
    } catch (_) {}

    if (order == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: 'Detail Lowongan'),
        body: Center(
          child: EmptyState(
            title: 'Pekerjaan Tidak Ditemukan',
            message: 'Maaf, data pekerjaan ini tidak dapat ditemukan.',
            icon: Icons.search_off,
            buttonText: 'Kembali',
            onButtonPressed: () => context.pop(),
          ),
        ),
      );
    }

    final activeOrder = order;
    final earning = appState.calculateDriverEarning(activeOrder);

    final formattedEarning = earning
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    final formattedDeliveryFee = activeOrder.deliveryFee
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    // Method delivery styling
    Color badgeBg;
    Color badgeText;
    switch (activeOrder.deliveryMethod.toLowerCase()) {
      case 'instant':
        badgeBg = const Color(0xFFFFEBE3);
        badgeText = const Color(0xFFE04A1B);
        break;
      case 'next day':
        badgeBg = const Color(0xFFE2F0FD);
        badgeText = const Color(0xFF0F62AC);
        break;
      default:
        badgeBg = const Color(0xFFECEFF1);
        badgeText = const Color(0xFF37474F);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Detail Job ${activeOrder.id}',
        onBackPress: () => context.pop(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Job summary card (with earnings)
                    AppCard(
                      color: const Color(0xFF1E293B),
                      radius: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ESTIMASI PENDAPATAN BERSIH',
                                style: AppTextStyles.label.copyWith(
                                  fontSize: 10,
                                  color: Colors.white60,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Rp$formattedEarning',
                                style: const TextStyle(
                                  color: Colors.teal,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: badgeBg.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              activeOrder.deliveryMethod,
                              style: AppTextStyles.label.copyWith(
                                fontSize: 11,
                                color: badgeText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Routes points
                    Text(
                      'Rute Pengiriman',
                      style: AppTextStyles.label.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    AppCard(
                      radius: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRouteNode(
                            icon: Icons.radio_button_checked,
                            iconColor: AppColors.primary,
                            title: 'AMBIL (PICKUP STORE)',
                            address: activeOrder.pickupAddress,
                            storeName: activeOrder.storeName,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Container(
                              width: 2,
                              height: 32,
                              color: AppColors.border,
                            ),
                          ),
                          _buildRouteNode(
                            icon: Icons.location_on,
                            iconColor: AppColors.secondary,
                            title: 'KIRIM (DROPOFF BUYER)',
                            address: activeOrder.dropoffAddress,
                            receiverName: activeOrder.address.receiverName,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Products summary
                    Text(
                      'Detail Barang Bawaan',
                      style: AppTextStyles.label.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    AppCard(
                      radius: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: activeOrder.items.length,
                            itemBuilder: (context, idx) {
                              final item = activeOrder.items[idx];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        color: AppColors.tertiary.withOpacity(0.3),
                                        child: Image.network(
                                          item.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.broken_image, size: 18),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.productName,
                                            style: AppTextStyles.label.copyWith(fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'Jumlah: ${item.quantity} barang',
                                            style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Biaya Ongkir',
                                style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                              ),
                              Text(
                                'Rp$formattedDeliveryFee',
                                style: AppTextStyles.label.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // CTA Button Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(top: BorderSide(color: AppColors.border, width: 1.0)),
              ),
              child: AppButton(
                text: 'Ambil Job Pengiriman',
                icon: Icons.check,
                styleType: ButtonStyleType.primary,
                onPressed: () async {
                  // Validate if driver has an active job
                  final hasActiveJob = appState.orders.any(
                    (o) => o.assignedDriverId == driverId && o.status == 'Sedang Dikirim'
                  );
                  if (hasActiveJob) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(duration: const Duration(seconds: 2), 
                        content: Text('Anda masih memiliki 1 pengiriman aktif! Selesaikan terlebih dahulu sebelum mengambil job baru.'),
                        backgroundColor: AppColors.danger,
                      ),
                    );
                    return;
                  }

                  // Take Job
                  final success = await appState.takeJob(activeOrder.id, driverId);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(duration: const Duration(seconds: 2), 
                        content: Text('Berhasil mengambil job ${activeOrder.id}!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                    context.go('/driver/active-job');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(duration: const Duration(seconds: 2), 
                        content: Text('Gagal mengambil job. Job ini mungkin sudah diambil kurir lain (Simulasi Race Condition).'),
                        backgroundColor: AppColors.danger,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteNode({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String address,
    String? storeName,
    String? receiverName,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.label.copyWith(
                  fontSize: 10,
                  color: AppColors.neutral,
                  letterSpacing: 0.5,
                ),
              ),
              if (storeName != null) ...[
                Text(
                  storeName,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
              if (receiverName != null) ...[
                Text(
                  receiverName,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
              Text(
                address,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
