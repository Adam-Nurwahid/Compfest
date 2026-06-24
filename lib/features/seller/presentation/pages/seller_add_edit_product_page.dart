import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';
import '../../../../data/dummy/dummy_data.dart';
import '../../../../data/models/models.dart';
import 'seller_widgets.dart';

class SellerAddEditProductPage extends StatefulWidget {
  final String? productId;

  const SellerAddEditProductPage({super.key, this.productId});

  @override
  State<SellerAddEditProductPage> createState() => _SellerAddEditProductPageState();
}

class _SellerAddEditProductPageState extends State<SellerAddEditProductPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Diving';
  String _selectedImageUrl = 'https://images.unsplash.com/photo-1530541930197-ff16ac917b0e?w=500&auto=format&fit=crop';
  
  final List<String> _categories = ['Diving', 'Sailing', 'Fishing'];

  final List<Map<String, String>> _mockImages = [
    {
      'name': 'Dive Comp',
      'url': 'https://images.unsplash.com/photo-1530541930197-ff16ac917b0e?w=500&auto=format&fit=crop',
    },
    {
      'name': 'Diving Knife',
      'url': 'https://images.unsplash.com/photo-1582201942988-13e60e4556ee?w=500&auto=format&fit=crop',
    },
    {
      'name': 'Wetsuit',
      'url': 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=500&auto=format&fit=crop',
    },
    {
      'name': 'Mask',
      'url': 'https://images.unsplash.com/photo-1607569762195-e8524d56d4db?w=500&auto=format&fit=crop',
    },
    {
      'name': 'Fins',
      'url': 'https://images.unsplash.com/photo-1518152006812-edab29b069ac?w=500&auto=format&fit=crop',
    },
    {
      'name': 'Helm Wheel',
      'url': 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=500&auto=format&fit=crop',
    },
    {
      'name': 'Anemometer',
      'url': 'https://images.unsplash.com/photo-1513553404607-988bf2703777?w=500&auto=format&fit=crop',
    },
    {
      'name': 'Gloves',
      'url': 'https://images.unsplash.com/photo-1516259762381-22954d7d3ad2?w=500&auto=format&fit=crop',
    },
    {
      'name': 'Deck Bag',
      'url': 'https://images.unsplash.com/photo-1622560480605-d83c853bc5c3?w=500&auto=format&fit=crop',
    },
    {
      'name': 'Reel Master',
      'url': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=500&auto=format&fit=crop',
    },
    {
      'name': 'Jigging Rod',
      'url': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500&auto=format&fit=crop',
    },
  ];

  Product? _existingProduct;

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  void _loadProductData() {
    if (widget.productId != null) {
      try {
        final product = dummyProducts.firstWhere((p) => p.id == widget.productId);
        _existingProduct = product;
        _nameController.text = product.name;
        _priceController.text = product.price.toString();
        _stockController.text = product.stock.toString();
        _descriptionController.text = product.description;
        _selectedCategory = product.category;
        _selectedImageUrl = product.imageUrl;
      } catch (_) {
        // Product not found
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveProduct(AppState appState) {
    final name = _nameController.text.trim();
    final priceStr = _priceController.text.trim();
    final stockStr = _stockController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty || priceStr.isEmpty || stockStr.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua kolom wajib diisi!'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (name.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama produk minimal 5 karakter!'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final price = int.tryParse(priceStr);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harga harus berupa angka dan lebih besar dari 0!'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final stock = int.tryParse(stockStr);
    if (stock == null || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stok harus berupa angka dan tidak boleh negatif!'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final store = appState.currentUserStore;
    if (store == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toko tidak ditemukan. Gagal menyimpan produk.')),
      );
      return;
    }

    if (_existingProduct == null) {
      // 1. ADD NEW PRODUCT
      final newProduct = Product(
        id: 'prod_${store.id}_${DateTime.now().millisecondsSinceEpoch}',
        storeId: store.id,
        name: name,
        price: price,
        stock: stock,
        description: description,
        imageUrl: _selectedImageUrl,
        category: _selectedCategory,
        rating: 5.0,
        reviewCount: 0,
      );

      appState.addProduct(newProduct);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil ditambahkan!'),
          backgroundColor: AppColors.primary,
        ),
      );
    } else {
      // 2. UPDATE EXISTING PRODUCT
      if (_existingProduct!.storeId != store.id) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akses Ditolak: Anda tidak dapat mengedit produk toko lain!'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      final updatedProduct = Product(
        id: _existingProduct!.id,
        storeId: _existingProduct!.storeId,
        name: name,
        price: price,
        stock: stock,
        description: description,
        imageUrl: _selectedImageUrl,
        category: _selectedCategory,
        rating: _existingProduct!.rating,
        reviewCount: _existingProduct!.reviewCount,
      );

      appState.updateProduct(updatedProduct);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil diperbarui!'),
          backgroundColor: AppColors.primary,
        ),
      );
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isEditMode = _existingProduct != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SellerAppBar(
        title: isEditMode ? 'Edit Produk' : 'Tambah Produk Baru',
        store: appState.currentUserStore,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditMode ? 'Ubah data produk kelautan Anda.' : 'Lengkapi detail produk kelautan yang ingin Anda jual.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Name Field
              AppTextField(
                label: 'Nama Produk',
                hintText: 'contoh: Wet Suit Premium 3mm',
                controller: _nameController,
              ),
              const SizedBox(height: 20),

              // Price & Stock row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Harga (Rupiah)',
                      hintText: 'contoh: 250000',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      label: 'Jumlah Stok',
                      hintText: 'contoh: 15',
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Category dropdown-like choice
              Text(
                'Kategori Produk',
                style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        }
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
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Description Field
              AppTextField(
                label: 'Deskripsi Detail Produk',
                hintText: 'Jelaskan keunggulan, spesifikasi, dan material produk kelautan Anda...',
                controller: _descriptionController,
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              // Image selector (Dummy Gallery)
              Text(
                'Pilih Gambar Produk (Demo)',
                style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _mockImages.length,
                  itemBuilder: (context, index) {
                    final img = _mockImages[index];
                    final isSelected = _selectedImageUrl == img['url'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImageUrl = img['url']!;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Image.network(
                            img['url']!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Submit Buttons
              AppButton(
                text: isEditMode ? 'Simpan Perubahan' : 'Tambah Produk Sekarang',
                onPressed: () => _saveProduct(appState),
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Batal',
                styleType: ButtonStyleType.outlined,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
