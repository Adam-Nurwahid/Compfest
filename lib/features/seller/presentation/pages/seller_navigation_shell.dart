import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dummy/app_state.dart';

// Import Seller Pages
import 'seller_dashboard_page.dart';
import 'seller_product_list_page.dart';
import 'seller_incoming_orders_page.dart';
import 'seller_income_report_page.dart';
import 'seller_profile_page.dart';

class SellerMainNavigationShell extends StatefulWidget {
  final int initialTab;

  const SellerMainNavigationShell({super.key, this.initialTab = 0});

  @override
  State<SellerMainNavigationShell> createState() => _SellerMainNavigationShellState();
}

class _SellerMainNavigationShellState extends State<SellerMainNavigationShell> {
  late int _currentIndex;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _pages = [
      const SellerDashboardPage(),
      const SellerProductListPage(),
      const SellerIncomingOrdersPage(),
      const SellerIncomeReportPage(),
      const SellerProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    // Calculate incoming order notifications
    final myStore = appState.currentUserStore;
    final pendingOrdersCount = myStore == null 
        ? 0 
        : appState.orders.where((o) => o.storeId == myStore.id && o.status == 'Sedang Dikemas').length;

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_currentIndex > 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
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
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard, color: AppColors.primary),
                label: 'Dashboard',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                activeIcon: Icon(Icons.inventory_2, color: AppColors.primary),
                label: 'Produk',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  label: pendingOrdersCount > 0 ? Text(pendingOrdersCount.toString()) : null,
                  isLabelVisible: pendingOrdersCount > 0,
                  backgroundColor: AppColors.secondary,
                  child: const Icon(Icons.receipt_long_outlined),
                ),
                activeIcon: Badge(
                  label: pendingOrdersCount > 0 ? Text(pendingOrdersCount.toString()) : null,
                  isLabelVisible: pendingOrdersCount > 0,
                  backgroundColor: AppColors.secondary,
                  child: const Icon(Icons.receipt_long, color: AppColors.primary),
                ),
                label: 'Pesanan',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart, color: AppColors.primary),
                label: 'Laporan',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person, color: AppColors.primary),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
