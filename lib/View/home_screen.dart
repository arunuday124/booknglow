import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Controller/address_controller.dart';
import '../Controller/notifications_controller.dart';
import '../Controller/salon_controller.dart';
import 'all_salons_screen.dart';
import 'notifications_screen.dart';
import 'salon_detail_bottom_sheet.dart';
import 'select_location_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final salonsCtrl = Get.put(SalonsController());
    final notifCtrl = Get.put(NotificationsController());

    // Categories list for beauty & wellness
    final List<Map<String, dynamic>> categories = [
      {'name': 'Facial', 'icon': Icons.face_retouching_natural_outlined},
      {'name': 'Massage', 'icon': Icons.spa_outlined},
      {'name': 'Nails', 'icon': Icons.brush_outlined},
      {'name': 'Hair', 'icon': Icons.content_cut_outlined},
      {'name': 'Spa', 'icon': Icons.bathtub_outlined},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F5),
        elevation: 0,
        toolbarHeight: 64,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Obx(() {
            final addrCtrl = Get.find<AddressController>();
            final selected = addrCtrl.selectedAddress.value;
            final locationName = selected?.locationName.isNotEmpty == true
                ? selected!.locationName
                : 'Set Location';
            String locationAddress = 'Tap to add your address';
            if (selected != null) {
              final full = selected.address.trim();
              final locName = selected.locationName.trim();
              if (locName.isNotEmpty) {
                final idx = full.toLowerCase().indexOf(locName.toLowerCase());
                if (idx != -1) {
                  locationAddress = full.substring(idx).trim();
                } else {
                  locationAddress = full;
                }
              } else {
                locationAddress = full;
              }
            }
            return GestureDetector(
              onTap: () => Get.to(() => const SelectLocationScreen()),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF05352F),
                        size: 17,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        locationName,
                        style: GoogleFonts.playfairDisplay(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF05352F),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF05352F),
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    locationAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      textStyle: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7A8D87),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_none_outlined,
                        color: Color(0xFF05352F),
                        size: 24,
                      ),
                      onPressed: () => Get.to(
                        () => const NotificationsScreen(),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ),
                  ),
                  Obx(
                    () => notifCtrl.hasUnread
                        ? Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF9E7E45), // Luxury gold alert
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              // Container(
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(12),
              //     boxShadow: [
              //       BoxShadow(
              //         color: const Color.fromRGBO(0, 0, 0, 0.03),
              //         blurRadius: 16,
              //         offset: const Offset(0, 8),
              //       ),
              //     ],
              //   ),
              //   child: TextField(
              //     style: GoogleFonts.plusJakartaSans(
              //       fontSize: 14,
              //       color: const Color(0xFF2C3E3A),
              //     ),
              //     decoration: InputDecoration(
              //       hintText: "Search salons, services or treatments...",
              //       hintStyle: GoogleFonts.plusJakartaSans(
              //         color: Colors.grey.shade400,
              //         fontSize: 14,
              //       ),
              //       prefixIcon: const Icon(
              //         Icons.search,
              //         color: Color(0xFF05352F),
              //         size: 20,
              //       ),
              //       border: InputBorder.none,
              //       contentPadding: const EdgeInsets.symmetric(
              //         horizontal: 16,
              //         vertical: 14,
              //       ),
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 20),

              // Greeting
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, Beautiful",
                    style: GoogleFonts.playfairDisplay(
                      textStyle: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF05352F),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 2),
                  // Text(
                  //   "Book Your Next Experience",
                  //   style: GoogleFonts.plusJakartaSans(
                  //     textStyle: const TextStyle(
                  //       fontSize: 12,
                  //       color: Color(0xFF7A8D87),
                  //       fontWeight: FontWeight.w400,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              // const SizedBox(height: 20),

              // Categories Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Explore Categories . . . .",
                    style: GoogleFonts.playfairDisplay(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF05352F),
                      ),
                    ),
                  ),
                  // GestureDetector(
                  //   onTap: () {},
                  //   child: Text(
                  //     "See All",
                  //     style: GoogleFonts.plusJakartaSans(
                  //       textStyle: const TextStyle(
                  //         fontSize: 13,
                  //         fontWeight: FontWeight.bold,
                  //         color: Color(0xFF9E7E45),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 16),

              // Categories Row
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    final categoryName = item['name'] as String;
                    return GestureDetector(
                      onTap: () {
                        final salonsCtrl = Get.isRegistered<SalonsController>()
                            ? Get.find<SalonsController>()
                            : Get.put(SalonsController());
                        salonsCtrl.updateCategory(categoryName);
                        Get.to(
                          () => AllSalonsScreen(initialCategory: categoryName),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromRGBO(0, 0, 0, 0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: const Color(0xFF05352F),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              categoryName,
                              style: GoogleFonts.plusJakartaSans(
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4C6B64),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Promotional Banner
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF05352F), Color(0xFF0A4D45)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(5, 53, 47, 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Abstract golden glowing circles
                    Positioned(
                      right: -40,
                      top: -40,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE8D5AF).withOpacity(0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -10,
                      bottom: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE8D5AF).withOpacity(0.05),
                        ),
                      ),
                    ),

                    // Banner Content card
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8D5AF).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "SPECIAL DEBUT",
                              style: GoogleFonts.plusJakartaSans(
                                textStyle: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE8D5AF),
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "20% Off Your First Booking",
                            style: GoogleFonts.playfairDisplay(
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Use code GLOW20 at checkout",
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7A8D87),
                                fontWeight: FontWeight.w400,
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

              // Recommended Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recommended Salons",
                    style: GoogleFonts.playfairDisplay(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF05352F),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const AllSalonsScreen()),
                    child: Text(
                      "See All",
                      style: GoogleFonts.plusJakartaSans(
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9E7E45),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Salons List (Top 5 Salons)
              Obx(() {
                if (salonsCtrl.isLoading.value && salonsCtrl.salons.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF05352F),
                      ),
                    ),
                  );
                }

                final top5 = salonsCtrl.salons.take(5).toList();
                if (top5.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Text(
                        "No salons available",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: const Color(0xFF7A8D87),
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: top5.length,
                  itemBuilder: (context, index) {
                    final salonModel = top5[index];
                    final salon = salonModel.toMap();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.02),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) =>
                                  SalonDetailBottomSheet(salonData: salon),
                            );
                          },
                          child: Row(
                            children: [
                              // Luxury placeholder or network image for salon
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5EFE0),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color.fromRGBO(5, 53, 47, 0.08),
                                      Color.fromRGBO(232, 213, 175, 0.2),
                                    ],
                                  ),
                                ),
                                child: salonModel.shopImage.isNotEmpty
                                    ? Image.network(
                                        salonModel.shopImage,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Center(
                                                  child: Icon(
                                                    Icons.spa_outlined,
                                                    color: Color(0xFF05352F),
                                                    size: 30,
                                                  ),
                                                ),
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.spa_outlined,
                                          color: Color(0xFF05352F),
                                          size: 30,
                                        ),
                                      ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              salonModel.salonName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  GoogleFonts.playfairDisplay(
                                                    textStyle: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF05352F),
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Color(0xFF9E7E45),
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${salonModel.ratings} (${salonModel.reviews} reviews)',
                                            style: GoogleFonts.plusJakartaSans(
                                              textStyle: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF6E7E7A),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            color: Color(0xFF7A8D87),
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              salonModel.address.isNotEmpty
                                                  ? salonModel.address
                                                  : 'Location unavailable',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    textStyle: const TextStyle(
                                                      fontSize: 11,
                                                      color: Color(0xFF7A8D87),
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
