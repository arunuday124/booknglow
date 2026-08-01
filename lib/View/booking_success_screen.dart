import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../Controller/navigation_controller.dart';
import 'main_navigation_screen.dart';

class BookingSuccessScreen extends StatelessWidget {
  final String salonName;
  final String date;
  final String time;
  final String services;
  final double totalAmount;
  final String paymentMethod;
  final String address;

  const BookingSuccessScreen({
    super.key,
    required this.salonName,
    required this.date,
    required this.time,
    required this.services,
    required this.totalAmount,
    required this.paymentMethod,
    required this.address,
  });

  void _goToHome() {
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().changeTab(0);
    }
    Get.offAll(() => const MainNavigationScreen());
  }

  void _goToBookings() {
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().changeTab(1);
    }
    Get.offAll(() => const MainNavigationScreen());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goToHome();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F5),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                const Spacer(flex: 1),

                // Lottie Success Animation in a loop
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    child: Lottie.asset(
                      'assets/videos/success.json',
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                      repeat: true,
                      animate: true,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 100,
                            color: Color(0xFF05352F),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Success Title
                Text(
                  "Booking Confirmed!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    textStyle: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF05352F),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Your appointment has been successfully scheduled",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7A8D87),
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Order Details Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF05352F).withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFF05352F).withOpacity(0.06),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        icon: Icons.storefront_rounded,
                        label: "Salon",
                        value: salonName,
                        isBold: true,
                      ),
                      const Divider(height: 24, color: Color(0xFFF0EFEA)),
                      _buildDetailRow(
                        icon: Icons.spa_outlined,
                        label: "Service(s)",
                        value: services,
                      ),
                      const Divider(height: 24, color: Color(0xFFF0EFEA)),
                      _buildDetailRow(
                        icon: Icons.calendar_today_rounded,
                        label: "Date & Time",
                        value: "$date at $time",
                      ),
                      const Divider(height: 24, color: Color(0xFFF0EFEA)),
                      _buildDetailRow(
                        icon: Icons.payment_rounded,
                        label: "Payment",
                        value:
                            "${paymentMethod.toLowerCase().contains('cash') ? 'Cash' : paymentMethod} (₹${totalAmount.toStringAsFixed(2)})",
                        valueColor: const Color(0xFF9E7E45),
                        isBold: true,
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Action Buttons at the bottom
                Column(
                  children: [
                    // Button 1: Go to Home
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF05352F),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _goToHome,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.home_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Go to Home",
                              style: GoogleFonts.plusJakartaSans(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Button 2: Go to the Booking Page
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF05352F),
                          side: const BorderSide(
                            color: Color(0xFF05352F),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _goToBookings,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_month_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Go to the Booking Page",
                              style: GoogleFonts.plusJakartaSans(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF9E7E45)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  textStyle: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A8D87),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  textStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                    color: valueColor ?? const Color(0xFF05352F),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
