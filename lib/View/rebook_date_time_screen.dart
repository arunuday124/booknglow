import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'rebook_summary_screen.dart';

class RebookDateTimeScreen extends StatelessWidget {
  final String salonId;
  final String salonName;
  final String salonLocation;
  final List<Map<String, dynamic>> services;
  final double itemTotal;
  final String originalDate;
  final String originalTime;

  final RxBool useSameTimeAsLast = true.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString selectedTime = '10:00 AM'.obs;
  final List<DateTime> availableDates;
  final List<String> availableTimes;

  RebookDateTimeScreen({
    super.key,
    required this.salonId,
    required this.salonName,
    required this.salonLocation,
    required this.services,
    required this.itemTotal,
    required this.originalDate,
    required this.originalTime,
  })  : availableDates = List.generate(
          14,
          (index) => DateTime.now().add(Duration(days: index)),
        ),
        availableTimes = _buildAvailableTimes(originalTime) {
    selectedDate.value = availableDates.first;
    final trimmedOriginal = originalTime.trim();
    if (trimmedOriginal.isNotEmpty) {
      selectedTime.value = trimmedOriginal;
    }
  }

  static List<String> _buildAvailableTimes(String orig) {
    final times = [
      '09:00 AM',
      '10:00 AM',
      '11:00 AM',
      '12:30 PM',
      '02:00 PM',
      '03:30 PM',
      '05:00 PM',
      '06:30 PM',
      '08:00 PM',
    ];
    final trimmed = orig.trim();
    if (trimmed.isNotEmpty && !times.contains(trimmed)) {
      times.insert(0, trimmed);
    }
    return times;
  }

  String _formatWeekday(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _formatMonthDay(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${months[date.month - 1]} ${date.day}";
  }

  @override
  Widget build(BuildContext context) {
    final serviceNames = services
        .map((s) => s['serviceName'] ?? s['name'] ?? s['title'] ?? 'Service')
        .join(', ');

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF05352F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Select Date & Time",
          style: GoogleFonts.plusJakartaSans(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Service Details Summary Chip
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.02),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF05352F).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.repeat_rounded,
                      color: Color(0xFF05352F),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salonName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF05352F),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          serviceNames,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: const Color(0xFF7A8D87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Quick Pick Chip: "Same time as last booking"
            Obx(() {
              final isSameTime = useSameTimeAsLast.value;
              final selDate = selectedDate.value;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F2EE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSameTime
                        ? const Color(0xFF05352F)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              color: Color(0xFF05352F),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Same time as last booking",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF05352F),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            useSameTimeAsLast.value = !useSameTimeAsLast.value;
                          },
                          child: Text(
                            isSameTime ? "Change" : "Use Quick-Pick",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF9E7E45),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Rebook for Today (${_formatMonthDay(selDate)}) at ${originalTime.isNotEmpty ? originalTime : '10:00 AM'}",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: const Color(0xFF2C3E3A),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // 3. Calendar View (Horizontal Strip)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select Date",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF05352F),
                  ),
                ),
                Obx(() => Text(
                      _formatMonthDay(selectedDate.value),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9E7E45),
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 14),

            SizedBox(
              height: 76,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: availableDates.length,
                itemBuilder: (context, index) {
                  final date = availableDates[index];

                  return Obx(() {
                    final currentSelDate = selectedDate.value;
                    final isSelected = currentSelDate.year == date.year &&
                        currentSelDate.month == date.month &&
                        currentSelDate.day == date.day;

                    return GestureDetector(
                      onTap: () {
                        selectedDate.value = date;
                        useSameTimeAsLast.value = false;
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 64,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF05352F)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF05352F)
                                : Colors.grey.shade200,
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? const Color(0xFF05352F).withValues(alpha: 0.15)
                                  : Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatWeekday(date),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? const Color(0xFFE8D5AF)
                                    : const Color(0xFF7A8D87),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              date.day.toString(),
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF05352F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            // 4. Time Slots Grid
            Text(
              "Available Time Slots",
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF05352F),
              ),
            ),
            const SizedBox(height: 14),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: availableTimes.map((time) {
                return Obx(() {
                  final isSelected = selectedTime.value == time;
                  return GestureDetector(
                    onTap: () {
                      selectedTime.value = time;
                      useSameTimeAsLast.value = false;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF05352F)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF05352F)
                              : Colors.grey.shade300,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        time,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF2C3E3A),
                        ),
                      ),
                    ),
                  );
                });
              }).toList(),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),

      // Bottom Navigation Bar with Proceed Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF05352F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Get.to(
                  () => RebookSummaryScreen(
                    salonId: salonId,
                    salonName: salonName,
                    salonLocation: salonLocation,
                    services: services,
                    itemTotal: itemTotal,
                    selectedDate: selectedDate.value,
                    selectedTime: selectedTime.value,
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Proceed to Summary",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
