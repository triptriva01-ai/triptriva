import 'package:get/get.dart';

import '../../../data/providers/api_exception.dart';
import '../../../data/services/partner_service.dart';

/// Partner-side Page 2.2 — Confirm the customer.
///
/// The guest reads out the 6-digit check-in code shown on their booking; the
/// partner types it in and `POST /api/partners/me/bookings/{id}/check-in`
/// checks them in.
class ConfirmCustomerController extends GetxController {
  static const codeLength = 6;

  final PartnerService _partnerService = Get.find<PartnerService>();

  final customerName = 'Customer'.obs;
  final entryDate = ''.obs;
  final entryTime = ''.obs;
  final avatarUrl = ''.obs;

  final code = ''.obs;
  final isVerifying = false.obs;
  final isConfirmed = false.obs;
  final errorMessage = ''.obs;

  /// The booking being checked in. Empty when opened from a manual booking
  /// that hasn't been saved — there's no code to check in that case.
  String _bookingId = '';

  bool get isComplete => code.value.length == codeLength;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      final name = args['customerName'];
      if (name is String && name.trim().isNotEmpty) {
        customerName.value = name.trim();
      }
      final date = args['date'];
      if (date is DateTime) {
        entryDate.value = '${date.day} ${_monthName(date.month)}';
      }
      final slot = args['slot'];
      if (slot is String && slot.trim().isNotEmpty) {
        entryTime.value = slot.trim();
      }
      _bookingId = '${args['bookingId'] ?? ''}';
    }
  }

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  String _monthName(int month) => _months[month - 1];

  void onCodeChanged(String value) {
    errorMessage.value = '';
    code.value = value;
  }

  /// Checks the code against the booking and shows the success state on this
  /// same route.
  Future<void> confirm() async {
    if (!isComplete || isVerifying.value) {
      return;
    }
    if (_bookingId.isEmpty) {
      errorMessage.value =
          'This booking isn\'t saved yet, so there is no check-in code.';
      return;
    }

    isVerifying.value = true;
    errorMessage.value = '';
    try {
      await _partnerService.checkIn(_bookingId, code.value);
      isConfirmed.value = true;
    } on ApiException catch (error) {
      // The server's message says what went wrong: wrong code (with the
      // attempts left), wrong day, already checked in, or locked.
      errorMessage.value = error.message;
    } finally {
      isVerifying.value = false;
    }
  }

  void goBack() => Get.back();

  /// Leaves the success screen and tells the dashboard the guest is in.
  void done() => Get.back(result: isConfirmed.value);
}
