import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';
import '../../../../data/dummy/dummy_data.dart';
import '../../../../data/models/models.dart';
import 'seller_widgets.dart';

class SellerProductListPage extends StatefulWidget {
  const SellerProductListPage({super.key});

  @override
  State<SellerProductListPage> createState() => _SellerProductListPageState();
}

class _SellerProductListPageState extends State<SellerProductListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  final List<String> _categories = ['Semua', 'Diving', 'Sailing', 'Fishing'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _getFilteredProducts(String storeId) {
    return dummyProducts.where((product) {
      // Must be seller's product
      if (product.storeId != storeId) return false;

      // Category filter
      final matchesCategory = _selectedCategory == 'Semua' || product.category.toLowerCase() == _selectedCategory.toLowerCase();

      // Search filter
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _confirmDelete(BuildContext context, AppState appState, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Hapus Produk'),
          content: Text('Apakah Anda yakin ingin menghapus "${product.name}"? Tindakan ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                appState.deleteProduct(product.id);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Produk berhasil dihapus!'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final myStore = appState.currentUserStore;

    // Guard: if no store, prompt to create one
    if (myStore == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const SellerAppBar(title: 'Daftar Produk'),
        body: EmptyState(
          title: 'Belum Memiliki Toko',
          message: 'Buat toko Anda terlebih dahulu untuk bisa menambahkan produk.',
          icon: Icons.storefront_outlined,
          buttonText: 'Buat Toko Sekarang',
          onButtonPressed: () {
            context.push('/seller/store');
          },
        ),
      );
    }

    final filteredList = _getFilteredProducts(myStore.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SellerAppBar(
        title: 'Daftar Produk',
        store: myStore,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Tambah Produk',
            onPressed: () => context.push('/seller/product/add'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar & Filter Headers
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Cari produk Anda...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.neutral),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Categories Chip list
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: AppTextStyles.label.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: 1.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Info Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menampilkan ${filteredList.length} produk',
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/seller/product/add'),
                    child: Text(
                      '+ Tambah Produk',
                      style: AppTextStyles.label.copyWith(color: AppColors.primary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            // Product List Builder
            Expanded(
              child: filteredList.isEmpty
                  ? EmptyState(
                      title: 'Produk Tidak Ditemukan',
                      message: _searchQuery.isNotEmpty
                          ? 'Tidak ada produk yang cocok dengan pencarian "$_searchQuery".'
                          : 'Toko Anda belum memiliki produk di kategori ini.',
                      icon: Icons.inventory_2_outlined,
                      buttonText: _searchQuery.isNotEmpty ? 'Reset Pencarian' : 'Tambah Produk Pertama',
                      onButtonPressed: () {
                        if (_searchQuery.isNotEmpty) {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                            _selectedCategory = 'Semua';
                          });
                        } else {
                          context.push('/seller/product/add');
                        }
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final product = filteredList[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ProductManageCard(
                            product: product,
                            onEdit: () {
                              context.push('/seller/product/edit/${product.id}');
                            },
                            onDelete: () => _confirmDelete(context, appState, product),
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
