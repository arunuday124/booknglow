import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Controller/rating_review_controller.dart';

class RatingReviewBottomSheet extends StatelessWidget {
  final String salonId;
  final String salonName;
  final String serviceName;
  final String? bookingId;
  final void Function(double rating, String review)? onSuccess;

  const RatingReviewBottomSheet({
    super.key,
    required this.salonId,
    required this.salonName,
    required this.serviceName,
    this.bookingId,
    this.onSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    required String salonId,
    required String salonName,
    required String serviceName,
    String? bookingId,
    void Function(double rating, String review)? onSuccess,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: RatingReviewBottomSheet(
          salonId: salonId,
          salonName: salonName,
          serviceName: serviceName,
          bookingId: bookingId,
          onSuccess: onSuccess,
        ),
      ),
    );

    if (Get.isRegistered<RatingReviewController>()) {
      Get.find<RatingReviewController>().reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RatingReviewController());

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAF9F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Title & Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Rate & Review",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF05352F),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Color(0xFF7A8D87)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Salon & Service Info
          Text(
            salonName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E3A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            serviceName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF7A8D87),
            ),
          ),
          const SizedBox(height: 20),

          // Interactive Star Rating Selector (Reactive with Obx)
          Center(
            child: Column(
              children: [
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      final isSelected = starValue <= controller.rating.value;
                      return IconButton(
                        onPressed: () =>
                            controller.setRating(starValue.toDouble()),
                        icon: Icon(
                          isSelected
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: isSelected
                              ? const Color(0xFFFFB800)
                              : const Color(0xFFCBD5E1),
                          size: 36,
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    '${controller.rating.value.toInt()} / 5 Stars',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF05352F),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Review Input Field
          Text(
            "Your Review",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF05352F),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller.reviewController,
            maxLines: 4,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF2C3E3A),
            ),
            decoration: InputDecoration(
              hintText: "Share your feedback and experience with this salon...",
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF94A3B8),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF05352F),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit Action Button (Reactive with Obx)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () => controller.submitReview(
                          context: context,
                          salonId: salonId,
                          salonName: salonName,
                          serviceName: serviceName,
                          bookingId: bookingId,
                          onSuccess: onSuccess,
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF05352F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        "Submit Review",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
