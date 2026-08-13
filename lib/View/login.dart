import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Controller/login_controller.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the controller
    final controller = Get.put(LoginController());

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFAF9F5), // Premium light alabaster
              Color(0xFFF5EFE0), // Elegant soft cream
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                // Brand Name
                Text(
                  "Book'N'Glow",
                  style: GoogleFonts.playfairDisplay(
                    textStyle: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF05352F), // Elegant deep forest green
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Brand Subtitle
                Text(
                  "Beauty, Effortlessly. ✨",
                  style: GoogleFonts.montserrat(
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7A8D87), // Muted teal-gray
                      letterSpacing: 3.5,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Card Container
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome header
                      Center(
                        child: Column(
                          children: [
                            Text(
                              "Welcome Back",
                              style: GoogleFonts.playfairDisplay(
                                textStyle: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF05352F),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Elevate your wellness journey today.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6E7E7A),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Salon / Barber Illustration
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.asset(
                          "assets/images/login_illustration.png",
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Google login button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: Obx(
                          () => InkWell(
                            onTap: controller.isGoogleLoading.value
                                ? null
                                : controller.loginWithGoogle,
                            borderRadius: BorderRadius.circular(10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1.2,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              alignment: Alignment.center,
                              child: controller.isGoogleLoading.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF05352F),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          "assets/images/google.png",
                                          height: 22,
                                          width: 22,
                                          fit: BoxFit.contain,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          "Continue with Google",
                                          style: GoogleFonts.plusJakartaSans(
                                            textStyle: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF05352F),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Apple login button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: InkWell(
                          onTap: () {
                            Get.snackbar(
                              'Coming Soon',
                              'Apple Sign-In is coming soon!',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFF05352F),
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12,
                              duration: const Duration(seconds: 2),
                            );
                          },
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/apple.png",
                                  height: 22,
                                  width: 22,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Continue with Apple",
                                  style: GoogleFonts.plusJakartaSans(
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF05352F),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Sign Up Footer
                      // Center(
                      //   child: GestureDetector(
                      //     onTap: controller.signUp,
                      //     child: RichText(
                      //       text: TextSpan(
                      //         text: "Don't have an account? ",
                      //         style: GoogleFonts.plusJakartaSans(
                      //           textStyle: const TextStyle(
                      //             color: Color(0xFF6E7E7A),
                      //             fontSize: 14,
                      //           ),
                      //         ),
                      //         children: [
                      //           TextSpan(
                      //             text: "Sign Up",
                      //             style: GoogleFonts.plusJakartaSans(
                      //               textStyle: const TextStyle(
                      //                 color: Color(0xFF9E7E45),
                      //                 fontWeight: FontWeight.bold,
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
