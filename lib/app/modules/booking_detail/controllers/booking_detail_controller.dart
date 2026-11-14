import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

import '../../../data/models/booking.dart';
import '../../../data/models/booking_detail.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/services/booking_service.dart';
import '../../../data/services/review_service.dart';
import '../../../routes/app_pages.dart';
import '../widgets/write_review_sheet.dart';
import '../constants/booking_detail_constants.dart';
import '../../../data/services/geo_service.dart';

/// Booking detail — the "reservation inside" page reached from My Bookings.
///
/// One `GET /api/bookings/{id}` fills the entire screen; the bill breakdown
/// behind "Payment Details" comes from the same payload rather than a second
/// round trip, so it opens instantly.
class BookingDetailController extends GetxController {
  final BookingService _bookingService = Get.find<BookingService>();
  final ReviewService _reviewService = Get.find<ReviewService>();

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
      // Only complain if there is nothing at all to show.
      if (detail.value == null) {
        errorMessage.value = error.message;
      }
    } finally {
      isLoading.value = false;
    }
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

  /// Dials the partner when the booking carries their number.
  Future<void> callPartner() async {
    final phone = detail.value?.partnerPhone.trim() ?? '';
    if (phone.isEmpty) {
      _notice(BookingDetailStrings.noPartnerPhone);
      return;
    }
    await launchUrl(Uri(scheme: 'tel', path: phone));
  }

  final isDownloading = false.obs;

  /// Fetches the PDF invoice, saves it and opens it in the PDF viewer.
  Future<void> downloadInvoice() async {
    final current = detail.value;
    if (current == null || isDownloading.value) return;
    if (!current.canDownloadInvoice) {
      _notice(BookingDetailStrings.invoiceUnavailable);
      return;
    }
    isDownloading.value = true;
    try {
      final bytes = await _bookingService.getInvoice(bookingId);
      final folder = await getApplicationDocumentsDirectory();
      final file = File('${folder.path}/invoice-${current.bookingId}.pdf');
      await file.writeAsBytes(bytes, flush: true);
      final result = await OpenFilex.open(file.path, type: 'application/pdf');
      if (result.type != ResultType.done) {
        _notice(BookingDetailStrings.invoiceSaved(file.path));
      }
    } on ApiException catch (error) {
      _notice(error.message);
    } finally {
      isDownloading.value = false;
    }
  }

  /// Star rating and a comment, posted once per completed booking.
  Future<void> writeReview() async {
    final current = detail.value;
    if (current == null) return;
    final review = await Get.bottomSheet<ReviewDraft>(
      const WriteReviewSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
    if (review == null) return;
    try {
      await _reviewService.submitReview(
        bookingId: bookingId,
        listingId: current.listingId.isNotEmpty
            ? current.listingId
            : current.related?.id ?? '',
        rating: review.rating,
        comment: review.comment,
      );
      _notice(BookingDetailStrings.reviewThanks);
      await loadDetail();
    } on ApiException catch (error) {
      _notice(error.message);
    }
  }

  /// Asks first, then cancels; the refund follows the listing's policy.
  Future<void> cancelBooking() async {
    final current = detail.value;
    if (current == null || !current.canCancel) return;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(BookingDetailStrings.cancelTitle),
        content: const Text(BookingDetailStrings.cancelBody),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(BookingDetailStrings.keepBooking),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(BookingDetailStrings.cancelBooking),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final data = await _bookingService.cancel(bookingId);
      final cancellation = data is Map ? data['cancellation'] : null;
      final refund = cancellation is Map ? cancellation['refundAmount'] : null;
      _notice(
        refund is num && refund > 0
            ? BookingDetailStrings.cancelledWithRefund(formatRupees(refund.toDouble()))
            : BookingDetailStrings.cancelled,
      );
      await loadDetail();
    } on ApiException catch (error) {
      _notice(error.message);
    }
  }

  void openListing() {
    final id = detail.value?.related?.id ?? detail.value?.listingId ?? '';
    if (id.isEmpty) return;
    Get.toNamed(Routes.LISTING_DETAIL, arguments: id);
  }

  void _notice(String message) => Get.snackbar(
        detail.value?.listingName ?? '',
        message,
        duration: BookingDetailDurations.snackbar,
        snackPosition: SnackPosition.BOTTOM,
      );

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
