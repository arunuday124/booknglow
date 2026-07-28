import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Controller/address_controller.dart';
import '../Controller/bookings_controller.dart';
import '../Controller/payment_controller.dart';
import '../model/saved_address_model.dart';
import 'select_location_screen.dart';
import 'booking_success_screen.dart';

class PaymentScreen extends StatelessWidget {
  final String salonId;
  final String salonName;
  final String salonLocation;
  final DateTime selectedDate;
  final String selectedTime;
  final List<Map<String, dynamic>> services;
  final double itemTotal;

  const PaymentScreen({
    super.key,
    this.salonId = '',
    required this.salonName,
    required this.salonLocation,
    required this.selectedDate,
    required this.selectedTime,
    required this.services,
    required this.itemTotal,
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
                  "Select Delivery Address",
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
                          size: 48,
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
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final SavedAddressModel item = list[index];
                    final isSelected =
                        item.isSelected ||
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
                        title: Row(
                          children: [
                            Text(
                              item.name.isNotEmpty ? item.name : item.type,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: const Color(0xFF05352F),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF05352F,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.type,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF05352F),
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "${item.houseNo.isNotEmpty ? '${item.houseNo}, ' : ''}${item.building.isNotEmpty ? '${item.building}, ' : ''}${item.address.isNotEmpty ? item.address : item.locationName}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF7A8D87),
                            ),
                          ),
                        ),
                        trailing: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isSelected
                              ? const Color(0xFF05352F)
                              : Colors.grey.shade400,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF05352F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Get.back();
                  Get.to(() => const SelectLocationScreen());
                },
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  "Add New Address",
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onPlaceOrder(
    BuildContext context,
    AddressController addressController,
    PaymentController payController,
  ) async {
    final selectedAddr = addressController.selectedAddress.value;
    if (selectedAddr == null && addressController.addresses.isNotEmpty) {
      _showAddressSelectionBottomSheet(context, addressController);
      return;
    }

    final serviceNames = services
        .map(
          (s) => s['serviceName'] ?? s['name'] ?? s['title'] ?? 'Salon Service',
        )
        .join(', ');
    final addressText = selectedAddr != null
        ? "${selectedAddr.type}: ${selectedAddr.houseNo.isNotEmpty ? '${selectedAddr.houseNo}, ' : ''}${selectedAddr.address.isNotEmpty ? selectedAddr.address : selectedAddr.locationName}"
        : "Standard Service Address";

    final finalTotal = payController.calculateFinalTotal(itemTotal);
    final formattedDate = _formatDate(selectedDate);

    // Show loading state while saving to Firebase
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF05352F)),
                ),
                const SizedBox(height: 16),
                Text(
                  "Confirming Booking...",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF05352F),
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Save to Firestore via BookingsController immediately
    final bController = Get.isRegistered<BookingsController>()
        ? Get.find<BookingsController>()
        : Get.put(BookingsController());

    final success = await bController.addBooking(
      salonId: salonId,
      salonName: salonName,
      date: formattedDate,
      time: selectedTime,
      services: services,
      paymentMethod: payController.paymentMethodType,
      bookingStatus: 'Pending',
    );

    // Dismiss loading dialog
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    if (success) {
      // Navigate to BookingSuccessScreen on successful Firebase write
      Get.off(
        () => BookingSuccessScreen(
          salonName: salonName,
          date: formattedDate,
          time: selectedTime,
          services: serviceNames,
          totalAmount: finalTotal,
          paymentMethod: payController.paymentMethodName,
          address: addressText,
        ),
      );
    } else {
      // Show error notification on failure
      Get.snackbar(
        'Booking Failed',
        'Unable to process your booking right now. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Inject controllers
    final addressController = Get.isRegistered<AddressController>()
        ? Get.find<AddressController>()
        : Get.put(AddressController());

    final payController = Get.put(PaymentController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF05352F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Payment",
          style: GoogleFonts.plusJakartaSans(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Delivery Address Card (At the top)
            _buildDeliveryAddressSection(context, addressController),

            const SizedBox(height: 16),

            // 2. Selected Salon & Services Summary Card
            _buildSelectedServicesSection(),

            const SizedBox(height: 16),

            // 3. Coupon Code Section
            _buildCouponSection(payController),

            const SizedBox(height: 16),

            // 4. Payment Method Section
            _buildPaymentMethodSection(payController),

            const SizedBox(height: 16),

            // 5. Order Summary Section
            _buildOrderSummarySection(payController),

            const SizedBox(height: 80),
          ],
        ),
      ),

      // Bottom Sticky Bar with Total & Place Order Button
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF7A8D87),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Obx(() {
                    final finalTotal = payController.calculateFinalTotal(
                      itemTotal,
                    );
                    return Text(
                      "₹${finalTotal.toStringAsFixed(2)}",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF05352F),
                      ),
                    );
                  }),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF05352F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () =>
                    _onPlaceOrder(context, addressController, payController),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Place Order",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 0. Selected Services & Booking Details Card
  Widget _buildSelectedServicesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Salon Name & Location
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF05352F).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Color(0xFF05352F),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      salonName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E3A),
                      ),
                    ),
                    if (salonLocation.isNotEmpty)
                      Text(
                        salonLocation,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF7A8D87),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Date & Time Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6EE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8D5AF)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Color(0xFF9E7E45),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(selectedDate),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
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
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9E7E45),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "Selected Services",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E3A),
            ),
          ),

          const SizedBox(height: 8),

          // List of Services
          if (services.isEmpty)
            Text(
              "No services selected",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF7A8D87),
              ),
            )
          else
            ...services.map((service) {
              final sName =
                  service['name']?.toString() ??
                  service['title']?.toString() ??
                  'Service';
              final sDuration = service['duration']?.toString() ?? '';
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
                                fontSize: 11,
                                color: const Color(0xFF7A8D87),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      "₹$sPrice",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF9E7E45),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // 1. Delivery Address Card
  Widget _buildDeliveryAddressSection(
    BuildContext context,
    AddressController addressController,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                    Icons.location_on_rounded,
                    color: Color(0xFF05352F),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Delivery Address",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E3A),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _showAddressSelectionBottomSheet(
                  context,
                  addressController,
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "Change",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF05352F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final selected = addressController.selectedAddress.value;

            if (selected == null) {
              return InkWell(
                onTap: () => _showAddressSelectionBottomSheet(
                  context,
                  addressController,
                ),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFE0B2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFD97706),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "No delivery address selected",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAF9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2EFEF)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF05352F).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.home_outlined,
                      color: Color(0xFF05352F),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              selected.name.isNotEmpty
                                  ? selected.name
                                  : selected.type,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF05352F),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF05352F,
                                ).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                selected.type.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF05352F),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${selected.houseNo.isNotEmpty ? '${selected.houseNo}, ' : ''}${selected.building.isNotEmpty ? '${selected.building}, ' : ''}${selected.address.isNotEmpty ? selected.address : selected.locationName}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: const Color(0xFF637470),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 2. Coupon Section
  Widget _buildCouponSection(PaymentController payController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_offer_outlined,
                color: Color(0xFF05352F),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                "Apply Coupon Code",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E3A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final applied = payController.appliedCoupon.value;
            final discount = payController.discountAmount.value;
            final error = payController.couponError.value;

            if (applied != null) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F2EE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF05352F).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF05352F),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Coupon '$applied' Applied",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF05352F),
                            ),
                          ),
                          Text(
                            "Saved ₹${discount.toStringAsFixed(2)} on this order",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFF4C6B64),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF05352F),
                        size: 18,
                      ),
                      onPressed: payController.removeCoupon,
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: payController.couponController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: "Enter Promo Code (e.g. GLOW20)",
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: Colors.grey.shade400,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7FAF9),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF05352F),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF05352F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => payController.applyCoupon(
                        payController.couponController.text,
                        itemTotal,
                      ),
                      child: Text(
                        "Apply",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                    child: Text(
                      error,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCouponChip('GLOW20', '20% OFF', payController),
                      const SizedBox(width: 8),
                      _buildCouponChip('WELCOME50', '₹50 OFF', payController),
                      const SizedBox(width: 8),
                      _buildCouponChip('BEAUTY100', '₹100 OFF', payController),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCouponChip(
    String code,
    String desc,
    PaymentController payController,
  ) {
    return InkWell(
      onTap: () {
        payController.couponController.text = code;
        payController.applyCoupon(code, itemTotal);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF6EE),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8D5AF)),
        ),
        child: Row(
          children: [
            const Icon(Icons.stars_rounded, size: 14, color: Color(0xFF9E7E45)),
            const SizedBox(width: 4),
            Text(
              "$code ($desc)",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF9E7E45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Payment Method Section
  Widget _buildPaymentMethodSection(PaymentController payController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.credit_card_rounded,
                color: Color(0xFF05352F),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                "Payment Method",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E3A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPaymentMethodOption(
            index: 0,
            title: "Credit / Debit Card",
            subtitle: "Visa, Mastercard, RuPay and more",
            icon: Icons.credit_card_outlined,
            iconBg: const Color(0xFFE2F2EE),
            iconColor: const Color(0xFF05352F),
            payController: payController,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodOption(
            index: 1,
            title: "UPI",
            subtitle: "GPay, PhonePe, Paytm and more",
            icon: Icons.account_balance_wallet_outlined,
            iconBg: const Color(0xFFF3E8FF),
            iconColor: const Color(0xFF7E22CE),
            payController: payController,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodOption(
            index: 2,
            title: "Cash",
            subtitle: "Pay after the service is completed",
            icon: Icons.payments_outlined,
            iconBg: const Color(0xFFDCFCE7),
            iconColor: const Color(0xFF15803D),
            payController: payController,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required PaymentController payController,
  }) {
    return Obx(() {
      final isSelected = payController.selectedPaymentMethod.value == index;

      return InkWell(
        onTap: () {
          payController.selectedPaymentMethod.value = index;
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF05352F)
                  : Colors.grey.shade200,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E3A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFF7A8D87),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected
                    ? const Color(0xFF05352F)
                    : Colors.grey.shade400,
                size: 22,
              ),
            ],
          ),
        ),
      );
    });
  }

  // 4. Order Summary Section
  Widget _buildOrderSummarySection(PaymentController payController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                color: Color(0xFF05352F),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                "Order Summary",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E3A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow("Item Total", "₹${itemTotal.toStringAsFixed(2)}"),

          Obx(() {
            final discount = payController.discountAmount.value;
            if (discount > 0) {
              return Column(
                children: [
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    "Coupon Discount",
                    "-₹${discount.toStringAsFixed(2)}",
                    valueColor: const Color(0xFF15803D),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "To Pay",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E3A),
                ),
              ),
              Obx(() {
                final finalTotal = payController.calculateFinalTotal(itemTotal);
                return Text(
                  "₹${finalTotal.toStringAsFixed(2)}",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF05352F),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: const Color(0xFF7A8D87),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF2C3E3A),
          ),
        ),
      ],
    );
  }
}
