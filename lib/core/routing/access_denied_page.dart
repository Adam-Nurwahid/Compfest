// lib/core/routing/access_denied_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/reusable_widgets.dart';
import '../../data/dummy/app_state.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';

class AccessDeniedPage extends StatelessWidget {
  final String requiredRole;
  final String currentRole;

  const AccessDeniedPage({
    super.key,
    required this.requiredRole,
    required this.currentRole,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Visual warning container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.gpp_bad_outlined,
                  size: 80,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Akses Dibatasi',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                  children: [
                    const TextSpan(text: 'Halaman ini hanya untuk '),
                    TextSpan(
                      text: requiredRole,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const TextSpan(text: '. Role aktif kamu saat ini adalah '),
                    TextSpan(
                      text: currentRole,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              if (appState.availableRoles.map((r) => r.toLowerCase()).contains(requiredRole.toLowerCase())) ...[
                AppButton(
                  text: 'Ganti ke Mode $requiredRole',
                  onPressed: () {
                    context.read<AuthBloc>().add(RoleSelected(targetRole: requiredRole.toLowerCase()));
                    appState.setActiveRole(requiredRole);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(duration: const Duration(seconds: 2), content: Text('Switched to $requiredRole Mode')),
                    );
                    if (requiredRole == 'Seller') {
                      context.go('/seller/dashboard');
                    } else if (requiredRole == 'Driver') {
                      context.go('/driver/find-jobs');
                    } else {
                      context.go('/landing');
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],

              AppButton(
                text: 'Pilih Role Lainnya',
                styleType: ButtonStyleType.outlined,
                onPressed: () {
                  context.go('/role-selection');
                },
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  if (currentRole == 'Seller') {
                    context.go('/seller/dashboard');
                  } else if (currentRole == 'Driver') {
                    context.go('/driver/find-jobs');
                  } else if (currentRole == 'Admin') {
                    context.go('/admin/dashboard');
                  } else {
                    context.go('/landing');
                  }
                },
                child: Text(
                  'Kembali ke Beranda Anda',
                  style: AppTextStyles.label.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
