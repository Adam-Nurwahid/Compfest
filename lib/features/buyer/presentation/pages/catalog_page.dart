import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';
import '../../../../data/dummy/dummy_data.dart';
import '../../../../data/models/models.dart';
import 'package:compfest/features/seller/data/repositories/seller_repository.dart';

class CatalogPage extends StatefulWidget {
  final String? initialCategory;

  const CatalogPage({super.key, this.initialCategory});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _searchController = TextEditingController();
  late String _selectedCategory;
  final List<String> _categories = ['Semua', 'Diving', 'Sailing', 'Fishing'];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'Semua';
    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = 'Semua';
    }

    // Trigger Supabase product load and sync to AppState
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final sellerRepo = context.read<SellerRepository>();
        final appState = Provider.of<AppState>(context, listen: false);
        final products = await sellerRepo.getAllProducts();
        final stores = await sellerRepo.getAllStores();
        appState.syncAllProductsAndStores(products, stores);
      } catch (e) {
        print('Error loading catalog from Supabase: $e');
      }
    });
  }

  @override
  void didUpdateWidget(covariant CatalogPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory && widget.initialCategory != null) {
      setState(() {
        _selectedCategory = widget.initialCategory!;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _getFilteredProducts() {
    return dummyProducts.where((product) {
      // Category filter
      final matchesCategory = _selectedCategory == 'Semua' || product.category.toLowerCase() == _selectedCategory.toLowerCase();
      // Search filter
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredProducts();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Katalog Gear', style: AppTextStyles.headlineMedium.copyWith(fontSize: 20)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textPrimary),
            onPressed: () => context.go('/cart'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search & Filter header
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
                        hintText: 'Cari alat diving, pancing, joran...',
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

            // Horizontal Categories list
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

            // Results summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Menampilkan ${filteredList.length} produk kelautan',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),

            // Product Grid
            Expanded(
              child: filteredList.isEmpty
                  ? EmptyState(
                      title: 'Produk Tidak Ditemukan',
                      message: 'Maaf, kami tidak dapat menemukan produk "${_searchQuery}" di kategori ini.',
                      icon: Icons.search_off_rounded,
                      buttonText: 'Reset Filter',
                      onButtonPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                          _selectedCategory = 'Semua';
                        });
                      },
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final product = filteredList[index];
                        return _buildProductCardItem(context, product);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCardItem(BuildContext context, Product product) {
    final store = dummyStores.firstWhere((s) => s.id == product.storeId, orElse: () => dummyStores.first);

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () {
        context.push('/product/${product.id}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image block
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
          // Description details block
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: AppTextStyles.label.copyWith(fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          // Navigate to store details page
                          context.push('/store/${store.id}');
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.storefront, size: 12, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                store.name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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