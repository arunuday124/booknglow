import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  static const _deepGreen = Color(0xFF05352F);
  static const _gold = Color(0xFF9E7E45);
  static const _lightGold = Color(0xFFE8D5AF);
  static const _goldBg = Color(0xFFFAF6EE);
  static const _cream = Color(0xFFFAF9F5);
  static const _cardBg = Colors.white;
  static const _mutedTeal = Color(0xFF7A8D87);

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
          "Payment Methods",
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
            // Coming Soon Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _lightGold.withAlpha(128), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(5, 53, 47, 0.05),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Icon container with gold gradient
                  Container(
                    width: 76,
                    height: 76,
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [_lightGold, _gold],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: _deepGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 36,
                        color: _lightGold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Coming Soon Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _goldBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _lightGold),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: _gold,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "COMING SOON",
                          style: GoogleFonts.plusJakartaSans(
                            textStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _gold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title & Description
                  Text(
                    "Seamless Payments Experience",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      textStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _deepGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "We are crafting an ultra-secure and effortless payment vault for your saved credit/debit cards, UPI apps, digital wallets, and exclusive BookN'Glow beauty rewards.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      textStyle: const TextStyle(
                        fontSize: 13,
                        color: _mutedTeal,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Section Title: What's Coming Next
            Text(
              "What to Expect",
              style: GoogleFonts.playfairDisplay(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _deepGreen,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Upcoming Payment Method Items
            _buildUpcomingFeatureCard(
              icon: Icons.credit_card_rounded,
              title: "Saved Credit & Debit Cards",
              subtitle: "Save Visa, Mastercard, Amex with 1-click encrypted checkout.",
              tag: "Encrypted",
            ),
            const SizedBox(height: 12),
            _buildUpcomingFeatureCard(
              icon: Icons.qr_code_scanner_rounded,
              title: "UPI & Instant Payment",
              subtitle: "Pay seamlessly with GPay, PhonePe, Paytm, or BHIM UPI.",
              tag: "Instant",
            ),
            const SizedBox(height: 12),
            _buildUpcomingFeatureCard(
              icon: Icons.card_giftcard_rounded,
              title: "BookN'Glow Wallet & Loyalty Points",
              subtitle: "Earn cashback on every salon visit & redeem instant discounts.",
              tag: "Rewards",
            ),
            const SizedBox(height: 12),
            _buildUpcomingFeatureCard(
              icon: Icons.storefront_rounded,
              title: "Pay at Salon",
              subtitle: "Book now and pay directly at the salon via Cash or POS Machine.",
              tag: "Flexible",
            ),

            const SizedBox(height: 32),

            // Notify Me Button
            InkWell(
              onTap: () {
                Get.snackbar(
                  'Notifications Enabled',
                  "We'll notify you as soon as payment management is live!",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: _deepGreen,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 10,
                  duration: const Duration(seconds: 3),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _deepGreen,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(5, 53, 47, 0.2),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Get Notified on Launch",
                            style: GoogleFonts.playfairDisplay(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Be the first to unlock early payment rewards",
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withAlpha(204),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.notifications_active_outlined,
                      color: _lightGold,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String tag,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.02),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: _goldBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _gold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _deepGreen,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _cream,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _mutedTeal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    textStyle: const TextStyle(
                      fontSize: 12,
                      color: _mutedTeal,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
