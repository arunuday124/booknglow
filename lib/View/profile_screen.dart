import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'login.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F5),
        elevation: 0,
        title: Text(
          "My Profile",
          style: GoogleFonts.playfairDisplay(
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF05352F),
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Profile Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar with golden border decoration
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFE8D5AF),
                            Color(0xFF9E7E45),
                          ],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: const Color(0xFFFAF9F5),
                        child: CircleAvatar(
                          radius: 43,
                          backgroundColor: const Color(0xFF05352F),
                          child: Text(
                            "VS",
                            style: GoogleFonts.playfairDisplay(
                              textStyle: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE8D5AF),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // User details
                    Text(
                      "Victoria Sterling",
                      style: GoogleFonts.playfairDisplay(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF05352F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "victoria.sterling@elegance.com",
                      style: GoogleFonts.plusJakartaSans(
                        textStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7A8D87),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Gold Tier Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF6EE),
                        border: Border.all(
                          color: const Color(0xFFE8D5AF),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.workspace_premium_outlined,
                            size: 14,
                            color: Color(0xFF9E7E45),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "GOLD TIER MEMBER",
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9E7E45),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Menu Options Title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Account Settings",
                  style: GoogleFonts.playfairDisplay(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF05352F),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Menu Options List
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildOption(
                      icon: Icons.person_outline,
                      title: "Personal Information",
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: Color(0xFFFAF9F5)),
                    _buildOption(
                      icon: Icons.payment_outlined,
                      title: "Payment Methods",
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: Color(0xFFFAF9F5)),
                    _buildOption(
                      icon: Icons.notifications_none_outlined,
                      title: "Notifications",
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: Color(0xFFFAF9F5)),
                    _buildOption(
                      icon: Icons.shield_outlined,
                      title: "Privacy & Security",
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: Color(0xFFFAF9F5)),
                    _buildOption(
                      icon: Icons.help_outline_outlined,
                      title: "Help & Support",
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Sign Out Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    // Show a quick logout snackbar
                    Get.snackbar(
                      'Signed Out',
                      'You have logged out successfully.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF05352F),
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 8,
                    );
                    // Navigate back to Login and clear history
                    Get.offAll(() => const Login());
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFD43A3A),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    "SIGN OUT",
                    style: GoogleFonts.plusJakartaSans(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD43A3A),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF05352F),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E3A),
          ),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF7A8D87),
        size: 18,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
    );
  }
}
