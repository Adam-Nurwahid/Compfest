import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/dummy/app_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
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

    // Allow guest access if permitted and user is guest
    if (allowGuest && appState.activeRole == 'Guest') {
      return child;
    }

    // Guard login: if not logged in, force LoginPage
    if (!appState.isLoggedIn) {
      return const LoginPage();
    }

    // Guard role: if activeRole does not match required, show AccessDeniedPage
    if (appState.activeRole != requiredRole) {
      return AccessDeniedPage(
        requiredRole: requiredRole,
        currentRole: appState.activeRole,
      );
    }

    return child;
  }
}
