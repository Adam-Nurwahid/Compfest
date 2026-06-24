import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';
import '../../../../data/models/models.dart';
import 'seller_widgets.dart';

class SellerIncomeReportPage extends StatefulWidget {
  const SellerIncomeReportPage({super.key});

  @override
  State<SellerIncomeReportPage> createState() => _SellerIncomeReportPageState();
}

class _SellerIncomeReportPageState extends State<SellerIncomeReportPage> {
  String _selectedStatusFilter = 'Semua';
  final List<String> _statusFilters = ['Semua', 'Selesai', 'Dikemas/Diproses', 'Dikembalikan'];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final myStore = appState.currentUserStore;

    // Guard: if no store, prompt to create one
    if (myStore == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const SellerAppBar(title: 'Laporan Pendapatan'),
        body: EmptyState(
          title: 'Belum Memiliki Toko',
          message: 'Buat toko Anda terlebih dahulu untuk melihat laporan pendapatan.',
          icon: Icons.storefront_outlined,
          buttonText: 'Buat Toko Sekarang',
          onButtonPressed: () {
            context.push('/seller/store');
          },
        ),
      );
    }

    // Filter orders for this store
    final myOrders = appState.orders.where((o) => o.storeId == myStore.id).toList();

    // 1. Calculate active revenue (exclude "Dikembalikan" / refunded)
    final activeOrders = myOrders.where((o) => o.status != 'Dikembalikan').toList();
    final completedOrders = activeOrders.where((o) => o.status == 'Pesanan Selesai').toList();

    final totalIncome = completedOrders.fold<int>(0, (sum, o) => sum + o.finalTotal);
    final pendingIncome = activeOrders.where((o) => o.status != 'Pesanan Selesai').fold<int>(0, (sum, o) => sum + o.finalTotal);

    final formattedIncome = totalIncome
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    final formattedPending = pendingIncome
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    // Chart monthly data (Jan - Jun)
    final List<double> chartValues = [1500000, 2800000, 1900000, 3500000, 4200000, totalIncome.toDouble()];
    final List<String> chartLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'];

    // 2. Filter transaction history
    List<Order> displayTransactions = [];
    if (_selectedStatusFilter == 'Semua') {
      displayTransactions = myOrders;
    } else if (_selectedStatusFilter == 'Selesai') {
      displayTransactions = myOrders.where((o) => o.status == 'Pesanan Selesai').toList();
    } else if (_selectedStatusFilter == 'Dikemas/Diproses') {
      displayTransactions = myOrders.where((o) => o.status == 'Sedang Dikemas' || o.status == 'Menunggu Pengirim' || o.status == 'Sedang Dikirim').toList();
    } else if (_selectedStatusFilter == 'Dikembalikan') {
      displayTransactions = myOrders.where((o) => o.status == 'Dikembalikan').toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SellerAppBar(
        title: 'Laporan Pendapatan',
        store: myStore,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Income Overview Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Pendapatan Bersih',
                                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rp$formattedIncome',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Dari pesanan selesai',
                            style: TextStyle(color: Colors.white60, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.pending_actions_outlined, color: AppColors.secondary, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Pendapatan Tertunda',
                                style: TextStyle(color: AppColors.neutral, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rp$formattedPending',
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Pesanan dikemas/kirim',
                            style: TextStyle(color: AppColors.neutral, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Note about Refund reversal
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.danger.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.danger, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Catatan: Pesanan dengan status "Dikembalikan" (Refund/Reversal) secara otomatis dikecualikan dari perhitungan pendapatan bersih toko.',
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 11, color: AppColors.danger, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Income Chart
              CustomDashboardChart(
                values: chartValues,
                labels: chartLabels,
                title: 'Grafik Pendapatan Bersih (6 Bulan Terakhir)',
              ),
              const SizedBox(height: 24),

              // Transaction History Title & Filters
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat Transaksi',
                    style: AppTextStyles.label.copyWith(fontSize: 16, color: AppColors.textPrimary),
                  ),
                  DropdownButton<String>(
                    value: _selectedStatusFilter,
                    icon: const Icon(Icons.filter_list_alt, size: 16, color: AppColors.primary),
                    underline: const SizedBox(),
                    style: AppTextStyles.label.copyWith(fontSize: 12, color: AppColors.primary),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedStatusFilter = newValue;
                        });
                      }
                    },
                    items: _statusFilters.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Transaction List
              displayTransactions.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          'Tidak ada transaksi di filter ini.',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayTransactions.length,
                      itemBuilder: (context, index) {
                        final tx = displayTransactions[index];
                        final formattedTxTotal = tx.finalTotal
                            .toString()
                            .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

                        final milestone = tx.statusTimeline.isNotEmpty
                            ? tx.statusTimeline.first.timestamp
                            : DateTime.now();
                        final txDate = '${milestone.day}/${milestone.month}/${milestone.year}';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tx.id,
                                  style: AppTextStyles.label.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Rp$formattedTxTotal',
                                  style: AppTextStyles.label.copyWith(
                                    fontSize: 13,
                                    color: tx.status == 'Dikembalikan' ? AppColors.danger : AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$txDate • ${tx.items.length} Item',
                                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: tx.status == 'Pesanan Selesai'
                                          ? AppColors.tertiary.withOpacity(0.5)
                                          : tx.status == 'Dikembalikan'
                                              ? AppColors.danger.withOpacity(0.1)
                                              : AppColors.secondary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      tx.status,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: tx.status == 'Pesanan Selesai'
                                            ? AppColors.primary
                                            : tx.status == 'Dikembalikan'
                                                ? AppColors.danger
                                                : AppColors.secondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right, size: 16, color: AppColors.neutral),
                            onTap: () {
                              context.push('/seller/order/${tx.id}');
                            },
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
