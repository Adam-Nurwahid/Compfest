import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';
import '../../../../data/dummy/dummy_data.dart';
import '../../../../data/models/models.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // Find the product in dummy list
    final product = dummyProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => dummyProducts.first,
    );

    // Find the store
    final store = dummyStores.firstWhere(
      (s) => s.id == product.storeId,
      orElse: () => dummyStores.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Detail Produk',
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textPrimary),
            onPressed: () => context.go('/cart'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Product Image
                    Container(
                      width: double.infinity,
                      height: 280,
                      decoration: const BoxDecoration(
                        color: AppColors.tertiary,
                      ),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.image_outlined, size: 80, color: AppColors.primary),
                          );
                        },
                      ),
                    ),

                    // 2. Info Block
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Price & Stock row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Rp${product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: AppColors.secondary,
                                  fontSize: 24,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: product.stock > 0 ? AppColors.tertiary : AppColors.danger.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  product.stock > 0 ? 'Stok: ${product.stock}' : 'Stok Habis',
                                  style: AppTextStyles.label.copyWith(
                                    fontSize: 12,
                                    color: product.stock > 0 ? AppColors.primary : AppColors.danger,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Product Name
                          Text(
                            product.name,
                            style: AppTextStyles.headlineMedium.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),

                          // Rating and category row
                          Row(
                            children: [
                              RatingStars(rating: product.rating, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                '${product.rating} (${product.reviewCount} ulasan)',
                                style: AppTextStyles.bodyMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              Chip(
                                label: Text(
                                  product.category,
                                  style: AppTextStyles.label.copyWith(fontSize: 11, color: AppColors.primary),
                                ),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ),
                          const Divider(height: 32),

                          // 3. Store Block
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.tertiary,
                                backgroundImage: NetworkImage(store.logoUrl),
                                onBackgroundImageError: (_, __) {},
                                child: const Icon(Icons.storefront, color: AppColors.primary),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      store.name,
                                      style: AppTextStyles.label.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      store.location,
                                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  textStyle: AppTextStyles.label.copyWith(fontSize: 12),
                                ),
                                onPressed: () {
                                  context.push('/store/${store.id}');
                                },
                                child: const Text('Kunjungi Toko'),
                              ),
                            ],
                          ),
                          const Divider(height: 32),

                          // 4. Description Block
                          Text(
                            'Deskripsi Produk',
                            style: AppTextStyles.label.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.description,
                            style: AppTextStyles.bodyMedium.copyWith(
                              height: 1.6,
                              color: AppColors.textPrimary.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Buy Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(top: BorderSide(color: AppColors.border, width: 1.0)),
              ),
              child: Row(
                children: [
                  // Chat button
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fitur chat ke seller dinonaktifkan di demo ini.')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Add to Cart
                  Expanded(
                    child: AppButton(
                      text: 'Tambah ke Keranjang',
                      onPressed: product.stock > 0
                          ? () {
                              _handleAddToCart(context, appState, product, store);
                            }
                          : null, // Disabled if stock is 0
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _handleAddToCart(BuildContext context, AppState appState, Product product, Store store) {
    // 1. Check logged in
    if (!appState.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus masuk sebagai Pembeli terlebih dahulu.'),
          backgroundColor: AppColors.secondary,
        ),
      );
      context.go('/login');
      return;
    }

    // 2. Add to Cart
    final success = appState.addToCart(product);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} berhasil ditambahkan ke keranjang.'),
          backgroundColor: AppColors.primary,
          action: SnackBarAction(
            label: 'Lihat',
            textColor: Colors.white,
            onPressed: () => context.go('/cart'),
          ),
        ),
      );
    } else {
      // Store conflict! Show warning dialog
      final existingStoreName = appState.cartStore?.name ?? 'Toko Lain';
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Ganti Keranjang?'),
            content: Text(
              'Keranjang belanja Anda saat ini berisi produk dari [$existingStoreName].\n\n'
              'Menambahkan produk dari [${store.name}] akan mengosongkan keranjang belanja Anda yang lain. Lanjutkan?',
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal', style: AppTextStyles.label.copyWith(color: AppColors.neutral)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  appState.addToCart(product, forceClear: true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Keranjang dikosongkan dan ditambahkan ${product.name}.'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                child: const Text('Lanjutkan'),
              ),
            ],
          );
        },
      );
    }
  }
}