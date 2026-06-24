import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';
import '../../../../data/dummy/dummy_data.dart';
import '../../../../data/models/models.dart';

class AdminDeliveriesPage extends StatefulWidget {
  const AdminDeliveriesPage({super.key});

  @override
  State<AdminDeliveriesPage> createState() => _AdminDeliveriesPageState();
}

class _AdminDeliveriesPageState extends State<AdminDeliveriesPage> {
  String _searchQuery = '';
  String _statusFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final orders = appState.orders;

    // Filter orders representing delivery jobs
    final filteredDeliveries = orders.where((order) {
      final driver = dummyUsers.firstWhere(
        (u) => u.id == order.assignedDriverId,
        orElse: () => User(id: '', name: 'Belum Ditugaskan', email: '', username: '', password: '', roles: [], activeRole: ''),
      );

      final matchesSearch = order.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          driver.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.pickupAddress.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.dropoffAddress.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesStatus = true;
      if (_statusFilter == 'Menunggu Pengirim') {
        matchesStatus = order.status == 'Menunggu Pengirim';
      } else if (_statusFilter == 'Sedang Dikirim') {
        matchesStatus = order.status == 'Sedang Dikirim';
      } else if (_statusFilter == 'Selesai') {
        matchesStatus = order.status == 'Pesanan Selesai';
      }

      return matchesSearch && matchesStatus;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter & Search Controls
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
                      hintText: 'Cari berdasarkan Order ID, nama kurir, alamat asal/tujuan...',
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

                // Status Filter Dropdown
                Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border, width: 1.2),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _statusFilter,
                      icon: const Icon(Icons.filter_list, color: AppColors.primary),
                      style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.textPrimary),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _statusFilter = val;
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: 'Semua', child: Text('Semua Status Pengiriman')),
                        DropdownMenuItem(value: 'Menunggu Pengirim', child: Text('Menunggu Pengirim')),
                        DropdownMenuItem(value: 'Sedang Dikirim', child: Text('Sedang Dikirim')),
                        DropdownMenuItem(value: 'Selesai', child: Text('Selesai (Tiba)')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Deliveries Table Card
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
                          Expanded(flex: 2, child: Text('Driver / Kurir', style: AppTextStyles.label)),
                          Expanded(flex: 3, child: Text('Alamat Asal (Pickup)', style: AppTextStyles.label)),
                          Expanded(flex: 3, child: Text('Alamat Tujuan (Dropoff)', style: AppTextStyles.label)),
                          Expanded(flex: 2, child: Text('Ongkos Kirim', style: AppTextStyles.label)),
                          Expanded(flex: 2, child: Text('Status Kirim', style: AppTextStyles.label)),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Body
                    Expanded(
                      child: filteredDeliveries.isEmpty
                          ? const Center(
                              child: EmptyState(
                                title: 'Pekerjaan Pengiriman Tidak Ditemukan',
                                message: 'Tidak ada status pengiriman logistik yang cocok dengan pencarian Anda.',
                                icon: Icons.local_shipping_outlined,
                              ),
                            )
                          : ListView.separated(
                              itemCount: filteredDeliveries.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final order = filteredDeliveries[index];
                                
                                // Find driver name
                                final driver = dummyUsers.firstWhere(
                                  (u) => u.id == order.assignedDriverId,
                                  orElse: () => User(id: '', name: 'Belum ditugaskan', email: '', username: '', password: '', roles: [], activeRole: ''),
                                );

                                final isAssigned = order.assignedDriverId != null;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  child: Row(
                                    children: [
                                      // Order ID
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          order.id,
                                          style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.primary),
                                        ),
                                      ),

                                      // Driver
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              driver.name,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: isAssigned ? AppColors.textPrimary : AppColors.neutral.withOpacity(0.7),
                                              ),
                                            ),
                                            if (isAssigned)
                                              Text(
                                                'ID: ${driver.id}',
                                                style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                                              ),
                                          ],
                                        ),
                                      ),

                                      // Origin Address
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.store, size: 16, color: AppColors.primary),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                order.pickupAddress,
                                                style: const TextStyle(fontSize: 12),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Destination Address
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.location_on, size: 16, color: AppColors.secondaryDark),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                order.dropoffAddress,
                                                style: const TextStyle(fontSize: 12),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Shipping fee
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Rp${order.deliveryFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'Layanan: ${order.deliveryMethod}',
                                              style: TextStyle(fontSize: 11, color: AppColors.neutral.withOpacity(0.8)),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Shipping Status
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          children: [
                                            StatusBadge(status: order.status),
                                          ],
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
}
