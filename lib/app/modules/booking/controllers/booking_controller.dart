import 'package:get/get.dart';

import '../../../data/models/listing_detail.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/services/pricing_service.dart';
import '../../../data/services/slot_service.dart';
import '../constants/booking_constants.dart';

/// Where the traveller is in the booking flow.
enum BookingStep { dateAndSlot, people }

/// Booking flow — pick a date and slot, then the party size, then pay.
class BookingController extends GetxController {
  final SlotService _slotService = Get.find<SlotService>();
  final PricingService _pricingService = Get.find<PricingService>();

  final listing = Rxn<ListingDetail>();
  final step = BookingStep.dateAndSlot.obs;

  /// Any date inside the month the calendar is showing.
  final month = DateTime(DateTime.now().year, DateTime.now().month).obs;
  final selectedDate = Rxn<DateTime>();

  /// Only used by slots that run overnight.
  final checkOutDate = Rxn<DateTime>();

  final slots = <ListingSlot>[].obs;
  final selectedSlot = Rxn<ListingSlot>();

  final pax = 1.obs;
  final wantsRefreshingRoom = false.obs;
  final isBillExpanded = false.obs;

  final isLoading = false.obs;
  final isBooking = false.obs;

  /// Availability for the month on screen, keyed by `yyyy-mm-dd`.
  final fullDays = <String>{}.obs;
  final offerDays = <String>{}.obs;
  final seasonDays = <String>{}.obs;

  /// Bill, filled by `GET /api/pricing/{id}` once a slot and pax are chosen.
  final basePrice = 0.0.obs;
  final discountedPrice = 0.0.obs;
  final couponDiscount = 0.0.obs;
  final savings = 0.0.obs;

  String get listingId => listing.value?.id ?? '';

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is ListingDetail) {
      listing.value = args;
      slots.assignAll(args.slots);
      basePrice.value = args.originalPrice ?? args.price;
      discountedPrice.value = args.price;
    } else if (args is String) {
      listing.value = ListingDetail(id: args, name: '');
    }

    if (listingId.isNotEmpty) {
      loadAvailability();
    }
  }

  // ── Availability ────────────────────────────────────────────────────

  Future<void> loadAvailability() async {
    isLoading.value = true;
    try {
      final data = await _slotService.getAvailability(listingId);
      if (data is Map<String, dynamic>) {
        fullDays.assignAll(_days(data['full'] ?? data['unavailable']));
        offerDays.assignAll(_days(data['offer']));
        seasonDays.assignAll(_days(data['seasonal'] ?? data['season']));
      }
    } on ApiException catch (error) {
      Get.log('Availability load failed: $error');
      _loadSampleAvailability();
    } finally {
      isLoading.value = false;
    }
  }

  Set<String> _days(dynamic value) {
    if (value is! List) return const {};
    return value.map((item) => '$item').toSet();
  }

  /// `yyyy-mm-dd`, the shape every slot and pricing endpoint expects.
  static String formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  /// "30 July Sun 2026" — the label on the check-in / check-out cards.
  static String formatLong(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${date.day} ${months[date.month - 1]} '
        '${weekdays[date.weekday - 1]} ${date.year}';
  }

  bool isFull(DateTime day) => fullDays.contains(formatDate(day));
  bool isOffer(DateTime day) => offerDays.contains(formatDate(day));
  bool isSeason(DateTime day) => seasonDays.contains(formatDate(day));

  // ── Selection ───────────────────────────────────────────────────────

  void previousMonth() {
    final current = month.value;
    month.value = DateTime(current.year, current.month - 1);
    loadAvailability();
  }

  void nextMonth() {
    final current = month.value;
    month.value = DateTime(current.year, current.month + 1);
    loadAvailability();
  }

  void selectDate(DateTime day) {
    if (isFull(day)) return;
    selectedDate.value = day;
    // A new date invalidates whatever slot was chosen for the old one.
    selectedSlot.value = null;
    checkOutDate.value = null;
    loadSlots();
  }

  Future<void> loadSlots() async {
    final date = selectedDate.value;
    if (date == null) return;

    try {
      final data = await _slotService.getSlots(listingId, formatDate(date));
      if (data is List) {
        slots.assignAll(
          data.whereType<Map<String, dynamic>>().map(ListingSlot.fromJson),
        );
      }
    } on ApiException catch (error) {
      Get.log('Slots load failed: $error');
      // Fall back to the slots the listing already advertised.
      slots.assignAll(listing.value?.slots ?? const []);
    }
  }

  void selectSlot(ListingSlot slot) {
    if (!slot.isAvailable) return;
    selectedSlot.value = slot;
    basePrice.value = slot.originalPrice ?? slot.price;
    discountedPrice.value = slot.price;

    // Overnight slots need a second date; day trips do not.
    final date = selectedDate.value;
    if (_isOvernight(slot) && date != null) {
      checkOutDate.value = date.add(const Duration(days: 1));
    } else {
      checkOutDate.value = null;
    }
    refreshPricing();
  }

  bool _isOvernight(ListingSlot slot) {
    final name = slot.name.toLowerCase();
    return name.contains('overnight') || name.contains('night');
  }

  bool get needsDateRange {
    final slot = selectedSlot.value;
    return slot != null && _isOvernight(slot);
  }

  void toggleRefreshingRoom() => wantsRefreshingRoom.toggle();

  void setPax(int value) {
    final detail = listing.value;
    final min = detail?.minPax ?? 1;
    final max = detail?.maxPax ?? 60;
    pax.value = value.clamp(min, max);
    refreshPricing();
  }

  void toggleBill() => isBillExpanded.toggle();

  // ── Pricing ─────────────────────────────────────────────────────────

  /// Total nights, which is what the bill's "Total Days" row counts.
  int get totalDays {
    final start = selectedDate.value;
    final end = checkOutDate.value;
    if (start == null || end == null) return 1;
    final nights = end.difference(start).inDays;
    return nights < 1 ? 1 : nights;
  }

  double get total => (discountedPrice.value * totalDays) -
      couponDiscount.value;

  Future<void> refreshPricing() async {
    final slot = selectedSlot.value;
    final date = selectedDate.value;
    if (slot == null || date == null) return;

    try {
      final data = await _pricingService.getPricing(
        listingId,
        slotId: slot.id,
        pax: pax.value,
        date: formatDate(date),
      );
      if (data is Map<String, dynamic>) {
        basePrice.value = _toDouble(data['basePrice']) ?? basePrice.value;
        discountedPrice.value =
            _toDouble(data['discountedPrice']) ?? discountedPrice.value;
        couponDiscount.value = _toDouble(data['couponDiscount']) ?? 0;
        savings.value = _toDouble(data['savings']) ??
            (basePrice.value - discountedPrice.value);
      }
    } on ApiException catch (error) {
      Get.log('Pricing load failed: $error');
      // Keep the slot's own prices; they are already on screen.
      savings.value = basePrice.value - discountedPrice.value;
    }
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// `₹1,21,500` — Indian digit grouping.
  static String formatRupees(double amount) {
    final whole = amount.round().abs().toString();
    if (whole.length <= 3) {
      return '₹$whole';
    }
    final last3 = whole.substring(whole.length - 3);
    var rest = whole.substring(0, whole.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) {
      groups.insert(0, rest);
    }
    return '₹${groups.join(',')},$last3';
  }

  // ── Navigation ──────────────────────────────────────────────────────

  bool get canContinue =>
      selectedDate.value != null && selectedSlot.value != null;

  void goBack() {
    if (step.value == BookingStep.people) {
      step.value = BookingStep.dateAndSlot;
      isBillExpanded.value = false;
      return;
    }
    Get.back();
  }

  void continueToPeople() {
    if (!canContinue) return;
    step.value = BookingStep.people;
    refreshPricing();
  }

  Future<void> book() async {
    final slot = selectedSlot.value;
    final date = selectedDate.value;
    if (slot == null || date == null || isBooking.value) return;

    isBooking.value = true;
    try {
      await _pricingService.initiateBooking(
        listingId: listingId,
        slotId: slot.id,
        date: formatDate(date),
        pax: pax.value,
      );
      // TODO(booking): hand off to the payment screen once it exists.
      _pending('Payment');
    } on ApiException catch (error) {
      Get.log('Booking failed: $error');
      Get.snackbar(
        BookingStrings.pendingTitle,
        error.message,
        duration: BookingDurations.snackbar,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isBooking.value = false;
    }
  }

  void _pending(String feature) {
    Get.snackbar(
      BookingStrings.pendingTitle,
      BookingStrings.pendingMessage(feature),
      duration: BookingDurations.snackbar,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ---------------------------------------------------------------------
  // Development placeholder — remove once
  // `GET /api/slots/{id}/availability` serves real data.
  // ---------------------------------------------------------------------

  void _loadSampleAvailability() {
    final current = month.value;
    String day(int value) =>
        formatDate(DateTime(current.year, current.month, value));

    fullDays.assignAll({day(7), day(9), day(14), day(21)});
    offerDays.assignAll({day(10), day(11), day(18)});
    seasonDays.assignAll({day(24), day(25)});
  }
}
