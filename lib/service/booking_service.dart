import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'user_service.dart';
import 'transaction_service.dart';

/// Handles all Firestore operations for the `bookings` collection.
class BookingService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Reference to the `bookings` collection.
  static CollectionReference<Map<String, dynamic>> get _bookingsCol =>
      _db.collection('bookings');

  /// Creates a new booking document in the Firestore `bookings` collection.
  static Future<String?> createBooking({
    required String salonId,
    required String salonName,
    required String date,
    required String time,
    required List<Map<String, dynamic>> services,
    required String paymentMethod,
    String bookingStatus = 'Pending',
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final cachedUser = UserService.cachedUser;

      final userId = user?.uid ?? '';
      final userName = (cachedUser?.name.isNotEmpty == true)
          ? cachedUser!.name
          : (user?.displayName?.isNotEmpty == true
                ? user!.displayName!
                : 'Guest User');

      // Transform services list to match Firestore array of maps schema
      final List<Map<String, dynamic>> firestoreServices = services.map((s) {
        final serviceName =
            s['serviceName']?.toString() ??
            s['name']?.toString() ??
            s['title']?.toString() ??
            'Service';
        final duration = s['duration']?.toString() ?? '';
        final num rawPrice = s['price'] is num
            ? s['price'] as num
            : (num.tryParse(s['price']?.toString() ?? '0') ?? 0);

        return {
          'duration': duration,
          'price': rawPrice.toInt(),
          'serviceName': serviceName,
        };
      }).toList();

      final bookingData = <String, dynamic>{
        'bookingStatus': bookingStatus,
        'createdAt': Timestamp.now(),
        'date': date,
        'isLocked': false,
        'paymentMethod': paymentMethod,
        'salonId': salonId,
        'salonName': salonName,
        'services': firestoreServices,
        'time': time,
        'userId': userId,
        'userName': userName,
      };

      debugPrint(
        '🔥 [BookingService] Writing booking to Firestore: $bookingData',
      );
      final docRef = await _bookingsCol.add(bookingData);
      clearSalonBookingsCache(salonId);
      debugPrint(
        '✅ [BookingService] Booking document created with ID: ${docRef.id}',
      );

      // Create transaction document in 'transactions' collection
      try {
        int totalAmountInt = 0;
        for (var s in firestoreServices) {
          final p = s['price'];
          if (p is num) {
            totalAmountInt += p.toInt();
          }
        }

        final txId = await TransactionService.createTransaction(
          bookingId: docRef.id,
          salonId: salonId,
          salonName: salonName,
          amount: totalAmountInt,
          paymentMethod: paymentMethod,
          userId: userId,
          userName: userName,
        );
        debugPrint(
          '✅ [BookingService] Transaction document created with ID: $txId',
        );
      } catch (txErr) {
        debugPrint(
          '⚠️ [BookingService] Error creating transaction document: $txErr',
        );
      }

      // Create staged notification document in 'notification' collection (sentAt = null until confirmed)
      try {
        final scheduledAtTimestamp = _parseScheduledTimestamp(date, time);

        final notificationData = <String, dynamic>{
          'bookingId': docRef.id,
          'createdAt': Timestamp.now(),
          'isRead': false,
          'notificationBody':
              'Your appointment at $salonName for $date $time has been confirmed by the salon.',
          'notificationTitle': 'Booking Confirmed! 🎉',
          'notificationType': 'booking_status',
          'salonId': salonId,
          'scheduledAt': scheduledAtTimestamp,
          'sentAt': null,
          'userId': userId,
        };

        await _db.collection('notification').add(notificationData);
        debugPrint(
          '✅ [BookingService] Staged notification created with scheduledAt: $scheduledAtTimestamp for bookingId: ${docRef.id}',
        );
      } catch (nErr) {
        debugPrint(
          '⚠️ [BookingService] Error creating staged notification: $nErr',
        );
      }

      return docRef.id;
    } catch (e, stack) {
      debugPrint(
        '❌ [BookingService] ERROR creating booking document: $e\n$stack',
      );
      rethrow;
    }
  }

  /// Parses date and time strings (e.g. "Mon, Aug 3, 2026" & "6:00 PM") into a Firestore Timestamp for scheduledAt
  static Timestamp _parseScheduledTimestamp(String dateStr, String timeStr) {
    try {
      int year = DateTime.now().year;
      int month = DateTime.now().month;
      int day = DateTime.now().day;
      int hour = 12;
      int minute = 0;

      // 1. Try standard ISO parse first
      final isoDate = DateTime.tryParse(dateStr);
      if (isoDate != null) {
        year = isoDate.year;
        month = isoDate.month;
        day = isoDate.day;
      } else {
        // 2. Parse human-formatted date strings like "Mon, Aug 3, 2026", "Aug 3, 2026", "3 Aug 2026"
        const monthMap = {
          'jan': 1,
          'feb': 2,
          'mar': 3,
          'apr': 4,
          'may': 5,
          'jun': 6,
          'jul': 7,
          'aug': 8,
          'sep': 9,
          'oct': 10,
          'nov': 11,
          'dec': 12,
          'january': 1,
          'february': 2,
          'march': 3,
          'april': 4,
          'june': 6,
          'july': 7,
          'august': 8,
          'september': 9,
          'october': 10,
          'november': 11,
          'december': 12,
        };

        // Extract year (4 digits starting with 20)
        final yearMatch = RegExp(r'\b(20\d{2})\b').firstMatch(dateStr);
        if (yearMatch != null) {
          year = int.parse(yearMatch.group(1)!);
        }

        // Extract month name
        final dateLower = dateStr.toLowerCase();
        for (var entry in monthMap.entries) {
          if (dateLower.contains(entry.key)) {
            month = entry.value;
            break;
          }
        }

        // Extract day number (1 or 2 digits)
        final dateWithoutYear = dateStr.replaceAll(RegExp(r'\b20\d{2}\b'), '');
        final dayMatch = RegExp(
          r'\b([1-9]|[12]\d|3[01])\b',
        ).firstMatch(dateWithoutYear);
        if (dayMatch != null) {
          day = int.parse(dayMatch.group(1)!);
        }
      }

      // 3. Parse timeStr (e.g. "6:00 PM", "06:00 PM", "18:00")
      final timeRegExp = RegExp(
        r'(\d{1,2}):(\d{2})\s*(AM|PM)?',
        caseSensitive: false,
      );
      final timeMatch = timeRegExp.firstMatch(timeStr);
      if (timeMatch != null) {
        hour = int.parse(timeMatch.group(1)!);
        minute = int.parse(timeMatch.group(2)!);
        final period = timeMatch.group(3)?.toUpperCase();

        if (period == 'PM' && hour < 12) {
          hour += 12;
        } else if (period == 'AM' && hour == 12) {
          hour = 0;
        }
      }

      final scheduledDateTime = DateTime(year, month, day, hour, minute);
      return Timestamp.fromDate(scheduledDateTime);
    } catch (e) {
      debugPrint('⚠️ Error parsing scheduledAt: $e');
      return Timestamp.now();
    }
  }

  /// One-shot fetch (NO real-time listeners) of all bookings for the currently logged-in user.
  static Future<List<Map<String, dynamic>>> getUserBookings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return [];
    }

    final snapshot = await _bookingsCol.where('userId', isEqualTo: uid).get();

    final list = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    // Sort by createdAt descending
    list.sort((a, b) {
      final aTime = a['createdAt'] as Timestamp?;
      final bTime = b['createdAt'] as Timestamp?;
      if (aTime != null && bTime != null) {
        return bTime.compareTo(aTime);
      }
      return 0;
    });

    return list;
  }

  // In-memory cache for salon booked slots: salonId -> list of booking maps
  static final Map<String, List<Map<String, dynamic>>> _cachedSalonBookings =
      {};
  static final Map<String, DateTime> _cachedSalonBookingsTimestamp = {};

  /// Clears all in-memory bookings cache (e.g. on user logout)
  static void clearCache() {
    _cachedSalonBookings.clear();
    _cachedSalonBookingsTimestamp.clear();
  }

  /// Clears the in-memory salon bookings cache
  static void clearSalonBookingsCache([String? salonId]) {
    if (salonId != null) {
      _cachedSalonBookings.remove(salonId);
      _cachedSalonBookingsTimestamp.remove(salonId);
    } else {
      clearCache();
    }
  }

  /// One-shot fetch of all bookings for a specific salon with in-memory cache (5-minute TTL).
  /// If forceRefresh is false and data is cached recently, returns cache with 0 Firestore read calls.
  static Future<List<Map<String, dynamic>>> getBookingsForSalon(
    String salonId, {
    bool forceRefresh = false,
  }) async {
    if (salonId.isEmpty) return [];

    final cached = _cachedSalonBookings[salonId];
    final cachedTime = _cachedSalonBookingsTimestamp[salonId];

    // Return cached list if available and within 5 minutes, unless forceRefresh is requested
    if (!forceRefresh &&
        cached != null &&
        cachedTime != null &&
        DateTime.now().difference(cachedTime).inMinutes < 5) {
      debugPrint(
        '⚡ [BookingService] Returning cached bookings for salon $salonId without DB call (${cached.length} records).',
      );
      return cached;
    }

    try {
      debugPrint(
        '🔥 [BookingService] Fetching confirmed bookings for salon $salonId from Firestore...',
      );
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        // Query ONLY confirmed/accepted bookings to minimize Firestore document reads
        snapshot = await _bookingsCol
            .where('salonId', isEqualTo: salonId)
            .where(
              'bookingStatus',
              whereIn: ['Confirmed', 'confirmed', 'Accepted', 'accepted'],
            )
            .get();
      } catch (filterErr) {
        log(
          '⚠️ [BookingService] Filtered query fallback to salonId only: $filterErr',
        );
        snapshot = await _bookingsCol
            .where('salonId', isEqualTo: salonId)
            .get();
      }

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      _cachedSalonBookings[salonId] = list;
      _cachedSalonBookingsTimestamp[salonId] = DateTime.now();

      debugPrint(
        '✅ [BookingService] Cached ${list.length} active/confirmed bookings for salon $salonId.',
      );
      return list;
    } catch (e) {
      debugPrint(
        '❌ [BookingService] Error fetching bookings for salon $salonId: $e',
      );
      return cached ?? [];
    }
  }
}
