import 'package:get/get.dart';

import '../constants/api_endpoints.dart';
import '../providers/api_client.dart';

/// Property details page — `Property` sheet (Page 5).
class PropertyService extends GetxService {
  final ApiClient _api = Get.find<ApiClient>();

  Future<dynamic> getDetail(String listingId) =>
      _api.getRequest(PropertyEndpoints.detail(listingId));

  /// Reviews for a listing. Filter: all/recent/positive/negative, page, limit.
  Future<dynamic> getReviews(String listingId, {Map<String, dynamic>? query}) =>
      _api.getRequest(PropertyEndpoints.reviews(listingId), query: query);

  Future<dynamic> getNearby(String listingId) =>
      _api.getRequest(PropertyEndpoints.nearby(listingId));
}
