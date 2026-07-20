import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Controller/salon_controller.dart';

class SalonDetailBottomSheet extends StatelessWidget {
  final Map<String, dynamic> salonData;

  const SalonDetailBottomSheet({super.key, required this.salonData});

  String _getWeekdayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _getMonthName(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[date.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    // Inject the controller unique to this salon instance
    final controller = Get.put(
      SalonDetailController(salonData),
      tag: salonData['name'] ?? 'default_salon',
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
    final String priceTier = (salonData['price']?.toString().isEmpty ?? true)
        ? r'₹₹'
        : salonData['price'] as String;

    return Container(
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
                // 1. Shop Image Banner
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5EFE0),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF05352F).withOpacity(0.12),
                        const Color(0xFFE8D5AF).withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: Image.asset(
                    salonData['image'] ?? 'assets/images/salon_aura.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
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
                            const Icon(
                              Icons.spa_outlined,
                              color: Color(0xFFE8D5AF),
                              size: 48,
                            ),
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
                    ),
                  ),
                ),

                // Drag handle bar
                Positioned(
                  top: 10,
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
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
                      color: Colors.black.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),
              ],
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Shop Name, Ratings, Address, Open/Close Time
                    Text(
                      name,
                      style: GoogleFonts.playfairDisplay(
                        textStyle: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF05352F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFF9E7E45), size: 18),
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
                        const SizedBox(width: 12),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Color(0xFF7A8D87),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          priceTier,
                          style: GoogleFonts.plusJakartaSans(
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9E7E45),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Color(0xFF9E7E45), size: 18),
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
                        const Icon(Icons.access_time_rounded, color: Color(0xFF7A8D87), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Open Today: 9:00 AM - 8:00 PM',
                          style: GoogleFonts.plusJakartaSans(
                            textStyle: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6E7E7A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Divider(color: const Color(0xFFE8D5AF).withOpacity(0.3), height: 1),
                    const SizedBox(height: 20),

                    // 3. Date Selector
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
                            final currentSelected = controller.selectedDate.value;
                            final isSelected = currentSelected != null &&
                                currentSelected.year == date.year &&
                                currentSelected.month == date.month &&
                                currentSelected.day == date.day;

                            return GestureDetector(
                              onTap: () => controller.selectDate(date),
                              child: Container(
                                width: 64,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF05352F) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected 
                                        ? const Color(0xFF05352F)
                                        : const Color(0xFFE8D5AF).withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? const Color(0xFF05352F).withOpacity(0.15)
                                          : const Color.fromRGBO(0, 0, 0, 0.02),
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
                                          color: isSelected ? const Color(0xFFE8D5AF) : const Color(0xFF7A8D87),
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
                                          color: isSelected ? Colors.white : const Color(0xFF05352F),
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
                    const SizedBox(height: 12),
                    
                    SizedBox(
                      height: 42,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: controller.availableTimes.length,
                        itemBuilder: (context, index) {
                          final timeSlot = controller.availableTimes[index];
                          
                          return Obx(() {
                            final isSelected = controller.selectedTime.value == timeSlot;

                            return GestureDetector(
                              onTap: () => controller.selectTime(timeSlot),
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF05352F) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected 
                                        ? const Color(0xFF05352F)
                                        : const Color(0xFFE8D5AF).withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? const Color(0xFF05352F).withOpacity(0.15)
                                          : const Color.fromRGBO(0, 0, 0, 0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  timeSlot,
                                  style: GoogleFonts.plusJakartaSans(
                                    textStyle: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : const Color(0xFF05352F),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    Divider(color: const Color(0xFFE8D5AF).withOpacity(0.3), height: 1),
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
                    
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.availableServices.length,
                      itemBuilder: (context, index) {
                        final service = controller.availableServices[index];
                        final serviceName = service['name'] as String;

                        return Obx(() {
                          final isSelected = controller.selectedServices.contains(serviceName);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFFAF6EE) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected 
                                    ? const Color(0xFF9E7E45).withOpacity(0.5)
                                    : const Color(0xFFE8D5AF).withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: CheckboxListTile(
                              activeColor: const Color(0xFF05352F),
                              checkColor: Colors.white,
                              value: isSelected,
                              onChanged: (val) => controller.toggleService(serviceName),
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
                              controlAffinity: ListTileControlAffinity.trailing,
                            ),
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Booking Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF05352F).withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                        Obx(() => Text(
                          "₹${controller.totalPrice.toStringAsFixed(0)}",
                          style: GoogleFonts.playfairDisplay(
                            textStyle: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF05352F),
                            ),
                          ),
                        )),
                      ],
                    ),
                    Obx(() {
                      final isValid = controller.isBookingValid;
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF05352F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                            } else if (controller.selectedTime.value.isEmpty) {
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
                            final date = controller.selectedDate.value!;
                            final formattedDate = "${_getWeekdayName(date)}, ${_getMonthName(date)} ${date.day}";
                            
                            Get.back(); // close bottom sheet
                            Get.snackbar(
                              'Booking Success',
                              'Appointment confirmed at $name on $formattedDate at ${controller.selectedTime.value} for ₹${controller.totalPrice.toStringAsFixed(0)}!',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFF0A3932),
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12,
                              icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
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
    );
  }
}
