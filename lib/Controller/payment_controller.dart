import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentController extends GetxController {
  // Selected payment method: 0 = Credit/Debit, 1 = UPI, 2 = Cash on Delivery
  final RxInt selectedPaymentMethod = 0.obs;

  // Coupon state
  final TextEditingController couponController = TextEditingController();
  final RxnString appliedCoupon = RxnString();
  final RxDouble discountAmount = 0.0.obs;
  final RxnString couponError = RxnString();

  final double deliveryFee = 0.0;

  double calculateFinalTotal(double itemTotal) {
    final calculated = itemTotal - discountAmount.value;
    return calculated < 0 ? 0 : calculated;
  }

  String get paymentMethodName {
    switch (selectedPaymentMethod.value) {
      case 0:
        return "Credit / Debit Card";
      case 1:
        return "UPI (GPay/PhonePe/Paytm)";
      case 2:
        return "Cash on Delivery";
      default:
        return "Card";
    }
  }

  String get paymentMethodType {
    switch (selectedPaymentMethod.value) {
      case 0:
        return "card";
      case 1:
        return "upi";
      case 2:
        return "cash";
      default:
        return "card";
    }
  }

  void applyCoupon(String code, double itemTotal) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      couponError.value = 'Please enter a coupon code';
      return;
    }

    if (cleanCode == 'GLOW20') {
      appliedCoupon.value = 'GLOW20';
      discountAmount.value = itemTotal * 0.20;
      couponError.value = null;
      Get.snackbar(
        'Coupon Applied!',
        '20% discount applied successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF05352F),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    } else if (cleanCode == 'WELCOME50') {
      appliedCoupon.value = 'WELCOME50';
      discountAmount.value = 50.0;
      couponError.value = null;
      Get.snackbar(
        'Coupon Applied!',
        '₹50 flat discount applied successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF05352F),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    } else if (cleanCode == 'BEAUTY100') {
      appliedCoupon.value = 'BEAUTY100';
      discountAmount.value = 100.0;
      couponError.value = null;
      Get.snackbar(
        'Coupon Applied!',
        '₹100 discount applied successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF05352F),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    } else {
      couponError.value = 'Invalid coupon code';
    }
  }

  void removeCoupon() {
    appliedCoupon.value = null;
    discountAmount.value = 0.0;
    couponController.clear();
    couponError.value = null;
  }

  @override
  void onClose() {
    couponController.dispose();
    super.onClose();
  }
}
