import 'package:get/get.dart';

import '../constants/api_endpoints.dart';
import '../models/partner_activity.dart';
import '../models/partner_booking.dart';
import '../providers/api_client.dart';

/// Partner portal — backed by `PartnersController` (`/api/partners`).
///
/// Everything under `/me/listings`, `/me/bookings` and `/me/revenue` needs the
/// partner role on the access token; `/me` and `apply` work for any user.
class PartnerService extends GetxService {
  final ApiClient _api = Get.find<ApiClient>();

  String? _cachedName;

  /// The partner's display name for the screen headers. Fetched once per app
  /// session; null if it can't be loaded (the header keeps its placeholder).
  Future<String?> displayName() async {
    if (_cachedName != null) return _cachedName;
    try {
      final user = (await getProfile())['user'];
      final name = user is Map ? '${user['name'] ?? ''}'.trim() : '';
      if (name.isNotEmpty) _cachedName = name;
    } catch (error) {
      Get.log('Partner name load failed: $error');
    }
    return _cachedName;
  }

  /// Forget the cached name (on logout or after a profile edit).
  void clearCache() => _cachedName = null;

  Future<dynamic> apply(Map<String, dynamic> body) =>
      _api.postRequest(PartnerEndpoints.apply, body: body);

  /// `{user, isPartner, applicationStatus, rejectionReason, listingsTotal, …}`.
  Future<Map<String, dynamic>> getProfile() async {
    final data = await _api.getRequest(PartnerEndpoints.me);
    return (data as Map).cast<String, dynamic>();
  }

  /// The partner's listings, newest first. [status]: all, pending, accepted, rejected.
  Future<List<PartnerActivity>> getMyListings({String status = 'all'}) async {
    final rows = await _allPages(
      PartnerEndpoints.myListings,
      {'status': status},
      pageSize: 100,
    );
    return rows.map(PartnerActivity.fromJson).toList();
  }

  Future<dynamic> createListing(Map<String, dynamic> body) =>
      _api.postRequest(PartnerEndpoints.myListings, body: body);

  /// Partial update — only the fields in [body] change.
  Future<dynamic> updateListing(String id, Map<String, dynamic> body) =>
      _api.putRequest(PartnerEndpoints.myListing(id), body: body);

  Future<dynamic> deleteListing(String id) =>
      _api.deleteRequest(PartnerEndpoints.myListing(id));

  /// Paid bookings on the partner's listings.
  /// [status]: all, upcoming, completed, cancelled.
  Future<List<PartnerBooking>> getMyBookings({
    String status = 'all',
    String? listingId,
  }) async {
    final rows = await _allPages(
      PartnerEndpoints.myBookings,
      {'status': status, 'listingId': listingId},
      // Bookings are served at most 50 a page (a larger limit falls back to 20).
      pageSize: 50,
    );
    return rows.map(PartnerBooking.fromJson).toList();
  }

  /// Checks the guest in with the code from their booking. 400 for a wrong
  /// code; 409 if it isn't for today, is already checked in, or is locked.
  Future<PartnerBooking> checkIn(String bookingId, String code) async {
    final data = await _api.postRequest(
      PartnerEndpoints.checkIn(bookingId),
      body: {'code': code},
    );
    return PartnerBooking.fromJson((data as Map).cast<String, dynamic>());
  }

  /// `{summary: {thisMonthTotal, growthPercent, yearTotal, …}, byListing: [...]}`.
  Future<Map<String, dynamic>> getMyRevenue() async {
    final data = await _api.getRequest(PartnerEndpoints.myRevenue);
    return (data as Map).cast<String, dynamic>();
  }

  /// Adds a walk-in booking; returns the created booking (with `checkInCode`).
  Future<Map<String, dynamic>> createManualBooking({
    required String listingId,
    required DateTime date,
    required String guestName,
    String? guestPhone,
    String? slotId,
    int pax = 1,
  }) async {
    final data = await _api.postRequest(
      PartnerEndpoints.manualBooking,
      body: {
        'listingId': listingId,
        'date': _day(date),
        'guestName': guestName,
        'guestPhone': ?guestPhone,
        'slotId': ?slotId,
        'pax': pax,
      },
    );
    return (data as Map).cast<String, dynamic>();
  }

  /// The listing's calendar from [from] to [to] (inclusive, at most 366 days).
  Future<Map<String, dynamic>> getAvailability(
    String listingId,
    DateTime from,
    DateTime to,
  ) async {
    final data = await _api.getRequest(
      PartnerEndpoints.availability(listingId),
      query: {'from': _day(from), 'to': _day(to)},
    );
    return (data as Map).cast<String, dynamic>();
  }

  /// Opens or closes a run of dates. [totalUnits] is required to open a date
  /// that was never set up (it has no capacity yet). 409 if a change would
  /// drop a day below what's already booked — nothing is saved in that case.
  Future<dynamic> setAvailability(
    String listingId, {
    required DateTime from,
    required DateTime to,
    required bool isAvailable,
    int? totalUnits,
  }) =>
      _api.putRequest(
        PartnerEndpoints.availability(listingId),
        body: {
          'from': _day(from),
          'to': _day(to),
          'isAvailable': isAvailable,
          'totalUnits': ?totalUnits,
        },
      );

  static String _day(DateTime day) =>
      '${day.year}-${day.month.toString().padLeft(2, '0')}'
      '-${day.day.toString().padLeft(2, '0')}';

  /// Follows `hasNextPage` so the screens see every row. Capped, so a runaway
  /// account can't make a screen load forever.
  Future<List<Map<String, dynamic>>> _allPages(
    String path,
    Map<String, dynamic> query, {
    required int pageSize,
    int maxPages = 20,
  }) async {
    final rows = <Map<String, dynamic>>[];
    for (var page = 1; page <= maxPages; page++) {
      final data = await _api.getRequest(
        path,
        query: {...query, 'page': page, 'limit': pageSize},
      );
      rows.addAll(_items(data));
      if (data is! Map || data['hasNextPage'] != true) break;
    }
    return rows;
  }

  /// Paged responses wrap rows in `items`.
  static List<Map<String, dynamic>> _items(dynamic data) {
    final items = data is Map ? data['items'] : data;
    return items is List
        ? items.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList()
        : const [];
  }
}
