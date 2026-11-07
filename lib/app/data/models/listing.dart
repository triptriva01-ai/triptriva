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
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      location: '${json['location'] ?? ''}',
      imageUrl: '${json['imageUrl'] ?? json['image'] ?? ''}',
      rating: _toDouble(json['rating']) ?? 0,
      price: _toDouble(json['price']) ?? 0,
      originalPrice: _toDouble(json['originalPrice']),
      discountPercent: _toInt(json['discountPercent']),
      isWishlisted: json['isWishlisted'] == true,
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
