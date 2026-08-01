import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../Controller/bookings_controller.dart';
import 'rebook_date_time_screen.dart';
import 'rating_review_bottom_sheet.dart';

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
    final controller = Get.find<BookingsController>();

    return Obx(() {
      final bookings = controller.upcomingBookings;

      return RefreshIndicator(
        color: const Color(0xFF05352F),
        onRefresh: () => controller.syncAndFetchBookings(),
        child: bookings.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Text(
                      "No upcoming bookings yet",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: const Color(0xFF7A8D87),
                      ),
                    ),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 24.0,
                  bottom: 100.0,
                ),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  final statusLower = (booking['status']?.toString() ?? '')
                      .toLowerCase()
                      .trim();
                  final isAccepted =
                      statusLower == 'accepted' || statusLower == 'confirmed';
                  final String rawService =
                      booking['service']?.toString() ?? '';
                  final List<String> serviceList = rawService
                      .split(', ')
                      .where((String s) => s.trim().isNotEmpty)
                      .toList();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.02),
                          blurRadius: 16,
                          offset: Offset(0, 8),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (serviceList.isEmpty)
                                      Text(
                                        booking['service']?.toString() ??
                                            'Salon Service',
                                        style: GoogleFonts.playfairDisplay(
                                          textStyle: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF05352F),
                                          ),
                                        ),
                                      )
                                    else
                                      ...serviceList.map((serviceName) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4.0,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "• ",
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: const Color(
                                                        0xFF05352F,
                                                      ),
                                                    ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  serviceName.trim(),
                                                  style:
                                                      GoogleFonts.playfairDisplay(
                                                        textStyle:
                                                            const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color(
                                                                0xFF05352F,
                                                              ),
                                                            ),
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    const SizedBox(height: 6),
                                    Text(
                                      booking['salon']!,
                                      style: GoogleFonts.plusJakartaSans(
                                        textStyle: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF2C3E3A),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isAccepted
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
                                      color: isAccepted
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
                                        booking['date']?.toString() ?? '',
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
                                    booking['time']?.toString() ?? '',
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
                                booking['price']?.toString() ?? '',
                                style: GoogleFonts.plusJakartaSans(
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF05352F),
                                  ),
                                ),
                              ),

                              // i will implemwnt it later when ever i need it
                              // Row(
                              //   children: [
                              //     TextButton(
                              //       onPressed: () {},
                              //       child: Text(
                              //         "Reschedule",
                              //         style: GoogleFonts.plusJakartaSans(
                              //           textStyle: const TextStyle(
                              //             fontSize: 13,
                              //             fontWeight: FontWeight.bold,
                              //             color: Color(0xFF9E7E45),
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      );
    });
  }
}

class HistoryBookingsTab extends StatelessWidget {
  const HistoryBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingsController>();

    return Obx(() {
      final bookings = controller.historyBookings;

      return RefreshIndicator(
        color: const Color(0xFF05352F),
        onRefresh: () => controller.syncAndFetchBookings(),
        child: bookings.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Text(
                      "No past bookings found",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: const Color(0xFF7A8D87),
                      ),
                    ),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 24.0,
                  bottom: 100.0,
                ),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  final statusLower = (booking['status']?.toString() ?? '')
                      .toLowerCase()
                      .trim();
                  final isCanceled =
                      statusLower == 'canceled' || statusLower == 'cancelled';
                  final String rawService =
                      booking['service']?.toString() ?? '';
                  final List<String> serviceList = rawService
                      .split(', ')
                      .where((String s) => s.trim().isNotEmpty)
                      .toList();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.02),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (serviceList.isEmpty)
                                      Text(
                                        booking['service']?.toString() ??
                                            'Salon Service',
                                        style: GoogleFonts.playfairDisplay(
                                          textStyle: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF05352F),
                                          ),
                                        ),
                                      )
                                    else
                                      ...serviceList.map((serviceName) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4.0,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "• ",
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: const Color(
                                                        0xFF05352F,
                                                      ),
                                                    ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  serviceName.trim(),
                                                  style:
                                                      GoogleFonts.playfairDisplay(
                                                        textStyle:
                                                            const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color(
                                                                0xFF05352F,
                                                              ),
                                                            ),
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            booking['salon']!,
                                            style: GoogleFonts.plusJakartaSans(
                                              textStyle: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF2C3E3A),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            RatingReviewBottomSheet.show(
                                              context,
                                              salonId:
                                                  booking['salonId']
                                                      ?.toString() ??
                                                  '',
                                              salonName:
                                                  booking['salon']
                                                      ?.toString() ??
                                                  'Salon',
                                              serviceName:
                                                  booking['service']
                                                      ?.toString() ??
                                                  'Salon Service',
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFFBEB),
                                              border: Border.all(
                                                color: const Color(0xFFFDE68A),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.star_rounded,
                                                  size: 15,
                                                  color: Color(0xFFD97706),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "Rate",
                                                  style:
                                                      GoogleFonts.plusJakartaSans(
                                                        fontSize: 11.5,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: const Color(
                                                          0xFF92400E,
                                                        ),
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isCanceled
                                      ? const Color(0xFFFDE8E8)
                                      : const Color(0xFFECECE8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  booking['status']!.toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    textStyle: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: isCanceled
                                          ? const Color(0xFFC53030)
                                          : const Color(0xFF7A8D87),
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
                                booking['price']?.toString() ?? '',
                                style: GoogleFonts.plusJakartaSans(
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF05352F),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  List<Map<String, dynamic>> services = [];
                                  if (booking['services'] is List &&
                                      (booking['services'] as List)
                                          .isNotEmpty) {
                                    services = (booking['services'] as List)
                                        .map(
                                          (s) => s is Map
                                              ? Map<String, dynamic>.from(s)
                                              : <String, dynamic>{},
                                        )
                                        .where((s) => s.isNotEmpty)
                                        .toList();
                                  }

                                  if (services.isEmpty) {
                                    final String rawServiceName =
                                        (booking['service']
                                                ?.toString()
                                                .isNotEmpty ==
                                            true)
                                        ? booking['service'].toString()
                                        : 'Salon Service';
                                    final names = rawServiceName
                                        .split(', ')
                                        .where((n) => n.trim().isNotEmpty)
                                        .toList();
                                    final priceStr =
                                        (booking['price']?.toString() ?? '')
                                            .replaceAll('₹', '')
                                            .trim();
                                    final totalPrice =
                                        double.tryParse(priceStr) ?? 0.0;
                                    final pricePerService = names.isNotEmpty
                                        ? totalPrice / names.length
                                        : totalPrice;

                                    services =
                                        (names.isNotEmpty
                                                ? names
                                                : [rawServiceName])
                                            .map(
                                              (n) => <String, dynamic>{
                                                'serviceName': n.trim(),
                                                'name': n.trim(),
                                                'price': pricePerService,
                                                'duration': '30 mins',
                                              },
                                            )
                                            .toList();
                                  }

                                  double itemTotal = 0.0;
                                  if (booking['rawPrice'] is num) {
                                    itemTotal = (booking['rawPrice'] as num)
                                        .toDouble();
                                  } else if (booking['price'] != null) {
                                    final cleaned = booking['price']
                                        .toString()
                                        .replaceAll('₹', '')
                                        .trim();
                                    itemTotal = double.tryParse(cleaned) ?? 0.0;
                                  }

                                  final originalDate =
                                      booking['date']?.toString() ?? '';
                                  final originalTime =
                                      booking['time']?.toString() ?? '';

                                  Get.to(
                                    () => RebookDateTimeScreen(
                                      salonId:
                                          booking['salonId']?.toString() ?? '',
                                      salonName:
                                          booking['salon']?.toString() ??
                                          'Salon',
                                      salonLocation:
                                          booking['salonLocation']
                                              ?.toString() ??
                                          '',
                                      services: services,
                                      itemTotal: itemTotal,
                                      originalDate: originalDate,
                                      originalTime: originalTime,
                                    ),
                                  );
                                },
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
              ),
      );
    });
  }
}
