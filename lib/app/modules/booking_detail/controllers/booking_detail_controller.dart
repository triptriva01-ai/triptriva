import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/models/booking.dart';
import '../../../data/models/booking_detail.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/services/booking_service.dart';
import '../constants/booking_detail_constants.dart';
import '../../../data/services/geo_service.dart';

/// Booking detail — the "reservation inside" page reached from My Bookings.
///
/// One `GET /api/bookings/{id}` fills the entire screen; the bill breakdown
/// behind "Payment Details" comes from the same payload rather than a second
/// round trip, so it opens instantly.
class BookingDetailController extends GetxController {
  final BookingService _bookingService = Get.find<BookingService>();

  final detail = Rxn<BookingDetail>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  /// Expands the About paragraph past its collapsed height.
  final isAboutExpanded = false.obs;

  /// True while a reminder is set for this trip.
  final hasReminder = false.obs;

  /// The id being shown, from route arguments.
  String bookingId = '';

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Booking) {
      bookingId = args.id;
      // Render immediately from the list row, then fill in the rest.
      detail.value = _fromListRow(args);
    } else if (args is Map) {
      bookingId = '${args['id'] ?? ''}';
    } else if (args is String) {
      bookingId = args;
    }

    if (bookingId.isNotEmpty) {
      loadDetail();
    }
  }

  /// Placeholder built from the data the list already had, so the page never
  /// opens blank while the request is in flight.
  BookingDetail _fromListRow(Booking booking) {
    return BookingDetail(
      id: booking.id,
      bookingId: booking.bookingId,
      listingName: booking.title,
      status: booking.status,
      imageUrl: booking.imageUrl,
      bookingDate: booking.date,
      timeSlot: booking.timeSlot,
    );
  }

  Future<void> loadDetail() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _bookingService.getDetail(bookingId);
      if (data is Map<String, dynamic>) {
        detail.value = BookingDetail.fromJson(data);
      }
    } on ApiException catch (error) {
      Get.log('Booking detail load failed: $error');
      _loadSampleDetail();
      // Only complain if there is nothing at all to show.
      if (detail.value == null) {
        errorMessage.value = error.message;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------
  // Development placeholder — mirrors `ReservationsController`, and should be
  // removed once `GET /api/bookings/{id}` serves real data.
  // ---------------------------------------------------------------------

  void _loadSampleDetail() {
    final existing = detail.value;

    detail.value = BookingDetail(
      id: existing?.id ?? bookingId,
      bookingId: existing?.bookingId ?? 'GYZ9948563201928',
      listingName: existing?.listingName ?? 'Kerala Boat Ac',
      status: existing?.status ?? BookingStatus.booked,
      address: 'Palarivattam , Kochi , Kerala',
      partnerName: 'kayakkin thrissur',
      partnerPhone: '+919000000000',
      bookingDate: '31 June 2026',
      tripType: 'Day Trip',
      timeSlot: '11 AM - 05 PM',
      stay: const StayDetails(rooms: 3, bathrooms: 3, beds: 6),
      facilities: const ['Free wifi', 'Musical dramas', 'DJ', '3 rooms'],
      policies: const [
        'Cancellation is allowed before 10 days before the slot date',
        'Guests are not allowed',
        'Outside food is not allowed',
        '3 rooms',
      ],
      about: 'A houseboat is a unique type of accommodation designed to offer '
          'the comfort of a home while floating on water. Traditionally used '
          'for transportation and living, houseboats today are popular for '
          'leisure travel and relaxing vacations, especially in scenic '
          'backwater destinations.',
      total: 12100,
      charges: const [
        BillLine(label: 'Day Trip Charge', amount: 500),
        BillLine(label: 'Google pay', amount: 11600),
      ],
      billLines: const [
        BillLine(label: 'Day Trip Charge', amount: 500, originalAmount: 1200),
        BillLine(label: 'GST', amount: 500),
        BillLine(label: 'Coupon Discount', amount: 0, isDeduction: true),
        BillLine(
          label: 'You have saved',
          amount: 700,
          isDeduction: true,
          isSaving: true,
        ),
      ],
      related: const RelatedListing(
        id: '1',
        name: 'Kerala Boat Ac',
        address: 'Palarivattam , Kochi , Kerala',
      ),
    );
  }

  void goBack() => Get.back();

  /// Copies the booking ID — the partner asks for it at check-in.
  Future<void> copyBookingId() async {
    final id = detail.value?.bookingId;
    if (id == null || id.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: id));
    Get.snackbar(
      BookingDetailStrings.copy,
      BookingDetailStrings.copied,
      duration: BookingDetailDurations.snackbar,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void toggleAbout() => isAboutExpanded.toggle();

  void toggleReminder() {
    hasReminder.toggle();
    // TODO(bookings): schedule/cancel a local notification for the slot.
    _pending('Reminders');
  }

  /// Turn-by-turn directions in Google Maps — to the pinned point, else the address.
  Future<void> openDirections() async {
    final current = detail.value;
    if (current == null) return;
    final opened = await GeoService.openDirections(
      point: current.point,
      address: current.address,
    );
    if (!opened) _pending('Directions');
  }

  /// Needs `url_launcher` to place the call; not a dependency yet.
  void callPartner() => _pending('Calling the partner');

  void downloadInvoice() => _pending('Invoice download');

  void writeReview() => _pending(BookingDetailStrings.writeReview);

  void openListing() => _pending(detail.value?.related?.name ?? 'Listing');

  void _pending(String feature) {
    Get.snackbar(
      BookingDetailStrings.pendingTitle,
      BookingDetailStrings.pendingMessage(feature),
      duration: BookingDetailDurations.snackbar,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Formats a rupee amount the Indian way: ₹1,21,500.
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
}
