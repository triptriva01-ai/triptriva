import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

import '../../../data/models/partner_activity.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/services/partner_service.dart';

/// Why a day is shaded on the manual-booking calendar (Sheet2 Page 2.1).
enum SlotAvailability { open, fullyFilled, offer, season, closed }

/// A bookable session on the selected day, for listings sold by time slot.
class ManualBookingSession {
  const ManualBookingSession({
    required this.id,
    required this.label,
    required this.availableUnits,
  });

  final String id;
  final String label;
  final int availableUnits;

  bool get isAvailable => availableUnits > 0;
}

/// Partner-side Page 2.1 — Manual Booking.
///
/// The partner picks one of their live listings and a date for a walk-in
/// customer; the calendar shows which days are full, closed, on offer or in
/// season. Saving creates a confirmed booking paid at the venue.
class ManualBookingController extends GetxController {
  final PartnerService _partnerService = Get.find<PartnerService>();

  final customerName = TextEditingController();
  final customerPhone = TextEditingController();

  /// Live listings the partner can book a walk-in on.
  final listings = <PartnerActivity>[].obs;
  final selectedListing = Rxn<PartnerActivity>();
  final isLoadingListings = false.obs;
  final isLoadingMonth = false.obs;

  /// First day of the month currently on screen.
  final visibleMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;
  final selectedDate = Rxn<DateTime>();

  /// Day-level availability, keyed by `yyyy-mm-dd`.
  final availability = <String, SlotAvailability>{}.obs;

  /// Sessions per day, for listings sold by time slot.
  final _sessions = <String, List<ManualBookingSession>>{};
  final sessionsForSelected = <ManualBookingSession>[].obs;
  final selectedSessionId = RxnString();

  final guests = 1.obs;
  final isSaving = false.obs;

  /// Bumped on every keystroke in the name field so [canSubmit] re-evaluates.
  final _nameVersion = 0.obs;

  bool get needsSession => sessionsForSelected.isNotEmpty;

  bool get canSubmit {
    _nameVersion.value;
    return selectedListing.value != null &&
        selectedDate.value != null &&
        customerName.text.trim().isNotEmpty &&
        (!needsSession || selectedSessionId.value != null);
  }

  @override
  void onInit() {
    super.onInit();
    customerName.addListener(() => _nameVersion.value++);
    _loadListings();
  }

  @override
  void onClose() {
    customerName.dispose();
    customerPhone.dispose();
    super.onClose();
  }

  static String keyFor(DateTime day) =>
      '${day.year}-${day.month.toString().padLeft(2, '0')}'
      '-${day.day.toString().padLeft(2, '0')}';

  SlotAvailability availabilityOf(DateTime day) =>
      availability[keyFor(day)] ?? SlotAvailability.closed;

  Future<void> _loadListings() async {
    isLoadingListings.value = true;
    try {
      final all = await _partnerService.getMyListings();
      listings.assignAll(all.where((listing) => listing.isActive));
      final wanted = Get.arguments is Map ? Get.arguments['listingId'] : null;
      selectedListing.value =
          listings.firstWhereOrNull((listing) => listing.id == wanted) ??
              listings.firstOrNull;
      await _loadMonth();
    } on ApiException catch (error) {
      _snack(error.message);
    } finally {
      isLoadingListings.value = false;
    }
  }

  Future<void> selectListing(PartnerActivity listing) async {
    if (listing.id == selectedListing.value?.id) return;
    selectedListing.value = listing;
    selectedDate.value = null;
    _clearSessions();
    await _loadMonth();
  }

  Future<void> _loadMonth() async {
    final listing = selectedListing.value;
    if (listing == null) {
      availability.clear();
      return;
    }
    final month = visibleMonth.value;
    isLoadingMonth.value = true;
    try {
      final data = await _partnerService.getAvailability(
        listing.id,
        DateTime(month.year, month.month, 1),
        DateTime(month.year, month.month + 1, 0),
      );
      final result = <String, SlotAvailability>{};
      final today = DateTime.now();
      final todayKey = keyFor(today);
      final days = data['days'];
      if (days is List) {
        for (final raw in days.whereType<Map>()) {
          final date = DateTime.tryParse('${raw['date']}');
          if (date == null) continue;
          final key = keyFor(date);
          final sessions = _parseSessions(raw['slots']);
          _sessions[key] = sessions;
          result[key] = _classify(
            raw,
            sessions,
            isPast: key.compareTo(todayKey) < 0,
          );
        }
      }
      availability.assignAll(result);
    } on ApiException catch (error) {
      _snack(error.message);
    } finally {
      isLoadingMonth.value = false;
    }
  }

  static SlotAvailability _classify(
    Map<dynamic, dynamic> raw,
    List<ManualBookingSession> sessions, {
    required bool isPast,
  }) {
    final published = raw['isPublished'] == true;
    final blocked = raw['isBlocked'] == true;
    if (isPast || !published || blocked) return SlotAvailability.closed;

    final hasRoom = sessions.isNotEmpty
        ? sessions.any((session) => session.isAvailable)
        : ((raw['availableUnits'] as num?)?.toInt() ?? 0) > 0;
    if (!hasRoom) return SlotAvailability.fullyFilled;

    return switch ('${raw['tag']}') {
      'offer' => SlotAvailability.offer,
      'seasonal' => SlotAvailability.season,
      _ => SlotAvailability.open,
    };
  }

  static List<ManualBookingSession> _parseSessions(dynamic slots) {
    if (slots is! List) return const [];
    return [
      for (final raw in slots.whereType<Map>())
        if ('${raw['slotId'] ?? ''}'.isNotEmpty)
          ManualBookingSession(
            id: '${raw['slotId']}',
            label: '${raw['startTime'] ?? ''} – ${raw['endTime'] ?? ''}',
            availableUnits: (raw['availableUnits'] as num?)?.toInt() ?? 0,
          ),
    ];
  }

  void previousMonth() {
    final month = visibleMonth.value;
    final now = DateTime.now();
    // Nothing before this month can take a booking.
    if (month.year == now.year && month.month == now.month) return;
    visibleMonth.value = DateTime(month.year, month.month - 1);
    _loadMonth();
  }

  void nextMonth() {
    final month = visibleMonth.value;
    visibleMonth.value = DateTime(month.year, month.month + 1);
    _loadMonth();
  }

  void selectDate(DateTime day) {
    final state = availabilityOf(day);
    if (state == SlotAvailability.fullyFilled) {
      _snack('This day is fully booked.');
      return;
    }
    if (state == SlotAvailability.closed) {
      _snack('This day is not open for booking.');
      return;
    }
    selectedDate.value = day;
    _clearSessions();
    final sessions = _sessions[keyFor(day)] ?? const [];
    sessionsForSelected.assignAll(sessions);
    final open = sessions.where((session) => session.isAvailable).toList();
    if (open.length == 1) selectedSessionId.value = open.single.id;
  }

  void selectSession(ManualBookingSession session) {
    if (!session.isAvailable) return;
    selectedSessionId.value = session.id;
  }

  void _clearSessions() {
    sessionsForSelected.clear();
    selectedSessionId.value = null;
  }

  void incrementGuests() => guests.value++;

  void decrementGuests() {
    if (guests.value > 1) guests.value--;
  }

  /// Creates the confirmed walk-in booking, then returns to the dashboard.
  Future<void> submit() async {
    final listing = selectedListing.value;
    final date = selectedDate.value;
    if (!canSubmit || listing == null || date == null) {
      return;
    }
    isSaving.value = true;
    try {
      final phone = customerPhone.text.trim();
      final booking = await _partnerService.createManualBooking(
        listingId: listing.id,
        date: date,
        guestName: customerName.text.trim(),
        guestPhone: phone.isEmpty ? null : phone,
        slotId: selectedSessionId.value,
        pax: guests.value,
      );
      final code = '${booking['checkInCode'] ?? ''}';
      Get.back(result: true);
      Get.snackbar(
        'Booking added',
        code.isEmpty
            ? '${customerName.text.trim()} is booked in.'
            : '${customerName.text.trim()} is booked in. '
                'Check-in code: $code',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 6),
      );
    } on ApiException catch (error) {
      _snack(error.message);
      // Space may have changed since the calendar loaded.
      await _loadMonth();
    } finally {
      isSaving.value = false;
    }
  }

  void goBack() => Get.back();

  void openHelp() => Get.toNamed(Routes.CUSTOMER_SUPPORT);

  void _snack(String message) => Get.snackbar(
        'Manual booking',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
}
