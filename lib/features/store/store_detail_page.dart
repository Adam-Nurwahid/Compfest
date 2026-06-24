import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/reusable_widgets.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/models.dart';

class StoreDetailPage extends StatelessWidget {
  final String storeId;

  const StoreDetailPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    // Find the store
    final store = dummyStores.firstWhere(
      (s) => s.id == storeId,
      orElse: () => dummyStores.first,
    );

    // Find products from this store
    final storeProducts = dummyProducts.where((p) => p.storeId == storeId).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: store.name,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Store Banner & Profile Header
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.tertiary,
                        backgroundImage: NetworkImage(store.logoUrl),
                        child: const Icon(Icons.storefront, size: 28, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: AppTextStyles.headlineMedium.copyWith(fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.neutral),
                                const SizedBox(width: 4),
                                Text(
                                  store.location,
                                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  store.rating.toString(),
                                  style: AppTextStyles.label.copyWith(fontSize: 13),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(Penjual Terpercaya)',
                                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tentang Toko',
                    style: AppTextStyles.label.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    store.description,
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Products list header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Semua Produk dari Toko Ini',
                  style: AppTextStyles.label.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Product Grid
            Expanded(
              child: storeProducts.isEmpty
                  ? const EmptyState(
                      title: 'Tidak Ada Produk',
                      message: 'Toko ini belum menambahkan produk saat ini.',
                      icon: Icons.store_mall_directory_outlined,
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: storeProducts.length,
                      itemBuilder: (context, index) {
                        final product = storeProducts[index];
                        return _buildProductCard(context, product);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () {
        context.push('/product/${product.id}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withOpacity(0.3),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.broken_image_outlined, size: 40, color: AppColors.primary),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toString(),
                        style: AppTextStyles.label.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Info details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.label.copyWith(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rp${product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                        style: AppTextStyles.label.copyWith(color: AppColors.secondary, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.stock > 0 ? 'Stok: ${product.stock}' : 'Stok Habis',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 11,
                          color: product.stock > 0 ? AppColors.neutral : AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
