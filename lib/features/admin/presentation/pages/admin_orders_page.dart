import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';
import '../../../../data/dummy/dummy_data.dart';
import '../../../../data/models/models.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  String _searchQuery = '';
  String _selectedStatusFilter = 'Semua';
  Order? _selectedOrder;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final orders = appState.orders;

    // Filter orders based on query and status
    final filteredOrders = orders.where((order) {
      final matchesSearch = order.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.storeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.address.receiverName.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _selectedStatusFilter == 'Semua' || order.status == _selectedStatusFilter;

      return matchesSearch && matchesStatus;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left side: Master list (Orders Table)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter controls
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Search
                      Expanded(
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari berdasarkan Order ID, Toko, atau Pembeli...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            fillColor: AppColors.background,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Status filter dropdown
                      Container(
                        width: 180,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border, width: 1.2),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStatusFilter,
                            icon: const Icon(Icons.filter_list, color: AppColors.primary),
                            style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.textPrimary),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedStatusFilter = val;
                                });
                              }
                            },
                            items: const [
                              DropdownMenuItem(value: 'Semua', child: Text('Semua Status')),
                              DropdownMenuItem(value: 'Sedang Dikemas', child: Text('Sedang Dikemas')),
                              DropdownMenuItem(value: 'Menunggu Pengirim', child: Text('Menunggu Pengirim')),
                              DropdownMenuItem(value: 'Sedang Dikirim', child: Text('Sedang Dikirim')),
                              DropdownMenuItem(value: 'Pesanan Selesai', child: Text('Pesanan Selesai')),
                              DropdownMenuItem(value: 'Dikembalikan', child: Text('Dikembalikan')),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Table Card
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Container(
                            color: AppColors.tertiary.withOpacity(0.4),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: Text('Order ID', style: AppTextStyles.label)),
                                Expanded(flex: 2, child: Text('Pembeli', style: AppTextStyles.label)),
                                Expanded(flex: 2, child: Text('Asal Toko', style: AppTextStyles.label)),
                                Expanded(flex: 1, child: Text('Metode', style: AppTextStyles.label)),
                                Expanded(flex: 2, child: Text('Total Pembayaran', style: AppTextStyles.label)),
                                Expanded(flex: 2, child: Text('Status', style: AppTextStyles.label)),
                              ],
                            ),
                          ),
                          const Divider(height: 1),

                          // List body
                          Expanded(
                            child: filteredOrders.isEmpty
                                ? const Center(
                                    child: EmptyState(
                                      title: 'Pesanan Tidak Ditemukan',
                                      message: 'Tidak ada pesanan transaksi yang cocok dengan pencarian Anda.',
                                      icon: Icons.receipt_long_outlined,
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: filteredOrders.length,
                                    separatorBuilder: (context, index) => const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final order = filteredOrders[index];
                                      final isSelected = _selectedOrder?.id == order.id;

                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedOrder = order;
                                          });
                                        },
                                        child: Container(
                                          color: isSelected ? AppColors.tertiary.withOpacity(0.3) : Colors.transparent,
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

                                              // Buyer
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(order.address.receiverName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                                    Text(order.address.phoneNumber, style: AppTextStyles.bodyMedium.copyWith(fontSize: 11)),
                                                  ],
                                                ),
                                              ),

                                              // Store
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  order.storeName,
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),

                                              // Method
                                              Expanded(
                                                flex: 1,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.secondary.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    order.deliveryMethod,
                                                    style: const TextStyle(fontSize: 11, color: AppColors.secondaryDark, fontWeight: FontWeight.bold),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),

                                              // Final Total
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  'Rp${order.finalTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                                ),
                                              ),

                                              // Status badge
                                              Expanded(
                                                flex: 2,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    StatusBadge(status: order.status),
                                                    const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.neutral),
                                                  ],
                                                ),
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
                  ),
                ),
              ],
            ),
          ),

          // Right side: Order Detail Pane (only if _selectedOrder is not null)
          if (_selectedOrder != null) ...[
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: _buildOrderDetailPanel(appState),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildOrderDetailPanel(AppState appState) {
    final order = _selectedOrder!;
    final driver = dummyUsers.firstWhere(
      (u) => u.id == order.assignedDriverId,
      orElse: () => User(id: '', name: 'Belum ditugaskan', email: '', username: '', password: '', roles: [], activeRole: ''),
    );

    return AppCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Transaksi',
                      style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      order.id,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedOrder = null;
                    });
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Scrollable Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Info Ringkas
                _buildSectionTitle('Informasi Pesanan'),
                _buildInfoRow('Status:', StatusBadge(status: order.status)),
                _buildInfoRow('Toko Asal:', Text(order.storeName, style: const TextStyle(fontWeight: FontWeight.bold))),
                _buildInfoRow('Pembeli:', Text(order.address.receiverName)),
                _buildInfoRow('Metode Kirim:', Text(order.deliveryMethod)),
                _buildInfoRow('Kurir Laut:', Text(driver.name, style: TextStyle(color: order.assignedDriverId == null ? AppColors.neutral : AppColors.primary, fontWeight: FontWeight.bold))),
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Alamat Pengiriman
                _buildSectionTitle('Alamat & Lokasi'),
                Text('Titik Jemput (Pickup):', style: AppTextStyles.label.copyWith(fontSize: 12, color: AppColors.neutral)),
                Text(order.pickupAddress, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Text('Titik Bongkar (Dropoff):', style: AppTextStyles.label.copyWith(fontSize: 12, color: AppColors.neutral)),
                Text(order.dropoffAddress, style: const TextStyle(fontSize: 12)),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Items list
                _buildSectionTitle('Item Produk'),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.items.length,
                  itemBuilder: (context, idx) {
                    final item = order.items[idx];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              item.imageUrl,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(width: 36, height: 36, color: AppColors.tertiary),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text('${item.quantity} x Rp${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}', style: TextStyle(fontSize: 11, color: AppColors.neutral.withOpacity(0.8))),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Rincian Biaya
                _buildSectionTitle('Rincian Pembayaran'),
                _buildCostRow('Biaya Pengiriman (SLA):', order.deliveryFee),
                if (order.voucherCode != null)
                  _buildCostRow('Diskon Voucher (${order.voucherCode}):', -order.discountAmount, isNegative: true),
                _buildCostRow('PPN (12%):', order.ppnAmount),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Akhir:', style: AppTextStyles.label.copyWith(fontSize: 14)),
                    Text(
                      'Rp${order.finalTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      style: AppTextStyles.label.copyWith(fontSize: 15, color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Timeline
                OrderStatusTimeline(
                  milestones: order.statusTimeline,
                  currentStatus: order.status,
                ),
              ],
            ),
          ),
          
          // Action button to advance status for demo/testing purposes
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: AppButton(
              text: 'Simulasikan Status Berikutnya',
              onPressed: () {
                appState.advanceOrderStatus(order.id);
                // Refresh local state pointer
                setState(() {
                  _selectedOrder = appState.orders.firstWhere((o) => o.id == order.id);
                });
              },
              styleType: ButtonStyleType.secondary,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: AppTextStyles.label.copyWith(fontSize: 14, color: AppColors.primary),
      ),
    );
  }

  Widget _buildInfoRow(String label, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.neutral.withOpacity(0.9))),
          content,
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, int amount, {bool isNegative = false}) {
    final prefix = isNegative ? '-' : '';
    final absAmount = amount.abs();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.neutral.withOpacity(0.8))),
          Text(
            '${prefix}Rp${absAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
            style: TextStyle(fontSize: 12, color: isNegative ? AppColors.danger : AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
