import 'package:get/get.dart';

class BookingsController extends GetxController {
  // 0 for Upcoming, 1 for History
  final RxInt selectedTab = 0.obs;

  // Dynamic upcoming bookings list
  final RxList<Map<String, String>> upcomingBookings = <Map<String, String>>[
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
  ].obs;

  void selectTab(int index) {
    selectedTab.value = index;
  }

  void addBooking(Map<String, String> booking) {
    upcomingBookings.insert(0, booking);
    selectedTab.value = 0; // Switch to upcoming tab when new booking is added
  }
}
