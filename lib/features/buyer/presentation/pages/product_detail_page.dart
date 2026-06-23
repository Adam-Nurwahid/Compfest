import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Gambar Utama Produk Besar + Indikator Slide
                Container(
                  height: 260,
                  width: double.infinity,
                  color: AppColors.background,
                  child: const Center(child: Icon(Icons.sailing, size: 120, color: AppColors.primary)),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(height: 8, width: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Container(height: 8, width: 8, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Container(height: 8, width: 8, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                  ],
                ),

                // 2. Konten Detail Judul dan Harga
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OceanMaster Elite Saltwater Spinning Reel', style: AppTextStyles.headlineMedium.copyWith(fontSize: 22)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('\$249.99', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.secondary, fontSize: 26)),
                          const SizedBox(width: 12),
                          Text('\$299.00', style: AppTextStyles.bodyMedium.copyWith(decoration: TextDecoration.lineThrough, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Row(children: List.generate(5, (_) => const Icon(Icons.star, color: Colors.amber, size: 16))),
                          const SizedBox(width: 6),
                          Text('4.8', style: AppTextStyles.label.copyWith(fontSize: 14)),
                          Text(' (124 Reviews)', style: AppTextStyles.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 3. Spanduk Ringkasan Informasi Toko Penjual
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.tertiary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.anchor, color: Colors.white)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Marine Pro Gear', style: AppTextStyles.label),
                                  Text('Verified Merchant', style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              style: AppButtonStyles.outlined.copyWith(padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 14, vertical: 8))),
                              onPressed: () {},
                              child: const Text('Visit Store'),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 4. Deskripsi Produk
                      Text('Product Description', style: AppTextStyles.label.copyWith(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        'Designed for the ultimate ocean enthusiast, the OceanMaster Elite offers unparalleled durability in harsh saltwater environments. Features a fully sealed drag system and carbon fiber construction for maximum strength without the weight.',
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary.withOpacity(0.8), fontSize: 14),
                      ),
                      const SizedBox(height: 24),

                      // 5. Tabel Spesifikasi Komposisi Dropdown Accordion
                      ExpansionTile(
                        title: Text('Specifications', style: AppTextStyles.label.copyWith(fontSize: 16)),
                        tilePadding: EdgeInsets.zero,
                        children: [
                          _buildSpecRow('Gear Ratio', '6.2:1'),
                          _buildSpecRow('Max Drag', '22 lbs'),
                          _buildSpecRow('Weight', '9.4 oz'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 6. Floating Action Bottom Bar dengan Kunci Akses Tamu (Guest Lock Overlay)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tombol Utama Login To Purchase
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: AppButtonStyles.primary.copyWith(backgroundColor: WidgetStateProperty.all(const Color(0xFFE6F4F4)), foregroundColor: WidgetStateProperty.all(AppColors.primary)),
                      onPressed: () {},
                      icon: const Icon(Icons.lock_outline, size: 18),
                      label: Text('Login to purchase', style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tombol Beli yang terarsir pudar karena status guest biasa
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: AppButtonStyles.outlined.copyWith(foregroundColor: WidgetStateProperty.all(Colors.grey.shade400)),
                          onPressed: null, // Disabled
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Add to Cart'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: AppButtonStyles.primary.copyWith(backgroundColor: WidgetStateProperty.all(AppColors.secondary.withOpacity(0.4))),
                          onPressed: null, // Disabled
                          child: const Text('Buy Now'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(value, style: AppTextStyles.label),
        ],
      ),
    );
  }
}