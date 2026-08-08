import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  /// Maps bookingId -> star rating (1-5) once the user has submitted a review.
  /// Loaded from Firestore on fetch and updated locally after submission.
  final RxMap<String, double> userRatings = <String, double>{}.obs;

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

      if (list.isEmpty) {
        upcomingBookings.assignAll(upcoming);
        historyBookings.assignAll(history);
        return;
      }

      // ── Batch query 1: fetch ALL transactions for these bookings in one shot ──
      final allBookingIds = list
          .map((d) => d['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      Map<String, Map<String, dynamic>> txMap = {};
      if (allBookingIds.isNotEmpty) {
        // Firestore whereIn supports max 30 items; chunk if needed
        for (int i = 0; i < allBookingIds.length; i += 30) {
          final chunk = allBookingIds.sublist(
            i,
            i + 30 > allBookingIds.length ? allBookingIds.length : i + 30,
          );
          final txSnap = await FirebaseFirestore.instance
              .collection('transactions')
              .where('bookingId', whereIn: chunk)
              .get();
          for (var doc in txSnap.docs) {
            final data = Map<String, dynamic>.from(doc.data());
            data['transactionId'] = doc.id;
            final bid = data['bookingId']?.toString() ?? '';
            if (bid.isNotEmpty) txMap[bid] = data;
          }
        }
      }

      // ── Parse bookings using txMap (no per-booking queries) ──
      final List<String> historyBookingIds = [];

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

        // Look up transaction from pre-fetched map — no extra query
        final tx = txMap[bookingId];
        final paymentStatus = tx?['paymentStatus']?.toString() ??
            (paymentMethod.toLowerCase().trim().contains('cash')
                ? 'pending'
                : 'completed');
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
          '_serviceNames': serviceNames, // temp key for review lookup below
        };

        final status =
            (doc['bookingStatus']?.toString() ?? '').toLowerCase().trim();
        if (status == 'completed' ||
            status == 'cancelled' ||
            status == 'canceled') {
          history.add(formattedMap);
          if (bookingId.isNotEmpty) historyBookingIds.add(bookingId);
        } else {
          upcoming.add(formattedMap);
        }
      }

      // ── Batch query 2: fetch ALL reviews for history bookings in one shot ──
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isNotEmpty && historyBookingIds.isNotEmpty) {
        // Build a lookup: salonId+serviceName -> rating
        // We query by userId only (no compound whereIn on multiple fields),
        // then filter locally by salonId+serviceName match.
        final historyItems = history.toList();
        final salonIds = historyItems
            .map((b) => b['salonId']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList();

        if (salonIds.isNotEmpty) {
          for (int i = 0; i < salonIds.length; i += 30) {
            final chunk = salonIds.sublist(
              i,
              i + 30 > salonIds.length ? salonIds.length : i + 30,
            );
            final reviewSnap = await FirebaseFirestore.instance
                .collection('reviews')
                .where('userId', isEqualTo: userId)
                .where('salonId', whereIn: chunk)
                .get();

            // Build a map: "salonId|serviceName" -> rating
            final reviewMap = <String, double>{};
            for (var doc in reviewSnap.docs) {
              final data = doc.data();
              final sid = data['salonId']?.toString() ?? '';
              final sn = data['serviceName']?.toString() ?? '';
              final r = data['ratings'];
              if (sid.isNotEmpty && sn.isNotEmpty && r is num) {
                reviewMap['$sid|$sn'] = r.toDouble();
              }
            }

            // Match to history bookings and populate userRatings
            for (var b in history) {
              final bid = b['id']?.toString() ?? '';
              if (bid.isEmpty) continue;
              final sid = b['salonId']?.toString() ?? '';
              final serviceNamesStr = b['_serviceNames']?.toString() ?? '';
              final firstService = serviceNamesStr.isNotEmpty
                  ? serviceNamesStr.split(', ').first
                  : '';
              final key = '$sid|$firstService';
              final rating = reviewMap[key];
              if (rating != null) {
                userRatings[bid] = rating;
              }
            }
          }
        }
      }

      // Clean up temporary _serviceNames key
      for (var b in history) {
        b.remove('_serviceNames');
      }
      for (var b in upcoming) {
        b.remove('_serviceNames');
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

  /// Called by the UI after the user successfully submits a review.
  /// Stores the rating locally so the Rate button is immediately replaced by stars.
  void setLocalRating(String bookingId, double rating) {
    userRatings[bookingId] = rating;
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

