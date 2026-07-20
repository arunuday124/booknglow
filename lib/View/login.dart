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

                      const SizedBox(height: 36),

                      // Email / Phone Field
                      Text(
                        "EMAIL",
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4C6B64),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF2C3E3A),
                          ),
                        ),
                        decoration: InputDecoration(
                          hintText: "e.g. elegance@lifestyle.com",
                          hintStyle: GoogleFonts.plusJakartaSans(
                            textStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          isDense: true,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.2,
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF05352F),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Password Field Header Row (Label + Forgot Password)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "PASSWORD",
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4C6B64),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: controller.forgotPassword,
                            child: Text(
                              "Forgot Password?",
                              style: GoogleFonts.plusJakartaSans(
                                textStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF9E7E45), // Warm luxury gold
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Obscure password input
                      Obx(
                        () => TextFormField(
                          controller: controller.passwordController,
                          obscureText: controller.isObscure.value,
                          style: GoogleFonts.plusJakartaSans(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF2C3E3A),
                            ),
                          ),
                          decoration: InputDecoration(
                            hintText: "• • • • • • • •",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                              letterSpacing: 2.0,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            isDense: true,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isObscure.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey.shade400,
                                size: 18,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.2,
                              ),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF05352F),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: Obx(() {
                          return ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF05352F,
                              ), // Dark Teal
                              disabledBackgroundColor: const Color.fromRGBO(
                                5,
                                53,
                                47,
                                0.7,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              elevation: 0,
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFE8D5AF),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "SIGN IN",
                                    style: GoogleFonts.plusJakartaSans(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE8D5AF), // Gold color
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                          );
                        }),
                      ),

                      const SizedBox(height: 32),

                      // Divider OR CONTINUE WITH
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade200,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              "OR CONTINUE WITH",
                              style: GoogleFonts.plusJakartaSans(
                                textStyle: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade400,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade200,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Social Media Login Buttons
                      Row(
                        children: [
                          // Google login button
                          Expanded(
                            child: InkWell(
                              onTap: controller.loginWithGoogle,
                              borderRadius: BorderRadius.circular(8.0),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                alignment: Alignment.center,
                                child: Image.asset(
                                  "assets/images/google.png",
                                  height: 22,
                                  width: 22,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Apple login button
                          Expanded(
                            child: InkWell(
                              onTap: controller.loginWithApple,
                              borderRadius: BorderRadius.circular(8.0),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                alignment: Alignment.center,
                                child: Image.asset(
                                  "assets/images/apple.png",
                                  height: 22,
                                  width: 22,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
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
