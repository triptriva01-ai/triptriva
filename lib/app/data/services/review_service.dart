import 'package:get/get.dart';

import '../constants/api_endpoints.dart';
import '../providers/api_client.dart';

/// Reviews — `Reviews` sheet (cross-screen).
class ReviewService extends GetxService {
  final ApiClient _api = Get.find<ApiClient>();

  /// Submit a review. Only valid for completed bookings.
  Future<dynamic> submitReview({
    required String bookingId,
    required String listingId,
    required int rating,
    required String comment,
  }) =>
      _api.postRequest(
        ReviewEndpoints.reviews,
        body: {
          'bookingId': bookingId,
          'listingId': listingId,
          'rating': rating,
          'comment': comment,
        },
      );

  /// Get reviews for a listing. Filter: all/recent/positive/negative, page,
  /// limit.
  Future<dynamic> getReviews(String listingId, {Map<String, dynamic>? query}) =>
      _api.getRequest(ReviewEndpoints.forListing(listingId), query: query);
}
