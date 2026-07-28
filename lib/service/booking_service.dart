import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'user_service.dart';

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
      debugPrint(
        '✅ [BookingService] Booking document created with ID: ${docRef.id}',
      );
      return docRef.id;
    } catch (e, stack) {
      debugPrint(
        '❌ [BookingService] ERROR creating booking document: $e\n$stack',
      );
      rethrow;
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
}
