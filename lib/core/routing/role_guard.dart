// lib/core/routing/role_guard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/dummy/app_state.dart';
import 'access_denied_page.dart';

class RoleGuard extends StatelessWidget {
  final String requiredRole;
  final bool allowGuest;
  final Widget child;

  const RoleGuard({
    super.key,
    required this.requiredRole,
    this.allowGuest = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // Izin masuk jika mode Tamu (Guest) diperbolehkan
    if (allowGuest && appState.activeRole == 'Guest') {
      return child;
    }

    // MEMPERBAIKI REDIRECT LOGIN (Fix Issue 1)
    if (!appState.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Memastikan peran aktif sesuai dengan hak akses halaman
    if (appState.activeRole != requiredRole) {
      return AccessDeniedPage(
        requiredRole: requiredRole,
        currentRole: appState.activeRole,
      );
    }



    return child;
  }
}