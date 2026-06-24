import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dummy/app_state.dart';
import '../../../landing/landing_page.dart';
import 'cart_page.dart';
import 'catalog_page.dart';
import 'profile_page.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialTab;

  const MainNavigationShell({super.key, this.initialTab = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  // Keep pages in IndexedStack to preserve scrolling state
  final List<Widget> _pages = [
    const LandingPage(),
    const CatalogPage(),
    const CartPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final cartItemCount = appState.cartItems.fold(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.border, width: 1.0)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.neutral,
          selectedLabelStyle: AppTextStyles.label.copyWith(fontSize: 12, color: AppColors.primary),
          unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.neutral),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home, color: AppColors.primary),
              label: 'Beranda',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view, color: AppColors.primary),
              label: 'Katalog',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                label: cartItemCount > 0 ? Text(cartItemCount.toString()) : null,
                isLabelVisible: cartItemCount > 0,
                backgroundColor: AppColors.secondary,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              activeIcon: Badge(
                label: cartItemCount > 0 ? Text(cartItemCount.toString()) : null,
                isLabelVisible: cartItemCount > 0,
                backgroundColor: AppColors.secondary,
                child: const Icon(Icons.shopping_cart, color: AppColors.primary),
              ),
              label: 'Keranjang',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person, color: AppColors.primary),
              label: appState.isLoggedIn ? 'Profil' : 'Masuk',
            ),
          ],
        ),
      ),
    );
  }
}