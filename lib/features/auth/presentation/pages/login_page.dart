import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../data/dummy/app_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'andi@seapedia.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        final appState = Provider.of<AppState>(context, listen: false);
        final success = appState.login(_emailController.text, _passwordController.text);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login berhasil!'),
              backgroundColor: AppColors.primary,
            ),
          );

          // Route based on available roles
          if (appState.currentUser!.roles.length > 1) {
            context.go('/role-selection');
          } else {
            if (appState.activeRole == 'Seller') {
              context.go('/seller/dashboard');
            } else if (appState.activeRole == 'Driver') {
              context.go('/driver/find-jobs');
            } else {
              context.go('/landing');
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Username/Email atau password salah! (Gunakan andi/budi/chandra/dedi dengan password123)'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
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
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral),
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
                    prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.neutral),
                  ),
                  const SizedBox(height: 20),

                  AppTextField(
                    label: 'Kata Sandi',
                    hintText: 'Masukkan kata sandi Anda',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.neutral),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
                            content: Text('Fitur lupa kata sandi dinonaktifkan di versi demo.'),
                          ),
                        );
                      },
                      child: Text(
                        'Lupa Kata Sandi?',
                        style: AppTextStyles.label.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Login Button
                  AppButton(
                    text: 'Masuk Sekarang',
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('ATAU GUEST', style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
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
                      // Navigate directly to landing page
                      context.go('/landing');
                    },
                  ),
                  const SizedBox(height: 20),

                  // Demo Login Helper Section
                  Text(
                    'Akun Demo (Klik untuk Autofill):',
                    style: AppTextStyles.label.copyWith(fontSize: 12, color: AppColors.neutral),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      ActionChip(
                        label: const Text('Buyer/Seller (Andi)'),
                        onPressed: () {
                          _emailController.text = 'andi@seapedia.com';
                          _passwordController.text = 'password123';
                        },
                      ),
                      ActionChip(
                        label: const Text('Seller Only (Budi)'),
                        onPressed: () {
                          _emailController.text = 'budi@seapedia.com';
                          _passwordController.text = 'password123';
                        },
                      ),
                      ActionChip(
                        label: const Text('All Roles (Chandra)'),
                        onPressed: () {
                          _emailController.text = 'chandra@seapedia.com';
                          _passwordController.text = 'password123';
                        },
                        backgroundColor: AppColors.tertiary.withOpacity(0.5),
                      ),
                      ActionChip(
                        label: const Text('Driver Only (Dedi)'),
                        onPressed: () {
                          _emailController.text = 'dedi@seapedia.com';
                          _passwordController.text = 'password123';
                        },
                        backgroundColor: AppColors.secondary.withOpacity(0.2),
                      ),
                    ],
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
      ),
    );
  }
}