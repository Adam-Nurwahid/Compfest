import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Dummy data item di dalam keranjang (Mengikuti Single-Store Rule: TechNexus Store)
  final String _currentStoreName = 'TechNexus Store';

  final List<Map<String, dynamic>> _cartItems = [
    {
      'id': '1',
      'name': 'Mechanical Keyboard Layout 75%',
      'price': 850000.00,
      'quantity': 1,
      'stock': 25,
    },
    {
      'id': '2',
      'name': 'Deskmat Minimalist Topography',
      'price': 180000.00,
      'quantity': 2,
      'stock': 50,
    },
  ];

  // Perhitungan Keuangan Domestik (Kalkulasi Lokal)
  double get _subtotal {
    return _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  double get _ppn => _subtotal * 0.12; // Aturan PPN 12% Seapedia [cite: 56, 253, 263, 294]
  double get _deliveryFee => _cartItems.isEmpty ? 0.00 : 15000.00; // Estimasi reguler awal
  double get _total => _subtotal + _ppn + _deliveryFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Keranjang Belanja',
          style: AppTextStyles.headlineMedium.copyWith(fontSize: 20),
        ),
      ),
      body: _cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
        children: [
          // 1. Banner Aturan Single-Store Checkout [cite: 75, 244]
          _buildSingleStoreBanner(),

          // 2. Daftar Item Komposisi (List View)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return _buildCartItemCard(item, index);
              },
            ),
          ),

          // 3. Ringkasan Pembayaran & Tombol Checkout (Footer)
          _buildCartFooter(),
        ],
      ),
    );
  }

  // Widget Banner Aturan Single-Store [cite: 75, 244]
  Widget _buildSingleStoreBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.tertiary.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Pesanan dari: $_currentStoreName',
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Aturan Single-Store: Kamu hanya bisa checkout dari satu toko yang sama sekaligus.',
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.primaryDark),
          ),
        ],
      ),
    );
  }

  // Widget Komposisi Kartu Item Produk
  Widget _buildCartItemCard(Map<String, dynamic> item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Gambar mini produk
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.tertiary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.waves, color: AppColors.primary),
            ),
            const SizedBox(width: 16),

            // Informasi detail teks
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: AppTextStyles.label.copyWith(fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rp ${item['price'].toStringAsFixed(0)}',
                    style: AppTextStyles.label.copyWith(color: AppColors.secondary, fontSize: 15),
                  ),
                  const SizedBox(height: 8),

                  // Baris Kontrol Kuantitas (Quantity Counter)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildQuantityButton(
                            icon: Icons.remove,
                            onPressed: item['quantity'] > 1
                                ? () => setState(() => item['quantity']--)
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              '${item['quantity']}',
                              style: AppTextStyles.label.copyWith(fontSize: 16),
                            ),
                          ),
                          _buildQuantityButton(
                            icon: Icons.add,
                            onPressed: item['quantity'] < item['stock']
                                ? () => setState(() => item['quantity']++)
                                : null,
                          ),
                        ],
                      ),

                      // Tombol Hapus Barang
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 22),
                        onPressed: () {
                          setState(() {
                            _cartItems.removeAt(index);
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, VoidCallback? onPressed}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: onPressed == null ? Colors.grey.shade200 : AppColors.tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16, color: onPressed == null ? Colors.grey : AppColors.primary),
        onPressed: onPressed,
      ),
    );
  }

  // Widget Footer Ringkasan Pembayaran [cite: 56, 253, 294]
  Widget _buildCartFooter() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow('Subtotal', 'Rp ${_subtotal.toStringAsFixed(0)}'),
          _buildSummaryRow('PPN (12%)', 'Rp ${_ppn.toStringAsFixed(0)}'), // Perhitungan PPN 12% [cite: 56, 253, 263, 294]
          _buildSummaryRow('Estimasi Ongkir', 'Rp ${_deliveryFee.toStringAsFixed(0)}'),
          const Divider(height: 24),
          _buildSummaryRow(
            'Total Pembayaran',
            'Rp ${_total.toStringAsFixed(0)}',
            isTotal: true,
          ),
          const SizedBox(height: 16),

          // Tombol Proses Checkout
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: AppButtonStyles.primary.copyWith(
                backgroundColor: WidgetStateProperty.all(AppColors.secondary),
              ),
              onPressed: () {
                // Integrasi aksi checkout level berikutnya
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lanjut ke Checkout',
                    style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTextStyles.label.copyWith(fontSize: 16)
                : AppTextStyles.bodyMedium,
          ),
          Text(
            value,
            style: isTotal
                ? AppTextStyles.headlineMedium.copyWith(color: AppColors.primary, fontSize: 18)
                : AppTextStyles.label.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Tampilan ketika keranjang kosong
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart, size: 80, color: AppColors.neutral.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Keranjangmu Kosong', style: AppTextStyles.headlineMedium.copyWith(fontSize: 20)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Yuk, jelajahi katalog dan temukan kebutuhan maritimmu!',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Mulai Belanja'),
          ),
        ],
      ),
    );
  }
}