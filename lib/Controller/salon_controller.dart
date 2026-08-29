import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      if (savedGender != null &&
          (savedGender == 'Female' || savedGender == 'Male')) {
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
    final currentGender = selectedGender.value
        .toLowerCase()
        .trim(); // 'male' or 'female'

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
  final RxBool isRefreshingSlots = false.obs;

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

    final match = RegExp(
      r'(\d{1,2}):(\d{2})\s*(AM|PM)?',
      caseSensitive: false,
    ).firstMatch(timeStr);

    if (match != null) {
      int hour = int.tryParse(match.group(1)!) ?? 0;
      final minute = int.tryParse(match.group(2)!) ?? 0;
      final period = match.group(3)?.toUpperCase();

      if (period == 'PM' && hour < 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return hour * 60 + minute;
    }

    final simpleMatch = RegExp(
      r'(\d{1,2})\s*(AM|PM)',
      caseSensitive: false,
    ).firstMatch(timeStr);

    if (simpleMatch != null) {
      int hour = int.tryParse(simpleMatch.group(1)!) ?? 0;
      final period = simpleMatch.group(2)?.toUpperCase();
      if (period == 'PM' && hour < 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }
      return hour * 60;
    }

    return null;
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

  // Parse any duration string format e.g. "30 min", "1 hr", "45 mins", "1.5 hr", "1 hr 30 min"
  int parseDurationToMinutes(String durationStr) {
    if (durationStr.trim().isEmpty) return 30;
    final lower = durationStr.toLowerCase().trim();

    int totalMins = 0;

    final hrMatch = RegExp(
      r'(\d+(?:\.\d+)?)\s*(?:hr|hour|h)\b',
    ).firstMatch(lower);
    if (hrMatch != null) {
      final hrs = double.tryParse(hrMatch.group(1) ?? '0') ?? 0;
      totalMins += (hrs * 60).round();
    }

    final minMatch = RegExp(r'(\d+)\s*(?:min|minute|m)\b').firstMatch(lower);
    if (minMatch != null) {
      final mins = int.tryParse(minMatch.group(1) ?? '0') ?? 0;
      totalMins += mins;
    }

    if (totalMins == 0) {
      final digitMatch = RegExp(r'(\d+)').firstMatch(lower);
      if (digitMatch != null) {
        totalMins = int.tryParse(digitMatch.group(1) ?? '30') ?? 30;
      }
    }

    return totalMins > 0 ? totalMins : 30;
  }

  // Computed total duration in minutes of all currently selected services
  int get totalDurationMinutes {
    selectedServices.length; // Rx dependency tracking for Obx
    int total = 0;
    for (var service in availableServices) {
      if (selectedServices.contains(service['name'])) {
        final dStr = service['duration']?.toString() ?? '';
        total += parseDurationToMinutes(dStr);
      }
    }
    return total;
  }

  // Number of 30-min slots covered by current duration
  int get totalSlotCount {
    final mins = totalDurationMinutes;
    if (mins <= 0) return 1;
    final count = (mins / 30).ceil();
    return count > 0 ? count : 1;
  }

  // Human-readable total duration string e.g. "45 min" or "1 hr 15 min"
  String get formattedTotalDuration {
    final mins = totalDurationMinutes;
    if (mins <= 0) return '30 min';
    final hrs = mins ~/ 60;
    final remainingMins = mins % 60;

    if (hrs > 0 && remainingMins > 0) {
      return '$hrs hr $remainingMins min';
    } else if (hrs > 0) {
      return hrs == 1 ? '1 hr' : '$hrs hrs';
    } else {
      return '$remainingMins min';
    }
  }

  // Calculates the end time given a starting time string and duration in minutes
  String calculateEndTime(String startTimeStr, int durationMinutes) {
    final startMins = _parseToMinutes(startTimeStr);
    if (startMins == null) return startTimeStr;

    final dur = durationMinutes > 0 ? durationMinutes : 30;
    final endMins = startMins + dur;
    final totalMins = endMins % (24 * 60);
    final hour = totalMins ~/ 60;
    final min = totalMins % 60;

    final period = hour >= 12 ? 'PM' : 'AM';
    int displayHour = hour % 12;
    if (displayHour == 0) displayHour = 12;

    final formattedHour = displayHour.toString().padLeft(2, '0');
    final formattedMin = min.toString().padLeft(2, '0');

    return '$formattedHour:$formattedMin $period';
  }

  // Full dynamic time range string e.g. "10:00 AM - 11:30 AM"
  String get dynamicTimeRange {
    if (selectedTime.value.isEmpty) return '';
    final duration = totalDurationMinutes > 0 ? totalDurationMinutes : 30;
    final endTime = calculateEndTime(selectedTime.value, duration);
    return '${selectedTime.value} - $endTime';
  }

  // Returns true if the given slot is the start slot of the selected window
  bool isWindowStartSlot(String timeSlot) {
    return selectedTime.value == timeSlot;
  }

  // Returns true if the given slot falls inside the active dynamic window [start, start + duration)
  bool isSlotInSelectedWindow(String timeSlot) {
    if (selectedTime.value.isEmpty) return false;
    final startMins = _parseToMinutes(selectedTime.value);
    final slotMins = _parseToMinutes(timeSlot);
    if (startMins == null || slotMins == null) return false;

    final duration = totalDurationMinutes > 0 ? totalDurationMinutes : 30;
    return slotMins >= startMins && slotMins < (startMins + duration);
  }

  // Computed totalPrice
  double get totalPrice {
    selectedServices
        .length; // Access Rx list so Obx observers always register even when availableServices is empty
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

    // If a time slot was already selected, verify it can still accommodate the new total duration
    if (selectedTime.value.isNotEmpty &&
        !canSlotFitDuration(selectedTime.value)) {
      final oldTime = selectedTime.value;
      selectedTime.value = '';
      final durText = formattedTotalDuration;
      Get.snackbar(
        'Time Slot Adjusted',
        'Your selected time ($oldTime) was cleared because it cannot fit the updated $durText duration due to booked slots.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color.fromARGB(255, 252, 139, 1),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
    }
  }

  /// Formats minutes from midnight into standardized slot string like "07:30 PM"
  String _minutesToSlotString(int totalMins) {
    final clampedMins = totalMins % (24 * 60);
    final hour = clampedMins ~/ 60;
    final min = clampedMins % 60;

    final period = hour >= 12 ? 'PM' : 'AM';
    int displayHour = hour % 12;
    if (displayHour == 0) displayHour = 12;

    final formattedHour = displayHour.toString().padLeft(2, '0');
    final formattedMin = min.toString().padLeft(2, '0');

    return '$formattedHour:$formattedMin $period';
  }

  /// Checks if a starting time slot can accommodate the selected service duration continuously.
  /// Returns null if valid, or an error explanation string if it cannot fit.
  String? getSlotUnavailabilityReason(String startTimeSlot) {
    final normStart = _normalizeTime(startTimeSlot) ?? startTimeSlot;
    if (isSlotLocked(normStart) || isSlotLocked(startTimeSlot)) {
      return 'This time slot ($startTimeSlot) is already booked and locked.';
    }

    final startMins = _parseToMinutes(startTimeSlot);
    if (startMins == null) return 'Invalid time slot ($startTimeSlot).';

    final duration = totalDurationMinutes > 0 ? totalDurationMinutes : 30;
    final endMins = startMins + duration;

    // Check each 30-minute block that this service duration will occupy
    for (int cur = startMins; cur < endMins; cur += 30) {
      final slotString = _minutesToSlotString(cur);

      // 1. Check if any consecutive slot within the duration is locked
      if (isSlotLocked(slotString)) {
        final durText = formattedTotalDuration;
        return 'Cannot select $startTimeSlot for a $durText service because the consecutive slot ($slotString) is already booked.';
      }

      // 2. Check if the slot exceeds salon operating hours
      final matchesAvailable = availableTimes.any(
        (avail) => _parseToMinutes(avail) == cur,
      );
      if (!matchesAvailable) {
        final durText = formattedTotalDuration;
        return 'Cannot select $startTimeSlot for a $durText service because it extends past salon operating hours.';
      }
    }

    return null; // All slots in the continuous window are free!
  }

  /// Returns true if the starting slot has all continuous required intervals free and unlocked
  bool canSlotFitDuration(String timeSlot) {
    return getSlotUnavailabilityReason(timeSlot) == null;
  }

  Future<void> fetchBookedSlots({bool forceRefresh = false}) async {
    final salonId =
        (salonData['salonId'] ?? salonData['id'] ?? salonData['name'] ?? '')
            .toString();
    if (salonId.isEmpty) return;

    if (forceRefresh) isRefreshingSlots.value = true;
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
    } finally {
      if (forceRefresh) {
        // Small delay so user sees smooth feedback
        await Future.delayed(const Duration(milliseconds: 300));
        isRefreshingSlots.value = false;
      }
    }
  }

  void _reevaluateLockedSlots() {
    lockedTimeSlots.clear();
    final date = selectedDate.value;
    if (date == null || _salonBookingsDocs.isEmpty) return;

    for (var doc in _salonBookingsDocs) {
      final status =
          (doc['bookingStatus']?.toString() ??
                  doc['status']?.toString() ??
                  doc['booking_status']?.toString() ??
                  '')
              .toLowerCase()
              .trim();
      final isLocked = doc['isLocked'] == true;

      // Lock slot if bookingStatus is confirmed/accepted or isLocked is true
      if (status != 'confirmed' && status != 'accepted' && !isLocked) {
        continue;
      }

      final docDateRaw = doc['date'] ?? doc['dateTime'] ?? doc['scheduledAt'];
      if (!_isSameDate(docDateRaw, date)) {
        continue;
      }

      final docTimeRaw = (doc['time'] ?? doc['timeSlot'] ?? '')
          .toString()
          .trim();
      if (docTimeRaw.isEmpty) continue;

      // Parse all time matches in docTimeRaw (e.g. "10:00 AM - 11:30 AM" or "10:00 AM")
      final matches = RegExp(
        r'(\d{1,2}):(\d{2})\s*(AM|PM)?',
        caseSensitive: false,
      ).allMatches(docTimeRaw).toList();

      if (matches.isNotEmpty) {
        final startMins = _parseToMinutes(matches[0].group(0)!);
        if (startMins != null) {
          int endMins;
          if (matches.length > 1) {
            endMins = _parseToMinutes(matches[1].group(0)!) ?? (startMins + 30);
          } else {
            // Calculate duration if services list is present in doc
            int docDuration = 30;
            if (doc['services'] is List &&
                (doc['services'] as List).isNotEmpty) {
              int totalSvcDuration = 0;
              for (var s in doc['services']) {
                if (s is Map && s['duration'] != null) {
                  totalSvcDuration += parseDurationToMinutes(
                    s['duration'].toString(),
                  );
                }
              }
              if (totalSvcDuration > 0) docDuration = totalSvcDuration;
            } else if (doc['duration'] != null) {
              docDuration = parseDurationToMinutes(doc['duration'].toString());
            }
            endMins = startMins + docDuration;
          }

          for (var slot in availableTimes) {
            final slotMins = _parseToMinutes(slot);
            if (slotMins != null) {
              if (slotMins >= startMins && slotMins < endMins) {
                lockedTimeSlots.add(slot);
              }
            }
          }
        }
      } else {
        // Fallback for single time string or non-standard format
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

    // If currently selected time is now locked, cannot fit duration, or not available, clear selection
    if (selectedTime.isNotEmpty &&
        (!canSlotFitDuration(selectedTime.value) ||
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

  bool _isSameDate(dynamic docDateRaw, DateTime target) {
    if (docDateRaw == null) return false;

    if (docDateRaw is Timestamp) {
      final dt = docDateRaw.toDate();
      return dt.year == target.year &&
          dt.month == target.month &&
          dt.day == target.day;
    }

    if (docDateRaw is DateTime) {
      return docDateRaw.year == target.year &&
          docDateRaw.month == target.month &&
          docDateRaw.day == target.day;
    }

    final dateStr = docDateRaw.toString().trim();
    if (dateStr.isEmpty) return false;

    // Direct ISO string parse check
    final parsed = DateTime.tryParse(dateStr);
    if (parsed != null) {
      return parsed.year == target.year &&
          parsed.month == target.month &&
          parsed.day == target.day;
    }

    final docLower = dateStr.toLowerCase();
    const months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];

    final targetMonthName = months[target.month - 1];

    // Extract year
    final yearMatch = RegExp(r'\b(20\d{2})\b').firstMatch(docLower);
    final docYear = yearMatch != null
        ? int.tryParse(yearMatch.group(1)!)
        : null;

    // Extract day
    final dayMatch = RegExp(
      r'\b([1-9]|[12]\d|3[01])\b',
    ).firstMatch(docLower.replaceAll(RegExp(r'\b20\d{2}\b'), ''));
    final docDay = dayMatch != null ? int.tryParse(dayMatch.group(1)!) : null;

    if (docYear != null && docDay != null) {
      if (docYear == target.year &&
          docDay == target.day &&
          docLower.contains(targetMonthName)) {
        return true;
      }
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
    _reevaluateLockedSlots();
    // Clear selected time if it's no longer available for the selected date or cannot fit duration
    if (selectedTime.isNotEmpty &&
        (!canSlotFitDuration(selectedTime.value) ||
            !filteredAvailableTimes.contains(selectedTime.value))) {
      selectedTime.value = '';
    }
  }

  void selectTime(String timeSlot) {
    final reason = getSlotUnavailabilityReason(timeSlot);
    if (reason != null) {
      Get.snackbar(
        'Slot Unavailable',
        reason,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color.fromARGB(255, 219, 62, 5),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
      return;
    }
    if (!filteredAvailableTimes.contains(timeSlot)) return;
    selectedTime.value = timeSlot;
  }

  bool get isBookingValid {
    return selectedDate.value != null &&
        selectedTime.value.isNotEmpty &&
        filteredAvailableTimes.contains(selectedTime.value) &&
        canSlotFitDuration(selectedTime.value) &&
        selectedServices.isNotEmpty;
  }

  void resetSelections() {
    selectedDate.value = null;
    selectedTime.value = '';
    selectedServices.clear();
  }
}
