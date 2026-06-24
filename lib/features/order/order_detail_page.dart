import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/reusable_widgets.dart';
import '../../data/dummy/app_state.dart';
import '../../data/models/models.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // Find the order in appState
    final orderIndex = appState.orders.indexWhere((o) => o.id == orderId);
    if (orderIndex == -1) {
      return const Scaffold(
        appBar: CustomAppBar(title: 'Detail Pesanan'),
        body: Center(child: Text('Pesanan tidak ditemukan')),
      );
    }
    final order = appState.orders[orderIndex];

    // Format fields
    final formattedFee = order.deliveryFee
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    final formattedPpn = order.ppnAmount
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    final formattedTotal = order.finalTotal
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    final formattedDiscount = order.discountAmount
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    // Subtotal
    final int subtotal = order.items.fold(0, (sum, item) => sum + (item.price * item.quantity));
    final formattedSubtotal = subtotal
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Detail Transaksi',
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bantuan pesanan dinonaktifkan di demo ini.')),
              );
            },
          ),
        ],
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
                    // Order ID Header Card
                    _buildOrderHeader(order),
                    const SizedBox(height: 20),

                    // Delivery Timeline Component
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: OrderStatusTimeline(
                        milestones: order.statusTimeline,
                        currentStatus: order.status,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Products List Details
                    _buildProductSection(order),
                    const SizedBox(height: 20),

                    // Shipping details Address
                    _buildShippingAddressSection(order),
                    const SizedBox(height: 20),

                    // Receipt Invoice Calculations Card
                    _buildReceiptSection(
                      subtotal: subtotal,
                      formattedSubtotal: formattedSubtotal,
                      order: order,
                      formattedFee: formattedFee,
                      formattedDiscount: formattedDiscount,
                      formattedPpn: formattedPpn,
                      formattedTotal: formattedTotal,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom Simulator controls for testing order lifecycles
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(top: BorderSide(color: AppColors.border, width: 1.0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.secondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Mode Demo: Gunakan tombol di bawah untuk menyimulasikan siklus status pengiriman.',
                          style: AppTextStyles.bodyMedium.copyWith(fontSize: 10, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    text: 'Simulasikan Status Selanjutnya',
                    styleType: ButtonStyleType.secondary,
                    onPressed: () {
                      appState.advanceOrderStatus(order.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Status pesanan berhasil diubah menjadi: "${appState.orders[orderIndex].status}"'),
                          backgroundColor: AppColors.primary,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(Order order) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ID Transaksi',
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                order.id,
                style: AppTextStyles.label.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          StatusBadge(status: order.status),
        ],
      ),
    );
  }

  Widget _buildProductSection(Order order) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                order.storeName,
                style: AppTextStyles.label.copyWith(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            itemBuilder: (context, idx) {
              final item = order.items[idx];
              final formattedPrice = item.price
                  .toString()
                  .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 52,
                        height: 52,
                        color: AppColors.tertiary.withOpacity(0.3),
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: AppTextStyles.label.copyWith(fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.quantity} barang  •  Rp$formattedPrice',
                            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddressSection(Order order) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Informasi Pengiriman',
                style: AppTextStyles.label.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Metode Kurir:', style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
              Text(
                '${order.deliveryMethod} (Rp${order.deliveryFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')})',
                style: AppTextStyles.label.copyWith(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.address.receiverName,
            style: AppTextStyles.label.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          Text(
            order.address.phoneNumber,
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            order.address.fullAddress,
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptSection({
    required int subtotal,
    required String formattedSubtotal,
    required Order order,
    required String formattedFee,
    required String formattedDiscount,
    required String formattedPpn,
    required String formattedTotal,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Rincian Pembayaran',
                style: AppTextStyles.label.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildRow('Subtotal Produk', 'Rp$formattedSubtotal'),
          if (order.discountAmount > 0)
            _buildRow(
              'Diskon ${order.voucherCode != null ? "Voucher (${order.voucherCode})" : "Promo"}',
              '- Rp$formattedDiscount',
              color: AppColors.primary,
            ),
          _buildRow('Ongkos Kirim', 'Rp$formattedFee'),
          _buildRow(
            'PPN (VAT) 12%*',
            'Rp$formattedPpn',
            subtitle: '12% × (${subtotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} - ${order.discountAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} + ${order.deliveryFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')})',
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Akhir',
                style: AppTextStyles.label.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                'Rp$formattedTotal',
                style: AppTextStyles.headlineMedium.copyWith(fontSize: 18, color: AppColors.secondary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String val, {Color? color, String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: color ?? AppColors.textPrimary),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 9, color: AppColors.neutral),
                  ),
                ],
              ],
            ),
          ),
          Text(
            val,
            style: AppTextStyles.label.copyWith(fontSize: 12, color: color ?? AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
