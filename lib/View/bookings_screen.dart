import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../Controller/bookings_controller.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookingsController());

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F5),
        elevation: 0,
        title: Center(
          child: Text(
            "My Bookings",
            style: GoogleFonts.playfairDisplay(
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF05352F),
              ),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Obx(
                () => Container(
                  width: 280,
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECECE8),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      // Upcoming Tab Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.selectTab(0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: controller.selectedTab.value == 0
                                  ? const Color(0xFF05352F)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Upcoming",
                              style: GoogleFonts.plusJakartaSans(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: controller.selectedTab.value == 0
                                      ? Colors.white
                                      : const Color(0xFF7A8D87),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // History Tab Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.selectTab(1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: controller.selectedTab.value == 1
                                  ? const Color(0xFF05352F)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "History",
                              style: GoogleFonts.plusJakartaSans(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: controller.selectedTab.value == 1
                                      ? Colors.white
                                      : const Color(0xFF7A8D87),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: controller.selectedTab.value == 0
              ? const UpcomingBookingsTab(key: ValueKey('upcoming'))
              : const HistoryBookingsTab(key: ValueKey('history')),
        ),
      ),
    );
  }
}

class UpcomingBookingsTab extends StatelessWidget {
  const UpcomingBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo upcoming booking
    final List<Map<String, String>> bookings = [
      {
        'salon': 'Aura Wellness & Spa',
        'service': 'Aromatherapy Massage',
        'date': 'Friday, July 24, 2026',
        'time': '03:30 PM',
        'status': 'Confirmed',
        'price': '₹85.00',
      },
      {
        'salon': 'Glow & Co. Hair Boutique',
        'service': 'Premium Hydrafacial & Blowout',
        'date': 'Wednesday, August 05, 2026',
        'time': '11:00 AM',
        'status': 'Pending',
        'price': '₹140.00',
      }
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 100.0),
      physics: const BouncingScrollPhysics(),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final isConfirmed = booking['status'] == 'Confirmed';

        return Container(
          margin: const EdgeInsets.only(bottom: 20.0),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking['service']!,
                          style: GoogleFonts.playfairDisplay(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF05352F),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking['salon']!,
                          style: GoogleFonts.plusJakartaSans(
                            textStyle: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7A8D87),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isConfirmed
                            ? const Color(0xFFE2F2EE)
                            : const Color(0xFFF9EED9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        booking['status']!.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: isConfirmed
                                ? const Color(0xFF05352F)
                                : const Color(0xFF9E7E45),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF0EFEA)),
              // Date & Time Detail Row
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Color(0xFF9E7E45),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              booking['date']!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                textStyle: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4C6B64),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_outlined,
                          size: 16,
                          color: Color(0xFF9E7E45),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          booking['time']!,
                          style: GoogleFonts.plusJakartaSans(
                            textStyle: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4C6B64),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF0EFEA)),
              // Action Buttons Footer
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking['price']!,
                      style: GoogleFonts.plusJakartaSans(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF05352F),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Reschedule",
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9E7E45),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF05352F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Directions",
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class HistoryBookingsTab extends StatelessWidget {
  const HistoryBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo history bookings
    final List<Map<String, String>> bookings = [
      {
        'salon': 'Elegance Nail Studio',
        'service': 'Gel Manicure & Pedicure',
        'date': 'Wednesday, June 24, 2026',
        'time': '02:00 PM',
        'status': 'Completed',
        'price': '₹55.00',
      },
      {
        'salon': 'Aura Wellness & Spa',
        'service': 'Swedish Full Body Massage',
        'date': 'Saturday, May 16, 2026',
        'time': '10:00 AM',
        'status': 'Completed',
        'price': '₹90.00',
      }
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 100.0),
      physics: const BouncingScrollPhysics(),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 20.0),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking['service']!,
                          style: GoogleFonts.playfairDisplay(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF05352F),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking['salon']!,
                          style: GoogleFonts.plusJakartaSans(
                            textStyle: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7A8D87),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECECE8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        booking['status']!.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7A8D87),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF0EFEA)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Color(0xFF7A8D87),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              booking['date']!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                textStyle: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7A8D87),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_outlined,
                          size: 16,
                          color: Color(0xFF7A8D87),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          booking['time']!,
                          style: GoogleFonts.plusJakartaSans(
                            textStyle: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7A8D87),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF0EFEA)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking['price']!,
                      style: GoogleFonts.plusJakartaSans(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF05352F),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF05352F),
                        side: const BorderSide(
                          color: Color(0xFF05352F),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Book Again",
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
