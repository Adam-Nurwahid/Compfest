import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Import Role Guard & Pages
import 'role_guard.dart';
import '../../data/dummy/app_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/buyer/presentation/pages/main_navigation_shell.dart';
import '../../features/buyer/presentation/pages/product_detail_page.dart';
import '../../features/store/store_detail_page.dart';
import '../../features/wallet/wallet_page.dart';
import '../../features/address/address_page.dart';
import '../../features/checkout/checkout_page.dart';
import '../../features/order/order_history_page.dart';
import '../../features/order/order_detail_page.dart';
import '../../features/report/spending_report_page.dart';
import '../../features/review/app_review_form_page.dart';

// Seller Pages
import '../../features/seller/presentation/pages/seller_navigation_shell.dart';
import '../../features/seller/presentation/pages/seller_add_edit_product_page.dart';
import '../../features/seller/presentation/pages/seller_order_detail_page.dart';
import '../../features/seller/presentation/pages/seller_store_page.dart';
import '../../features/driver/presentation/pages/driver_navigation_shell.dart';
import '../../features/driver/presentation/pages/driver_job_detail_page.dart';

// Admin Pages
import '../../features/admin/presentation/pages/admin_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/landing',
  refreshListenable: AppState.instance,
  redirect: (context, state) {
    final appState = AppState.instance;
    final loc = state.matchedLocation;

    // 1. Not logged in redirection
    if (!appState.isLoggedIn) {
      // Allow guest pages
      final isGuestAllowed = loc == '/landing' ||
          loc == '/catalog' ||
          loc == '/login' ||
          loc == '/register' ||
          loc.startsWith('/product/') ||
          loc.startsWith('/store/');
      if (!isGuestAllowed) {
        return '/login';
      }
      return null;
    }

    // 2. Logged in, auth pages redirection
    if (loc == '/login' || loc == '/register') {
      final role = appState.activeRole.toLowerCase();
      if (role == 'seller') return '/seller/dashboard';
      if (role == 'driver') return '/driver/find-jobs';
      if (role == 'admin') return '/admin/dashboard';
      return '/landing';
    }

    // 3. Role-based guard redirection
    final role = appState.activeRole.toLowerCase();
    
    if (role == 'seller') {
      final isAllowed = loc.startsWith('/seller') || 
          loc == '/profile' || 
          loc == '/role-selection' || 
          loc.startsWith('/product/') || 
          loc.startsWith('/store/');
      if (!isAllowed) {
        return '/seller/dashboard';
      }
    } else if (role == 'driver') {
      final isAllowed = loc.startsWith('/driver') || 
          loc == '/profile' || 
          loc == '/role-selection';
      if (!isAllowed) {
        return '/driver/find-jobs';
      }
    } else if (role == 'admin') {
      final isAllowed = loc.startsWith('/admin') || 
          loc == '/profile' || 
          loc == '/role-selection';
      if (!isAllowed) {
        return '/admin/dashboard';
      }
    } else {
      // Buyer
      final isForbidden = loc.startsWith('/seller') || 
          loc.startsWith('/driver') || 
          loc.startsWith('/admin');
      if (isForbidden) {
        return '/landing';
      }
    }

    return null;
  },
  routes: [
    // --- MAIN SHELL ROUTING (indexed stack tabs) ---
    GoRoute(
      path: '/landing',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Buyer',
        allowGuest: true,
        child: MainNavigationShell(initialTab: 0),
      ),
    ),
    GoRoute(
      path: '/catalog',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Buyer',
        allowGuest: true,
        child: MainNavigationShell(initialTab: 1),
      ),
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Buyer',
        child: MainNavigationShell(initialTab: 2),
      ),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) {
        final appState = Provider.of<AppState>(context, listen: false);
        if (appState.activeRole == 'Seller') {
          return const RoleGuard(
            requiredRole: 'Seller',
            child: SellerMainNavigationShell(initialTab: 4),
          );
        } else if (appState.activeRole == 'Driver') {
          return const RoleGuard(
            requiredRole: 'Driver',
            child: DriverMainNavigationShell(initialTab: 3),
          );
        }
        return const MainNavigationShell(initialTab: 3);
      },
    ),

    // --- AUTH FLOW ---
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionPage(),
    ),

    // --- DETAILS SCREENS ---
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return RoleGuard(
          requiredRole: 'Buyer',
          allowGuest: true,
          child: ProductDetailPage(productId: productId),
        );
      },
    ),
    GoRoute(
      path: '/store/:id',
      builder: (context, state) {
        final storeId = state.pathParameters['id']!;
        return RoleGuard(
          requiredRole: 'Buyer',
          allowGuest: true,
          child: StoreDetailPage(storeId: storeId),
        );
      },
    ),

    // --- BUYER FEATURES (PRIVATE/LOGGED IN) ---
    GoRoute(
      path: '/wallet',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Buyer',
        child: WalletPage(),
      ),
    ),
    GoRoute(
      path: '/addresses',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Buyer',
        child: AddressPage(),
      ),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Buyer',
        child: CheckoutPage(),
      ),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Buyer',
        child: OrderHistoryPage(),
      ),
    ),
    GoRoute(
      path: '/order/:id',
      builder: (context, state) {
        final orderId = state.pathParameters['id']!;
        return RoleGuard(
          requiredRole: 'Buyer',
          child: OrderDetailPage(orderId: orderId),
        );
      },
    ),
    GoRoute(
      path: '/report',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Buyer',
        child: SpendingReportPage(),
      ),
    ),

    // --- REVIEW FLOW ---
    GoRoute(
      path: '/submit-review',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Buyer',
        allowGuest: true,
        child: AppReviewFormPage(),
      ),
    ),

    // --- SELLER FEATURES ---
    GoRoute(
      path: '/seller/dashboard',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Seller',
        child: SellerMainNavigationShell(initialTab: 0),
      ),
    ),
    GoRoute(
      path: '/seller/products',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Seller',
        child: SellerMainNavigationShell(initialTab: 1),
      ),
    ),
    GoRoute(
      path: '/seller/orders',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Seller',
        child: SellerMainNavigationShell(initialTab: 2),
      ),
    ),
    GoRoute(
      path: '/seller/report',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Seller',
        child: SellerMainNavigationShell(initialTab: 3),
      ),
    ),
    GoRoute(
      path: '/seller/profile',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Seller',
        child: SellerMainNavigationShell(initialTab: 4),
      ),
    ),
    GoRoute(
      path: '/seller/product/add',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Seller',
        child: SellerAddEditProductPage(),
      ),
    ),
    GoRoute(
      path: '/seller/product/edit/:id',
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return RoleGuard(
          requiredRole: 'Seller',
          child: SellerAddEditProductPage(productId: productId),
        );
      },
    ),
    GoRoute(
      path: '/seller/order/:id',
      builder: (context, state) {
        final orderId = state.pathParameters['id']!;
        return RoleGuard(
          requiredRole: 'Seller',
          child: SellerOrderDetailPage(orderId: orderId),
        );
      },
    ),
    GoRoute(
      path: '/seller/store',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Seller',
        child: SellerStorePage(),
      ),
    ),
    
    // --- DRIVER FEATURES ---
    GoRoute(
      path: '/driver/find-jobs',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Driver',
        child: DriverMainNavigationShell(initialTab: 0),
      ),
    ),
    GoRoute(
      path: '/driver/active-job',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Driver',
        child: DriverMainNavigationShell(initialTab: 1),
      ),
    ),
    GoRoute(
      path: '/driver/history-earnings',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Driver',
        child: DriverMainNavigationShell(initialTab: 2),
      ),
    ),
    GoRoute(
      path: '/driver/profile',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Driver',
        child: DriverMainNavigationShell(initialTab: 3),
      ),
    ),
    GoRoute(
      path: '/driver/job/:id',
      builder: (context, state) {
        final orderId = state.pathParameters['id']!;
        return RoleGuard(
          requiredRole: 'Driver',
          child: DriverJobDetailPage(orderId: orderId),
        );
      },
    ),

    // --- ADMIN FEATURES ---
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Admin',
        child: AdminMainNavigationShell(initialTab: 0),
      ),
    ),
    GoRoute(
      path: '/admin/users',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Admin',
        child: AdminMainNavigationShell(initialTab: 1),
      ),
    ),
    GoRoute(
      path: '/admin/stores',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Admin',
        child: AdminMainNavigationShell(initialTab: 2),
      ),
    ),
    GoRoute(
      path: '/admin/products',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Admin',
        child: AdminMainNavigationShell(initialTab: 3),
      ),
    ),
    GoRoute(
      path: '/admin/orders',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Admin',
        child: AdminMainNavigationShell(initialTab: 4),
      ),
    ),
    GoRoute(
      path: '/admin/vouchers',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Admin',
        child: AdminMainNavigationShell(initialTab: 5),
      ),
    ),
    GoRoute(
      path: '/admin/promos',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Admin',
        child: AdminMainNavigationShell(initialTab: 6),
      ),
    ),
    GoRoute(
      path: '/admin/deliveries',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Admin',
        child: AdminMainNavigationShell(initialTab: 7),
      ),
    ),
    GoRoute(
      path: '/admin/overdue',
      builder: (context, state) => const RoleGuard(
        requiredRole: 'Admin',
        child: AdminMainNavigationShell(initialTab: 8),
      ),
    ),
  ],
);
