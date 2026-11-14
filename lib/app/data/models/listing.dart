import '../constants/api_endpoints.dart';

/// A stay / houseboat / adventure listing as shown on cards across the app.
class Listing {
  const Listing({
    required this.id,
    required this.title,
    required this.location,
    this.imageUrl = '',
    this.rating = 0,
    this.price = 0,
    this.originalPrice,
    this.discountPercent,
    this.isWishlisted = false,
    this.type = '',
  });

  /// Reads the API's `ListingSummaryResponse` (`title`, `coverImage`, `city`,
  /// `basePrice`, `avgRating`) and the older card shape alike.
  factory Listing.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    final price = _toDouble(json['price']) ?? _toDouble(json['basePrice']) ?? 0;
    final original = _toDouble(json['originalPrice']);
    return Listing(
      id: '${json['id'] ?? json['listingId'] ?? ''}',
      title: '${json['title'] ?? json['listingTitle'] ?? ''}',
      location: location is String && location.isNotEmpty
          ? location
          : '${json['city'] ?? ''}',
      imageUrl: ApiConfig.mediaUrl(
        '${json['imageUrl'] ?? json['coverImage'] ?? json['image'] ?? ''}',
      ),
      rating: _toDouble(json['rating']) ?? _toDouble(json['avgRating']) ?? 0,
      price: price,
      originalPrice: original,
      discountPercent: _toInt(json['discountPercent']) ??
          (original != null && original > price && original > 0
              ? ((original - price) * 100 / original).round()
              : null),
      isWishlisted: json['isWishlisted'] == true,
      type: '${json['type'] ?? json['listingType'] ?? ''}',
    );
  }

  final String id;
  final String title;
  final String location;
  final String imageUrl;
  final double rating;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final bool isWishlisted;

  /// `stay`, `houseboat` or `adventure`.
  final String type;

  bool get hasDiscount => (discountPercent ?? 0) > 0;

  Listing copyWith({bool? isWishlisted}) {
    return Listing(
      id: id,
      title: title,
      location: location,
      imageUrl: imageUrl,
      rating: rating,
      price: price,
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      type: type,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
