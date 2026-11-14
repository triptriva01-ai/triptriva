import 'package:get/get.dart';

import '../constants/api_endpoints.dart';
import '../providers/api_client.dart';

/// Home / Explore page — `Home` sheet (Page 1).
class HomeService extends GetxService {
  final ApiClient _api = Get.find<ApiClient>();

  /// The whole home screen in one call: banners, categories, featured,
  /// trending and (with lat/lng) nearby.
  Future<dynamic> getFeed({double? lat, double? lng}) => _api.getRequest(
        HomeEndpoints.feed,
        query: {'lat': ?lat, 'lng': ?lng},
      );

  /// Published listings. Params: q, type, city, minPrice, maxPrice,
  /// minRating, guests, lat, lng, radiusKm, sort (recommended / price_asc /
  /// price_desc / rating / newest / popular / distance), page, limit.
  /// Returns a page: `{items, totalCount, page, limit, hasNextPage}`.
  Future<dynamic> getListings({Map<String, dynamic>? query}) =>
      _api.getRequest(HomeEndpoints.listings, query: query);

  /// Nearest first. Params: lat, lng, radiusKm, limit, type.
  Future<dynamic> getNearby({
    required double lat,
    required double lng,
    String? type,
    int limit = 10,
  }) =>
      _api.getRequest(
        HomeEndpoints.nearby,
        query: {'lat': lat, 'lng': lng, 'type': ?type, 'limit': limit},
      );

  Future<dynamic> getCategories() => _api.getRequest(HomeEndpoints.categories);
}
