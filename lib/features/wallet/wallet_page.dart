import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/reusable_widgets.dart';
import '../../data/dummy/app_state.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _showTopUpDialog(BuildContext context, AppState appState) {
    _amountController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Up Saldo Wallet',
                    style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Masukkan jumlah nominal saldo yang ingin Anda tambahkan ke akun SEA-Wallet Anda.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 20),

              // Suggestion quick amounts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [50000, 100000, 500000].map((quickAmount) {
                  return InkWell(
                    onTap: () {
                      _amountController.text = quickAmount.toString();
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.tertiary.withOpacity(0.3),
                      ),
                      child: Text(
                        'Rp${quickAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                        style: AppTextStyles.label.copyWith(color: AppColors.primary, fontSize: 13),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              AppTextField(
                label: 'Nominal Top Up (Rp)',
                hintText: 'contoh: 250000',
                controller: _amountController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.attach_money_rounded, color: AppColors.neutral),
              ),
              const SizedBox(height: 28),

              AppButton(
                text: 'Konfirmasi Top Up',
                onPressed: () {
                  final int? amount = int.tryParse(_amountController.text.trim());
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Masukkan jumlah nominal angka yang valid!'),
                        backgroundColor: AppColors.danger,
                      ),
                    );
                    return;
                  }

                  appState.topUp(amount);
                  Navigator.pop(context); // Close bottomsheet

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Top Up saldo Rp${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} berhasil!',
                      ),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final formattedBalance = appState.walletBalance
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'SEA-Wallet',
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Balance Card Section
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
              child: AppCard(
                color: AppColors.primary,
                radius: 20,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL SALDO AKTIF',
                      style: AppTextStyles.label.copyWith(color: Colors.white.withOpacity(0.7), fontSize: 11),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp$formattedBalance',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            onPressed: () => _showTopUpDialog(context, appState),
                            icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                            label: Text(
                              'Isi Saldo (Top Up)',
                              style: AppTextStyles.label.copyWith(color: AppColors.primary, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Transactions Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Riwayat Transaksi',
                  style: AppTextStyles.label.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Transactions List
            Expanded(
              child: appState.walletTransactions.isEmpty
                  ? const EmptyState(
                      title: 'Belum Ada Transaksi',
                      message: 'Semua riwayat top-up dan pembayaran akan dicatat di sini.',
                      icon: Icons.receipt_long_outlined,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      itemCount: appState.walletTransactions.length,
                      itemBuilder: (context, index) {
                        final tx = appState.walletTransactions[index];
                        final isTopUp = tx.type == 'topup';
                        final amountText = (isTopUp ? '+' : '-') +
                            'Rp${tx.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: AppCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Type icon container
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isTopUp
                                        ? const Color(0xFFD4EDDA)
                                        : const Color(0xFFF8D7DA),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isTopUp ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                    color: isTopUp ? const Color(0xFF155724) : const Color(0xFF721C24),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Title and date
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.title,
                                        style: AppTextStyles.label.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${tx.timestamp.day}/${tx.timestamp.month}/${tx.timestamp.year}  ${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}',
                                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                // Amount
                                Text(
                                  amountText,
                                  style: AppTextStyles.label.copyWith(
                                    fontSize: 15,
                                    color: isTopUp ? const Color(0xFF155724) : const Color(0xFF721C24),
                                    fontWeight: FontWeight.bold,
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
    );
  }
}
