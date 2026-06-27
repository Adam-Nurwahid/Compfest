import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/dummy_data.dart';
import '../../../../data/models/models.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  String _searchQuery = '';
  String _selectedStoreFilter = 'Semua';
  String _selectedCategoryFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    // Filter products based on query, store, and category
    final filteredProducts = dummyProducts.where((product) {
      final store = dummyStores.firstWhere(
        (s) => s.id == product.storeId,
        orElse: () => Store(id: '', sellerId: '', name: 'Toko Tidak Dikenal', location: '', logoUrl: '', rating: 0, description: ''),
      );

      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          store.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStore = _selectedStoreFilter == 'Semua' || product.storeId == _selectedStoreFilter;
      final matchesCategory = _selectedCategoryFilter == 'Semua' || product.category == _selectedCategoryFilter;

      return matchesSearch && matchesStore && matchesCategory;
    }).toList();

    // Get unique categories from all products
    final categories = {'Semua', ...dummyProducts.map((p) => p.category)};

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter controls
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Search Field
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan nama produk, kategori, atau toko...',
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

                // Store Filter Dropdown
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
                      value: _selectedStoreFilter,
                      icon: const Icon(Icons.store, color: AppColors.primary),
                      style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.textPrimary),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedStoreFilter = val;
                          });
                        }
                      },
                      items: [
                        const DropdownMenuItem(value: 'Semua', child: Text('Semua Toko')),
                        ...dummyStores.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Category Filter Dropdown
                Container(
                  width: 160,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border, width: 1.2),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategoryFilter,
                      icon: const Icon(Icons.category, color: AppColors.primary),
                      style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.textPrimary),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCategoryFilter = val;
                          });
                        }
                      },
                      items: categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat == 'Semua' ? 'Semua Kategori' : cat));
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Products Table Card
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
                          Expanded(flex: 3, child: Text('Nama Produk', style: AppTextStyles.label)),
                          Expanded(flex: 2, child: Text('Asal Toko', style: AppTextStyles.label)),
                          Expanded(flex: 1, child: Text('Kategori', style: AppTextStyles.label)),
                          Expanded(flex: 2, child: Text('Harga (IDR)', style: AppTextStyles.label)),
                          Expanded(flex: 1, child: Text('Stok', style: AppTextStyles.label)),
                          Expanded(flex: 1, child: Text('Rating', style: AppTextStyles.label)),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Body List
                    Expanded(
                      child: filteredProducts.isEmpty
                          ? const Center(
                              child: EmptyState(
                                title: 'Produk Tidak Ditemukan',
                                message: 'Tidak ada produk laut yang cocok dengan kriteria pencarian dan filter Anda.',
                                icon: Icons.inventory_2_outlined,
                              ),
                            )
                          : ListView.separated(
                              itemCount: filteredProducts.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];

                                // Find store
                                final store = dummyStores.firstWhere(
                                  (s) => s.id == product.storeId,
                                  orElse: () => Store(id: '', sellerId: '', name: 'Toko Tidak Dikenal', location: '', logoUrl: '', rating: 0, description: ''),
                                );

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  child: Row(
                                    children: [
                                      // Product Name + Thumbnail Image
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.network(
                                                product.imageUrl,
                                                width: 44,
                                                height: 44,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  width: 44,
                                                  height: 44,
                                                  color: AppColors.tertiary,
                                                  child: const Icon(Icons.image, color: AppColors.primary),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product.name,
                                                    style: AppTextStyles.label.copyWith(fontSize: 14),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'ID: ${product.id}',
                                                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 11, color: AppColors.neutral.withOpacity(0.7)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Store
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          store.name,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      // Category
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            product.category,
                                            style: AppTextStyles.label.copyWith(fontSize: 11, color: AppColors.primary),
                                          ),
                                        ),
                                      ),

                                      // Price
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Rp${product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                      ),

                                      // Stock (Stok)
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '${product.stock} Unit',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: product.stock <= 5 ? AppColors.danger : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),

                                      // Rating
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                                            const SizedBox(width: 4),
                                            Text(
                                              product.rating.toString(),
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '(${product.reviewCount})',
                                              style: TextStyle(fontSize: 11, color: AppColors.neutral.withOpacity(0.6)),
                                            ),
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
