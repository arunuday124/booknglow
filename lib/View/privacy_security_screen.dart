import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  static const _deepGreen = Color(0xFF05352F);
  static const _gold = Color(0xFF9E7E45);
  static const _cream = Color(0xFFFAF9F5);
  static const _cardBg = Colors.white;
  static const _mutedTeal = Color(0xFF7A8D87);
  static const _dangerRed = Color(0xFFD43A3A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _deepGreen,
          ),
        ),
        title: Text(
          "Privacy & Security",
          style: GoogleFonts.playfairDisplay(
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _deepGreen,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Legal & Data Rights Header
            _buildSectionHeader("Legal & Data Rights"),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.02),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildActionTile(
                    icon: Icons.privacy_tip_outlined,
                    title: "Privacy Policy",
                    subtitle: "Read how we collect & safeguard your data",
                    onTap: () => _showPrivacyPolicyBottomSheet(context),
                  ),
                  const Divider(height: 1, color: Color(0xFFFAF9F5)),
                  _buildActionTile(
                    icon: Icons.gavel_rounded,
                    title: "Terms of Service",
                    subtitle: "Platform usage terms & booking policies",
                    onTap: () => _showTermsBottomSheet(context),
                  ),
                  const Divider(height: 1, color: Color(0xFFFAF9F5)),
                  _buildActionTile(
                    icon: Icons.download_for_offline_outlined,
                    title: "Request Data Copy",
                    subtitle: "Export a copy of your account & appointment logs",
                    onTap: () {
                      _showToast(
                        "Data Export Requested",
                        "We are preparing your data copy. An email link will be sent shortly.",
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Delete Account Danger Zone
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4F4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _dangerRed.withAlpha(80)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _dangerRed.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: _dangerRed,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Delete BookN'Glow Account",
                          style: GoogleFonts.plusJakartaSans(
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _dangerRed,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Permanently erase your account, history & points",
                          style: GoogleFonts.plusJakartaSans(
                            textStyle: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF9E3636),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _showDeleteAccountDialog,
                    child: Text(
                      "Delete",
                      style: GoogleFonts.plusJakartaSans(
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _dangerRed,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _deepGreen,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: _cream,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: _deepGreen, size: 20),
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
      subtitle: Text(
        subtitle,
        style: GoogleFonts.plusJakartaSans(
          textStyle: const TextStyle(
            fontSize: 11.5,
            color: _mutedTeal,
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Text(
              trailingText,
              style: GoogleFonts.plusJakartaSans(
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _gold,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          const Icon(
            Icons.chevron_right,
            color: _mutedTeal,
            size: 18,
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
    );
  }

  void _showToast(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _deepGreen,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
    );
  }

  void _showPrivacyPolicyBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Privacy Policy",
                  style: GoogleFonts.playfairDisplay(
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _deepGreen,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPolicySection(
                      "1. Information We Collect",
                      "BookN'Glow collects personal details such as your name, contact information, email address, and booking history to provide personalized salon services and notifications.",
                    ),
                    _buildPolicySection(
                      "2. How We Protect Your Data",
                      "All communication between BookN'Glow app and our servers is encrypted using 256-bit SSL encryption. We never share your payment details or passwords with salons or third parties.",
                    ),
                    _buildPolicySection(
                      "3. Salon Partner Data Sharing",
                      "When you book an appointment, only necessary information (name, contact number, and requested services) is shared with the specific salon partner.",
                    ),
                    _buildPolicySection(
                      "4. Your Privacy Choices",
                      "You maintain full control over your data. You may request data deletion at any time through these privacy controls.",
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showTermsBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Terms of Service",
                  style: GoogleFonts.playfairDisplay(
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _deepGreen,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPolicySection(
                      "1. Booking Agreement",
                      "By scheduling an appointment through BookN'Glow, you agree to arrive at the designated salon on time. Cancellations should be made at least 2 hours prior.",
                    ),
                    _buildPolicySection(
                      "2. Service Quality & Disputes",
                      "Salon partners are independent service providers. BookN'Glow guarantees platform safety and resolution assistance for any booking disputes.",
                    ),
                    _buildPolicySection(
                      "3. Fair Use & Reviews",
                      "Reviews posted on BookN'Glow must represent genuine user experiences. Ratings containing hate speech or abusive language will be removed.",
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildPolicySection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _deepGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: _mutedTeal,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Delete Account?",
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: _dangerRed,
          ),
        ),
        content: Text(
          "Are you sure you want to permanently delete your BookN'Glow account? All booking records, saved addresses, and reward points will be permanently deleted.",
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _deepGreen),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: GoogleFonts.plusJakartaSans(color: _mutedTeal),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _dangerRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Get.back();
              _showToast(
                "Account Deletion Initiated",
                "Your request has been logged. We will send confirmation via email.",
              );
            },
            child: Text(
              "Confirm Delete",
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
