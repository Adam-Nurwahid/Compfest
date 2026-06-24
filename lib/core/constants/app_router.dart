import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import Pages
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

final GoRouter appRouter = GoRouter(
  initialLocation: '/landing',
  routes: [
    // --- MAIN SHELL ROUTING (indexed stack tabs) ---
    GoRoute(
      path: '/landing',
      builder: (context, state) => const MainNavigationShell(initialTab: 0),
    ),
    GoRoute(
      path: '/catalog',
      builder: (context, state) {
        final category = state.uri.queryParameters['category'];
        return MainNavigationShell(initialTab: 1 + (category != null ? 0 : 0)); // shell handles catalog
      },
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const MainNavigationShell(initialTab: 2),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const MainNavigationShell(initialTab: 3),
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
        return ProductDetailPage(productId: productId);
      },
    ),
    GoRoute(
      path: '/store/:id',
      builder: (context, state) {
        final storeId = state.pathParameters['id']!;
        return StoreDetailPage(storeId: storeId);
      },
    ),

    // --- BUYER FEATURES (PRIVATE/LOGGED IN) ---
    GoRoute(
      path: '/wallet',
      builder: (context, state) => const WalletPage(),
    ),
    GoRoute(
      path: '/addresses',
      builder: (context, state) => const AddressPage(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutPage(),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrderHistoryPage(),
    ),
    GoRoute(
      path: '/order/:id',
      builder: (context, state) {
        final orderId = state.pathParameters['id']!;
        return OrderDetailPage(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/report',
      builder: (context, state) => const SpendingReportPage(),
    ),

    // --- REVIEW FLOW ---
    GoRoute(
      path: '/submit-review',
      builder: (context, state) => const AppReviewFormPage(),
    ),
  ],
);
