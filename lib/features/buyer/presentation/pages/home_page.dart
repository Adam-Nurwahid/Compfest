import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('SEAPEDIA', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              style: AppButtonStyles.labelTag,
              onPressed: () {},
              child: const Row(
                children: [
                  Icon(Icons.login, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Login'),
                ],
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search marine gear...',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),

            // Promo Banner Card
            Card(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(6)),
                            child: const Text('SEASON SALE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 8),
                          Text('Diving Essentials\nUp to 40% Off', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('Explore the deep with unbeatable prices.', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.pool, size: 64, color: AppColors.tertiary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Categories Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Categories', style: AppTextStyles.label.copyWith(fontSize: 16)),
                TextButton(onPressed: () {}, child: const Text('See All')),
              ],
            ),
            Row(
              children: [
                Chip(avatar: const Icon(Icons.electric_bolt, size: 16), label: const Text('Electronics')),
                const SizedBox(width: 8),
                Chip(avatar: const Icon(Icons.checkroom, size: 16), label: const Text('Fashion')),
              ],
            ),
            const SizedBox(height: 24),

            // Recommended Grid Section (2 Columns)
            Text('Recommended for You', style: AppTextStyles.label.copyWith(fontSize: 16)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                final products = [
                  {'name': 'SeaNavigator X-1', 'store': 'Oceanic Gear', 'price': '\$549.00', 'rate': '4.9'},
                  {'name': 'ProDive Carbon Mask', 'store': 'Marina Hub', 'price': '\$120.00', 'rate': '4.7'},
                  {'name': 'Marine Cooler 45L', 'store': 'Deep Blue Supply', 'price': '\$285.00', 'rate': '4.5'},
                  {'name': 'VHF Guardian Radio', 'store': 'Coastal Prime', 'price': '\$199.00', 'rate': '4.8'},
                ];
                final item = products[index];
                return _buildProductCard(item['name']!, item['store']!, item['price']!, item['rate']!);
              },
            ),
            const SizedBox(height: 24),

            // Application Reviews Section
            Text('Application Reviews', style: AppTextStyles.label.copyWith(fontSize: 16)),
            Text('What our community says about SEAPEDIA', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 12),
            OutlinedButton(
              style: AppButtonStyles.outlined,
              onPressed: () {},
              child: const Center(child: Text('Write a Review')),
            ),
            const SizedBox(height: 16),
            _buildReviewCard('Sarah Johnson', 'SEAPEDIA is a game changer for boat owners. I found rare parts for my 1985 yacht within minutes. Highly recommended!'),
          ],
        ),
      ),
    );
  }

  // Product Card Widget Composition
  Widget _buildProductCard(String name, String store, String price, String rating) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.tertiary.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Center(child: Icon(Icons.image, size: 48, color: AppColors.neutral)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(store, style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(rating, style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(price, style: AppTextStyles.label.copyWith(color: AppColors.secondary, fontSize: 15)),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.secondary,
                      child: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Review Card Widget Composition
  Widget _buildReviewCard(String name, String comment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tertiary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 16)),
              const SizedBox(width: 8),
              Text(name, style: AppTextStyles.label),
              const Spacer(),
              Row(children: List.generate(5, (_) => const Icon(Icons.star, color: Colors.amber, size: 14))),
            ],
          ),
          const SizedBox(height: 8),
          Text('"$comment"', style: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}