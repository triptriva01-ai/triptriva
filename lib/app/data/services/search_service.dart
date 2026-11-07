import 'package:get/get.dart';

import '../constants/api_endpoints.dart';
import '../providers/api_client.dart';

/// Search & discovery page — `Search` sheet (Page 6).
class SearchService extends GetxService {
  final ApiClient _api = Get.find<ApiClient>();

  /// Full text search. Params: q, category, lat, lng, date, pax.
  Future<dynamic> search(Map<String, dynamic> query) =>
      _api.getRequest(SearchEndpoints.search, query: query);

  Future<dynamic> suggestions(String q) =>
      _api.getRequest(SearchEndpoints.suggestions, query: {'q': q});

  Future<dynamic> nearby({required double lat, required double lng}) =>
      _api.getRequest(SearchEndpoints.nearby, query: {'lat': lat, 'lng': lng});

  Future<dynamic> available({String? date}) =>
      _api.getRequest(SearchEndpoints.available, query: {'date': date});

  Future<dynamic> popularLocations() =>
      _api.getRequest(SearchEndpoints.popularLocations);

  Future<dynamic> recent() => _api.getRequest(SearchEndpoints.recent);

  Future<dynamic> clearRecent() => _api.deleteRequest(SearchEndpoints.recent);

  Future<dynamic> removeRecent(String id) =>
      _api.deleteRequest(SearchEndpoints.recentEntry(id));
}
