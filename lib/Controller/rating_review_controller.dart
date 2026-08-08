import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service/review_service.dart';

class RatingReviewController extends GetxController {
  final RxDouble rating = 0.0.obs;
  final TextEditingController reviewController = TextEditingController();
  final RxBool isSubmitting = false.obs;

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }

  void setRating(double value) {
    rating.value = value;
  }

  /// Resets input fields and state after bottom sheet is dismissed or submitted
  void reset() {
    rating.value = 0.0;
    reviewController.clear();
    isSubmitting.value = false;
  }

  Future<void> submitReview({
    BuildContext? context,
    required String salonId,
    required String salonName,
    required String serviceName,
    void Function(double rating)? onSuccess,
  }) async {
    final reviewText = reviewController.text.trim();
    if (reviewText.isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter a brief review message.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isSubmitting.value = true;

    final submittedRating = rating.value;
    final result = await ReviewService.submitReview(
      salonId: salonId,
      salonName: salonName,
      serviceName: serviceName,
      ratings: submittedRating,
      review: reviewText,
    );

    isSubmitting.value = false;

    if (result == 'SUCCESS') {
      onSuccess?.call(submittedRating);
      reset();

      if (context != null && context.mounted) {
        Navigator.of(context).pop();
      } else {
        Get.back();
      }

      Get.snackbar(
        'Success',
        'Thank you! Your rating and review have been submitted.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF05352F),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } else if (result == 'ALREADY_SUBMITTED') {
      Get.snackbar(
        'Already Submitted',
        'You have already submitted a review for this service.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFC53030),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to submit review. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
  }
}
