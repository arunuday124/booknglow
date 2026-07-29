import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Controller/address_controller.dart';
import '../model/saved_address_model.dart';
import 'payment_screen.dart';
import 'select_location_screen.dart';

class RebookSummaryScreen extends StatelessWidget {
  final String salonId;
  final String salonName;
  final String salonLocation;
  final List<Map<String, dynamic>> services;
  final double itemTotal;
  final DateTime selectedDate;
  final String selectedTime;

  const RebookSummaryScreen({
    super.key,
    required this.salonId,
    required this.salonName,
    required this.salonLocation,
    required this.services,
    required this.itemTotal,
    required this.selectedDate,
    required this.selectedTime,
  });

  String _formatDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
    return "${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  void _showAddressSelectionBottomSheet(
    BuildContext context,
    AddressController addressController,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Color(0xFFFAF9F5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(20),
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
                  "Select Service Address",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF05352F),
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
              child: Obx(() {
                final list = addressController.addresses;
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_off_outlined,
                          size: 44,
                          color: Color(0xFF7A8D87),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No saved addresses found",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: const Color(0xFF7A8D87),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Get.back();
                            Get.to(() => const SelectLocationScreen());
                          },
                          icon: const Icon(Icons.add_location_alt_outlined),
                          label: const Text("Add New Address"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF05352F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final SavedAddressModel item = list[index];
                    final isSelected =
                        addressController.selectedAddress.value?.id == item.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE2F2EE)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF05352F)
                              : Colors.grey.shade200,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          if (item.id != null) {
                            addressController.selectAddress(item.id!);
                          }
                          Get.back();
                        },
                        leading: Icon(
                          item.type.toLowerCase() == 'home'
                              ? Icons.home_rounded
                              : item.type.toLowerCase() == 'work'
                              ? Icons.work_rounded
                              : Icons.location_on_rounded,
                          color: const Color(0xFF05352F),
                        ),
                        title: Text(
                          item.name.isNotEmpty ? item.name : item.type,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: const Color(0xFF05352F),
                          ),
                        ),
                        subtitle: Text(
                          "${item.houseNo.isNotEmpty ? '${item.houseNo}, ' : ''}${item.address.isNotEmpty ? item.address : item.locationName}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF7A8D87),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF05352F),
                              )
                            : null,
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressController = Get.isRegistered<AddressController>()
        ? Get.find<AddressController>()
        : Get.put(AddressController());

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
          "Review Booking Summary",
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
            // 1. Salon Card
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF05352F).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF05352F),
                          ),
                        ),
                        if (salonLocation.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            salonLocation,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF7A8D87),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Scheduled Date & Time Card with Edit button
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: Color(0xFF05352F),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Date & Time",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C3E3A),
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => Get.back(), // Returns to RebookDateTimeScreen
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 15,
                          color: Color(0xFF9E7E45),
                        ),
                        label: Text(
                          "Edit",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF9E7E45),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF6EE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8D5AF)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _formatDate(selectedDate),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF9E7E45),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: Color(0xFF9E7E45),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          selectedTime,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF9E7E45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Service Address Card with Edit button
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 20,
                            color: Color(0xFF05352F),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Service Address",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C3E3A),
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddressSelectionBottomSheet(
                          context,
                          addressController,
                        ),
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 15,
                          color: Color(0xFF9E7E45),
                        ),
                        label: Text(
                          "Edit",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF9E7E45),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final selectedAddr = addressController.selectedAddress.value;
                    if (selectedAddr == null) {
                      return Text(
                        "No address selected. Tap Edit to choose one.",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: const Color(0xFF7A8D87),
                        ),
                      );
                    }
                    return Text(
                      "${selectedAddr.type}: ${selectedAddr.houseNo.isNotEmpty ? '${selectedAddr.houseNo}, ' : ''}${selectedAddr.building.isNotEmpty ? '${selectedAddr.building}, ' : ''}${selectedAddr.address.isNotEmpty ? selectedAddr.address : selectedAddr.locationName}",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF2C3E3A),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Selected Services List Card
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.content_cut_rounded,
                        size: 18,
                        color: Color(0xFF05352F),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Selected Services",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E3A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...services.map((service) {
                    final sName = service['serviceName']?.toString() ??
                        service['name']?.toString() ??
                        service['title']?.toString() ??
                        service['service']?.toString() ??
                        'Salon Service';
                    final sDuration = service['duration']?.toString() ?? '30 mins';
                    final sPrice = service['price']?.toString() ?? '0';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF05352F),
                                  ),
                                ),
                                if (sDuration.isNotEmpty)
                                  Text(
                                    sDuration,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      color: const Color(0xFF7A8D87),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            "₹$sPrice",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF05352F),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 5. Total Price Card
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Amount",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E3A),
                    ),
                  ),
                  Text(
                    "₹${itemTotal.toStringAsFixed(2)}",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF05352F),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),

      // Bottom Navigation Bar with Proceed to Payment Button
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
                  () => PaymentScreen(
                    salonId: salonId,
                    salonName: salonName,
                    salonLocation: salonLocation,
                    selectedDate: selectedDate,
                    selectedTime: selectedTime,
                    services: services,
                    itemTotal: itemTotal,
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Proceed to Payment",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.payment_rounded, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
