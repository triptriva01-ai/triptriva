import 'package:get/get.dart';

import '../constants/api_endpoints.dart';
import '../providers/api_client.dart';

/// Reservations page — `Reservations` sheet (Page 2).
class BookingService extends GetxService {
  final ApiClient _api = Get.find<ApiClient>();

  /// All bookings for the current user. Params: status (all/booked/completed),
  /// search, date.
  Future<dynamic> getBookings({Map<String, dynamic>? query}) =>
      _api.getRequest(BookingEndpoints.bookings, query: query);

  /// Full booking detail — complete payload designed for offline caching.
  Future<dynamic> getDetail(String id) =>
      _api.getRequest(BookingEndpoints.detail(id));

  Future<dynamic> cancel(String id, {String? reason}) => _api.postRequest(
        BookingEndpoints.cancel(id),
        body: {'reason': ?reason},
      );

  /// The invoice as PDF bytes.
  Future<List<int>> getInvoice(String id) =>
      _api.getBytes(BookingEndpoints.invoice(id));

  /// The bill line by line, and what is still due.
  Future<dynamic> getPayment(String id) =>
      _api.getRequest(BookingEndpoints.payment(id));

  Future<dynamic> createPaymentOrder(String id) =>
      _api.postRequest(BookingEndpoints.paymentOrder(id));

  Future<dynamic> confirmPayment(
    String id, {
    required String orderId,
    required String paymentId,
    required String signature,
    String? method,
  }) =>
      _api.postRequest(
        BookingEndpoints.paymentConfirm(id),
        body: {
          'orderId': orderId,
          'paymentId': paymentId,
          'signature': signature,
          'method': ?method,
        },
      );

  Future<dynamic> sandboxCheckout(String orderId) => _api.postRequest(
        BookingEndpoints.sandboxCheckout,
        body: {'orderId': orderId},
      );
}
