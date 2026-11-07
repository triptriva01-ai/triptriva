import '../constants/api_endpoints.dart';

/// A listing owned by the signed-in partner, as shown on My Business and
/// Quick Updates — `GET /api/partners/me/listings`.
///
/// Distinct from [Listing], which is the traveller-facing shape: this one
/// carries the partner's own price and the review status.
class PartnerActivity {
  const PartnerActivity({
    required this.id,
    required this.name,
    this.type = '',
    this.location = '',
    this.imageUrl = '',
    this.basePrice = 0,
    this.discountPercent = 0,
    this.status = '',
    this.rejectionReason,
    this.priceUnit = '',
  });

  factory PartnerActivity.fromJson(Map<String, dynamic> json) {
    final images = json['images'];
    final cover = json['coverImage'] as String? ??
        (images is List && images.isNotEmpty ? '${images.first}' : '');

    return PartnerActivity(
      id: '${json['id'] ?? ''}',
      name: '${json['title'] ?? json['name'] ?? ''}',
      type: '${json['type'] ?? ''}'.toLowerCase(),
      location: [json['city'], json['state']]
          .whereType<String>()
          .where((part) => part.trim().isNotEmpty)
          .join(', '),
      imageUrl: ApiConfig.mediaUrl(cover),
      basePrice: _toDouble(json['basePrice']) ?? 0,
      discountPercent: _toDouble(json['discountPercent']) ?? 0,
      status: '${json['status'] ?? ''}'.toLowerCase(),
      rejectionReason: json['rejectionReason'] as String?,
      priceUnit: '${json['priceUnit'] ?? ''}',
    );
  }

  final String id;
  final String name;

  /// "stay", "houseboat" or "adventure".
  final String type;
  final String location;
  final String imageUrl;

  /// Price before any discount.
  final double basePrice;
  final double discountPercent;

  /// "pending" (in admin review), "accepted" (live) or "rejected".
  final String status;
  final String? rejectionReason;
  final String priceUnit;

  /// What a guest pays after the discount.
  double get price => basePrice * (1 - discountPercent.clamp(0, 100) / 100);

  /// Pre-discount price, struck through when higher than [price].
  double get originalPrice => basePrice;

  /// Live and bookable — only accepted listings are shown to guests.
  bool get isActive => status == 'accepted';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  bool get hasDiscount => discountPercent > 0 && basePrice > 0;

  /// Shown under the listing where the design has "Open until …".
  String get openUntil => switch (status) {
        'pending' => 'In review',
        'rejected' => 'Rejected',
        _ => '',
      };

  /// Shown on the pricing tab.
  String get discountType =>
      hasDiscount ? '${discountPercent.toStringAsFixed(0)}% off' : '';

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
