import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SalonsController extends GetxController {
  // Rich dataset of premium salons with multiple services/categories
  final List<Map<String, dynamic>> allSalons = [
    {
      'name': 'Aura Wellness & Spa',
      'rating': '4.9',
      'reviews': '124 reviews',
      'location': 'Downtown, Luxury Plaza',
      'categories': <String>['Spa', 'Massage', 'Facial'],
      'price': r'₹₹₹',
      'icon': Icons.spa_outlined,
      'isOpen': true,
    },
    {
      'name': 'Glow & Co. Hair Boutique',
      'rating': '4.8',
      'reviews': '98 reviews',
      'location': 'Westside Avenue, Lane 5',
      'categories': <String>['Hair', 'Nails'],
      'price': r'₹₹',
      'icon': Icons.content_cut_outlined,
      'isOpen': true,
    },
    {
      'name': 'Elegance Nail Studio',
      'rating': '4.7',
      'reviews': '86 reviews',
      'location': 'Midtown Shopping Arcade',
      'categories': <String>['Nails'],
      'price': r'₹₹',
      'icon': Icons.brush_outlined,
      'isOpen': false,
    },
    {
      'name': 'Zenith Facial & Skincare',
      'rating': '4.9',
      'reviews': '142 reviews',
      'location': 'Sunset Boulevard, Block B',
      'categories': <String>['Facial', 'Spa'],
      'price': r'₹₹₹',
      'icon': Icons.face_retouching_natural_outlined,
      'isOpen': true,
    },
    {
      'name': 'Rejuvenate Massage Center',
      'rating': '4.6',
      'reviews': '75 reviews',
      'location': 'East End, Royal Gardens',
      'categories': <String>['Massage', 'Spa'],
      'price': r'₹₹',
      'icon': Icons.spa_outlined,
      'isOpen': true,
    },
    {
      'name': 'Vogue Hair & Lounge',
      'rating': '4.7',
      'reviews': '112 reviews',
      'location': 'High Street, Fashion Hub',
      'categories': <String>['Hair', 'Nails', 'Facial'],
      'price': r'₹₹₹',
      'icon': Icons.content_cut_outlined,
      'isOpen': true,
    },
    {
      'name': 'Serene Nails & Oasis',
      'rating': '4.8',
      'reviews': '93 reviews',
      'location': 'Financial District, Mall 3',
      'categories': <String>['Nails', 'Spa'],
      'price': r'₹₹',
      'icon': Icons.brush_outlined,
      'isOpen': true,
    },
    {
      'name': 'Nirvana Luxury Bath & Spa',
      'rating': '5.0',
      'reviews': '210 reviews',
      'location': 'Plaza de Palms, Suite 400',
      'categories': <String>['Spa', 'Massage', 'Facial'],
      'price': r'₹₹₹₹',
      'icon': Icons.bathtub_outlined,
      'isOpen': true,
    },
  ];

  // Search and Category observables
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;

  // Categories list
  final List<String> categories = ['All', 'Facial', 'Massage', 'Nails', 'Hair', 'Spa'];

  // Dynamically computed filtered list of salons
  List<Map<String, dynamic>> get filteredSalons {
    final query = searchQuery.value.toLowerCase();
    final category = selectedCategory.value;

    return allSalons.where((salon) {
      final matchesSearch = salon['name'].toString().toLowerCase().contains(query) ||
          salon['location'].toString().toLowerCase().contains(query);
      final matchesCategory = category == 'All' ||
          (salon['categories'] as List<String>).contains(category);
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void updateCategory(String category) {
    selectedCategory.value = category;
  }

  void clearSearch() {
    searchQuery.value = '';
  }
}

class SalonDetailController extends GetxController {
  final Map<String, dynamic> salonData;

  SalonDetailController(this.salonData);

  // Available lists
  final List<DateTime> availableDates = [];
  final List<String> availableTimes = [
    "09:30 AM",
    "11:30 AM",
    "02:00 PM",
    "04:30 PM",
    "06:30 PM"
  ];
  List<Map<String, dynamic>> availableServices = [];

  // Observables
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final RxString selectedTime = ''.obs;
  final RxSet<String> selectedServices = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _generateDates();
    _generateServices();
  }

  void _generateDates() {
    final today = DateTime.now();
    for (int i = 0; i < 7; i++) {
      availableDates.add(today.add(Duration(days: i)));
    }
  }

  void _generateServices() {
    final List<String> categories = [];
    
    // Parse categories from data
    if (salonData['categories'] != null) {
      categories.addAll(List<String>.from(salonData['categories']));
    } else if (salonData['category'] != null) {
      categories.add(salonData['category'] as String);
    } else {
      // Default fallback categories based on name matching
      final name = salonData['name'].toString().toLowerCase();
      if (name.contains('spa')) categories.add('Spa');
      if (name.contains('hair') || name.contains('boutique')) categories.add('Hair');
      if (name.contains('nail') || name.contains('studio')) categories.add('Nails');
      if (name.contains('wellness')) categories.addAll(['Massage', 'Spa']);
      if (categories.isEmpty) categories.add('Spa'); // ultimate fallback
    }

    final List<Map<String, dynamic>> services = [];

    // Add category-specific services
    for (var cat in categories) {
      switch (cat) {
        case 'Facial':
          services.addAll([
            {'name': 'Signature Gold Facial', 'price': 85, 'duration': '45 min'},
            {'name': 'HydraFacial Skin Therapy', 'price': 120, 'duration': '60 min'},
          ]);
          break;
        case 'Massage':
          services.addAll([
            {'name': 'Swedish Relieving Massage', 'price': 95, 'duration': '60 min'},
            {'name': 'Deep Tissue Target Therapy', 'price': 115, 'duration': '75 min'},
          ]);
          break;
        case 'Nails':
          services.addAll([
            {'name': 'Luxury Gel Manicure', 'price': 50, 'duration': '35 min'},
            {'name': 'Paraffin Restoring Pedicure', 'price': 65, 'duration': '50 min'},
          ]);
          break;
        case 'Hair':
          services.addAll([
            {'name': 'Luxury Wash, Cut & Style', 'price': 70, 'duration': '40 min'},
            {'name': 'Keratin Intense Smooth Treatment', 'price': 150, 'duration': '120 min'},
          ]);
          break;
        case 'Spa':
          services.addAll([
            {'name': 'Nirvana Botanical Bath', 'price': 110, 'duration': '50 min'},
            {'name': 'Aromatherapy Mud Wrap', 'price': 130, 'duration': '70 min'},
          ]);
          break;
      }
    }

    // If no service added, add basic spa package
    if (services.isEmpty) {
      services.addAll([
        {'name': 'Aura Wellness Package', 'price': 140, 'duration': '90 min'},
        {'name': 'Quick Glow Touch Up', 'price': 45, 'duration': '30 min'},
      ]);
    }

    availableServices = services;
  }

  // Computed totalPrice
  double get totalPrice {
    double total = 0;
    for (var service in availableServices) {
      if (selectedServices.contains(service['name'])) {
        total += service['price'] as int;
      }
    }
    return total;
  }

  void toggleService(String serviceName) {
    if (selectedServices.contains(serviceName)) {
      selectedServices.remove(serviceName);
    } else {
      selectedServices.add(serviceName);
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  void selectTime(String timeSlot) {
    selectedTime.value = timeSlot;
  }

  bool get isBookingValid {
    return selectedDate.value != null &&
        selectedTime.value.isNotEmpty &&
        selectedServices.isNotEmpty;
  }
}
