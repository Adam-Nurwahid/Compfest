// lib/features/auth/presentation/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Buyer'; // Peran bawaan default
  bool _obscurePassword = true;

  final List<String> _roleOptions = ['Buyer', 'Seller', 'Driver'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(duration: const Duration(seconds: 2), 
          content: Text('Semua field wajib diisi!'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      RegisterSubmitted(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
        phoneNumber: '08123456789',
        selectedRole: _selectedRole,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Daftar Akun',
        onBackPress: () => context.go('/login'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthRegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(duration: const Duration(seconds: 2), 
                content: Text(state.message),
                backgroundColor: AppColors.primary,
              ),
            );
            context.go('/login');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(duration: const Duration(seconds: 2), 
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Buat Akun Baru', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Gabung bersama SEAPEDIA untuk transaksi kelautan terlengkap.', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 32),

                  AppTextField(
                    label: 'Nama Lengkap',
                    hintText: 'Masukkan nama lengkap Anda',
                    controller: _nameController,
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.neutral),
                  ),
                  const SizedBox(height: 20),

                  AppTextField(
                    label: 'Email',
                    hintText: 'contoh: nelayan@seapedia.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.neutral),
                  ),
                  const SizedBox(height: 20),

                  // PILIHAN ROLE BARU (Fix Issue 2)
                  Text('Daftar Sebagai Peran', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.assignment_ind_outlined, color: AppColors.neutral),
                      filled: true,
                      fillColor: AppColors.tertiary.withOpacity(0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                    items: _roleOptions.map((role) {
                      return DropdownMenuItem(value: role, child: Text(role));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRole = val);
                    },
                  ),
                  const SizedBox(height: 20),

                  AppTextField(
                    label: 'Kata Sandi',
                    hintText: 'Masukkan kata sandi baru',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.neutral),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.neutral),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 32),

                  AppButton(
                    text: 'Daftar Sekarang',
                    isLoading: isLoading,
                    onPressed: _handleRegister,
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sudah punya akun? ', style: AppTextStyles.bodyMedium),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Text('Masuk di Sini', style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}