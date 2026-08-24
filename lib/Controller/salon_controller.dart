import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/salon_model.dart';
import '../service/salon_service.dart';
import '../service/booking_service.dart';

class SalonsController extends GetxController {
  static const String _genderPrefKey = 'selected_gender';

  final RxList<SalonModel> salons = <SalonModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;

  // Search, Category and Gender observables
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString selectedGender = 'Female'.obs;

  Future<void> toggleGender() async {
    if (selectedGender.value == 'Female') {
      selectedGender.value = 'Male';
    } else {
      selectedGender.value = 'Female';
    }
    await _saveGenderPreference(selectedGender.value);
  }

  Future<void> setGender(String gender) async {
    selectedGender.value = gender;
    await _saveGenderPreference(gender);
  }

  Future<void> _loadSavedGenderPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedGender = prefs.getString(_genderPrefKey);
      if (savedGender != null && (savedGender == 'Female' || savedGender == 'Male')) {
        selectedGender.value = savedGender;
      } else {
        // Default stays Female and is saved to preferences
        selectedGender.value = 'Female';
        await prefs.setString(_genderPrefKey, 'Female');
      }
    } catch (e) {
      debugPrint('Error loading gender preference: $e');
    }
  }

  Future<void> _saveGenderPreference(String gender) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_genderPrefKey, gender);
    } catch (e) {
      debugPrint('Error saving gender preference: $e');
    }
  }

  // Categories list
  final List<String> categories = [
    'All',
    'Facial',
    'Massage',
    'Nails',
    'Hair',
    'Spa',
  ];

  // Scroll controller for lazy-loading pagination
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _loadSavedGenderPreference();
    _initSalons();

    // Scroll listener for pagination (loads next 10 salons near scroll end)
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        loadMoreSalons();
      }
    });
  }

  Future<void> _initSalons() async {
    if (SalonService.hasFetchedInitial &&
        SalonService.cachedSalons.isNotEmpty) {
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

  Future<void> refreshSalons() async {
    final list = await SalonService.fetchInitialSalons(forceRefresh: true);
    salons.value = List.from(list);
    hasMore.value = SalonService.hasMore;
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

  /// Recommended salons for Home Screen matching selected gender toggle ('Male' / 'Female')
  List<SalonModel> get recommendedSalons {
    final currentGender = selectedGender.value.toLowerCase().trim();

    return salons.where((salon) {
      final type = salon.salonType.toLowerCase().trim();
      if (type.isNotEmpty && type != 'unisex') {
        if (currentGender == 'male' && type != 'male') {
          return false;
        }
        if (currentGender == 'female' && type != 'female') {
          return false;
        }
      }
      return true;
    }).toList();
  }

  /// Filtered list of salons matching gender toggle ('Male' / 'Female'), category and search query
  List<SalonModel> get filteredSalons {
    final query = searchQuery.value.toLowerCase().trim();
    final category = selectedCategory.value.toLowerCase().trim();
    final currentGender = selectedGender.value.toLowerCase().trim(); // 'male' or 'female'

    return salons.where((salon) {
      // 1. Gender filtering based on salonType ('male', 'female', or 'unisex')
      // 'male' toggle shows male & unisex salons
      // 'female' toggle shows female & unisex salons
      final type = salon.salonType.toLowerCase().trim();
      if (type.isNotEmpty && type != 'unisex') {
        if (currentGender == 'male' && type != 'male') {
          return false;
        }
        if (currentGender == 'female' && type != 'female') {
          return false;
        }
      }

      // 2. Fast category check first
      if (category != 'all' &&
          !salon.categories.any((c) => c.toLowerCase() == category)) {
        return false;
      }

      // 3. Short-circuit search query check
      if (query.isEmpty) return true;

      return salon.salonName.toLowerCase().contains(query) ||
          salon.address.toLowerCase().contains(query) ||
          salon.ownerName.toLowerCase().contains(query);
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
  final List<String> availableTimes = [];
  List<Map<String, dynamic>> availableServices = [];

  // Observables
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final RxString selectedTime = ''.obs;
  final RxSet<String> selectedServices = <String>{}.obs;
  final RxSet<String> lockedTimeSlots = <String>{}.obs;

  List<Map<String, dynamic>> _salonBookingsDocs = [];

  @override
  void onInit() {
    super.onInit();
    _generateDates();
    _generateTimes();
    _generateServices();
    fetchBookedSlots();

    // Re-evaluate locked slots whenever selectedDate changes
    ever(selectedDate, (_) => _reevaluateLockedSlots());
  }

  void _generateDates() {
    availableDates.clear();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (int i = 0; i < 7; i++) {
      availableDates.add(today.add(Duration(days: i)));
    }
  }

  void _generateTimes() {
    availableTimes.clear();

    String openStr =
        (salonData['openingHours'] ??
                salonData['opening_hours'] ??
                salonData['openingTime'] ??
                '9 AM')
            .toString()
            .trim();
    String closeStr =
        (salonData['closingHours'] ??
                salonData['closing_hours'] ??
                salonData['closingTime'] ??
                '10 PM')
            .toString()
            .trim();

    if (openStr.contains('-') &&
        (closeStr.isEmpty || closeStr == openStr || closeStr == '10 PM')) {
      final parts = openStr.split('-');
      openStr = parts[0].trim();
      closeStr = parts[1].trim();
    }

    final openMinutes = _parseToMinutes(openStr) ?? (9 * 60);
    final closeMinutes = _parseToMinutes(closeStr) ?? (22 * 60);

    int start = openMinutes;
    int end = closeMinutes;

    if (end <= start) {
      end += 24 * 60;
    }

    for (int current = start; current <= end; current += 30) {
      final totalMins = current % (24 * 60);
      final hour = totalMins ~/ 60;
      final min = totalMins % 60;

      final period = hour >= 12 ? 'PM' : 'AM';
      int displayHour = hour % 12;
      if (displayHour == 0) displayHour = 12;

      final formattedHour = displayHour.toString().padLeft(2, '0');
      final formattedMin = min.toString().padLeft(2, '0');

      availableTimes.add('$formattedHour:$formattedMin $period');
    }
  }

  int? _parseToMinutes(String timeStr) {
    if (timeStr.isEmpty) return null;

    final upper = timeStr.toUpperCase();
    final isPM = upper.contains('PM');
    final isAM = upper.contains('AM');

    final cleanStr = upper.replaceAll(RegExp(r'[^0-9:]'), '').trim();
    if (cleanStr.isEmpty) return null;

    final parts = cleanStr.split(':');
    int hour = int.tryParse(parts[0]) ?? 0;
    int minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    if (isPM && hour < 12) {
      hour += 12;
    } else if (isAM && hour == 12) {
      hour = 0;
    }

    return hour * 60 + minute;
  }

  void _generateServices() {
    // 1. Try parsing services array directly from Firestore document data
    if (salonData['services'] != null &&
        (salonData['services'] as List).isNotEmpty) {
      final rawList = salonData['services'] as List;
      final List<Map<String, dynamic>> parsedServices = [];

      for (var item in rawList) {
        if (item is Map) {
          final sName =
              item['serviceName']?.toString() ??
              item['name']?.toString() ??
              'Service';
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

    availableServices = [];

    /*
    // 2. Fallback to generating categories-based services if services array is empty
    final List<String> categories = [];
    if (salonData['categories'] != null) {
      categories.addAll(List<String>.from(salonData['categories']));
    } else if (salonData['category'] != null) {
      categories.add(salonData['category'] as String);
    } else {
      final name = (salonData['salonName'] ?? salonData['name'] ?? '')
          .toString()
          .toLowerCase();
      if (name.contains('spa')) categories.add('Spa');
      if (name.contains('hair') ||
          name.contains('boutique') ||
          name.contains('skincare')) {
        categories.add('Hair');
      }
      if (name.contains('nail') || name.contains('studio'))
        categories.add('Nails');
      if (name.contains('wellness')) categories.addAll(['Massage', 'Spa']);
      if (categories.isEmpty) categories.add('Spa');
    }

    final List<Map<String, dynamic>> services = [];

    for (var cat in categories) {
      switch (cat) {
        case 'Facial':
        case 'facial':
          services.addAll([
            {
              'name': 'Signature Gold Facial',
              'price': 85,
              'duration': '45 min',
            },
            {
              'name': 'HydraFacial Skin Therapy',
              'price': 120,
              'duration': '60 min',
            },
          ]);
          break;
        case 'Massage':
        case 'massage':
          services.addAll([
            {
              'name': 'Swedish Relieving Massage',
              'price': 95,
              'duration': '60 min',
            },
            {
              'name': 'Deep Tissue Target Therapy',
              'price': 115,
              'duration': '75 min',
            },
          ]);
          break;
        case 'Nails':
        case 'nails':
          services.addAll([
            {'name': 'Luxury Gel Manicure', 'price': 50, 'duration': '35 min'},
            {
              'name': 'Paraffin Restoring Pedicure',
              'price': 65,
              'duration': '50 min',
            },
          ]);
          break;
        case 'Hair':
        case 'hair':
          services.addAll([
            {
              'name': 'Luxury Wash, Cut & Style',
              'price': 70,
              'duration': '40 min',
            },
            {
              'name': 'Keratin Intense Smooth Treatment',
              'price': 150,
              'duration': '120 min',
            },
          ]);
          break;
        case 'Spa':
        case 'spa':
          services.addAll([
            {
              'name': 'Nirvana Botanical Bath',
              'price': 110,
              'duration': '50 min',
            },
            {
              'name': 'Aromatherapy Mud Wrap',
              'price': 130,
              'duration': '70 min',
            },
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
    */
  }

  // Computed totalPrice
  double get totalPrice {
    selectedServices.length; // Access Rx list so Obx observers always register even when availableServices is empty
    double total = 0;
    for (var service in availableServices) {
      if (selectedServices.contains(service['name'])) {
        total += (service['price'] is num
            ? (service['price'] as num).toDouble()
            : 0);
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

  Future<void> fetchBookedSlots({bool forceRefresh = false}) async {
    final salonId =
        (salonData['salonId'] ?? salonData['id'] ?? salonData['name'] ?? '')
            .toString();
    if (salonId.isEmpty) return;

    try {
      _salonBookingsDocs = await BookingService.getBookingsForSalon(
        salonId,
        forceRefresh: forceRefresh,
      );
      _reevaluateLockedSlots();
    } catch (e) {
      debugPrint(
        '⚠️ [SalonDetailController] Error fetching salon bookings: $e',
      );
    }
  }

  void _reevaluateLockedSlots() {
    lockedTimeSlots.clear();
    final date = selectedDate.value;
    if (date == null || _salonBookingsDocs.isEmpty) return;

    for (var doc in _salonBookingsDocs) {
      final status = (doc['bookingStatus']?.toString() ?? '')
          .toLowerCase()
          .trim();
      // Lock slot ONLY if bookingStatus is "Confirmed"
      if (status != 'confirmed') {
        continue;
      }

      final docDateRaw = doc['date']?.toString() ?? '';
      final docTimeRaw = doc['time']?.toString() ?? '';

      if (_isSameDate(docDateRaw, date)) {
        final normalizedDocTime = _normalizeTime(docTimeRaw);
        if (normalizedDocTime != null) {
          for (var slot in availableTimes) {
            if (_normalizeTime(slot) == normalizedDocTime) {
              lockedTimeSlots.add(slot);
            }
          }
        }
      }
    }

    // If currently selected time is now locked or not available, clear selection
    if (selectedTime.isNotEmpty &&
        (lockedTimeSlots.contains(selectedTime.value) ||
            !filteredAvailableTimes.contains(selectedTime.value))) {
      selectedTime.value = '';
    }
  }

  bool isSlotLocked(String timeSlot) {
    return lockedTimeSlots.contains(timeSlot);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Returns time slots filtered by current time if today is selected,
  /// or all available times for future dates.
  List<String> get filteredAvailableTimes {
    final date = selectedDate.value;
    if (date == null) {
      return availableTimes;
    }

    if (!_isToday(date)) {
      return availableTimes;
    }

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    return availableTimes.where((slot) {
      final slotMinutes = _parseToMinutes(slot);
      if (slotMinutes == null) return true;
      return slotMinutes > currentMinutes;
    }).toList();
  }

  bool _isSameDate(String docDateRaw, DateTime target) {
    if (docDateRaw.isEmpty) return false;
    final docLower = docDateRaw.toLowerCase().trim();

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
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
    final formatted1 =
        "${days[target.weekday - 1]}, ${months[target.month - 1]} ${target.day}, ${target.year}"
            .toLowerCase();

    if (docLower == formatted1) return true;

    final formatted2 =
        "${target.year}-${target.month.toString().padLeft(2, '0')}-${target.day.toString().padLeft(2, '0')}"
            .toLowerCase();
    if (docLower == formatted2) return true;

    final parsed = DateTime.tryParse(docDateRaw);
    if (parsed != null) {
      return parsed.year == target.year &&
          parsed.month == target.month &&
          parsed.day == target.day;
    }

    final monthStr = months[target.month - 1].toLowerCase();
    final dayStr = target.day.toString();
    final yearStr = target.year.toString();
    if (docLower.contains(monthStr) &&
        docLower.contains(dayStr) &&
        docLower.contains(yearStr)) {
      return true;
    }

    return false;
  }

  String? _normalizeTime(String timeStr) {
    final mins = _parseToMinutes(timeStr);
    if (mins == null) return null;

    final totalMins = mins % (24 * 60);
    final hour = totalMins ~/ 60;
    final min = totalMins % 60;

    final period = hour >= 12 ? 'PM' : 'AM';
    int displayHour = hour % 12;
    if (displayHour == 0) displayHour = 12;

    final formattedHour = displayHour.toString().padLeft(2, '0');
    final formattedMin = min.toString().padLeft(2, '0');

    return '$formattedHour:$formattedMin $period';
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    // Clear selected time if it's no longer available for the selected date
    if (selectedTime.isNotEmpty &&
        !filteredAvailableTimes.contains(selectedTime.value)) {
      selectedTime.value = '';
    }
  }

  void selectTime(String timeSlot) {
    if (isSlotLocked(timeSlot)) return;
    if (!filteredAvailableTimes.contains(timeSlot)) return;
    selectedTime.value = timeSlot;
  }

  bool get isBookingValid {
    return selectedDate.value != null &&
        selectedTime.value.isNotEmpty &&
        filteredAvailableTimes.contains(selectedTime.value) &&
        !isSlotLocked(selectedTime.value) &&
        selectedServices.isNotEmpty;
  }

  void resetSelections() {
    selectedDate.value = null;
    selectedTime.value = '';
    selectedServices.clear();
  }
}
