import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/reusable_widgets.dart';
import '../../data/dummy/app_state.dart';
import '../../data/models/models.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // Shipping Method
  String _selectedDeliveryMethod = 'Regular';
  int _deliveryFee = 5000;

  // Coupon / Voucher
  final _couponController = TextEditingController();
  String? _validatedCouponCode;
  String? _validatedCouponType; // 'Voucher' or 'Promo'
  int _discountAmount = 0;
  String? _couponError;
  String? _couponSuccessMessage;

  // Selected Address (defaults to appState.defaultAddress)
  Address? _customSelectedAddress;

  // Track if order is successfully completed to show success view
  bool _isOrderSuccess = false;
  String _placedOrderId = '';

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _updateDeliveryMethod(String method) {
    setState(() {
      _selectedDeliveryMethod = method;
      if (method == 'Instant') {
        _deliveryFee = 20000;
      } else if (method == 'Next Day') {
        _deliveryFee = 10000;
      } else {
        _deliveryFee = 5000;
      }
    });
  }

  void _applyCoupon(AppState appState, int subtotal) {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _couponError = null;
      _couponSuccessMessage = null;
      _discountAmount = 0;
      _validatedCouponCode = null;
      _validatedCouponType = null;
    });

    // Check Voucher first, then Promo
    final voucherResult = appState.validateVoucher(code, subtotal);
    if (voucherResult['valid']) {
      setState(() {
        _validatedCouponCode = voucherResult['code'];
        _discountAmount = voucherResult['discount'];
        _couponSuccessMessage = '${voucherResult['type']} AKTIF: ${voucherResult['message']}';
        _validatedCouponType = voucherResult['type'];
      });
      return;
    }

    final promoResult = appState.validatePromo(code, subtotal);
    if (promoResult['valid']) {
      setState(() {
        _validatedCouponCode = promoResult['code'];
        _discountAmount = promoResult['discount'];
        _couponSuccessMessage = '${promoResult['type']} AKTIF: ${promoResult['message']}';
        _validatedCouponType = promoResult['type'];
      });
      return;
    }

    // If both failed, show error based on voucherResult
    setState(() {
      _couponError = 'Kode tidak valid, expired, atau kuota habis!';
    });
  }

  void _showAddressSelectDialog(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Alamat Pengiriman',
                style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: appState.addresses.length,
                  itemBuilder: (context, index) {
                    final addr = appState.addresses[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      title: Text(
                        '${addr.receiverName} (${addr.phoneNumber})',
                        style: AppTextStyles.label.copyWith(fontSize: 14),
                      ),
                      subtitle: Text(
                        addr.fullAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        setState(() {
                          _customSelectedAddress = addr;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Kelola Alamat',
                styleType: ButtonStyleType.outlined,
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/addresses');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _processPayment(AppState appState, Address address, int ppn, int total) {
    // Generate order ID for confirmation dialog
    final orderId = 'ORD-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    setState(() {
      _placedOrderId = orderId;
    });

    appState.placeOrder(
      address: address,
      deliveryMethod: _selectedDeliveryMethod,
      deliveryFee: _deliveryFee,
      voucherCode: _validatedCouponCode,
      discountAmount: _discountAmount,
      ppnAmount: ppn,
      finalTotal: total,
    );

    setState(() {
      _isOrderSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // If order was placed successfully, display Success Screen
    if (_isOrderSuccess) {
      return _buildSuccessScreen(context);
    }

    final subtotal = appState.cartSubtotal;
    // Calculate PPN: 12% * (subtotal - discount + deliveryFee)
    final taxableAmount = (subtotal - _discountAmount + _deliveryFee).clamp(0, 999999999);
    final ppnAmount = (taxableAmount * 0.12).round();
    final finalTotal = taxableAmount + ppnAmount;

    // Determine address
    final selectedAddress = _customSelectedAddress ?? appState.defaultAddress;

    // Check wallet balance
    final hasEnoughBalance = appState.walletBalance >= finalTotal;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Checkout Pembayaran',
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
                    // 1. Shipping Address Card
                    Text(
                      'Alamat Pengiriman',
                      style: AppTextStyles.label.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedAddress.receiverName,
                                style: AppTextStyles.label.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              InkWell(
                                onTap: () => _showAddressSelectDialog(context, appState),
                                child: Text(
                                  'Ganti Alamat',
                                  style: AppTextStyles.label.copyWith(color: AppColors.primary, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedAddress.phoneNumber,
                            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            selectedAddress.fullAddress,
                            style: AppTextStyles.bodyMedium.copyWith(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. Product Summary Card
                    Text(
                      'Ringkasan Produk',
                      style: AppTextStyles.label.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.storefront, color: AppColors.primary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                appState.cartStore?.name ?? 'Toko Kelautan',
                                style: AppTextStyles.label.copyWith(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: appState.cartItems.length,
                            itemBuilder: (context, idx) {
                              final item = appState.cartItems[idx];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.product.name} (x${item.quantity})',
                                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 13, color: AppColors.textPrimary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'Rp${(item.product.price * item.quantity).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                      style: AppTextStyles.label.copyWith(fontSize: 13),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. Shipping Options Section
                    Text(
                      'Metode Pengiriman',
                      style: AppTextStyles.label.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildDeliveryChip('Regular', 'Rp5.000'),
                        const SizedBox(width: 8),
                        _buildDeliveryChip('Next Day', 'Rp10.000'),
                        const SizedBox(width: 8),
                        _buildDeliveryChip('Instant', 'Rp20.000'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 4. Voucher/Promo Section
                    Text(
                      'Voucher atau Promo',
                      style: AppTextStyles.label.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _couponController,
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                                  decoration: InputDecoration(
                                    hintText: 'Kode Voucher (SEAVOUCH100, dll)',
                                    hintStyle: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                onPressed: () => _applyCoupon(appState, subtotal),
                                child: Text('Gunakan', style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 13)),
                              ),
                            ],
                          ),
                          if (_couponError != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _couponError!,
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                          if (_couponSuccessMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _couponSuccessMessage!,
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                          const SizedBox(height: 12),
                          // Info Voucher/Promo
                          Text(
                            'Informasi: Voucher (limit kuota & expired), Promo (hanya expired). PPN dihitung dari (Subtotal - Diskon + Ongkir).',
                            style: AppTextStyles.bodyMedium.copyWith(fontSize: 11, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 5. Payment Summary Card
                    Text(
                      'Ringkasan Pembayaran',
                      style: AppTextStyles.label.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildReceiptRow('Subtotal Produk', subtotal),
                          if (_discountAmount > 0)
                            _buildReceiptRow(
                              'Diskon ${_validatedCouponType ?? ""}',
                              -_discountAmount,
                              color: AppColors.primary,
                            ),
                          _buildReceiptRow('Biaya Ongkos Kirim', _deliveryFee),
                          // PPN row showing formulation info
                          _buildReceiptRow(
                            'PPN (VAT) 12%*',
                            ppnAmount,
                            subtitle: '12% × (${subtotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} - ${_discountAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} + ${_deliveryFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')})',
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Pembayaran',
                                style: AppTextStyles.label.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Rp${finalTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                style: AppTextStyles.headlineMedium.copyWith(fontSize: 20, color: AppColors.secondary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 6. SEA-Wallet info & checks
                    AppCard(
                      color: hasEnoughBalance ? AppColors.tertiary.withOpacity(0.2) : AppColors.danger.withOpacity(0.05),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            color: hasEnoughBalance ? AppColors.primary : AppColors.danger,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Saldo SEA-Wallet Anda',
                                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Rp${appState.walletBalance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                  style: AppTextStyles.label.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: hasEnoughBalance ? AppColors.textPrimary : AppColors.danger,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!hasEnoughBalance)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                // Direct action to top up
                                appState.topUp(finalTotal - appState.walletBalance + 50000); // Top up exact lack plus buffer
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Top up otomatis berhasil ditambahkan! Saldo mencukupi.')),
                                );
                              },
                              child: Text('Top Up Cepat', style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 11)),
                            ),
                        ],
                      ),
                    ),
                    if (!hasEnoughBalance) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          '* Saldo tidak cukup untuk melakukan pembayaran ini. Silakan klik Top Up.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom bar holding Checkout Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(top: BorderSide(color: AppColors.border, width: 1.0)),
              ),
              child: AppButton(
                text: 'Bayar Sekarang',
                onPressed: hasEnoughBalance
                    ? () {
                        _processPayment(appState, selectedAddress, ppnAmount, finalTotal);
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryChip(String method, String price) {
    final isSelected = _selectedDeliveryMethod == method;
    return Expanded(
      child: InkWell(
        onTap: () => _updateDeliveryMethod(method),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.tertiary.withOpacity(0.4) : AppColors.surface,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.8 : 1.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                method,
                style: AppTextStyles.label.copyWith(
                  fontSize: 13,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 11,
                  color: isSelected ? AppColors.primary : AppColors.neutral,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String title, int val, {Color? color, String? subtitle}) {
    final isNegative = val < 0;
    final absVal = val.abs();
    final formattedVal = (isNegative ? '- ' : '') +
        'Rp${absVal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
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
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    color: color ?? AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 10, color: AppColors.neutral),
                  ),
                ],
              ],
            ),
          ),
          Text(
            formattedVal,
            style: AppTextStyles.label.copyWith(
              fontSize: 13,
              color: color ?? AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success visual icon
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 80,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Pembayaran Berhasil!',
                style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary, fontSize: 26),
              ),
              const SizedBox(height: 12),
              Text(
                'Terima kasih! Pesanan Anda telah diterima oleh seller dan sedang diproses pengiriman.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 28),

              // Order detail reference
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order ID:', style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
                        Text(_placedOrderId, style: AppTextStyles.label.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Metode Bayar:', style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
                        Text('SEA-Wallet', style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status Awal:', style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.tertiary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Sedang Dikemas',
                            style: AppTextStyles.label.copyWith(fontSize: 11, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Action buttons
              AppButton(
                text: 'Pantau Status Pesanan',
                onPressed: () {
                  // Direct to orders history
                  context.go('/orders');
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Kembali Ke Beranda',
                styleType: ButtonStyleType.outlined,
                onPressed: () {
                  context.go('/landing');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
