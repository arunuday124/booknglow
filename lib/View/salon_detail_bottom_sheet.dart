import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Controller/salon_controller.dart';
import 'payment_screen.dart';

class SalonDetailBottomSheet extends StatelessWidget {
  final Map<String, dynamic> salonData;

  const SalonDetailBottomSheet({super.key, required this.salonData});

  String _getWeekdayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  Widget _buildShopImage(String rawImage) {
    final imageStr = rawImage.trim();

    if (imageStr.isEmpty) {
      return _buildImagePlaceholder();
    }

    if (imageStr.startsWith('http://') || imageStr.startsWith('https://')) {
      return Image.network(
        imageStr,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 180,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            height: 180,
            color: const Color(0xFF05352F).withValues(alpha: 0.08),
            child: const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: Color(0xFF05352F),
                  strokeWidth: 2.5,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      );
    } else if (imageStr.startsWith('assets/')) {
      return Image.asset(
        imageStr,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 180,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      );
    } else if (File(imageStr).existsSync()) {
      return Image.file(
        File(imageStr),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 180,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      );
    }

    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF05352F), Color(0xFF0A4D45)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.spa_outlined, color: Color(0xFFE8D5AF), size: 48),
            const SizedBox(height: 8),
            Text(
              "Book'N'Glow Experience",
              style: GoogleFonts.playfairDisplay(
                textStyle: const TextStyle(
                  color: Color(0xFFFAF9F5),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Inject the controller unique to this salon instance
    final controller = Get.put(
      SalonDetailController(salonData),
      tag:
          salonData['salonId']?.toString() ??
          salonData['id']?.toString() ??
          salonData['name']?.toString() ??
          'default_salon',
    );

    // Parse rating and reviews count safely
    final String ratingRaw = salonData['rating']?.toString() ?? '4.8';
    String rating = ratingRaw;
    String reviews = '120 reviews';

    if (ratingRaw.contains('(')) {
      final parts = ratingRaw.split('(');
      rating = parts[0].trim();
      reviews = parts[1].replaceAll(')', '').trim();
    } else if (salonData['reviews'] != null) {
      reviews = salonData['reviews'] as String;
    }

    final String name = salonData['name'] ?? 'Luxury Salon';
    final String location = salonData['location'] ?? 'Downtown';
    final String rawSalonType =
        (salonData['salonType'] ??
                salonData['gender'] ??
                salonData['type'] ??
                salonData['salon_type'] ??
                'Unisex')
            .toString()
            .trim();

    String displaySalonType = 'Unisex';
    final lowerType = rawSalonType.toLowerCase();
    if (lowerType.contains('female') ||
        lowerType.contains('women') ||
        lowerType.contains('ladies')) {
      displaySalonType = 'Female';
    } else if (lowerType.contains('male') ||
        lowerType.contains('men') ||
        lowerType.contains('gents')) {
      displaySalonType = 'Male';
    } else if (rawSalonType.isNotEmpty) {
      displaySalonType =
          rawSalonType[0].toUpperCase() + rawSalonType.substring(1);
    }

    final String openingHours =
        salonData['openingHours']?.toString() ?? '10 AM';
    final String closingHours = salonData['closingHours']?.toString() ?? '8 PM';
    final String phone = salonData['phone']?.toString() ?? '';
    final String ownerName = salonData['ownerName']?.toString() ?? '';

    final String rawImage =
        (salonData['shopImage'] ??
                salonData['image'] ??
                salonData['shop_image'] ??
                salonData['photoUrl'] ??
                '')
            .toString()
            .trim();

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        controller.resetSelections();
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFFFAF9F5), // Premium alabaster
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Column(
            children: [
              // Drag handle indicator (overlay on image)
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  // 1. Shop Image Banner at top of bottom sheet
                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: _buildShopImage(rawImage),
                  ),

                  // Drag handle bar
                  Positioned(
                    top: 10,
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Close Button (overlay)
                  Positioned(
                    top: 10,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          controller.resetSelections();
                          Get.back();
                        },
                      ),
                    ),
                  ),
                ],
              ),

              // Scrollable Content with Pull-Down Refresh
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF05352F),
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    await controller.fetchBookedSlots(forceRefresh: true);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Shop Name & Salon Type Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: GoogleFonts.playfairDisplay(
                                textStyle: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF05352F),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: displaySalonType == 'Male'
                                  ? const Color(0xFFE3F2FD)
                                  : displaySalonType == 'Female'
                                  ? const Color(0xFFFFF8E1)
                                  : const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: displaySalonType == 'Male'
                                    ? const Color(
                                        0xFF2196F3,
                                      ).withValues(alpha: 0.4)
                                    : displaySalonType == 'Female'
                                    ? const Color(
                                        0xFFFFB300,
                                      ).withValues(alpha: 0.4)
                                    : const Color(
                                        0xFF4CAF50,
                                      ).withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  displaySalonType == 'Male'
                                      ? Icons.boy_rounded
                                      : displaySalonType == 'Female'
                                      ? Icons.girl_rounded
                                      : Icons.people_rounded,
                                  size: 14,
                                  color: displaySalonType == 'Male'
                                      ? const Color(0xFF1976D2)
                                      : displaySalonType == 'Female'
                                      ? const Color(0xFFF57F17)
                                      : const Color(0xFF2E7D32),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  displaySalonType,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: displaySalonType == 'Male'
                                        ? const Color(0xFF1976D2)
                                        : displaySalonType == 'Female'
                                        ? const Color(0xFFF57F17)
                                        : const Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFF9E7E45),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$rating ',
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E3A),
                              ),
                            ),
                          ),
                          Text(
                            '($reviews)',
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7A8D87),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFF9E7E45),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              location,
                              style: GoogleFonts.plusJakartaSans(
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6E7E7A),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: Color(0xFF7A8D87),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Open Today: $openingHours - $closingHours',
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6E7E7A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (phone.isNotEmpty && phone != '0') ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_outlined,
                              color: Color(0xFF7A8D87),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              phone,
                              style: GoogleFonts.plusJakartaSans(
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6E7E7A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (ownerName.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline_rounded,
                              color: Color(0xFF7A8D87),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Owner: $ownerName',
                              style: GoogleFonts.plusJakartaSans(
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6E7E7A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),

                      Divider(
                        color: const Color(0xFFE8D5AF).withValues(alpha: 0.3),
                        height: 1,
                      ),
                      const SizedBox(height: 20),

                      // 3. Date Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select Date",
                            style: GoogleFonts.playfairDisplay(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF05352F),
                              ),
                            ),
                          ),
                          Obx(() {
                            final isRefreshing =
                                controller.isRefreshingSlots.value;
                            return Tooltip(
                              message: "Refresh availability",
                              child: InkWell(
                                onTap: isRefreshing
                                    ? null
                                    : () => controller.fetchBookedSlots(
                                        forceRefresh: true,
                                      ),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAF6EE),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF9E7E45)
                                          .withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      isRefreshing
                                          ? const SizedBox(
                                              width: 12,
                                              height: 12,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 1.8,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Color(0xFF9E7E45),
                                                ),
                                              ),
                                            )
                                          : const Icon(
                                              Icons.refresh_rounded,
                                              size: 13,
                                              color: Color(0xFF9E7E45),
                                            ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isRefreshing
                                            ? "Refreshing..."
                                            : "Refresh",
                                        style: GoogleFonts.plusJakartaSans(
                                          textStyle: const TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF9E7E45),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        height: 76,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: controller.availableDates.length,
                          itemBuilder: (context, index) {
                            final date = controller.availableDates[index];

                            return Obx(() {
                              final currentSelected =
                                  controller.selectedDate.value;
                              final isSelected =
                                  currentSelected != null &&
                                  currentSelected.year == date.year &&
                                  currentSelected.month == date.month &&
                                  currentSelected.day == date.day;

                              return GestureDetector(
                                onTap: () => controller.selectDate(date),
                                child: Container(
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
                                          : const Color(
                                              0xFFE8D5AF,
                                            ).withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? const Color(
                                                0xFF05352F,
                                              ).withValues(alpha: 0.15)
                                            : const Color.fromRGBO(
                                                0,
                                                0,
                                                0,
                                                0.02,
                                              ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _getWeekdayName(date),
                                        style: GoogleFonts.plusJakartaSans(
                                          textStyle: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? const Color(0xFFE8D5AF)
                                                : const Color(0xFF7A8D87),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        date.day.toString(),
                                        style: GoogleFonts.playfairDisplay(
                                          textStyle: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xFF05352F),
                                          ),
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
                      const SizedBox(height: 20),

                      // 4. Time Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select Time",
                            style: GoogleFonts.playfairDisplay(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF05352F),
                              ),
                            ),
                          ),
                          Obx(() {
                            final dur = controller.formattedTotalDuration;
                            if (controller.totalDurationMinutes <= 0) {
                              return const SizedBox.shrink();
                            }
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF6EE),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF9E7E45).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.timer_outlined,
                                    size: 13,
                                    color: Color(0xFF9E7E45),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    dur,
                                    style: GoogleFonts.plusJakartaSans(
                                      textStyle: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF9E7E45),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Obx(() {
                        final times = controller.filteredAvailableTimes;
                        if (times.isEmpty) {
                          return Container(
                            height: 42,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 16,
                                  color: Color(0xFF9E7E45),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "No time slots available for today. Please choose a future date.",
                                  style: GoogleFonts.plusJakartaSans(
                                    textStyle: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF7A8D87),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return SizedBox(
                          height: 42,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: times.length,
                            itemBuilder: (context, index) {
                              final timeSlot = times[index];

                              return Obx(() {
                                final isStart =
                                    controller.isWindowStartSlot(timeSlot);
                                final isInWindow =
                                    controller.isSlotInSelectedWindow(timeSlot);
                                final isLocked = controller.isSlotLocked(
                                  timeSlot,
                                );

                                Color bgColor;
                                Color borderColor;
                                Color textColor;

                                if (isLocked) {
                                  bgColor = const Color(0xFFEFECE6);
                                  borderColor = const Color(0xFFD6CFC4);
                                  textColor = const Color(0xFF9E9588);
                                } else if (isStart) {
                                  bgColor = const Color(0xFF05352F);
                                  borderColor = const Color(0xFF05352F);
                                  textColor = Colors.white;
                                } else if (isInWindow) {
                                  bgColor = const Color(0xFFE8F2EF);
                                  borderColor = const Color(0xFF05352F);
                                  textColor = const Color(0xFF05352F);
                                } else {
                                  bgColor = Colors.white;
                                  borderColor = const Color(
                                    0xFFE8D5AF,
                                  ).withValues(alpha: 0.3);
                                  textColor = const Color(0xFF05352F);
                                }

                                return GestureDetector(
                                  onTap: isLocked
                                      ? () {
                                          Get.snackbar(
                                            'Slot Locked',
                                            'This time slot ($timeSlot) is already booked and locked.',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor:
                                                const Color.fromARGB(
                                                  255,
                                                  219,
                                                  62,
                                                  5,
                                                ),
                                            colorText: Colors.white,
                                            margin: const EdgeInsets.all(16),
                                            borderRadius: 12,
                                            duration: const Duration(
                                              seconds: 2,
                                            ),
                                          );
                                        }
                                      : () => controller.selectTime(timeSlot),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: borderColor,
                                        width: (isStart || isInWindow) ? 1.5 : 1,
                                      ),
                                      boxShadow: isLocked
                                          ? []
                                          : (isStart || isInWindow)
                                          ? [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF05352F,
                                                ).withValues(alpha: 0.12),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              ),
                                            ]
                                          : [
                                              const BoxShadow(
                                                color: Color.fromRGBO(
                                                  0,
                                                  0,
                                                  0,
                                                  0.02,
                                                ),
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isLocked) ...[
                                          const Icon(
                                            Icons.lock_rounded,
                                            size: 13,
                                            color: Color(0xFF9E9588),
                                          ),
                                          const SizedBox(width: 5),
                                        ] else if (isInWindow && !isStart) ...[
                                          const Icon(
                                            Icons.link_rounded,
                                            size: 13,
                                            color: Color(0xFF05352F),
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                        Text(
                                          timeSlot,
                                          style: GoogleFonts.plusJakartaSans(
                                            textStyle: TextStyle(
                                              fontSize: 13,
                                              fontWeight:
                                                  (isStart || isInWindow)
                                                      ? FontWeight.w800
                                                      : FontWeight.w600,
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                            },
                          ),
                        );
                      }),

                      // Dynamic Selected Time Window Animated Card
                      Obx(() {
                        if (controller.selectedTime.value.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        final timeRange = controller.dynamicTimeRange;
                        final dur = controller.formattedTotalDuration;
                        final slotCount = controller.totalSlotCount;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.only(top: 14),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFAF6EE),
                                const Color(0xFFF2ECE0),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(
                                0xFF9E7E45,
                              ).withValues(alpha: 0.35),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF05352F,
                                ).withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF05352F),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.access_time_filled_rounded,
                                          size: 13,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Selected Window",
                                        style: GoogleFonts.plusJakartaSans(
                                          textStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF05352F),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF05352F),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "$slotCount slot${slotCount > 1 ? 's' : ''} • $dur",
                                      style: GoogleFonts.plusJakartaSans(
                                        textStyle: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                timeRange,
                                style: GoogleFonts.plusJakartaSans(
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF05352F),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 24),

                      Divider(
                        color: const Color(0xFFE8D5AF).withValues(alpha: 0.3),
                        height: 1,
                      ),
                      const SizedBox(height: 20),

                      // 5. Service Selector
                      Text(
                        "Select Services",
                        style: GoogleFonts.playfairDisplay(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF05352F),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (controller.availableServices.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF9F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(
                                0xFFE8D5AF,
                              ).withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: Color(0xFF7A8D87),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "No Services Added yet",
                                style: GoogleFonts.plusJakartaSans(
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF7A8D87),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.availableServices.length,
                          itemBuilder: (context, index) {
                            final service = controller.availableServices[index];
                            final serviceName = service['name'] as String;

                            return Obx(() {
                              final isSelected = controller.selectedServices
                                  .contains(serviceName);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFFAF6EE)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(
                                            0xFF9E7E45,
                                          ).withValues(alpha: 0.5)
                                        : const Color(
                                            0xFFE8D5AF,
                                          ).withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: CheckboxListTile(
                                  activeColor: const Color(0xFF05352F),
                                  checkColor: Colors.white,
                                  value: isSelected,
                                  onChanged: (val) =>
                                      controller.toggleService(serviceName),
                                  title: Text(
                                    serviceName,
                                    style: GoogleFonts.plusJakartaSans(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF05352F),
                                      ),
                                    ),
                                  ),
                                  subtitle: Text(
                                    service['duration'] as String,
                                    style: GoogleFonts.plusJakartaSans(
                                      textStyle: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF7A8D87),
                                      ),
                                    ),
                                  ),
                                  secondary: Text(
                                    '₹${service['price']}',
                                    style: GoogleFonts.plusJakartaSans(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF9E7E45),
                                      ),
                                    ),
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                ),
                              );
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),

              // Bottom Booking Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF05352F).withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "TOTAL PRICE",
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7A8D87),
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => Text(
                              "₹${controller.totalPrice.toStringAsFixed(0)}",
                              style: GoogleFonts.playfairDisplay(
                                textStyle: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF05352F),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Obx(() {
                        final isValid = controller.isBookingValid;
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF05352F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (!isValid) {
                              // Validation message
                              String missing = '';
                              if (controller.selectedDate.value == null) {
                                missing = 'Select Date';
                              } else if (controller
                                  .selectedTime
                                  .value
                                  .isEmpty) {
                                missing = 'Select Time';
                              } else if (controller.selectedServices.isEmpty) {
                                missing = 'Select at least one Service';
                              }

                              Get.snackbar(
                                'Incomplete Details',
                                'Please complete the booking flow: $missing.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red.shade800,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                            } else {
                              final selectedDate =
                                  controller.selectedDate.value!;
                              final selectedTime =
                                  controller.dynamicTimeRange.isNotEmpty
                                      ? controller.dynamicTimeRange
                                      : controller.selectedTime.value;
                              final selectedServices = controller
                                  .availableServices
                                  .where(
                                    (s) => controller.selectedServices.contains(
                                      s['name'],
                                    ),
                                  )
                                  .toList();
                              final itemTotal = controller.totalPrice;

                              controller.resetSelections();
                              Get.back(); // close bottom sheet

                              Get.to(
                                () => PaymentScreen(
                                  salonId:
                                      salonData['id']?.toString() ??
                                      salonData['salonId']?.toString() ??
                                      '',
                                  salonName: name,
                                  salonLocation: location,
                                  selectedDate: selectedDate,
                                  selectedTime: selectedTime,
                                  services: selectedServices,
                                  itemTotal: itemTotal,
                                ),
                              );
                            }
                          },
                          child: Text(
                            "Book Now",
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
