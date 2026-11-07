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
      authorName: '${json['authorName'] ?? json['userName'] ?? ''}',
      avatarUrl: '${json['avatarUrl'] ?? ''}',
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
      avatarUrl: '${json['avatarUrl'] ?? ''}',
    );
  }

  final String name;
  final String role;
  final String avatarUrl;
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

  factory ListingSlot.fromJson(Map<String, dynamic> json) {
    return ListingSlot(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? json['type'] ?? ''}',
      timeRange: '${json['timeRange'] ?? json['time'] ?? ''}',
      price: ListingReview._toDouble(json['price']) ?? 0,
      originalPrice: ListingReview._toDouble(json['originalPrice']),
      isAvailable: json['isAvailable'] != false,
    );
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

    return ListingDetail(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? json['title'] ?? ''}',
      address: json['address'] is String
          ? json['address'] as String
          : json['location'] is String
              ? json['location'] as String
              : locationAddress,
      imageUrls: strings('imageUrls'),
      rooms: _toInt(json['rooms']),
      bathrooms: _toInt(json['bathrooms']),
      beds: _toInt(json['beds']),
      tagline: '${json['tagline'] ?? ''}',
      rating: ListingReview._toDouble(json['rating']) ?? 0,
      ratingLabel: '${json['ratingLabel'] ?? ''}',
      ratingCaption: '${json['ratingCaption'] ?? ''}',
      reviewCount: _toInt(json['reviewCount']) ?? 0,
      host: json['host'] is Map<String, dynamic>
          ? ListingHost.fromJson(json['host'] as Map<String, dynamic>)
          : null,
      facilities: strings('facilities'),
      policies: strings('policies'),
      coordinates: json['coordinates'] is String
          ? json['coordinates'] as String
          : locationPoint?.label ?? '',
      mapUrl: '${json['mapUrl'] ?? ''}',
      about: '${json['about'] ?? json['description'] ?? ''}',
      reviews: (json['reviews'] as List?)
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
      price: ListingReview._toDouble(json['price']) ?? 0,
      originalPrice: ListingReview._toDouble(json['originalPrice']),
      maxPax: _toInt(json['maxPax']) ?? 60,
      minPax: _toInt(json['minPax']) ?? 1,
      cancellationNote: '${json['cancellationNote'] ?? ''}',
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
