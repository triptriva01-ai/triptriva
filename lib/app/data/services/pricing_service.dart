import 'package:get/get.dart';

import '../constants/api_endpoints.dart';
import '../providers/api_client.dart';

/// PAX selection & pricing page — `PAX & Pricing` sheet (Page 7).
class PricingService extends GetxService {
  final ApiClient _api = Get.find<ApiClient>();

  /// Dynamic pricing. Params: slotId, pax, date.
  /// Returns: basePrice, discountedPrice, couponDiscount, finalAmount.
  Future<dynamic> getPricing(
    String listingId, {
    required String slotId,
    required int pax,
    required String date,
  }) =>
      _api.getRequest(
        PricingEndpoints.pricing(listingId),
        query: {'slotId': slotId, 'pax': pax, 'date': date},
      );

  Future<dynamic> validateCoupon({
    required String couponCode,
    required String listingId,
    required num amount,
  }) =>
      _api.postRequest(
        PricingEndpoints.validateCoupon,
        body: {
          'couponCode': couponCode,
          'listingId': listingId,
          'amount': amount,
        },
      );

  Future<dynamic> getCoupons({String? listingId}) => _api.getRequest(
        PricingEndpoints.coupons,
        query: {'listingId': listingId},
      );

  Future<dynamic> initiateBooking({
    required String listingId,
    required String slotId,
    required String date,
    required int pax,
    String? couponCode,
  }) =>
      _api.postRequest(
        PricingEndpoints.initiateBooking,
        body: {
          'listingId': listingId,
          'slotId': slotId,
          'date': date,
          'pax': pax,
          'couponCode': ?couponCode,
        },
      );
}
