import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';
import '../../../../data/models/models.dart';
import 'seller_widgets.dart';

class SellerIncomingOrdersPage extends StatelessWidget {
  const SellerIncomingOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final myStore = appState.currentUserStore;

    // Guard: if no store, prompt to create one
    if (myStore == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const SellerAppBar(title: 'Pesanan Masuk'),
        body: EmptyState(
          title: 'Belum Memiliki Toko',
          message: 'Buat toko Anda terlebih dahulu untuk menerima pesanan dari pembeli.',
          icon: Icons.storefront_outlined,
          buttonText: 'Buat Toko Sekarang',
          onButtonPressed: () {
            context.push('/seller/store');
          },
        ),
      );
    }

    // Filter orders matching seller's store_id
    final myOrders = appState.orders.where((o) => o.storeId == myStore.id).toList();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          title: Row(
            children: [
              Text(
                'Pesanan Masuk',
                style: AppTextStyles.headlineMedium.copyWith(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Seller Mode',
                  style: AppTextStyles.label.copyWith(fontSize: 9, color: Colors.white),
                ),
              ),
            ],
          ),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppColors.secondaryLight,
            unselectedLabelColor: Colors.white60,
            indicatorColor: AppColors.secondary,
            tabs: [
              Tab(text: 'Semua'),
              Tab(text: 'Perlu Diproses'),
              Tab(text: 'Sedang Diproses'),
              Tab(text: 'Selesai & Lainnya'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderTabList(context, appState, myOrders, 'all'),
            _buildOrderTabList(context, appState, myOrders, 'pending'),
            _buildOrderTabList(context, appState, myOrders, 'processing'),
            _buildOrderTabList(context, appState, myOrders, 'completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTabList(
    BuildContext context,
    AppState appState,
    List<Order> orders,
    String filterType,
  ) {
    List<Order> filteredList = [];

    if (filterType == 'all') {
      filteredList = orders;
    } else if (filterType == 'pending') {
      filteredList = orders.where((o) => o.status == 'Sedang Dikemas').toList();
    } else if (filterType == 'processing') {
      filteredList = orders.where((o) => o.status == 'Menunggu Pengirim' || o.status == 'Sedang Dikirim').toList();
    } else if (filterType == 'completed') {
      filteredList = orders.where((o) => o.status == 'Pesanan Selesai' || o.status == 'Dikembalikan').toList();
    }

    if (filteredList.isEmpty) {
      String title = 'Tidak Ada Pesanan';
      String message = 'Toko Anda belum menerima pesanan di kategori ini.';
      IconData icon = Icons.receipt_long_outlined;

      if (filterType == 'pending') {
        title = 'Tidak Ada Pesanan Baru';
        message = 'Hebat! Semua pesanan baru masuk telah selesai Anda proses.';
        icon = Icons.done_all_rounded;
      }

      return EmptyState(
        title: title,
        message: message,
        icon: icon,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final order = filteredList[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: OrderProcessCard(
            order: order,
            onTap: () {
              context.push('/seller/order/${order.id}');
            },
            onProcess: () async {
              await appState.processOrder(order.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(duration: const Duration(seconds: 2), 
                  content: Text('Pesanan ${order.id} berhasil diproses!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
