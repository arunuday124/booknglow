import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../service/booking_service.dart';
import '../service/transaction_service.dart';

class BookingsController extends GetxController {
  // 0 for Upcoming, 1 for History
  final RxInt selectedTab = 0.obs;

  // Dynamic upcoming and history bookings lists
  final RxList<Map<String, dynamic>> upcomingBookings =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> historyBookings =
      <Map<String, dynamic>>[].obs;
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
      final List<Map<String, dynamic>> upcoming = [];
      final List<Map<String, dynamic>> history = [];

      for (var doc in list) {
        final bookingId = doc['id']?.toString() ?? '';
        final servicesList = (doc['services'] as List<dynamic>?) ?? [];
        final List<Map<String, dynamic>> parsedServices = [];
        for (var s in servicesList) {
          if (s is Map) {
            parsedServices.add(Map<String, dynamic>.from(s));
          }
        }

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

        if (parsedServices.isEmpty) {
          final fallbackName = doc['serviceName']?.toString() ??
              doc['service']?.toString() ??
              doc['name']?.toString() ??
              'Salon Service';
          final fallbackPrice = totalPrice > 0 ? totalPrice : 0;
          parsedServices.add({
            'serviceName': fallbackName,
            'name': fallbackName,
            'price': fallbackPrice,
            'duration': '30 mins',
          });
        }

        final serviceNames = parsedServices
            .map((s) =>
                s['serviceName']?.toString() ??
                s['name']?.toString() ??
                s['title']?.toString() ??
                'Service')
            .join(', ');

        final paymentMethod = doc['paymentMethod']?.toString() ?? 'card';
        
        // Fetch matching transaction to get current paymentStatus
        final tx = await TransactionService.getTransactionByBookingId(bookingId);
        final paymentStatus = tx?['paymentStatus']?.toString() ??
            (paymentMethod.toLowerCase().trim().contains('cash') ? 'pending' : 'completed');
        final transactionId = tx?['transactionId']?.toString() ?? '';

        final formattedMap = <String, dynamic>{
          'id': bookingId,
          'salonId': doc['salonId']?.toString() ?? '',
          'salon': doc['salonName']?.toString() ?? 'Salon',
          'salonLocation': doc['salonLocation']?.toString() ?? '',
          'service': serviceNames.isNotEmpty ? serviceNames : 'Salon Service',
          'services': parsedServices,
          'rawPrice': totalPrice.toDouble(),
          'date': doc['date']?.toString() ?? '',
          'time': doc['time']?.toString() ?? '',
          'status': doc['bookingStatus']?.toString() ?? 'Pending',
          'price': '₹${totalPrice.toStringAsFixed(2)}',
          'paymentMethod': paymentMethod,
          'paymentStatus': paymentStatus,
          'transactionId': transactionId,
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

  /// Marks a pending cash payment as completed in Firestore transactions collection
  /// and updates local state.
  Future<bool> markPaymentAsComplete(String bookingId, {String? transactionId}) async {
    try {
      final success = await TransactionService.markPaymentAsComplete(
        transactionId: transactionId,
        bookingId: bookingId,
      );

      if (success) {
        for (var b in upcomingBookings) {
          if (b['id'] == bookingId) {
            b['paymentStatus'] = 'completed';
            break;
          }
        }
        for (var b in historyBookings) {
          if (b['id'] == bookingId) {
            b['paymentStatus'] = 'completed';
            break;
          }
        }
        upcomingBookings.refresh();
        historyBookings.refresh();
        return true;
      }
    } catch (e, stack) {
      debugPrint('❌ [BookingsController] Error completing cash payment: $e\n$stack');
    }
    return false;
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

      final isCash = paymentMethod.toLowerCase().trim().contains('cash');
      final initialPaymentStatus = isCash ? 'pending' : 'completed';

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
        'salonId': salonId,
        'salon': salonName,
        'salonLocation': '',
        'service': serviceNames.isNotEmpty ? serviceNames : 'Salon Service',
        'services': services,
        'rawPrice': totalPrice.toDouble(),
        'date': date,
        'time': time,
        'status': bookingStatus,
        'price': '₹${totalPrice.toStringAsFixed(2)}',
        'paymentMethod': paymentMethod,
        'paymentStatus': initialPaymentStatus,
        'transactionId': '',
      });
      selectedTab.value = 0;
      return true;
    } catch (e, stack) {
      debugPrint('❌ [BookingsController] Error creating booking: $e\n$stack');
      return false;
    }
  }
}

