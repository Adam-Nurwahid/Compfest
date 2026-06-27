import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/reusable_widgets.dart';
import '../../data/dummy/app_state.dart';

class AppReviewFormPage extends StatefulWidget {
  const AppReviewFormPage({super.key});

  @override
  State<AppReviewFormPage> createState() => _AppReviewFormPageState();
}

class _AppReviewFormPageState extends State<AppReviewFormPage> {
  final _nameController = TextEditingController();
  final _commentController = TextEditingController();
  double _rating = 5.0;

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(duration: const Duration(seconds: 2), 
          content: Text('Komentar review tidak boleh kosong!'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    appState.addAppReview(
      _nameController.text.trim(),
      _rating,
      _commentController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(duration: const Duration(seconds: 2), 
        content: Text('Terima kasih! Review Anda telah disimpan.'),
        backgroundColor: AppColors.primary,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Tulis Review Aplikasi',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bagikan Pengalaman Anda',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Review Anda akan tampil langsung di halaman beranda aplikasi SEAPEDIA.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 28),

              // Rating Selection
              Text(
                'Rating Aplikasi',
                style: AppTextStyles.label.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RatingStars(
                      rating: _rating,
                      size: 36,
                      interactive: true,
                      onRatingChanged: (newRating) {
                        setState(() {
                          _rating = newRating;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${_rating.toInt()} / 5 Bintang',
                      style: AppTextStyles.label.copyWith(fontSize: 16, color: AppColors.secondary),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Name input
              AppTextField(
                label: 'Nama Pengulas',
                hintText: 'Masukkan nama Anda (kosongkan untuk Anonim)',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.neutral),
              ),
              const SizedBox(height: 24),

              // Comment input
              AppTextField(
                label: 'Komentar / Ulasan',
                hintText: 'Ceritakan pengalaman Anda menggunakan aplikasi SEAPEDIA...',
                controller: _commentController,
                maxLines: 4,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 56.0),
                  child: Icon(Icons.chat_bubble_outline_rounded, color: AppColors.neutral),
                ),
              ),
              const SizedBox(height: 40),

              // Submit Button
              AppButton(
                text: 'Kirim Ulasan',
                onPressed: _submitReview,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
