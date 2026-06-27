import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // If not logged in, show Guest login prompt
    if (!appState.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Keranjang Belanja', style: AppTextStyles.headlineMedium.copyWith(fontSize: 20)),
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: AppColors.border, height: 1.0),
          ),
        ),
        body: EmptyState(
          title: 'Belum Masuk Akun',
          message: 'Silakan masuk ke akun SEAPEDIA Anda untuk mulai berbelanja peralatan kelautan.',
          icon: Icons.shopping_cart_outlined,
          buttonText: 'Masuk Akun',
          onButtonPressed: () {
            context.go('/login');
          },
        ),
      );
    }

    final cartItems = appState.cartItems;
    final cartStore = appState.cartStore;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Keranjang Belanja', style: AppTextStyles.headlineMedium.copyWith(fontSize: 20)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: cartItems.isNotEmpty
            ? [
                TextButton(
                  onPressed: () {
                    appState.clearCart();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(duration: const Duration(seconds: 2), content: Text('Keranjang berhasil dikosongkan.')),
                    );
                  },
                  child: Text(
                    'Kosongkan',
                    style: AppTextStyles.label.copyWith(color: AppColors.danger, fontSize: 13),
                  ),
                ),
              ]
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: cartItems.isEmpty
            ? EmptyState(
                title: 'Keranjang Kosong',
                message: 'Anda belum menambahkan produk kelautan apapun ke keranjang Anda.',
                icon: Icons.remove_shopping_cart_outlined,
                buttonText: 'Mulai Belanja',
                onButtonPressed: () => context.go('/catalog'),
              )
            : Column(
                children: [
                  // Store Owner Header
                  if (cartStore != null)
                    Container(
                      color: AppColors.surface,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              cartStore.name,
                              style: AppTextStyles.label.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Text(
                            cartStore.location,
                            style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Items List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        final itemSubtotal = item.product.price * item.quantity;
                        final formattedPrice = item.product.price
                            .toString()
                            .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
                        final formattedSubtotal = itemSubtotal
                            .toString()
                            .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: AppCard(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image Thumbnail
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    color: AppColors.tertiary.withOpacity(0.3),
                                    child: Image.network(
                                      item.product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Icons.image_outlined,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Product Title & Calculations
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: AppTextStyles.label.copyWith(fontSize: 13),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Rp$formattedPrice',
                                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.neutral),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Subtotal: Rp$formattedSubtotal',
                                        style: AppTextStyles.label.copyWith(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),

                                // Actions (Qty +/- & delete)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                                      onPressed: () => appState.removeFromCart(item.product.id),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        _buildQtyButton(
                                          icon: Icons.remove,
                                          onTap: () => appState.updateCartQuantity(item.product.id, -1),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                          child: Text(
                                            item.quantity.toString(),
                                            style: AppTextStyles.label.copyWith(fontSize: 14),
                                          ),
                                        ),
                                        _buildQtyButton(
                                          icon: Icons.add,
                                          // Limit quantity to stock
                                          onTap: item.quantity < item.product.stock
                                              ? () => appState.updateCartQuantity(item.product.id, 1)
                                              : () {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(duration: const Duration(seconds: 2), 
                                                      content: Text('Batas maksimal stok tercapai!'),
                                                      backgroundColor: AppColors.secondary,
                                                    ),
                                                  );
                                                },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom checkout panel
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal Produk',
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Rp${appState.cartSubtotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                              style: AppTextStyles.headlineMedium.copyWith(fontSize: 18, color: AppColors.secondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          text: 'Lanjut ke Checkout',
                          onPressed: () {
                            context.push('/checkout');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildQtyButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 1.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}