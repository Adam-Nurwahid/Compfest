import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Join the Voyage',
                  style: AppTextStyles.headlineLarge,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Create your account to explore the ocean marketplace.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              const SizedBox(height: 32),

              // Form Input Formations
              _buildInputField('Full Name', 'John Doe', 'Legal name as it appears on your ID.', Icons.person_outline),
              _buildInputField('Username', 'seafarer_24', 'At least 4 characters, unique to you.', Icons.alternate_email),
              _buildInputField('Email Address', 'example@ocean.com', 'Verification link will be sent here.', Icons.mail_outline),
              _buildInputField('Phone Number', '+1(555) 000-0000', 'For secure two-factor authentication.', Icons.phone_android),
              _buildInputField('Password', '••••••••', 'Minimum 8 characters with numbers & symbols.', Icons.lock_outline, isPassword: true),
              _buildInputField('Confirm Password', '••••••••', 'Please re-enter your password.', Icons.verified_user_outlined, isPassword: true),

              const SizedBox(height: 16),
              // Checkbox Persetujuan
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium,
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(text: 'Terms of Service ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            const TextSpan(text: 'and '),
                            TextSpan(text: 'Privacy Policy ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            const TextSpan(text: 'of SEAPEDIA.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppButtonStyles.primary.copyWith(
                    backgroundColor: WidgetStateProperty.all(AppColors.secondary),
                  ),
                  onPressed: _agreeToTerms ? () {
                    Navigator.pop(context); // Kembali ke login setelah sukses simulasi
                  } : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Create Account', style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 16)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Builder Kecil untuk Input Field (Composition)
  Widget _buildInputField(String label, String hint, String subLabel, IconData icon, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon),
            ),
          ),
          const SizedBox(height: 4),
          Text(subLabel, style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}