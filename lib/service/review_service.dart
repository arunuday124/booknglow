import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'user_service.dart';
import 'salon_service.dart';

/// Handles Firestore operations for the `reviews` collection and updates salon rating statistics.
class ReviewService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Checks if the current logged in user has already submitted a review for a specific salon service.
  static Future<bool> hasUserReviewedService({
    required String salonId,
    required String serviceName,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || userId.isEmpty) return false;

    try {
      final querySnapshot = await _db
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .where('salonId', isEqualTo: salonId)
          .where('serviceName', isEqualTo: serviceName)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('❌ [ReviewService] Error checking existing review: $e');
      return false;
    }
  }

  /// Submits a user review for a salon service and updates the salon's average rating and total review count.
  /// Returns status string: 'SUCCESS', 'ALREADY_SUBMITTED', or 'ERROR'.
  static Future<String> submitReview({
    required String salonId,
    required String salonName,
    required String serviceName,
    required double ratings,
    required String review,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final cachedUser = UserService.cachedUser;

      final userId = user?.uid ?? '';
      if (userId.isEmpty) {
        return 'ERROR';
      }

      // Check if user has already submitted a review for this salon service
      final alreadyReviewed = await hasUserReviewedService(
        salonId: salonId,
        serviceName: serviceName,
      );

      if (alreadyReviewed) {
        debugPrint('⚠️ [ReviewService] User $userId has already submitted a review for service: $serviceName at salon: $salonId');
        return 'ALREADY_SUBMITTED';
      }

      final userName = (cachedUser?.name.isNotEmpty == true)
          ? cachedUser!.name
          : (user?.displayName?.isNotEmpty == true
                ? user!.displayName!
                : 'Guest User');

      final reviewData = <String, dynamic>{
        'userName': userName,
        'salonName': salonName,
        'serviceName': serviceName,
        'ratings': ratings,
        'userId': userId,
        'salonId': salonId,
        'review': review,
        'reviewtime': Timestamp.now(),
      };

      debugPrint('🔥 [ReviewService] Writing review to Firestore: $reviewData');
      await _db.collection('reviews').add(reviewData);

      // Recalculate average rating and total reviews for the salon if salonId is available
      if (salonId.isNotEmpty) {
        final querySnapshot = await _db
            .collection('reviews')
            .where('salonId', isEqualTo: salonId)
            .get();

        final totalReviews = querySnapshot.docs.length;
        double sum = 0.0;
        for (var doc in querySnapshot.docs) {
          final r = doc.data()['ratings'];
          if (r is num) {
            sum += r.toDouble();
          }
        }

        final double avgRating = totalReviews > 0
            ? double.parse((sum / totalReviews).toStringAsFixed(1))
            : 0.0;

        debugPrint(
          '🔥 [ReviewService] Updating salon $salonId with ratings: $avgRating, reviews: $totalReviews',
        );

        await _db.collection('salons').doc(salonId).update({
          'ratings': avgRating,
          'reviews': totalReviews,
        });

        // Clear cached salons so screens reload fresh rating data
        SalonService.clearCache();
      }

      return 'SUCCESS';
    } catch (e, stack) {
      debugPrint('❌ [ReviewService] ERROR submitting review: $e\n$stack');
      return 'ERROR';
    }
  }
}
