import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'product_detail_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['All Gear', 'Diving', 'Sailing', 'Fishing'];

  // Dummy list data produk katalog
  final List<Map<String, String>> _products = [
    {'name': 'AquaPro Smart Dive Computer', 'store': 'DEEP SEA GEAR', 'price': '\$499.00', 'rate': '4.8', 'reviews': '24'},
    {'name': 'Pro-Grid Carbon Sailing Gloves', 'store': 'NORTH WIND TECH', 'price': '\$85.50', 'rate': '4.9', 'reviews': '112'},
    {'name': 'Eco-Float Solar Beacon', 'store': 'ECO-OCEANICS', 'price': '\$210.00', 'rate': '4.7', 'reviews': '56'},
    {'name': 'Titanium Series Reef Master Reel', 'store': 'BLUEFIN ELITE', 'price': '\$1,250.00', 'rate': '5.0', 'reviews': '9'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Search Bar + Filter Icon Row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search gear, boats, tech...',
                            prefixIcon: const Icon(Icons.search),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.tune, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Horizontal Categories List
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedCategoryIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(_categories[index]),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategoryIndex = index;
                              });
                            },
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surface,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Meta Data Pencarian
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Showing 128 results', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Text('Sort by: Relevance'),
                        label: const Icon(Icons.keyboard_arrow_down, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 2 Columns Product Grid Layout
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final item = _products[index];
                        return _buildCatalogProductCard(context, item);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Floating Action Filter Button (Orange Floating Button)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onPressed: () {},
                child: const Icon(Icons.filter_list, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Komposisi Kartu Produk Katalog
  Widget _buildCatalogProductCard(BuildContext context, Map<String, String> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProductDetailPage()),
        );
      },
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Atas Gambar + Tombol Favorit
            Stack(
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withOpacity(0.3),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: const Center(child: Icon(Icons.waves, size: 48, color: AppColors.primary)),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: const Icon(Icons.favorite_border, color: AppColors.danger, size: 18),
                  ),
                ),
              ],
            ),

            // Detail Informasi Teks Bawah
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name']!,
                    style: AppTextStyles.label.copyWith(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${item['rate']} (${item['reviews']})',
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['store']!,
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 11, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['price']!,
                    style: AppTextStyles.label.copyWith(color: AppColors.secondary, fontSize: 16),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}