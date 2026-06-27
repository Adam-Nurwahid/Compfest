import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/dummy_data.dart';
import '../../../../data/models/models.dart';

class AdminStoresPage extends StatefulWidget {
  const AdminStoresPage({super.key});

  @override
  State<AdminStoresPage> createState() => _AdminStoresPageState();
}

class _AdminStoresPageState extends State<AdminStoresPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Filter stores based on search query
    final filteredStores = dummyStores.where((store) {
      // Find owner name to search by owner too
      final owner = dummyUsers.firstWhere(
        (u) => u.id == store.sellerId,
        orElse: () => User(id: '', name: 'Unknown', email: '', username: '', password: '', roles: [], activeRole: ''),
      );

      final matchesSearch = store.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          store.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          owner.name.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesSearch;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search controls
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan nama toko, lokasi, atau nama pemilik...',
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
          const SizedBox(height: 20),

          // Stores Table
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
                          Expanded(flex: 3, child: Text('Nama Toko', style: AppTextStyles.label)),
                          Expanded(flex: 2, child: Text('Pemilik (Owner)', style: AppTextStyles.label)),
                          Expanded(flex: 2, child: Text('Lokasi', style: AppTextStyles.label)),
                          Expanded(flex: 1, child: Text('Produk', style: AppTextStyles.label)),
                          Expanded(flex: 1, child: Text('Rating', style: AppTextStyles.label)),
                          Expanded(flex: 1, child: Text('Status', style: AppTextStyles.label)),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Body List
                    Expanded(
                      child: filteredStores.isEmpty
                          ? const Center(
                              child: EmptyState(
                                title: 'Toko Tidak Ditemukan',
                                message: 'Tidak ada toko merchant yang cocok dengan kriteria pencarian Anda.',
                                icon: Icons.storefront_outlined,
                              ),
                            )
                          : ListView.separated(
                              itemCount: filteredStores.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final store = filteredStores[index];

                                // Find owner
                                final owner = dummyUsers.firstWhere(
                                  (u) => u.id == store.sellerId,
                                  orElse: () => User(id: '', name: 'Pemilik Tidak Dikenal', email: '', username: '', password: '', roles: [], activeRole: ''),
                                );

                                // Count products in this store
                                final productCount = dummyProducts.where((p) => p.storeId == store.id).length;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  child: Row(
                                    children: [
                                      // Store Name + Logo
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.network(
                                                store.logoUrl,
                                                width: 44,
                                                height: 44,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  width: 44,
                                                  height: 44,
                                                  color: AppColors.tertiary,
                                                  child: const Icon(Icons.store, color: AppColors.primary),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    store.name,
                                                    style: AppTextStyles.label.copyWith(fontSize: 14),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    store.description,
                                                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Owner
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(owner.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                            Text(owner.email, style: AppTextStyles.bodyMedium.copyWith(fontSize: 11)),
                                          ],
                                        ),
                                      ),

                                      // Location
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          children: [
                                            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.neutral),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                store.location,
                                                style: const TextStyle(fontSize: 13),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Product Count
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '$productCount Item',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
                                              store.rating.toString(),
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Status (Active default since it's mock)
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text('Buka', style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold)),
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
