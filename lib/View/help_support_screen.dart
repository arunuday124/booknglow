import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _deepGreen = Color(0xFF05352F);
  static const _gold = Color(0xFF9E7E45);
  static const _lightGold = Color(0xFFE8D5AF);
  static const _goldBg = Color(0xFFFAF6EE);
  static const _cream = Color(0xFFFAF9F5);
  static const _cardBg = Colors.white;
  static const _mutedTeal = Color(0xFF7A8D87);

  static const List<Map<String, String>> _faqs = [
    {
      'question': 'How do I reschedule or cancel a booking?',
      'answer':
          'Go to the "Bookings" tab from the bottom navigation bar. Select your active booking, tap "Manage Appointment", and choose either "Reschedule Date & Time" or "Cancel Booking". Cancellations made at least 2 hours before the slot are free of charge.',
      'category': 'Bookings',
    },
    {
      'question': 'What happens if I arrive late for my appointment?',
      'answer':
          'Salon partners hold your slot for up to 15 minutes. If you are running late, you can contact the salon directly via the phone icon on your active booking screen or inform our support team.',
      'category': 'Bookings',
    },
    {
      'question': 'Are the service prices the same as the salon rate card?',
      'answer':
          'Yes! All prices on BookN\'Glow are identical to or lower than the official salon rate cards. You also earn loyalty points and access app-exclusive promotional discounts.',
      'category': 'Pricing & Payments',
    },
    {
      'question': 'How do I submit a rating and review for a salon?',
      'answer':
          'Once your salon appointment is completed, a "Rate & Review" prompt will appear in your Bookings screen. You can rate cleanliness, service quality, staff behavior, and upload photo feedback.',
      'category': 'Reviews',
    },
    {
      'question': 'Can I request a specific hair stylist or beauty artist?',
      'answer':
          'Yes, during service selection or in the booking notes section, you can specify your preferred stylist or artist.',
      'category': 'Services',
    },
    {
      'question': 'Is my payment & personal information secure?',
      'answer':
          'Absolutely. BookN\'Glow uses high-grade 256-bit encryption for all user data. Your payment information is processed through PCI-DSS compliant payment gateways.',
      'category': 'Security',
    },
  ];

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
          "Help & Support",
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
            // Search Input Header (Static UI preview)
            Container(
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.03),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                readOnly: true,
                onTap: () {
                  Get.snackbar(
                    "Search Support",
                    "Browse frequently asked questions below or contact our concierge.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: _deepGreen,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                  );
                },
                decoration: InputDecoration(
                  hintText: "Search questions, topics, bookings...",
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: _mutedTeal,
                    fontSize: 13.5,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, color: _deepGreen),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Contact Options Header
            Text(
              "Need Quick Help?",
              style: GoogleFonts.playfairDisplay(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _deepGreen,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.headset_mic_rounded,
                    title: "24/7 Concierge",
                    subtitle: "Call support",
                    onTap: _showCallSupportDialog,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: "Live Chat",
                    subtitle: "Instant response",
                    onTap: () => _showLiveChatBottomSheet(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.mail_outline_rounded,
                    title: "Email Us",
                    subtitle: "Send ticket",
                    onTap: () => _showFeedbackBottomSheet(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // FAQs Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Frequently Asked Questions",
                  style: GoogleFonts.playfairDisplay(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _deepGreen,
                    ),
                  ),
                ),
                Text(
                  "${_faqs.length} topics",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: _mutedTeal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

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
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _faqs.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: Color(0xFFFAF9F5)),
                itemBuilder: (context, index) {
                  final item = _faqs[index];
                  return Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      childrenPadding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _goldBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.help_outline_rounded,
                          color: _gold,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        item['question']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: _deepGreen,
                        ),
                      ),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item['answer']!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              color: const Color(0xFF4C6B64),
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Still Have Questions Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_deepGreen, Color(0xFF0A4D44)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(5, 53, 47, 0.2),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _gold.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: _lightGold,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Still Need Assistance?",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Our dedicated concierge team is available to assist you with booking modifications, special requests, or feedback.",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.white.withAlpha(200),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => _showFeedbackBottomSheet(context),
                      child: Text(
                        "Contact Support Concierge",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: _goldBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _gold, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _deepGreen,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                color: _mutedTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCallSupportDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.phone_in_talk_rounded, color: _gold),
            const SizedBox(width: 10),
            Text(
              "Call Support",
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                color: _deepGreen,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Speak with our 24/7 BookN'Glow luxury concierge team.",
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _deepGreen),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cream,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _lightGold),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "+1 (800) 555-GLOW",
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      color: _deepGreen,
                      fontSize: 14,
                    ),
                  ),
                  const Icon(Icons.content_copy_rounded, size: 18, color: _mutedTeal),
                ],
              ),
            ),
          ],
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
              backgroundColor: _deepGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Get.back();
              Get.snackbar(
                "Connecting Call",
                "Dialing BookN'Glow Concierge Support...",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: _deepGreen,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
              );
            },
            child: Text(
              "Call Now",
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

  void _showLiveChatBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: _goldBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.headset_mic_rounded, color: _gold, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "BookN'Glow Support Assistant",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _deepGreen,
                      ),
                    ),
                    Text(
                      "Online • Typically replies instantly",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildChatMessage(
                    context: context,
                    isUser: false,
                    text:
                        "Hello! Welcome to BookN'Glow Concierge Support. How can I help you today?",
                    time: "Just now",
                  ),
                  _buildChatMessage(
                    context: context,
                    isUser: true,
                    text: "Hi, I want to check my upcoming appointment status.",
                    time: "Just now",
                  ),
                  _buildChatMessage(
                    context: context,
                    isUser: false,
                    text:
                        "Certainly! I can see your upcoming booking at 'Luxe Hair & Spa' for tomorrow. Your slot is confirmed!",
                    time: "Just now",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: () {
                      Get.snackbar(
                        "Chat Support",
                        "Our live agent is ready to assist you.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: _deepGreen,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: _mutedTeal,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: _cream,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: _deepGreen,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    onPressed: () {
                      Get.snackbar(
                        "Chat Agent",
                        "Message sent to concierge team.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: _deepGreen,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildChatMessage({
    required BuildContext context,
    required bool isUser,
    required String text,
    required String time,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? _deepGreen : _cream,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.start : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: isUser ? Colors.white : _deepGreen,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: isUser ? Colors.white70 : _mutedTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedbackBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              Text(
                "Send Feedback or Inquiry",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _deepGreen,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Let us know how we can improve your BookN'Glow experience.",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: _mutedTeal,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Describe your feedback or question in detail...",
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: _mutedTeal,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: _cream,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _deepGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                    Get.snackbar(
                      "Feedback Sent",
                      "Thank you! Our support team will review your message shortly.",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: _deepGreen,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                  child: Text(
                    "Submit Ticket",
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
