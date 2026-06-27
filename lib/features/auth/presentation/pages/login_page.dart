import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 2),
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
          if (state is AuthNeedsRoleSelection) {
            // Update AppState so GoRouter sees isLoggedIn=true and doesn't redirect away
            final appState = Provider.of<AppState>(context, listen: false);
            appState.setLoggedInUser(
              state.user.id,
              state.user.username,
              '${state.user.username}@seapedia.com',
              state.user.ownedRoles,
              state.user.ownedRoles.first,
            );
            context.go('/role-selection');
          }
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                duration: Duration(seconds: 1, milliseconds: 500),
                content: Text('Login berhasil!'),
                backgroundColor: AppColors.primary,
              ),
            );

            final appState = Provider.of<AppState>(context, listen: false);
            appState.setLoggedInUser(
              state.user.id,
              state.user.username,
              '${state.user.username}@seapedia.com',
              state.user.ownedRoles,
              state.activeRole,
            );

            // Arahkan ke dasbor berdasarkan peran aktif
            final role = state.activeRole.toLowerCase();
            if (role == 'seller') {
              context.go('/seller/dashboard');
            } else if (role == 'driver') {
              context.go('/driver/find-jobs');
            } else if (role == 'admin') {
              context.go('/admin/dashboard');
            } else {
              context.go('/landing');
            }
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Container
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.tertiary.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.sailing_rounded,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'SEAPEDIA',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Marketplace Kelautan Multi-Seller',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.neutral,
                        ),
                      ),
                      const SizedBox(height: 32),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Masuk Akun',
                          style: AppTextStyles.headlineMedium,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Silakan masuk untuk melanjutkan transaksi Anda',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Inputs
                      AppTextField(
                        label: 'Email atau Username',
                        hintText: 'contoh: andi@seapedia.com',
                        controller: _emailController,
                        prefixIcon: const Icon(
                          Icons.alternate_email_rounded,
                          color: AppColors.neutral,
                        ),
                      ),
                      const SizedBox(height: 20),

                      AppTextField(
                        label: 'Kata Sandi',
                        hintText: 'Masukkan kata sandi Anda',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.neutral,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.neutral,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),

                      // Lupa Kata Sandi
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                duration: Duration(seconds: 2),
                                content: Text('Fitur lupa kata sandi dinonaktifkan di versi demo.'),
                              ),
                            );
                          },
                          child: Text(
                            'Lupa Kata Sandi?',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                            context.read<AuthBloc>().add(
                              LoginSubmitted(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              ),
                            );
                          },
                          child: state is AuthLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            'Login',
                            style: AppTextStyles.label.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppColors.border)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'ATAU GUEST',
                              style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                            ),
                          ),
                          const Expanded(child: Divider(color: AppColors.border)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Guest Button
                      AppButton(
                        text: 'Jelajahi Sebagai Guest',
                        styleType: ButtonStyleType.outlined,
                        onPressed: () {
                          context.go('/landing');
                        },
                      ),
                      const SizedBox(height: 20),

                      // Footer Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Belum punya akun? ', style: AppTextStyles.bodyMedium),
                          GestureDetector(
                            onTap: () => context.push('/register'),
                            child: Text(
                              'Daftar Sekarang',
                              style: AppTextStyles.label.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}