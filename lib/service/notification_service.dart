import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// Top-level background message handler for Firebase Messaging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔥 [NotificationService] Background FCM message: ${message.messageId}');
}

/// Service handling FCM permissions and real-time booking status confirmation triggers.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _bookingSubscription;
  StreamSubscription<User?>? _authSubscription;

  /// Cache document ID -> previous status string
  final Map<String, String> _previousStatuses = {};

  /// Initializes FCM and listens to Auth/Booking changes.
  Future<void> initialize() async {
    try {
      debugPrint('🔔 [NotificationService] Initializing notification service...');

      // 1. Request FCM permissions from user
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('🔔 [NotificationService] FCM status: ${settings.authorizationStatus}');

      // 2. FCM token refresh listener
      _fcm.onTokenRefresh.listen((newToken) async {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance
              .collection('user')
              .doc(uid)
              .update({'pushToken': newToken});
        }
      });

      // 3. Listen to auth state changes to start/stop booking listener
      _authSubscription?.cancel();
      _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null) {
          _startBookingStatusListener(user.uid);
        } else {
          _stopBookingStatusListener();
        }
      });

      debugPrint('✅ [NotificationService] Notification service initialized successfully!');
    } catch (e, stack) {
      debugPrint('❌ [NotificationService] Initialization error: $e\n$stack');
    }
  }

  /// Listens to real-time status updates on user's bookings.
  void _startBookingStatusListener(String userId) {
    _stopBookingStatusListener();
    _previousStatuses.clear();

    _bookingSubscription = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
      (snapshot) async {
        for (var change in snapshot.docChanges) {
          final data = change.doc.data();
          if (data == null) continue;

          final docId = change.doc.id;
          final status = (data['bookingStatus'] as String? ?? '').trim();
          final salonName = data['salonName'] as String? ?? 'Salon';
          final date = data['date'] as String? ?? '';
          final time = data['time'] as String? ?? '';
          final salonId = data['salonId'] as String? ?? '';

          final previousStatus = _previousStatuses[docId];

          // Store initial status on load without triggering update
          if (change.type == DocumentChangeType.added) {
            _previousStatuses[docId] = status;
            continue;
          }

          _previousStatuses[docId] = status;

          final isNowConfirmed = status.toLowerCase() == 'confirmed';
          final wasNotConfirmed = previousStatus != null &&
              previousStatus.toLowerCase() != 'confirmed';

          // When booking status transitions from Pending to Confirmed
          if (isNowConfirmed && wasNotConfirmed) {
            debugPrint(
              '🎉 [NotificationService] Booking $docId confirmed! Populating sentAt on notification doc...',
            );

            await _markNotificationAsConfirmed(
              bookingId: docId,
              userId: userId,
              salonId: salonId,
              salonName: salonName,
              date: date,
              time: time,
            );
          }
        }
      },
      onError: (error) {
        debugPrint('❌ [NotificationService] Firestore listener error: $error');
      },
    );
  }

  /// Sets sentAt = Timestamp.now() on the staged notification document in Firestore.
  Future<void> _markNotificationAsConfirmed({
    required String bookingId,
    required String userId,
    required String salonId,
    required String salonName,
    required String date,
    required String time,
  }) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('notification')
          .where('bookingId', isEqualTo: bookingId)
          .limit(1)
          .get();

      final now = Timestamp.now();
      final title = 'Booking Confirmed! 🎉';
      final body =
          'Your appointment at $salonName for $date $time has been confirmed by the salon.';

      if (query.docs.isNotEmpty) {
        final docRef = query.docs.first.reference;
        await docRef.update({
          'sentAt': now,
          'notificationTitle': title,
          'notificationBody': body,
        });
        debugPrint('✅ [NotificationService] Staged notification updated with sentAt: ${docRef.id}');
      } else {
        // Fallback: create notification doc if it wasn't staged at creation
        final scheduledAt = _parseScheduledTimestamp(date, time);

        await FirebaseFirestore.instance.collection('notification').add({
          'bookingId': bookingId,
          'createdAt': now,
          'isRead': false,
          'notificationBody': body,
          'notificationTitle': title,
          'notificationType': 'booking_status',
          'salonId': salonId,
          'scheduledAt': scheduledAt,
          'sentAt': now,
          'userId': userId,
        });
        debugPrint('✅ [NotificationService] Fallback notification document created!');
      }
    } catch (e, st) {
      debugPrint('❌ [NotificationService] Error updating notification document: $e\n$st');
    }
  }

  static Timestamp _parseScheduledTimestamp(String dateStr, String timeStr) {
    try {
      int year = DateTime.now().year;
      int month = DateTime.now().month;
      int day = DateTime.now().day;
      int hour = 12;
      int minute = 0;

      final isoDate = DateTime.tryParse(dateStr);
      if (isoDate != null) {
        year = isoDate.year;
        month = isoDate.month;
        day = isoDate.day;
      } else {
        const monthMap = {
          'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
          'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
          'january': 1, 'february': 2, 'march': 3, 'april': 4, 'june': 6,
          'july': 7, 'august': 8, 'september': 9, 'october': 10, 'november': 11, 'december': 12
        };

        final yearMatch = RegExp(r'\b(20\d{2})\b').firstMatch(dateStr);
        if (yearMatch != null) {
          year = int.parse(yearMatch.group(1)!);
        }

        final dateLower = dateStr.toLowerCase();
        for (var entry in monthMap.entries) {
          if (dateLower.contains(entry.key)) {
            month = entry.value;
            break;
          }
        }

        final dateWithoutYear = dateStr.replaceAll(RegExp(r'\b20\d{2}\b'), '');
        final dayMatch = RegExp(r'\b([1-9]|[12]\d|3[01])\b').firstMatch(dateWithoutYear);
        if (dayMatch != null) {
          day = int.parse(dayMatch.group(1)!);
        }
      }

      final timeRegExp = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)?', caseSensitive: false);
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
      return Timestamp.now();
    }
  }

  void _stopBookingStatusListener() {
    _bookingSubscription?.cancel();
    _bookingSubscription = null;
    _previousStatuses.clear();
  }
}
