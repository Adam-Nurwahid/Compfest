import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../data/models/models.dart';

/// Repository responsible for reading and writing app reviews
/// to and from the public.app_reviews Supabase table.
class AppReviewRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  /// Fetches all app reviews ordered by newest first.
  /// Returns an empty list on any error to keep the UI non-fatal.
  Future<List<AppReview>> fetchAllReviews() async {
    try {
      final response = await _supabaseClient
          .from('app_reviews')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((row) {
        return AppReview(
          id: row['id']?.toString() ?? '',
          name: row['reviewer_name'] as String? ?? 'Anonim',
          rating: (row['rating'] as num?)?.toDouble() ?? 5.0,
          comment: row['comment'] as String? ?? '',
          date: row['created_at'] != null
              ? DateTime.parse(row['created_at'] as String)
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Error fetchAllReviews: $e');
      return [];
    }
  }

  /// Inserts a new app review into public.app_reviews.
  /// Returns the created [AppReview] on success, or null on failure.
  Future<AppReview?> insertReview({
    required String reviewerName,
    required double rating,
    required String comment,
  }) async {
    try {
      final response = await _supabaseClient
          .from('app_reviews')
          .insert({
            'reviewer_name': reviewerName.isEmpty ? 'Anonim' : reviewerName,
            'rating': rating,
            'comment': comment,
          })
          .select()
          .single();

      return AppReview(
        id: response['id']?.toString() ?? '',
        name: response['reviewer_name'] as String? ?? 'Anonim',
        rating: (response['rating'] as num?)?.toDouble() ?? rating,
        comment: response['comment'] as String? ?? comment,
        date: response['created_at'] != null
            ? DateTime.parse(response['created_at'] as String)
            : DateTime.now(),
      );
    } catch (e) {
      print('Error insertReview: $e');
      return null;
    }
  }
}
