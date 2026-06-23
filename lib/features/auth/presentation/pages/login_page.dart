import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'register_page.dart';
import '../../../buyer/presentation/pages/main_navigation_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Logo Placeholder (Sailboat Icon)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.sailing,
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
              const SizedBox(height: 24),
              Text(
                'Selamat Datang Kembali',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Jelajahi keajaiban laut hari ini.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 40),

              // Form Inputs
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email atau Username', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'nama@email.com',
                      prefixIcon: const Icon(Icons.alternate_email),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Kata Sandi', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  TextField(
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Lupa Kata Sandi?',
                    style: AppTextStyles.label.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Login Button (Orange matching Wireframe)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppButtonStyles.primary.copyWith(
                    backgroundColor: WidgetStateProperty.all(AppColors.secondary),
                  ),
                  onPressed: () {
                    // Berpindah ke Halaman Utama setelah Login
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainNavigationShell()),
                    );
                  },
                  child: Text(
                    'Login',
                    style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Divider Opsi "ATAU"
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('ATAU', style: AppTextStyles.bodyMedium),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),

              // Social Media Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: AppButtonStyles.outlined,
                      onPressed: () {},
                      icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
                      label: const Text('Google'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: AppButtonStyles.outlined,
                      onPressed: () {},
                      icon: const Icon(Icons.facebook, color: Colors.blue),
                      label: const Text('Facebook'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Footer Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Belum punya akun? ', style: AppTextStyles.bodyMedium),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterPage()),
                      );
                    },
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
    );
  }
}