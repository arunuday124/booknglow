import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../service/booking_service.dart';

class BookingsController extends GetxController {
  // 0 for Upcoming, 1 for History
  final RxInt selectedTab = 0.obs;

  // Dynamic upcoming and history bookings lists
  final RxList<Map<String, String>> upcomingBookings =
      <Map<String, String>>[].obs;
  final RxList<Map<String, String>> historyBookings =
      <Map<String, String>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load from Firestore on app launch / controller initialization
    fetchBookings();
  }

  /// Triggered on app launch or manual swipe-down pull-to-refresh:
  /// Executes a single one-shot `.get()` fetch to load user bookings from Firestore.
  Future<void> fetchBookings() async {
    isLoading.value = true;
    try {
      final list = await BookingService.getUserBookings();
      final List<Map<String, String>> upcoming = [];
      final List<Map<String, String>> history = [];

      for (var doc in list) {
        final servicesList = (doc['services'] as List<dynamic>?) ?? [];
        final serviceNames = servicesList
            .map((s) {
              if (s is Map) {
                return s['serviceName']?.toString() ??
                    s['name']?.toString() ??
                    'Service';
              }
              return 'Service';
            })
            .join(', ');

        num totalPrice = 0;
        for (var s in servicesList) {
          if (s is Map) {
            final p = s['price'];
            if (p is num) {
              totalPrice += p;
            } else if (p != null) {
              totalPrice += num.tryParse(p.toString()) ?? 0;
            }
          }
        }

        final formattedMap = <String, String>{
          'id': doc['id']?.toString() ?? '',
          'salon': doc['salonName']?.toString() ?? 'Salon',
          'service': serviceNames.isNotEmpty ? serviceNames : 'Salon Service',
          'date': doc['date']?.toString() ?? '',
          'time': doc['time']?.toString() ?? '',
          'status': doc['bookingStatus']?.toString() ?? 'Pending',
          'price': '₹${totalPrice.toStringAsFixed(2)}',
          'paymentMethod': doc['paymentMethod']?.toString() ?? 'card',
        };

        final status = (doc['bookingStatus']?.toString() ?? '').toLowerCase().trim();
        if (status == 'completed' || status == 'cancelled' || status == 'canceled') {
          history.add(formattedMap);
        } else {
          // 'pending', 'accepted', etc.
          upcoming.add(formattedMap);
        }
      }

      upcomingBookings.assignAll(upcoming);
      historyBookings.assignAll(history);
    } catch (e, stack) {
      debugPrint(
        '❌ [BookingsController] Error fetching bookings: $e\n$stack',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Kept for backwards compatibility with pull-to-refresh
  Future<void> syncAndFetchBookings() async {
    await fetchBookings();
  }

  void selectTab(int index) {
    selectedTab.value = index;
  }

  /// Immediately creates the booking document in Firestore.
  /// On success, updates local UI state directly without re-fetching all bookings.
  Future<bool> addBooking({
    required String salonId,
    required String salonName,
    required String date,
    required String time,
    required List<Map<String, dynamic>> services,
    required String paymentMethod,
    String bookingStatus = 'Pending',
  }) async {
    try {
      final serviceNames = services
          .map((s) => s['serviceName'] ?? s['name'] ?? s['title'] ?? 'Service')
          .join(', ');

      num totalPrice = 0;
      for (var s in services) {
        final p = s['price'];
        if (p is num) {
          totalPrice += p;
        } else if (p != null) {
          totalPrice += num.tryParse(p.toString()) ?? 0;
        }
      }

      // 1. Immediately create document in Firestore
      final docId = await BookingService.createBooking(
        salonId: salonId,
        salonName: salonName,
        date: date,
        time: time,
        services: services,
        paymentMethod: paymentMethod,
        bookingStatus: bookingStatus,
      );

      // 2. On success, update local UI state in memory without re-fetching
      upcomingBookings.insert(0, {
        'id': docId ?? '',
        'salon': salonName,
        'service': serviceNames.isNotEmpty ? serviceNames : 'Salon Service',
        'date': date,
        'time': time,
        'status': bookingStatus,
        'price': '₹${totalPrice.toStringAsFixed(2)}',
        'paymentMethod': paymentMethod,
      });
      selectedTab.value = 0;
      return true;
    } catch (e, stack) {
      debugPrint('❌ [BookingsController] Error creating booking: $e\n$stack');
      return false;
    }
  }
}
