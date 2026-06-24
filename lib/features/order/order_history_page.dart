import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/reusable_widgets.dart';
import '../../data/dummy/app_state.dart';
import '../../data/models/models.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  String _selectedStatusFilter = 'Semua';
  final List<String> _statusFilters = [
    'Semua',
    'Sedang Dikemas',
    'Menunggu Pengirim',
    'Sedang Dikirim',
    'Pesanan Selesai',
    'Dikembalikan',
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // Filter orders
    final filteredOrders = appState.orders.where((order) {
      if (_selectedStatusFilter == 'Semua') return true;
      return order.status == _selectedStatusFilter;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Pesanan Saya',
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Horizontal Scroll List
            Container(
              color: AppColors.surface,
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _statusFilters.length,
                itemBuilder: (context, index) {
                  final status = _statusFilters[index];
                  final isSelected = _selectedStatusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatusFilter = status;
                        });
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: AppTextStyles.label.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: 1.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Orders list
            Expanded(
              child: filteredOrders.isEmpty
                  ? EmptyState(
                      title: 'Pesanan Tidak Ditemukan',
                      message: 'Anda tidak memiliki riwayat pesanan dengan status "$_selectedStatusFilter".',
                      icon: Icons.receipt_long_outlined,
                      buttonText: 'Reset Filter',
                      onButtonPressed: () {
                        setState(() {
                          _selectedStatusFilter = 'Semua';
                        });
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        final formattedTotal = order.finalTotal
                            .toString()
                            .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

                        // Quantity sum
                        final totalQty = order.items.fold(0, (sum, item) => sum + item.quantity);

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: AppCard(
                            padding: const EdgeInsets.all(16),
                            onTap: () {
                              context.push('/order/${order.id}');
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Order ID, Store Name & Status Badge Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.id,
                                            style: AppTextStyles.label.copyWith(fontSize: 11, color: AppColors.neutral),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              const Icon(Icons.storefront, size: 14, color: AppColors.primary),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  order.storeName,
                                                  style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    StatusBadge(status: order.status),
                                  ],
                                ),
                                const Divider(height: 20),

                                // First item snapshot
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: 52,
                                        height: 52,
                                        color: AppColors.tertiary.withOpacity(0.3),
                                        child: Image.network(
                                          order.items.first.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.items.first.productName,
                                            style: AppTextStyles.label.copyWith(fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$totalQty barang  •  Rp${order.items.first.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (order.items.length > 1) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '+ ${order.items.length - 1} produk lainnya',
                                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 11, fontStyle: FontStyle.italic),
                                  ),
                                ],
                                const Divider(height: 20),

                                // Final Total Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Transaksi',
                                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      'Rp$formattedTotal',
                                      style: AppTextStyles.label.copyWith(fontSize: 15, color: AppColors.secondary, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
