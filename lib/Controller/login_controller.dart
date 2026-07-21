import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../View/main_navigation_screen.dart';

class LoginController extends GetxController {
  // Text input controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable states
  final RxBool isObscure = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;

  // Firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Toggle password visibility
  void togglePasswordVisibility() {
    isObscure.value = !isObscure.value;
  }

  // Email / Password sign-in method
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter your email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Validation Error',
        'Please enter a valid email address',
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

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
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
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String message = 'An error occurred. Please try again.';
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        message = 'Invalid email or password.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is badly formatted.';
      } else if (e.code == 'user-disabled') {
        message = 'This user account has been disabled.';
      } else {
        message = e.message ?? message;
      }
      Get.snackbar(
        'Authentication Failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    }
  }

  // Google sign-in action (google_sign_in v7 API)
  Future<void> loginWithGoogle() async {
    isGoogleLoading.value = true;

    try {
      // v7: Use the singleton instance and initialize before use
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();

      // Trigger the native account picker
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      // Get the ID token from the authenticated account
      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      // Create a Firebase credential — idToken is sufficient for Firebase Auth
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      await _auth.signInWithCredential(credential);

      isGoogleLoading.value = false;

      Get.snackbar(
        'Welcome',
        'Signed in with Google successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0A3932),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );

      Get.offAll(() => const MainNavigationScreen());
    } on GoogleSignInException catch (e) {
      isGoogleLoading.value = false;
      // User cancelled or sign-in was aborted — don't show error for cancellation
      if (e.code != GoogleSignInExceptionCode.canceled) {
        Get.snackbar(
          'Google Sign-In Failed',
          e.description ?? 'An error occurred. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );
      }
    } on FirebaseAuthException catch (e) {
      isGoogleLoading.value = false;
      Get.snackbar(
        'Google Sign-In Failed',
        e.message ?? 'An error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } catch (e) {
      isGoogleLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to sign in with Google. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    }
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
