import 'package:get/get.dart';

import '../constants/api_endpoints.dart';
import '../providers/api_client.dart';

/// Wishlist page — `Wishlist` sheet (Page 3).
class WishlistService extends GetxService {
  final ApiClient _api = Get.find<ApiClient>();

  /// Current user's wishlist. Params: category, search, date.
  Future<dynamic> getWishlist({Map<String, dynamic>? query}) =>
      _api.getRequest(WishlistEndpoints.wishlist, query: query);

  Future<dynamic> add(String listingId) =>
      _api.postRequest(WishlistEndpoints.item(listingId));

  Future<dynamic> remove(String listingId) =>
      _api.deleteRequest(WishlistEndpoints.item(listingId));

  Future<dynamic> isWishlisted(String listingId) =>
      _api.getRequest(WishlistEndpoints.check(listingId));
}
