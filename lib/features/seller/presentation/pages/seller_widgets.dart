import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/models/models.dart';

/// 1. SellerAppBar
class SellerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Store? store;
  final List<Widget>? actions;

  const SellerAppBar({
    super.key,
    required this.title,
    this.store,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1E293B), // Dark slate header
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: AppTextStyles.headlineMedium.copyWith(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Seller Mode',
                  style: AppTextStyles.label.copyWith(fontSize: 9, color: Colors.white),
                ),
              ),
            ],
          ),
          if (store != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.storefront, size: 12, color: AppColors.secondaryLight),
                const SizedBox(width: 4),
                Text(
                  store!.name,
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Colors.white.withOpacity(0.1), height: 1.0),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4.0);
}

/// 2. StatCard
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      radius: 16,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.neutral),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.label.copyWith(fontSize: 18, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right, color: AppColors.neutral, size: 18),
        ],
      ),
    );
  }
}

/// 3. ProductManageCard
class ProductManageCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductManageCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final formattedPrice = product.price
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    return AppCard(
      radius: 16,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              product.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: AppColors.tertiary.withOpacity(0.3),
                  child: const Icon(Icons.broken_image_outlined, color: AppColors.primary),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Info Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.label.copyWith(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp$formattedPrice',
                  style: AppTextStyles.label.copyWith(color: AppColors.secondary, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.stock > 0
                            ? AppColors.tertiary.withOpacity(0.5)
                            : AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.stock > 0 ? 'Stok: ${product.stock}' : 'Stok Habis',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 10,
                          color: product.stock > 0 ? AppColors.primary : AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.neutral.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.category,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 10,
                          color: AppColors.neutral,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Actions
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                onPressed: onEdit,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 4. OrderProcessCard
class OrderProcessCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onProcess;
  final VoidCallback? onTap;

  const OrderProcessCard({
    super.key,
    required this.order,
    this.onProcess,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = order.statusTimeline.isNotEmpty
        ? order.statusTimeline.first.timestamp
        : DateTime.now();

    final dateStr = '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final itemsCount = order.items.fold(0, (sum, i) => sum + i.quantity);

    final formattedPrice = order.finalTotal
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    return AppCard(
      onTap: onTap,
      radius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.id,
                style: AppTextStyles.label.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tanggal: $dateStr',
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
          ),
          const Divider(height: 20),
          Row(
            children: [
              // Product Preview Image (of the first item)
              if (order.items.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    order.items.first.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: AppColors.tertiary.withOpacity(0.3),
                      child: const Icon(Icons.broken_image_outlined, size: 24, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.items.isNotEmpty ? order.items.first.productName : 'Pesanan Tanpa Nama',
                      style: AppTextStyles.label.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$itemsCount Item • Total: Rp$formattedPrice',
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (order.status == 'Sedang Dikemas' && onProcess != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onProcess,
                icon: const Icon(Icons.inventory_2_outlined, size: 16),
                label: const Text('Proses Pesanan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 5. CustomDashboardChart
class CustomDashboardChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final String title;

  const CustomDashboardChart({
    super.key,
    required this.values,
    required this.labels,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    double maxValue = values.fold(1.0, (max, v) => v > max ? v : max);

    return AppCard(
      radius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.label.copyWith(fontSize: 14, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(values.length, (index) {
                final val = values[index];
                final label = labels[index];
                final ratio = val / maxValue;
                final barHeight = (ratio * 120).clamp(5.0, 120.0);

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Value tooltip
                      Text(
                        val >= 1000000
                            ? '${(val / 1000000).toStringAsFixed(1)}M'
                            : '${(val / 1000).toStringAsFixed(0)}k',
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      // Styled bar
                      Container(
                        height: barHeight,
                        width: 14,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.6),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Label
                      Text(
                        label,
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 10, color: AppColors.neutral),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
