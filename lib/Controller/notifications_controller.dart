import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[
    {
      'id': '1',
      'title': 'Booking Confirmed!',
      'message': 'Your appointment at Aura Wellness & Spa is confirmed for Sat, July 25th at 02:00 PM.',
      'time': '10m ago',
      'icon': Icons.calendar_today_outlined,
      'isUnread': true,
    },
    {
      'id': '2',
      'title': 'Exclusive 20% OFF Offer',
      'message': 'Unlock 20% off on all HydraFacial & Gold Skin Therapies this weekend!',
      'time': '2h ago',
      'icon': Icons.local_offer_outlined,
      'isUnread': true,
    },
    {
      'id': '3',
      'title': 'Reminder: Upcoming Visit',
      'message': 'Don\'t forget your appointment tomorrow at Elegance Nail Studio at 11:30 AM.',
      'time': 'Yesterday',
      'icon': Icons.access_time_outlined,
      'isUnread': false,
    },
    {
      'id': '4',
      'title': 'Welcome to BookNGlow',
      'message': 'Thank you for joining BookNGlow Premium. Discover top-rated luxury salons near you!',
      'time': '3 days ago',
      'icon': Icons.stars_outlined,
      'isUnread': false,
    },
  ].obs;

  bool get hasUnread => notifications.any((n) => n['isUnread'] == true);

  void markAllAsRead() {
    for (var n in notifications) {
      n['isUnread'] = false;
    }
    notifications.refresh();
  }

  void markAsRead(int index) {
    notifications[index]['isUnread'] = false;
    notifications.refresh();
  }
}
