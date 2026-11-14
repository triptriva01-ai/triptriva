import '../constants/api_endpoints.dart';
import 'listing.dart';
import 'geo_place.dart';

/// One review on the listing detail page.
class ListingReview {
  const ListingReview({
    required this.id,
    required this.authorName,
    this.avatarUrl = '',
    this.rating = 0,
    this.comment = '',
  });

  factory ListingReview.fromJson(Map<String, dynamic> json) {
    return ListingReview(
      id: '${json['id'] ?? ''}',
      authorName: '${json['authorName'] ?? json['userName'] ?? 'Guest'}',
      avatarUrl: ApiConfig.mediaUrl(
        '${json['avatarUrl'] ?? json['userAvatarUrl'] ?? ''}',
      ),
      rating: _toDouble(json['rating']) ?? 0,
      comment: '${json['comment'] ?? ''}',
    );
  }

  final String id;
  final String authorName;
  final String avatarUrl;
  final double rating;
  final String comment;

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

/// The person renting the listing out.
class ListingHost {
  const ListingHost({
    required this.name,
    this.role = 'Host',
    this.avatarUrl = '',
  });

  factory ListingHost.fromJson(Map<String, dynamic> json) {
    return ListingHost(
      name: '${json['name'] ?? ''}',
      role: '${json['role'] ?? 'Host'}',
      avatarUrl: ApiConfig.mediaUrl('${json['avatarUrl'] ?? ''}'),
    );
  }

  final String name;
  final String role;
  final String avatarUrl;
}

/// Names a session from its times, since the API sends none.
abstract final class ListingSlotNames {
  static String forTimes(String? start, String? end) =>
      ListingSlot._nameFor(start, end);
}

/// One bookable time slot on a given date.
class ListingSlot {
  const ListingSlot({
    required this.id,
    required this.name,
    required this.timeRange,
    this.price = 0,
    this.originalPrice,
    this.isAvailable = true,
  });

  /// Reads the API's session (`slotId`, `startTime`/`endTime` as "HH:mm")
  /// as well as the older `{id, name, timeRange}` shape. The API has no
  /// session names, so one is derived from the times.
  factory ListingSlot.fromJson(Map<String, dynamic> json) {
    final start = json['startTime'] as String?;
    final end = json['endTime'] as String?;
    return ListingSlot(
      id: '${json['id'] ?? json['slotId'] ?? ''}',
      name: '${json['name'] ?? json['type'] ?? _nameFor(start, end)}',
      timeRange: '${json['timeRange'] ?? json['time'] ?? formatRange(start, end)}',
      price: ListingReview._toDouble(json['price']) ?? 0,
      originalPrice: ListingReview._toDouble(json['originalPrice']),
      isAvailable: json['isAvailable'] != false,
    );
  }

  static int? _minutes(String? hhmm) {
    final parts = hhmm?.split(':');
    if (parts == null || parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    return h == null || m == null ? null : h * 60 + m;
  }

  /// Ends before it starts → runs overnight; starts in the evening → night.
  static String _nameFor(String? start, String? end) {
    final from = _minutes(start);
    final to = _minutes(end);
    if (from == null) return 'Session';
    if (to != null && to <= from) return 'Overnight';
    if (from >= 17 * 60) return 'Night Stay';
    return 'Day Trip';
  }

  /// "11:00", "17:00" → "11 AM - 05 PM".
  static String formatRange(String? start, String? end) {
    String label(String? hhmm) {
      final total = _minutes(hhmm);
      if (total == null) return '';
      final h = total ~/ 60;
      final m = total % 60;
      final hour12 = h % 12 == 0 ? 12 : h % 12;
      final minutes = m == 0 ? '' : ':${m.toString().padLeft(2, '0')}';
      return '${hour12.toString().padLeft(2, '0')}$minutes ${h < 12 ? 'AM' : 'PM'}';
    }

    final from = label(start);
    final to = label(end);
    if (from.isEmpty) return '';
    return to.isEmpty ? from : '$from - $to';
  }

  final String id;

  /// "Day Trip", "Overnight", "Night Stay".
  final String name;

  /// "11 AM - 05 PM".
  final String timeRange;
  final double price;
  final double? originalPrice;
  final bool isAvailable;
}

/// The full listing payload behind the product page.
class ListingDetail {
  const ListingDetail({
    required this.id,
    required this.name,
    this.address = '',
    this.imageUrls = const [],
    this.rooms,
    this.bathrooms,
    this.beds,
    this.tagline = '',
    this.rating = 0,
    this.ratingLabel = '',
    this.ratingCaption = '',
    this.reviewCount = 0,
    this.host,
    this.facilities = const [],
    this.policies = const [],
    this.coordinates = '',
    this.mapUrl = '',
    this.about = '',
    this.reviews = const [],
    this.nearbyTitle = '',
    this.nearby = const [],
    this.slots = const [],
    this.price = 0,
    this.originalPrice,
    this.maxPax = 60,
    this.minPax = 1,
    this.cancellationNote = '',
    this.refreshingRoomNote = '',
    this.type = '',
  });

  factory ListingDetail.fromJson(Map<String, dynamic> json) {
    List<String> strings(String key) =>
        (json[key] as List?)?.map((item) => '$item').toList() ?? const [];

    // The API nests the address and map point under `location`.
    final location = json['location'] is Map
        ? (json['location'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final locationAddress = [
      location['address'],
      location['city'],
      location['state'],
    ].where((part) => part is String && part.trim().isNotEmpty).join(', ');
    final locationPoint =
        GeoPoint.tryParse(location['latitude'], location['longitude']);

    Map<String, dynamic> nested(String key) => json[key] is Map
        ? (json[key] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final price = nested('price');
    final rating = nested('rating');
    final capacity = nested('capacity');
    final policy = nested('policies');

    // `images` (API) or `imageUrls`, with the cover first.
    final cover = json['coverImage'] as String?;
    final images = [
      if (cover != null && cover.isNotEmpty) cover,
      ...strings('imageUrls'),
      ...strings('images').where((url) => url != cover),
    ].map(ApiConfig.mediaUrl).toList();

    // `policies` is a list of lines in the old shape, an object in the API's.
    final policies = json['policies'] is List
        ? strings('policies')
        : [
            if (policy['checkInTime'] != null)
              'Check-in from ${policy['checkInTime']}',
            if (policy['checkOutTime'] != null)
              'Check-out by ${policy['checkOutTime']}',
            ...((policy['houseRules'] as List?)?.map((rule) => '$rule') ??
                const <String>[]),
          ];
    final reviewCount =
        _toInt(json['reviewCount']) ?? _toInt(rating['count']) ?? 0;
    final average = json['rating'] is num
        ? ListingReview._toDouble(json['rating'])
        : ListingReview._toDouble(rating['average']);
    final maxGuests = _toInt(json['maxPax']) ?? _toInt(capacity['maxGuests']);

    return ListingDetail(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? json['title'] ?? ''}',
      address: json['address'] is String
          ? json['address'] as String
          : json['location'] is String
              ? json['location'] as String
              : locationAddress,
      imageUrls: images,
      rooms: _toInt(json['rooms']) ?? _toInt(capacity['bedrooms']),
      bathrooms: _toInt(json['bathrooms']) ?? _toInt(capacity['bathrooms']),
      beds: _toInt(json['beds']) ?? _toInt(capacity['beds']),
      tagline: '${json['tagline'] ?? ''}',
      rating: average ?? 0,
      ratingLabel: '${json['ratingLabel'] ?? _ratingLabel(average)}',
      ratingCaption: '${json['ratingCaption'] ?? ''}',
      reviewCount: reviewCount,
      host: json['host'] is Map<String, dynamic>
          ? ListingHost.fromJson(json['host'] as Map<String, dynamic>)
          : null,
      facilities: [...strings('facilities'), ...strings('amenities')],
      policies: policies,
      coordinates: json['coordinates'] is String
          ? json['coordinates'] as String
          : locationPoint?.label ?? '',
      mapUrl: '${json['mapUrl'] ?? ''}',
      about: '${json['about'] ?? json['description'] ?? ''}',
      reviews: ((json['reviews'] ?? json['recentReviews']) as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(ListingReview.fromJson)
              .toList() ??
          const [],
      nearbyTitle: '${json['nearbyTitle'] ?? ''}',
      nearby: (json['nearby'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(Listing.fromJson)
              .toList() ??
          const [],
      slots: (json['slots'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(ListingSlot.fromJson)
              .toList() ??
          const [],
      price: ListingReview._toDouble(json['price']) ??
          ListingReview._toDouble(price['basePrice']) ??
          0,
      originalPrice: ListingReview._toDouble(json['originalPrice']),
      maxPax: maxGuests == null || maxGuests < 1 ? 60 : maxGuests,
      minPax: _toInt(json['minPax']) ?? 1,
      cancellationNote: '${json['cancellationNote'] ?? _cancellationText(policy['cancellationPolicy'])}',
      type: '${json['type'] ?? ''}',
      refreshingRoomNote: '${json['refreshingRoomNote'] ?? ''}',
    );
  }

  final String id;
  final String name;
  final String address;
  final List<String> imageUrls;

  /// Stay counts. Null for listings where the line does not apply, e.g. an
  /// adventure that has a [tagline] instead.
  final int? rooms;
  final int? bathrooms;
  final int? beds;

  /// Shown in place of the stay counts, e.g. "Refreshing room".
  final String tagline;

  final double rating;

  /// "Great" — the word shown beside the score.
  final String ratingLabel;

  /// "For the user".
  final String ratingCaption;
  final int reviewCount;

  final ListingHost? host;
  final List<String> facilities;
  final List<String> policies;

  /// "9.9948565, 76.3201928".
  final String coordinates;

  /// [coordinates] as a map point; null when absent or unreadable.
  GeoPoint? get point {
    final parts = coordinates.split(',');
    if (parts.length != 2) return null;
    return GeoPoint.tryParse(
      double.tryParse(parts[0].trim()),
      double.tryParse(parts[1].trim()),
    );
  }
  final String mapUrl;
  final String about;
  final List<ListingReview> reviews;

  /// "Near By Tree House" — the heading varies with the listing category.
  final String nearbyTitle;
  final List<Listing> nearby;

  final List<ListingSlot> slots;
  final double price;
  final double? originalPrice;

  /// Bounds of the "Number of people" slider.
  final int maxPax;
  final int minPax;

  final String cancellationNote;

  /// "Get 1 hour for refreshing" — only offered by some stays.
  final String refreshingRoomNote;

  /// `stay`, `houseboat` or `adventure`.
  final String type;

  /// For the parts the page loads separately: the nearby rail and reviews.
  ListingDetail copyWith({
    String? nearbyTitle,
    List<Listing>? nearby,
    List<ListingReview>? reviews,
    int? reviewCount,
    List<ListingSlot>? slots,
  }) {
    return ListingDetail(
      id: id,
      name: name,
      address: address,
      imageUrls: imageUrls,
      rooms: rooms,
      bathrooms: bathrooms,
      beds: beds,
      tagline: tagline,
      rating: rating,
      ratingLabel: ratingLabel,
      ratingCaption: ratingCaption,
      reviewCount: reviewCount ?? this.reviewCount,
      host: host,
      facilities: facilities,
      policies: policies,
      coordinates: coordinates,
      mapUrl: mapUrl,
      about: about,
      reviews: reviews ?? this.reviews,
      nearbyTitle: nearbyTitle ?? this.nearbyTitle,
      nearby: nearby ?? this.nearby,
      slots: slots ?? this.slots,
      price: price,
      originalPrice: originalPrice,
      maxPax: maxPax,
      minPax: minPax,
      cancellationNote: cancellationNote,
      refreshingRoomNote: refreshingRoomNote,
      type: type,
    );
  }

  /// The API names the policy; the bottom bar wants a sentence.
  static String _cancellationText(dynamic policy) => switch ('${policy ?? ''}') {
        'flexible' => 'Free cancellation up to 24 hours before',
        'moderate' => 'Free cancellation up to 5 days before, 50% after',
        'strict' => '50% refund if cancelled 7 days before',
        '' || 'null' => '',
        final other => other,
      };

  /// "Great" for 4+, the badge under the rating on the summary card.
  static String _ratingLabel(double? average) {
    if (average == null || average <= 0) return '';
    if (average >= 4.5) return 'Excellent';
    if (average >= 4) return 'Great';
    if (average >= 3) return 'Good';
    return 'Fair';
  }

  bool get hasStayCounts =>
      rooms != null || bathrooms != null || beds != null;

  /// "3 rooms · 3 bathroom · 6 bed" as its separate parts.
  List<String> get stayCounts => [
        if (rooms != null) '$rooms rooms',
        if (bathrooms != null) '$bathrooms bathroom',
        if (beds != null) '$beds bed',
      ];

  static int? _toInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
