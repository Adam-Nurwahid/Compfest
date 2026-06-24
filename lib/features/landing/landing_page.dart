import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/reusable_widgets.dart';
import '../../data/dummy/app_state.dart';
import '../../data/dummy/dummy_data.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Section (Beautiful teal/orange blend with text)
              _buildHero(context, appState),

              const SizedBox(height: 24),

              // 2. Categories Section
              _buildCategories(context),

              const SizedBox(height: 28),

              // 3. Highlighted Products
              _buildProductHighlights(context),

              const SizedBox(height: 28),

              // 4. Testimonial / Application Reviews Section
              _buildTestimonials(context, appState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, AppState appState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.sailing_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'SEAPEDIA',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              if (appState.isLoggedIn)
                GestureDetector(
                  onTap: () => context.go('/profile'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Halo, ${appState.activeRole}',
                          style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Masuk',
                    style: AppTextStyles.label.copyWith(color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Gerbang Belanja\nKemaritiman Nusantara',
            style: AppTextStyles.headlineLarge.copyWith(
              color: Colors.white,
              fontSize: 28,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Jelajahi, temukan, dan penuhi segala kebutuhan berlayar, diving, dan pancing Anda langsung dari produsen lokal terbaik.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Navigate to Catalog Page tab
                      // GoRouter allows changing shell branch or passing search query
                      context.go('/catalog');
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.neutral),
                          const SizedBox(width: 12),
                          Text(
                            'Cari dive computer, joran pancing...',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      {'name': 'Diving', 'icon': Icons.scuba_diving_rounded, 'desc': 'Selam & Snorkel'},
      {'name': 'Sailing', 'icon': Icons.sailing_rounded, 'desc': 'Kapal & Layar'},
      {'name': 'Fishing', 'icon': Icons.phishing_rounded, 'desc': 'Alat Pancing'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori Unggulan',
            style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: categories.map((cat) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    onTap: () {
                      context.go('/catalog?category=${cat['name'] as String}');
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.tertiary.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            cat['icon'] as IconData,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat['name'] as String,
                          style: AppTextStyles.label.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cat['desc'] as String,
                          style: AppTextStyles.bodyMedium.copyWith(fontSize: 10, color: AppColors.neutral),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductHighlights(BuildContext context) {
    // Show top 4 products
    final highlights = dummyProducts.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rekomendasi Terhangat',
                style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
              ),
              TextButton(
                onPressed: () => context.go('/catalog'),
                child: Row(
                  children: [
                    Text('Lihat Semua', style: AppTextStyles.label.copyWith(color: AppColors.primary, fontSize: 13)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 240,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: highlights.length,
            itemBuilder: (context, index) {
              final product = highlights[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: AppCard(
                  padding: EdgeInsets.zero,
                  onTap: () {
                    context.push('/product/${product.id}');
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image Container
                      Stack(
                        children: [
                          Container(
                            height: 110,
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
                                    child: Icon(Icons.broken_image_outlined, size: 36, color: AppColors.primary),
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
                      // Details
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: AppTextStyles.label.copyWith(fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Rp${product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                              style: AppTextStyles.label.copyWith(color: AppColors.secondary, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Stok: ${product.stock}',
                              style: AppTextStyles.bodyMedium.copyWith(fontSize: 10, color: AppColors.neutral),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonials(BuildContext context, AppState appState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Review Aplikasi',
                style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: AppTextStyles.label.copyWith(fontSize: 11),
                ),
                onPressed: () {
                  context.push('/submit-review');
                },
                icon: const Icon(Icons.rate_review_outlined, size: 14),
                label: const Text('Tulis Review'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 155,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: appState.appReviews.length,
              itemBuilder: (context, index) {
                final review = appState.appReviews[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 12, bottom: 4, top: 4),
                  child: AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              review.name,
                              style: AppTextStyles.label.copyWith(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                            RatingStars(rating: review.rating, size: 14),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${review.date.day}/${review.date.month}/${review.date.year}',
                          style: AppTextStyles.bodyMedium.copyWith(fontSize: 10, color: AppColors.neutral),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            review.comment,
                            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.textPrimary),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
