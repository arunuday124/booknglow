import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/booking_service.dart';
import '../service/salon_service.dart';
import 'rebook_summary_screen.dart';

class RebookDateTimeController extends GetxController {
  final String salonId;
  final String salonName;
  final String salonLocation;
  final List<Map<String, dynamic>> services;
  final double itemTotal;
  final String originalDate;
  final String originalTime;

  RebookDateTimeController({
    required this.salonId,
    required this.salonName,
    required this.salonLocation,
    required this.services,
    required this.itemTotal,
    required this.originalDate,
    required this.originalTime,
  });

  // State observables
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString selectedTime = ''.obs;
  final RxBool useSameTimeAsLast = false.obs;
  final RxBool isLoading = false.obs;
  final RxSet<String> lockedTimeSlots = <String>{}.obs;

  final List<DateTime> availableDates = [];
  final List<String> availableTimes = [];
  List<Map<String, dynamic>> _salonBookingsDocs = [];

  @override
  void onInit() {
    super.onInit();
    _generateDates();
    _generateTimes();
    selectedDate.value = availableDates.first;

    // Initial setup for quick pick & selected time
    _initializeDefaultTime();

    // One-shot fetch of salon bookings to determine locked slots (uses 5-min cache if available)
    fetchSalonBookings(forceRefresh: false);
  }

  void _generateDates() {
    availableDates.clear();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (int i = 0; i < 14; i++) {
      availableDates.add(today.add(Duration(days: i)));
    }
  }

  void _generateTimes() {
    availableTimes.clear();

    // Look up opening/closing hours from SalonService cache if available
    String openStr = '9 AM';
    String closeStr = '10 PM';

    final cachedSalon = SalonService.cachedSalons.firstWhereOrNull(
      (s) =>
          s.salonId == salonId ||
          s.salonName.toLowerCase() == salonName.toLowerCase(),
    );

    if (cachedSalon != null) {
      openStr = cachedSalon.openingHours.trim();
      closeStr = cachedSalon.closingHours.trim();
    }

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

    // Ensure originalTime is included if provided and not in the list
    final trimmedOriginal = originalTime.trim();
    if (trimmedOriginal.isNotEmpty) {
      final normalizedOriginal = _normalizeTime(trimmedOriginal);
      if (normalizedOriginal != null &&
          !availableTimes.contains(normalizedOriginal)) {
        availableTimes.insert(0, normalizedOriginal);
      }
    }
  }

  void _initializeDefaultTime() {
    final validTimes = filteredAvailableTimes;
    final trimmedOrig = originalTime.trim();
    final normalizedOrig = _normalizeTime(trimmedOrig);

    if (normalizedOrig != null && validTimes.contains(normalizedOrig)) {
      selectedTime.value = normalizedOrig;
      useSameTimeAsLast.value = true;
    } else if (validTimes.isNotEmpty) {
      selectedTime.value = validTimes.first;
      useSameTimeAsLast.value = false;
    } else {
      selectedTime.value = '';
      useSameTimeAsLast.value = false;
    }
  }

  /// One-shot fetch of confirmed bookings for this salon (uses in-memory cache by default)
  Future<void> fetchSalonBookings({bool forceRefresh = false}) async {
    if (salonId.isEmpty) return;

    isLoading.value = true;
    try {
      final docs = await BookingService.getBookingsForSalon(
        salonId,
        forceRefresh: forceRefresh,
      );
      _salonBookingsDocs = docs;
      _reevaluateLockedSlots();
    } catch (e) {
      debugPrint(
        '⚠️ [RebookDateTimeController] Error fetching salon bookings: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _reevaluateLockedSlots() {
    lockedTimeSlots.clear();
    final date = selectedDate.value;
    if (_salonBookingsDocs.isEmpty) return;

    for (var doc in _salonBookingsDocs) {
      final status =
          (doc['bookingStatus']?.toString() ??
                  doc['status']?.toString() ??
                  doc['booking_status']?.toString() ??
                  '')
              .toLowerCase()
              .trim();
      final isLocked = doc['isLocked'] == true;

      // Lock slot if confirmed/accepted or explicitly isLocked
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
            endMins = startMins + 30;
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

    // If currently selected time is locked, cannot fit duration, or no longer available, select next available or clear
    if (selectedTime.isNotEmpty &&
        (lockedTimeSlots.contains(selectedTime.value) ||
            !canSlotFitDuration(selectedTime.value) ||
            !filteredAvailableTimes.contains(selectedTime.value))) {
      final available = filteredAvailableTimes
          .where((t) => !lockedTimeSlots.contains(t) && canSlotFitDuration(t))
          .toList();
      if (available.isNotEmpty) {
        selectedTime.value = available.first;
        useSameTimeAsLast.value =
            (_normalizeTime(originalTime.trim()) == selectedTime.value);
      } else {
        selectedTime.value = '';
        useSameTimeAsLast.value = false;
      }
    }
  }

  int parseDurationToMinutes(String durationStr) {
    if (durationStr.trim().isEmpty) return 30;
    final lower = durationStr.toLowerCase().trim();

    int totalMins = 0;
    final hrMatch = RegExp(r'(\d+)\s*(?:hr|hour)').firstMatch(lower);
    if (hrMatch != null) {
      final hrs = int.tryParse(hrMatch.group(1) ?? '0') ?? 0;
      totalMins += hrs * 60;
    }

    final minMatch = RegExp(r'(\d+)\s*(?:min|minute)').firstMatch(lower);
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

  int get totalDurationMinutes {
    int total = 0;
    for (var service in services) {
      final dStr = service['duration']?.toString() ?? '';
      total += parseDurationToMinutes(dStr);
    }
    return total > 0 ? total : 30;
  }

  String get formattedTotalDuration {
    final mins = totalDurationMinutes;
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

  String? getSlotUnavailabilityReason(String startTimeSlot) {
    final normStart = _normalizeTime(startTimeSlot) ?? startTimeSlot;
    if (isSlotLocked(normStart) || isSlotLocked(startTimeSlot)) {
      return 'This time slot ($startTimeSlot) is already booked and locked.';
    }

    final startMins = _parseToMinutes(startTimeSlot);
    if (startMins == null) return 'Invalid time slot ($startTimeSlot).';

    final duration = totalDurationMinutes > 0 ? totalDurationMinutes : 30;
    final endMins = startMins + duration;

    for (int cur = startMins; cur < endMins; cur += 30) {
      final slotString = _minutesToSlotString(cur);

      if (isSlotLocked(slotString)) {
        final durText = formattedTotalDuration;
        return 'Cannot select $startTimeSlot for a $durText service because the consecutive slot ($slotString) is already booked.';
      }

      final matchesAvailable = availableTimes.any(
        (avail) => _parseToMinutes(avail) == cur,
      );
      if (!matchesAvailable) {
        final durText = formattedTotalDuration;
        return 'Cannot select $startTimeSlot for a $durText service because it extends past salon operating hours.';
      }
    }

    return null;
  }

  bool canSlotFitDuration(String timeSlot) {
    return getSlotUnavailabilityReason(timeSlot) == null;
  }

  bool isSlotLocked(String timeSlot) {
    return lockedTimeSlots.contains(timeSlot);
  }

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static int? _parseToMinutes(String timeStr) {
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

  static String? _normalizeTime(String timeStr) {
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

  List<String> get filteredAvailableTimes {
    final date = selectedDate.value;
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

  void selectDate(DateTime date) {
    selectedDate.value = date;
    _reevaluateLockedSlots();

    final validTimes = filteredAvailableTimes;
    final normalizedOrig = _normalizeTime(originalTime.trim());

    if (useSameTimeAsLast.value &&
        normalizedOrig != null &&
        validTimes.contains(normalizedOrig) &&
        canSlotFitDuration(normalizedOrig)) {
      selectedTime.value = normalizedOrig;
    } else if (!validTimes.contains(selectedTime.value) ||
        !canSlotFitDuration(selectedTime.value)) {
      final available = validTimes.where((t) => canSlotFitDuration(t)).toList();
      if (available.isNotEmpty) {
        selectedTime.value = available.first;
      } else {
        selectedTime.value = '';
      }
      useSameTimeAsLast.value = false;
    }
  }

  void selectTime(String timeSlot) {
    final reason = getSlotUnavailabilityReason(timeSlot);
    if (reason != null) {
      Get.snackbar(
        'Slot Unavailable',
        reason,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (!filteredAvailableTimes.contains(timeSlot)) return;

    selectedTime.value = timeSlot;
    final normalizedOrig = _normalizeTime(originalTime.trim());
    useSameTimeAsLast.value = (normalizedOrig == timeSlot);
  }

  void toggleQuickPick() {
    final normalizedOrig = _normalizeTime(originalTime.trim());
    final validTimes = filteredAvailableTimes;

    if (normalizedOrig == null || !validTimes.contains(normalizedOrig)) {
      Get.snackbar(
        'Time Slot Unavailable',
        'The previous time slot ($originalTime) has already passed for today. Please pick an upcoming time slot.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF05352F),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    if (isSlotLocked(normalizedOrig)) {
      Get.snackbar(
        'Slot Booked',
        'Your previous time slot ($originalTime) is already booked for this date. Please choose another available slot.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color.fromARGB(255, 219, 62, 5),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    useSameTimeAsLast.value = !useSameTimeAsLast.value;
    if (useSameTimeAsLast.value) {
      selectedTime.value = normalizedOrig;
    }
  }

  bool get isBookingValid {
    return selectedTime.value.isNotEmpty &&
        filteredAvailableTimes.contains(selectedTime.value) &&
        !isSlotLocked(selectedTime.value);
  }
}

class RebookDateTimeScreen extends StatelessWidget {
  final String salonId;
  final String salonName;
  final String salonLocation;
  final List<Map<String, dynamic>> services;
  final double itemTotal;
  final String originalDate;
  final String originalTime;

  const RebookDateTimeScreen({
    super.key,
    required this.salonId,
    required this.salonName,
    required this.salonLocation,
    required this.services,
    required this.itemTotal,
    required this.originalDate,
    required this.originalTime,
  });

  String _formatWeekday(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _formatMonthDay(DateTime date) {
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
    return "${months[date.month - 1]} ${date.day}";
  }

  @override
  Widget build(BuildContext context) {
    // Inject or find the controller unique to this salon instance
    final controller = Get.put(
      RebookDateTimeController(
        salonId: salonId,
        salonName: salonName,
        salonLocation: salonLocation,
        services: services,
        itemTotal: itemTotal,
        originalDate: originalDate,
        originalTime: originalTime,
      ),
      tag: 'rebook_$salonId',
    );

    final serviceNames = services
        .map((s) => s['serviceName'] ?? s['name'] ?? s['title'] ?? 'Service')
        .join(', ');

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF05352F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Select Date & Time",
          style: GoogleFonts.plusJakartaSans(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: "Refresh slots",
            onPressed: () => controller.fetchSalonBookings(forceRefresh: true),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF05352F),
        backgroundColor: Colors.white,
        onRefresh: () async {
          await controller.fetchSalonBookings(forceRefresh: true);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Service Details Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.02),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF05352F).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.repeat_rounded,
                        color: Color(0xFF05352F),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            salonName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF05352F),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            serviceNames,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              color: const Color(0xFF7A8D87),
                            ),
                          ),
                          if (salonLocation.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              salonLocation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: const Color(0xFF9E7E45),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Quick Pick Chip: "Same time as last booking"
              Obx(() {
                final isSameTime = controller.useSameTimeAsLast.value;
                final selDate = controller.selectedDate.value;
                final validTimes = controller.filteredAvailableTimes;
                final normOrig = RebookDateTimeController._normalizeTime(
                  originalTime.trim(),
                );
                final isOrigLocked =
                    normOrig != null && controller.isSlotLocked(normOrig);
                final isOrigPassed =
                    normOrig == null || !validTimes.contains(normOrig);

                String statusSubtitle =
                    "Rebook for ${_formatMonthDay(selDate)} at ${originalTime.isNotEmpty ? originalTime : '10:00 AM'}";
                if (isOrigPassed) {
                  statusSubtitle =
                      "Previous slot ($originalTime) is in the past for today";
                } else if (isOrigLocked) {
                  statusSubtitle =
                      "Previous slot ($originalTime) is already booked for this date";
                }

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isOrigPassed || isOrigLocked
                        ? const Color(0xFFF7F5F0)
                        : const Color(0xFFE2F2EE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSameTime
                          ? const Color(0xFF05352F)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isOrigLocked
                                    ? Icons.lock_outline_rounded
                                    : Icons.auto_awesome_rounded,
                                color: isOrigPassed || isOrigLocked
                                    ? const Color(0xFF9E9588)
                                    : const Color(0xFF05352F),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Same time as last booking",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isOrigPassed || isOrigLocked
                                      ? const Color(0xFF6E7E7A)
                                      : const Color(0xFF05352F),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => controller.toggleQuickPick(),
                            child: Text(
                              isSameTime ? "Selected" : "Use Quick-Pick",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isOrigPassed || isOrigLocked
                                    ? const Color(0xFF9E9588)
                                    : const Color(0xFF9E7E45),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        statusSubtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: isOrigPassed || isOrigLocked
                              ? const Color(0xFF8C7E6A)
                              : const Color(0xFF2C3E3A),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // 3. Date Selection Header & Horizontal Strip (Matching main booking)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Date",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF05352F),
                    ),
                  ),
                  Obx(
                    () => Text(
                      _formatMonthDay(controller.selectedDate.value),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9E7E45),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              SizedBox(
                height: 76,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.availableDates.length,
                  itemBuilder: (context, index) {
                    final date = controller.availableDates[index];

                    return Obx(() {
                      final currentSelDate = controller.selectedDate.value;
                      final isSelected =
                          currentSelDate.year == date.year &&
                          currentSelDate.month == date.month &&
                          currentSelDate.day == date.day;

                      return GestureDetector(
                        onTap: () => controller.selectDate(date),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 64,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF05352F)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF05352F)
                                  : const Color(
                                      0xFFE8D5AF,
                                    ).withValues(alpha: 0.3),
                              width: isSelected ? 1.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? const Color(
                                        0xFF05352F,
                                      ).withValues(alpha: 0.15)
                                    : const Color.fromRGBO(0, 0, 0, 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatWeekday(date),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFFE8D5AF)
                                      : const Color(0xFF7A8D87),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                date.day.toString(),
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF05352F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              // 4. Time Slots Header & Availability Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Time",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF05352F),
                    ),
                  ),
                  // Availability Legend Badges
                  Row(
                    children: [
                      _buildLegendBadge(
                        label: "Available",
                        dotColor: const Color(0xFF05352F),
                      ),
                      const SizedBox(width: 10),
                      _buildLegendBadge(
                        label: "Booked",
                        dotColor: const Color(0xFF9E9588),
                        isLocked: true,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 5. Time Slots Grid / List with Locked Slot State & Pull-down info
              Obx(() {
                final times = controller.filteredAvailableTimes;

                if (times.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFF9E7E45),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "No time slots available for today. Please select a future date.",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: const Color(0xFF7A8D87),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: times.map((timeSlot) {
                    return Obx(() {
                      final isSelected =
                          controller.selectedTime.value == timeSlot;
                      final isLocked = controller.isSlotLocked(timeSlot);
                      final canFit = controller.canSlotFitDuration(timeSlot);
                      final isBlocked = isLocked || !canFit;

                      return GestureDetector(
                        onTap: () => controller.selectTime(timeSlot),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isBlocked
                                ? const Color(0xFFFDECEA)
                                : isSelected
                                ? const Color(0xFF05352F)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isBlocked
                                  ? const Color(0xFFF5B7B1)
                                  : isSelected
                                  ? const Color(0xFF05352F)
                                  : const Color(
                                      0xFFE8D5AF,
                                    ).withValues(alpha: 0.3),
                              width: isSelected ? 1.5 : 1,
                            ),
                            boxShadow: isBlocked
                                ? []
                                : [
                                    BoxShadow(
                                      color: isSelected
                                          ? const Color(
                                              0xFF05352F,
                                            ).withValues(alpha: 0.15)
                                          : const Color.fromRGBO(0, 0, 0, 0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isBlocked) ...[
                                const Icon(
                                  Icons.lock_rounded,
                                  size: 14,
                                  color: Color(0xFFE53935),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                timeSlot,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: isSelected || isBlocked
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isBlocked
                                      ? const Color(0xFFC0392B)
                                      : isSelected
                                      ? Colors.white
                                      : const Color(0xFF05352F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  }).toList(),
                );
              }),

              const SizedBox(height: 20),

              // Pull-to-refresh note
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_downward_rounded,
                      size: 14,
                      color: Color(0xFF7A8D87),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Scroll down to refresh slot availability",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFF7A8D87),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar with Proceed Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: Obx(() {
              final isValid = controller.isBookingValid;

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF05352F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  if (!isValid) {
                    if (controller.selectedTime.value.isEmpty) {
                      Get.snackbar(
                        'Select Time Slot',
                        'Please select an upcoming time slot to continue.',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.red.shade800,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                      );
                    } else if (controller.isSlotLocked(
                      controller.selectedTime.value,
                    )) {
                      Get.snackbar(
                        'Slot Locked',
                        'The chosen time slot is already booked. Please choose an available slot.',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.red.shade800,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                      );
                    }
                    return;
                  }

                  Get.to(
                    () => RebookSummaryScreen(
                      salonId: salonId,
                      salonName: salonName,
                      salonLocation: salonLocation,
                      services: services,
                      itemTotal: itemTotal,
                      selectedDate: controller.selectedDate.value,
                      selectedTime: controller.selectedTime.value,
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Proceed to Summary",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendBadge({
    required String label,
    required Color dotColor,
    bool isLocked = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLocked ? const Color(0xFFFDECEA) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLocked
              ? const Color(0xFFF5B7B1)
              : const Color(0xFFE8D5AF).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLocked)
            const Icon(Icons.lock_rounded, size: 10, color: Color(0xFFE53935))
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: isLocked
                  ? const Color(0xFFC0392B)
                  : const Color(0xFF05352F),
            ),
          ),
        ],
      ),
    );
  }
}
