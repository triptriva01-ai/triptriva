import 'package:get/get.dart';

import '../constants/api_endpoints.dart';
import '../providers/api_client.dart';

/// Home / Explore page — `Home` sheet (Page 1).
class HomeService extends GetxService {
  final ApiClient _api = Get.find<ApiClient>();

  /// All listings. Supported query params: category, date, priceMin, priceMax,
  /// capacity, lat, lng, page, limit.
  Future<dynamic> getListings({Map<String, dynamic>? query}) =>
      _api.getRequest(HomeEndpoints.listings, query: query);

  Future<dynamic> getPopular() => _api.getRequest(HomeEndpoints.popular);

  Future<dynamic> getNearby({required double lat, required double lng}) =>
      _api.getRequest(HomeEndpoints.nearby, query: {'lat': lat, 'lng': lng});

  Future<dynamic> getFresh() => _api.getRequest(HomeEndpoints.fresh);

  Future<dynamic> getAllFresh({int page = 1, int limit = 20}) => _api.getRequest(
        HomeEndpoints.freshAll,
        query: {'page': page, 'limit': limit},
      );

  Future<dynamic> getNewAdventures() =>
      _api.getRequest(HomeEndpoints.newAdventures);

  Future<dynamic> getBanners() => _api.getRequest(HomeEndpoints.banners);

  Future<dynamic> getCategories() => _api.getRequest(HomeEndpoints.categories);
}
