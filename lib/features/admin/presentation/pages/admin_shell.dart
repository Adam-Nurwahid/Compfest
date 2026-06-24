import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/dummy/app_state.dart';
import '../../../../data/models/models.dart';

// Import Admin pages
import 'admin_dashboard_page.dart';
import 'admin_users_page.dart';
import 'admin_stores_page.dart';
import 'admin_products_page.dart';
import 'admin_orders_page.dart';
import 'admin_vouchers_page.dart';
import 'admin_promos_page.dart';
import 'admin_deliveries_page.dart';
import 'admin_overdue_page.dart';

class AdminMainNavigationShell extends StatefulWidget {
  final int initialTab;

  const AdminMainNavigationShell({super.key, this.initialTab = 0});

  @override
  State<AdminMainNavigationShell> createState() => _AdminMainNavigationShellState();
}

class _AdminMainNavigationShellState extends State<AdminMainNavigationShell> {
  late int _currentIndex;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _pages = [
      const AdminDashboardPage(),
      const AdminUsersPage(),
      const AdminStoresPage(),
      const AdminProductsPage(),
      const AdminOrdersPage(),
      const AdminVouchersPage(),
      const AdminPromosPage(),
      const AdminDeliveriesPage(),
      const AdminOverduePage(),
    ];
  }

  @override
  void didUpdateWidget(covariant AdminMainNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      setState(() {
        _currentIndex = widget.initialTab;
      });
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Sync path with router
    switch (index) {
      case 0:
        context.go('/admin/dashboard');
        break;
      case 1:
        context.go('/admin/users');
        break;
      case 2:
        context.go('/admin/stores');
        break;
      case 3:
        context.go('/admin/products');
        break;
      case 4:
        context.go('/admin/orders');
        break;
      case 5:
        context.go('/admin/vouchers');
        break;
      case 6:
        context.go('/admin/promos');
        break;
      case 7:
        context.go('/admin/deliveries');
        break;
      case 8:
        context.go('/admin/overdue');
        break;
    }
  }

  String _getPageTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard Overview';
      case 1:
        return 'Users Monitoring';
      case 2:
        return 'Stores Monitoring';
      case 3:
        return 'Products Monitoring';
      case 4:
        return 'Orders Monitoring';
      case 5:
        return 'Voucher Management';
      case 6:
        return 'Promo Management';
      case 7:
        return 'Delivery Jobs';
      case 8:
        return 'Overdue Orders';
      default:
        return 'Admin Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;

    // Responsive design check
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: !isDesktop
          ? Drawer(
              child: _buildSidebar(appState, context),
            )
          : null,
      appBar: !isDesktop
          ? AppBar(
              title: Text(_getPageTitle(), style: AppTextStyles.headlineMedium.copyWith(fontSize: 20)),
              actions: [
                _buildUserAvatar(user, context),
                const SizedBox(width: 12),
              ],
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 260,
              child: _buildSidebar(appState, context),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isDesktop) _buildTopBar(user, context),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _pages,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(User? user, BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getPageTitle(),
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
              fontSize: 22,
            ),
          ),
          Row(
            children: [
              // Change Role button
              OutlinedButton.icon(
                onPressed: () {
                  context.go('/role-selection');
                },
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: const Text('Ganti Peran'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 20),
              _buildUserAvatar(user, context),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildUserAvatar(User? user, BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              user?.name ?? 'Admin Seapedia',
              style: AppTextStyles.label.copyWith(fontSize: 14, color: AppColors.textPrimary),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Super Admin',
                style: AppTextStyles.label.copyWith(fontSize: 10, color: AppColors.secondaryDark),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') {
              appState.logout();
              context.go('/login');
            } else if (value == 'role') {
              context.go('/role-selection');
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'role',
              child: Row(
                children: [
                  Icon(Icons.swap_horiz, size: 18, color: AppColors.neutral),
                  SizedBox(width: 8),
                  Text('Ganti Peran'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 18, color: AppColors.danger),
                  SizedBox(width: 8),
                  Text('Keluar', style: TextStyle(color: AppColors.danger)),
                ],
              ),
            ),
          ],
          child: CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 18,
            child: Text(
              user?.name.substring(0, 1).toUpperCase() ?? 'A',
              style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar(AppState appState, BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          // Logo & Title
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.sailing_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'SEAPEDIA',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.primary,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                _buildSidebarItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Dashboard Overview'),
                const SizedBox(height: 4),
                _buildSidebarItem(1, Icons.people_outline, Icons.people, 'Users Monitoring'),
                const SizedBox(height: 4),
                _buildSidebarItem(2, Icons.storefront_outlined, Icons.storefront, 'Stores Monitoring'),
                const SizedBox(height: 4),
                _buildSidebarItem(3, Icons.inventory_2_outlined, Icons.inventory_2, 'Products Monitoring'),
                const SizedBox(height: 4),
                _buildSidebarItem(4, Icons.receipt_long_outlined, Icons.receipt_long, 'Orders Monitoring'),
                const SizedBox(height: 4),
                _buildSidebarItem(5, Icons.card_membership_outlined, Icons.card_membership, 'Voucher Management'),
                const SizedBox(height: 4),
                _buildSidebarItem(6, Icons.campaign_outlined, Icons.campaign, 'Promo Management'),
                const SizedBox(height: 4),
                _buildSidebarItem(7, Icons.local_shipping_outlined, Icons.local_shipping, 'Delivery Jobs'),
                const SizedBox(height: 4),
                _buildSidebarItem(
                  8,
                  Icons.report_problem_outlined,
                  Icons.report_problem,
                  'Overdue Orders',
                  badgeCount: appState.orders.where((o) => o.status == 'Sedang Dikirim' && o.deliveryMethod == 'Instant').length, // count of instant orders representing time-critical ones for demo
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    appState.logout();
                    context.go('/login');
                  },
                  icon: const Icon(Icons.logout, color: AppColors.danger),
                  tooltip: 'Keluar',
                ),
                const SizedBox(width: 8),
                Text(
                  'Keluar Sesi',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.danger, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData outlineIcon, IconData solidIcon, String title, {int badgeCount = 0}) {
    final isSelected = _currentIndex == index;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.tertiary : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: () => _onTabSelected(index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Icon(
          isSelected ? solidIcon : outlineIcon,
          color: isSelected ? AppColors.primary : AppColors.neutral,
          size: 20,
        ),
        title: Text(
          title,
          style: AppTextStyles.label.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        trailing: badgeCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            : null,
      ),
    );
  }
}
