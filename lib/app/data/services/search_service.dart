import 'package:get/get.dart';

import '../constants/api_endpoints.dart';
import '../providers/api_client.dart';

/// Search & discovery page — `Search` sheet (Page 6).
class SearchService extends GetxService {
  final ApiClient _api = Get.find<ApiClient>();

  /// Full text search; a non-blank `q` is saved as a recent search.
  /// Params: q, category, lat, lng, date, pax, page, limit. Returns a page.
  Future<dynamic> search(Map<String, dynamic> query) =>
      _api.getRequest(SearchEndpoints.search, query: query);

  /// Autocomplete while typing — a list of strings.
  Future<dynamic> suggestions(String q, {int limit = 8}) => _api.getRequest(
        SearchEndpoints.suggestions,
        query: {'q': q, 'limit': limit},
      );

  Future<dynamic> nearby({
    required double lat,
    required double lng,
    String? category,
    int limit = 20,
  }) =>
      _api.getRequest(
        SearchEndpoints.nearby,
        query: {'lat': lat, 'lng': lng, 'category': ?category, 'limit': limit},
      );

  /// Listings with capacity open today, or on [date] (`YYYY-MM-DD`).
  /// Returns a page.
  Future<dynamic> available({
    String? date,
    String? category,
    int page = 1,
    int limit = 20,
  }) =>
      _api.getRequest(
        SearchEndpoints.available,
        query: {
          'date': ?date,
          'category': ?category,
          'page': page,
          'limit': limit,
        },
      );

  /// `[{name, searchCount}]`, most searched first.
  Future<dynamic> popularLocations({int limit = 5}) => _api.getRequest(
        SearchEndpoints.popularLocations,
        query: {'limit': limit},
      );

  /// `[{id, query, category, searchedAt}]`, newest first.
  Future<dynamic> recent({int limit = 10}) =>
      _api.getRequest(SearchEndpoints.recent, query: {'limit': limit});

  Future<dynamic> clearRecent() => _api.deleteRequest(SearchEndpoints.recent);

  Future<dynamic> removeRecent(String id) =>
      _api.deleteRequest(SearchEndpoints.recentEntry(id));
}
