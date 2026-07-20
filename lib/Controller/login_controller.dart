import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../View/main_navigation_screen.dart';

class LoginController extends GetxController {
  // Text input controllers
  final emailController = TextEditingController(text: 'victoria.sterling@elegance.com');
  final passwordController = TextEditingController(text: 'password123');

  // Observable states
  final RxBool isObscure = true.obs;
  final RxBool isLoading = false.obs;

  // Toggle password visibility
  void togglePasswordVisibility() {
    isObscure.value = !isObscure.value;
  }

  // Email / Password sign-in method
  void login() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter your email or phone number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      return;
    }

    if (password.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter your password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      return;
    }

    isLoading.value = true;

    // Simulate login API call
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      Get.snackbar(
        'Welcome Back',
        'You have successfully signed in!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0A3932), // Forest Green
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      Get.offAll(() => const MainNavigationScreen());
    });
  }

  // Google sign-in action
  void loginWithGoogle() {
    Get.snackbar(
      'Google Authentication',
      'Connecting to Google...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
    Future.delayed(const Duration(seconds: 1), () {
      Get.offAll(() => const MainNavigationScreen());
    });
  }

  // Apple sign-in action
  void loginWithApple() {
    Get.snackbar(
      'Apple Authentication',
      'Connecting to Apple...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
    Future.delayed(const Duration(seconds: 1), () {
      Get.offAll(() => const MainNavigationScreen());
    });
  }

  // Forgot password action
  void forgotPassword() {
    Get.snackbar(
      'Reset Password',
      'Redirection to password recovery system...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF9E7E45), // Soft Gold
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // Sign up transition action
  void signUp() {
    Get.snackbar(
      'Register',
      'Redirecting to registration page...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0A3932),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  @override
  void onClose() {
    // Dispose text field controllers to prevent memory leaks
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
