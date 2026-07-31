import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationsController extends GetxController {
  final RxList<Map<String, dynamic>> notifications =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _listenToNotifications();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void _listenToNotifications() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;

    _subscription = FirebaseFirestore.instance
        .collection('notification')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen(
          (snapshot) {
            final List<Map<String, dynamic>> list = [];

            for (var doc in snapshot.docs) {
              final data = doc.data();

              // ONLY show notification if sentAt is NOT null (meaning it has been confirmed/sent)
              final sentAt = data['sentAt'] as Timestamp?;
              if (sentAt == null) continue;

              final isRead = data['isRead'] as bool? ?? false;
              final title =
                  data['notificationTitle'] as String? ?? 'Notification';
              final message = data['notificationBody'] as String? ?? '';
              final type = data['notificationType'] as String? ?? 'general';
              final scheduledAt = data['scheduledAt'] as Timestamp?;

              list.add({
                'id': doc.id,
                'title': title,
                'message': message,
                'time': _formatTime(sentAt),
                'sentAt': sentAt,
                'scheduledAt': scheduledAt,
                'icon': _getIconForType(type),
                'isUnread': !isRead,
                'bookingId': data['bookingId'] ?? '',
                'salonId': data['salonId'] ?? '',
              });
            }

            // Sort by sentAt descending
            list.sort((a, b) {
              final aTime = a['sentAt'] as Timestamp?;
              final bTime = b['sentAt'] as Timestamp?;
              if (aTime != null && bTime != null) {
                return bTime.compareTo(aTime);
              }
              return 0;
            });

            notifications.assignAll(list);
            isLoading.value = false;
          },
          onError: (error) {
            debugPrint(
              '❌ [NotificationsController] Firestore subscription error: $error',
            );
            isLoading.value = false;
          },
        );
  }

  bool get hasUnread => notifications.any((n) => n['isUnread'] == true);

  /// Marks a specific notification as read in Firestore
  Future<void> markAsRead(String docId) async {
    try {
      final index = notifications.indexWhere((n) => n['id'] == docId);
      if (index != -1 && notifications[index]['isUnread'] == false) {
        // Already read, skip redundant database write
        return;
      }

      await FirebaseFirestore.instance
          .collection('notification')
          .doc(docId)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('❌ [NotificationsController] Error marking as read: $e');
    }
  }

  /// Marks all unread notifications for the user as read in Firestore
  Future<void> markAllAsRead() async {
    try {
      if (!hasUnread) {
        return; // Skip database write if no unread notifications exist
      }

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('notification')
          .where('userId', isEqualTo: uid)
          .where('isRead', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('❌ [NotificationsController] Error marking all as read: $e');
    }
  }

  /// Opens Google Calendar web / app intent with title, description, and scheduled start/end dates
  Future<void> addToGoogleCalendar(Map<String, dynamic> item) async {
    try {
      const title = "Book'N'Glow: Salon Appointment 🎉";
      final description = item['message'] as String? ?? '';
      final Timestamp? scheduledAtTs = item['scheduledAt'] as Timestamp?;

      final DateTime startTime = scheduledAtTs != null
          ? scheduledAtTs.toDate()
          : DateTime.now().add(const Duration(hours: 1));
      final DateTime endTime = startTime.add(const Duration(hours: 1));

      String formatUtc(DateTime dt) {
        final utc = dt.toUtc();
        return '${utc.year}'
            '${utc.month.toString().padLeft(2, '0')}'
            '${utc.day.toString().padLeft(2, '0')}T'
            '${utc.hour.toString().padLeft(2, '0')}'
            '${utc.minute.toString().padLeft(2, '0')}'
            '${utc.second.toString().padLeft(2, '0')}Z';
      }

      final datesParam = '${formatUtc(startTime)}/${formatUtc(endTime)}';

      final Uri googleCalendarUri = Uri.parse(
        'https://calendar.google.com/calendar/render?'
        'action=TEMPLATE'
        '&text=${Uri.encodeComponent(title)}'
        '&details=${Uri.encodeComponent(description)}'
        '&dates=$datesParam',
      );

      debugPrint('📅 Opening Google Calendar URI: $googleCalendarUri');

      try {
        await launchUrl(
          googleCalendarUri,
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {
        await launchUrl(googleCalendarUri, mode: LaunchMode.platformDefault);
      }
    } catch (e, st) {
      debugPrint('❌ Error launching calendar: $e\n$st');
      final isChannelError =
          e.toString().contains('channel-error') ||
          e.toString().contains('Unable to establish connection');

      Get.snackbar(
        'Calendar Integration',
        isChannelError
            ? 'Please stop and restart the app (flutter run) to activate calendar launcher.'
            : 'Could not open Google Calendar.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF05352F),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'booking_status':
        return Icons.calendar_today_outlined;
      case 'offer':
        return Icons.local_offer_outlined;
      case 'reminder':
        return Icons.access_time_outlined;
      default:
        return Icons.stars_outlined;
    }
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      final day = date.day.toString().padLeft(2, '0');
      final month = _monthName(date.month);
      return '$day $month';
    }
  }

  String _monthName(int month) {
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
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}
