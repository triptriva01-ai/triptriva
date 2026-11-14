import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../data/providers/api_exception.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/booking_service.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/trip_loader.dart';
import '../../booking/controllers/booking_controller.dart';
import '../constants/payment_constants.dart';

/// What the booking flow hands to the payment screen.
class PaymentArgs {
  const PaymentArgs({
    required this.listingName,
    required this.tripFee,
    this.originalTripFee,
    this.platformFee = 0,
    this.originalPlatformFee,
    this.gst = 0,
    this.originalGst,
    this.couponDiscount = 0,
    this.savings = 0,
    this.bookingId,
    this.imageUrl,
  });

  final String listingName;
  final double tripFee;
  final double? originalTripFee;
  final double platformFee;
  final double? originalPlatformFee;
  final double gst;
  final double? originalGst;
  final double couponDiscount;
  final double savings;
  final String? bookingId;
  final String? imageUrl;

  double get total => tripFee + platformFee + gst - couponDiscount;
}

/// What the success screen shows.
class BookingSuccessArgs {
  const BookingSuccessArgs({required this.bookingId, this.imageUrl});

  final String bookingId;
  final String? imageUrl;
}

enum PaymentMethod { upi, card }

/// How a checkout ended, from Razorpay's callbacks.
sealed class _CheckoutResult {
  const _CheckoutResult();
}

class _CheckoutPaid extends _CheckoutResult {
  const _CheckoutPaid(this.orderId, this.paymentId, this.signature);
  final String orderId;
  final String paymentId;
  final String signature;
}

class _CheckoutFailed extends _CheckoutResult {
  const _CheckoutFailed(this.message, {this.cancelled = false});
  final String message;
  final bool cancelled;
}

/// Payment page — review the bill, pick UPI or card, pay.
///
/// "Pay" asks the backend for a gateway order, opens Razorpay's checkout
/// for it, then has the backend verify the signed result. Card numbers and
/// UPI ids are typed into Razorpay's own sheet; they never touch this app or
/// our server. With the backend's sandbox gateway (development without
/// keys) the sandbox endpoint stands in for the checkout.
class PaymentController extends GetxController {
  final BookingService _bookingService = Get.find<BookingService>();
  final AuthService _authService = Get.find<AuthService>();

  /// The bill on screen — what the booking flow passed in, then replaced by
  /// the server's own breakdown once `GET /bookings/{id}/payment` returns.
  final bill = const PaymentArgs(listingName: '', tripFee: 0).obs;
  PaymentArgs get args => bill.value;

  final errorMessage = ''.obs;

  /// The method Razorpay's sheet opens on.
  final expanded = Rxn<PaymentMethod>(PaymentMethod.upi);

  final isPaying = false.obs;

  Razorpay? _razorpay;
  Completer<_CheckoutResult>? _checkout;

  @override
  void onInit() {
    super.onInit();
    final value = Get.arguments;
    if (value is PaymentArgs) bill.value = value;
    _loadBill();
  }

  @override
  void onClose() {
    _razorpay?.clear();
    super.onClose();
  }

  Future<void> _loadBill() async {
    final id = args.bookingId;
    if (id == null || id.isEmpty) return;
    try {
      final data = await _bookingService.getPayment(id);
      if (data is! Map) return;
      double? number(String key) {
        final raw = data[key];
        return raw is num ? raw.toDouble() : double.tryParse('${raw ?? ''}');
      }

      final base = number('basePrice');
      final discounted = number('discountedPrice');
      final coupon = number('couponDiscount') ?? 0;
      if (discounted == null) return;
      bill.value = PaymentArgs(
        listingName: args.listingName,
        tripFee: discounted,
        originalTripFee: base != null && base > discounted ? base : null,
        couponDiscount: coupon,
        savings: ((base ?? discounted) - discounted) + coupon,
        bookingId: id,
        imageUrl: args.imageUrl,
      );
    } on ApiException catch (error) {
      Get.log('Payment summary load failed: $error');
    }
  }

  String rupees(double amount) => BookingController.formatRupees(amount);

  /// "₹3,200.00" — the header shows paise as well.
  String get totalLabel => '${rupees(args.total)}.00';

  void toggle(PaymentMethod method) => expanded.value = method;

  bool get canPay => !isPaying.value && (args.bookingId ?? '').isNotEmpty;

  String get _method => switch (expanded.value) {
        PaymentMethod.card => 'card',
        _ => 'upi',
      };

  /// Order → checkout → confirm.
  Future<void> pay() async {
    final id = args.bookingId;
    if (!canPay || id == null) return;
    isPaying.value = true;
    errorMessage.value = '';
    try {
      final order = await TripLoader.during(
        () => _bookingService.createPaymentOrder(id),
      );
      if (order is! Map) {
        throw const ApiException(message: PaymentStrings.orderFailed);
      }
      final orderId = '${order['orderId'] ?? ''}';
      final provider = '${order['provider'] ?? ''}';

      final result = switch (provider) {
        'razorpay' => await _openRazorpay(order.cast<String, dynamic>()),
        'sandbox' => await _sandboxCheckout(orderId),
        _ => throw const ApiException(message: PaymentStrings.gatewayMissing),
      };

      switch (result) {
        case _CheckoutFailed(:final message, :final cancelled):
          if (!cancelled) _fail(message);
          return;
        case _CheckoutPaid(:final orderId, :final paymentId, :final signature):
          await TripLoader.during(
            () => _bookingService.confirmPayment(
              id,
              orderId: orderId,
              paymentId: paymentId,
              signature: signature,
              method: _method,
            ),
          );
      }
    } on ApiException catch (error) {
      Get.log('Payment failed: $error');
      _fail(error.message);
      return;
    } finally {
      isPaying.value = false;
    }
    Get.offNamed(
      Routes.BOOKING_SUCCESS,
      arguments: BookingSuccessArgs(bookingId: id, imageUrl: args.imageUrl),
    );
  }

  void _fail(String message) {
    errorMessage.value = message;
    Get.snackbar(
      PaymentStrings.paymentFailed,
      message,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Opens Razorpay's checkout sheet and waits for it to close.
  Future<_CheckoutResult> _openRazorpay(Map<String, dynamic> order) async {
    final razorpay = _razorpay ??= Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaid)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _onFailed)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    // Fill in who is paying, so the sheet skips straight to the method.
    String? email;
    String? phone;
    try {
      final me = await _authService.me();
      email = me.email.isEmpty ? null : me.email;
      phone = me.phone.isEmpty ? null : me.phone;
    } on ApiException catch (error) {
      Get.log('Could not prefill checkout: $error');
    }

    final amount = order['amount'];
    final checkout = _checkout = Completer<_CheckoutResult>();
    razorpay.open({
      'key': order['keyId'],
      'order_id': order['orderId'],
      // Paise; the order already fixes the amount, Razorpay shows this one.
      'amount': amount is num ? (amount * 100).round() : 0,
      'currency': order['currency'] ?? 'INR',
      'name': PaymentStrings.merchantName,
      'description': args.listingName,
      'prefill': {
        'email': ?email,
        'contact': ?phone,
        'method': _method,
      },
      'theme': {'color': '#1F7A63'},
      'retry': {'enabled': true, 'max_count': 2},
    });
    return checkout.future;
  }

  void _onPaid(PaymentSuccessResponse response) {
    _checkout?.complete(
      _CheckoutPaid(
        response.orderId ?? '',
        response.paymentId ?? '',
        response.signature ?? '',
      ),
    );
    _checkout = null;
  }

  void _onFailed(PaymentFailureResponse response) {
    // Code 2 is Razorpay's "payment cancelled by user" (sheet closed).
    final cancelled = response.code == Razorpay.PAYMENT_CANCELLED;
    _checkout?.complete(
      _CheckoutFailed(
        cancelled
            ? PaymentStrings.paymentCancelled
            : (response.message?.isNotEmpty ?? false)
                ? response.message!
                : PaymentStrings.paymentDeclined,
        cancelled: cancelled,
      ),
    );
    _checkout = null;
  }

  /// A wallet that pays outside Razorpay (e.g. Paytm app) — the payment is
  /// not confirmed here; treat it like a closed sheet.
  void _onExternalWallet(ExternalWalletResponse response) {
    _checkout?.complete(
      const _CheckoutFailed(PaymentStrings.paymentCancelled, cancelled: true),
    );
    _checkout = null;
  }

  /// Development backends without keys: the sandbox signs a fake payment.
  Future<_CheckoutResult> _sandboxCheckout(String orderId) async {
    final checkout = await TripLoader.during(
      () => _bookingService.sandboxCheckout(orderId),
    );
    if (checkout is! Map) {
      return const _CheckoutFailed(PaymentStrings.orderFailed);
    }
    return _CheckoutPaid(
      orderId,
      '${checkout['paymentId']}',
      '${checkout['signature']}',
    );
  }
}

/// Success page — confirmation after payment.
class BookingSuccessController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final BookingSuccessArgs args;

  /// Drives the reveal: blank card → badge → tick, text and confetti.
  late final AnimationController reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void onInit() {
    super.onInit();
    final value = Get.arguments;
    args = value is BookingSuccessArgs
        ? value
        : const BookingSuccessArgs(bookingId: '');
  }

  @override
  void onReady() {
    super.onReady();
    reveal.forward();
  }

  @override
  void onClose() {
    reveal.dispose();
    super.onClose();
  }

  Future<void> copyBookingId() async {
    await Clipboard.setData(ClipboardData(text: args.bookingId));
    Get.snackbar(
      PaymentStrings.success,
      PaymentStrings.copied,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToExplore() => Get.offAllNamed(Routes.HOME);

  void goToReserve() {
    Get.offAllNamed(Routes.HOME);
    Get.toNamed(Routes.RESERVATIONS);
  }
}
