import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/salon_model.dart';
import '../service/salon_service.dart';

class SalonsController extends GetxController {
  final RxList<SalonModel> salons = <SalonModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;

  // Search and Category observables
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;

  // Categories list
  final List<String> categories = ['All', 'Facial', 'Massage', 'Nails', 'Hair', 'Spa'];

  // Scroll controller for lazy-loading pagination
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _initSalons();

    // Scroll listener for pagination (loads next 10 salons near scroll end)
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        loadMoreSalons();
      }
    });
  }

  Future<void> _initSalons() async {
    if (SalonService.hasFetchedInitial && SalonService.cachedSalons.isNotEmpty) {
      salons.value = SalonService.cachedSalons;
      hasMore.value = SalonService.hasMore;
      return;
    }

    isLoading.value = true;
    final list = await SalonService.fetchInitialSalons();
    salons.value = List.from(list);
    hasMore.value = SalonService.hasMore;
    isLoading.value = false;
  }

  Future<void> loadMoreSalons() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;
    final list = await SalonService.fetchMoreSalons();
    salons.value = List.from(list);
    hasMore.value = SalonService.hasMore;
    isLoadingMore.value = false;
  }

  /// Backward-compatible list of salon Maps for UI views
  List<Map<String, dynamic>> get allSalons {
    return salons.map((s) => s.toMap()).toList();
  }

  /// Filtered list of salons matching category and search query
  List<SalonModel> get filteredSalons {
    final query = searchQuery.value.toLowerCase().trim();
    final category = selectedCategory.value.toLowerCase().trim();

    return salons.where((salon) {
      final matchesSearch = query.isEmpty ||
          salon.salonName.toLowerCase().contains(query) ||
          salon.address.toLowerCase().contains(query) ||
          salon.ownerName.toLowerCase().contains(query);

      final matchesCategory = category == 'all' ||
          salon.categories.any((c) => c.toLowerCase() == category);

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

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
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
    // 1. Try parsing services array directly from Firestore document data
    if (salonData['services'] != null && (salonData['services'] as List).isNotEmpty) {
      final rawList = salonData['services'] as List;
      final List<Map<String, dynamic>> parsedServices = [];

      for (var item in rawList) {
        if (item is Map) {
          final sName = item['serviceName']?.toString() ?? item['name']?.toString() ?? 'Service';
          final sPriceRaw = item['price'] ?? 50;
          final int sPrice = sPriceRaw is num
              ? sPriceRaw.toInt()
              : (int.tryParse(sPriceRaw.toString()) ?? 50);
          final sDuration = item['duration']?.toString() ?? '30 min';
          parsedServices.add({
            'name': sName,
            'price': sPrice,
            'duration': sDuration,
          });
        }
      }

      if (parsedServices.isNotEmpty) {
        availableServices = parsedServices;
        return;
      }
    }

    // 2. Fallback to generating categories-based services if services array is empty
    final List<String> categories = [];
    if (salonData['categories'] != null) {
      categories.addAll(List<String>.from(salonData['categories']));
    } else if (salonData['category'] != null) {
      categories.add(salonData['category'] as String);
    } else {
      final name = (salonData['salonName'] ?? salonData['name'] ?? '').toString().toLowerCase();
      if (name.contains('spa')) categories.add('Spa');
      if (name.contains('hair') || name.contains('boutique') || name.contains('skincare')) {
        categories.add('Hair');
      }
      if (name.contains('nail') || name.contains('studio')) categories.add('Nails');
      if (name.contains('wellness')) categories.addAll(['Massage', 'Spa']);
      if (categories.isEmpty) categories.add('Spa');
    }

    final List<Map<String, dynamic>> services = [];

    for (var cat in categories) {
      switch (cat) {
        case 'Facial':
        case 'facial':
          services.addAll([
            {'name': 'Signature Gold Facial', 'price': 85, 'duration': '45 min'},
            {'name': 'HydraFacial Skin Therapy', 'price': 120, 'duration': '60 min'},
          ]);
          break;
        case 'Massage':
        case 'massage':
          services.addAll([
            {'name': 'Swedish Relieving Massage', 'price': 95, 'duration': '60 min'},
            {'name': 'Deep Tissue Target Therapy', 'price': 115, 'duration': '75 min'},
          ]);
          break;
        case 'Nails':
        case 'nails':
          services.addAll([
            {'name': 'Luxury Gel Manicure', 'price': 50, 'duration': '35 min'},
            {'name': 'Paraffin Restoring Pedicure', 'price': 65, 'duration': '50 min'},
          ]);
          break;
        case 'Hair':
        case 'hair':
          services.addAll([
            {'name': 'Luxury Wash, Cut & Style', 'price': 70, 'duration': '40 min'},
            {'name': 'Keratin Intense Smooth Treatment', 'price': 150, 'duration': '120 min'},
          ]);
          break;
        case 'Spa':
        case 'spa':
          services.addAll([
            {'name': 'Nirvana Botanical Bath', 'price': 110, 'duration': '50 min'},
            {'name': 'Aromatherapy Mud Wrap', 'price': 130, 'duration': '70 min'},
          ]);
          break;
      }
    }

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
        total += (service['price'] is num ? (service['price'] as num).toDouble() : 0);
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
