import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';
import '../../../../data/models/models.dart';
import 'seller_widgets.dart';

class SellerOrderDetailPage extends StatelessWidget {
  final String orderId;

  const SellerOrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final myStore = appState.currentUserStore;

    // Retrieve order
    Order? order;
    try {
      order = appState.orders.firstWhere((o) => o.id == orderId);
    } catch (_) {}

    // Guard: Order not found or doesn't belong to this seller
    if (order == null || myStore == null || order.storeId != myStore.id) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const SellerAppBar(title: 'Detail Pesanan'),
        body: Center(
          child: EmptyState(
            title: 'Pesanan Tidak Ditemukan',
            message: 'Maaf, data pesanan ini tidak dapat diakses atau bukan milik Toko Anda.',
            icon: Icons.receipt_long_outlined,
            buttonText: 'Kembali',
            onButtonPressed: () => context.pop(),
          ),
        ),
      );
    }

    // Capture non-nullable final variable for promotion
    final activeOrder = order;

    final formattedTotal = activeOrder.finalTotal
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    final formattedDelivery = activeOrder.deliveryFee
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    final formattedDiscount = activeOrder.discountAmount
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    final formattedPpn = activeOrder.ppnAmount
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    final itemsSubtotal = activeOrder.items.fold<int>(0, (sum, i) => sum + (i.price * i.quantity));
    final formattedSubtotal = itemsSubtotal
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SellerAppBar(
        title: 'Detail ${activeOrder.id}',
        store: myStore,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Order Status & Header Card
              AppCard(
                radius: 16,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID Pesanan: ${activeOrder.id}',
                          style: AppTextStyles.label.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status saat ini',
                          style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                    StatusBadge(status: activeOrder.status),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Buyer Shipping Information Card
              Text(
                'Informasi Pengiriman',
                style: AppTextStyles.label.copyWith(fontSize: 14, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              AppCard(
                radius: 16,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          activeOrder.address.receiverName,
                          style: AppTextStyles.label.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.phone_iphone_outlined, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          activeOrder.address.phoneNumber,
                          style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            activeOrder.address.fullAddress,
                            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined, size: 16, color: AppColors.secondary),
                        const SizedBox(width: 8),
                        Text(
                          'Kurir: ${activeOrder.deliveryMethod}',
                          style: AppTextStyles.label.copyWith(fontSize: 12, color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Order Items
              Text(
                'Produk yang Dipesan',
                style: AppTextStyles.label.copyWith(fontSize: 14, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              AppCard(
                radius: 16,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: List.generate(activeOrder.items.length, (idx) {
                    final item = activeOrder.items[idx];
                    final formattedItemPrice = item.price
                        .toString()
                        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
                    final formattedItemSub = (item.price * item.quantity)
                        .toString()
                        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 50,
                                  height: 50,
                                  color: AppColors.tertiary.withOpacity(0.3),
                                  child: const Icon(Icons.broken_image_outlined, size: 24, color: AppColors.primary),
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
                                    style: AppTextStyles.label.copyWith(fontSize: 13),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.quantity} x Rp$formattedItemPrice',
                                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Rp$formattedItemSub',
                              style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        if (idx < activeOrder.items.length - 1) const Divider(height: 24),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),

              // 4. Financial breakdown
              Text(
                'Rincian Pembayaran',
                style: AppTextStyles.label.copyWith(fontSize: 14, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              AppCard(
                radius: 16,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildRowDetail('Subtotal Produk', 'Rp$formattedSubtotal'),
                    const SizedBox(height: 8),
                    _buildRowDetail('Biaya Pengiriman', 'Rp$formattedDelivery'),
                    const SizedBox(height: 8),
                    _buildRowDetail('Diskon Voucher', '-Rp$formattedDiscount', isDiscount: true),
                    const SizedBox(height: 8),
                    _buildRowDetail('PPN (12%)', 'Rp$formattedPpn'),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Pendapatan',
                          style: AppTextStyles.label.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rp$formattedTotal',
                          style: AppTextStyles.label.copyWith(fontSize: 16, color: AppColors.secondary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 5. Timeline Delivery status
              OrderStatusTimeline(
                milestones: activeOrder.statusTimeline,
                currentStatus: activeOrder.status,
              ),
              const SizedBox(height: 32),

              // Process Order Action Button
              if (activeOrder.status == 'Sedang Dikemas') ...[
                AppButton(
                  text: 'Proses Pesanan Sekarang',
                  icon: Icons.inventory_2_outlined,
                  styleType: ButtonStyleType.secondary,
                  onPressed: () async {
                    await appState.processOrder(orderId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(duration: const Duration(seconds: 2), 
                        content: Text('Pesanan $orderId berhasil diproses!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              AppButton(
                text: 'Kembali ke Daftar Pesanan',
                styleType: ButtonStyleType.outlined,
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowDetail(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
        Text(
          value,
          style: AppTextStyles.label.copyWith(
            fontSize: 12,
            color: isDiscount ? AppColors.danger : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
