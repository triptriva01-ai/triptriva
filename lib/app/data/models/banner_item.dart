import '../constants/api_endpoints.dart';

/// A promotional banner in the home carousel (`banners` in `GET /api/home`).
class BannerItem {
  const BannerItem({
    required this.id,
    required this.title,
    this.imageUrl = '',
    this.ctaLabel = 'Book Now',
    this.targetType = '',
    this.targetValue,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      imageUrl: ApiConfig.mediaUrl('${json['imageUrl'] ?? json['image'] ?? ''}'),
      ctaLabel: '${json['ctaLabel'] ?? 'Book Now'}',
      targetType: '${json['targetType'] ?? ''}',
      targetValue: json['targetValue'] as String?,
    );
  }

  final String id;
  final String title;
  final String imageUrl;
  final String ctaLabel;

  /// What tapping the banner opens: `listing` (a listing id), `category`
  /// (a listing type), `search` (a query) or `url`.
  final String targetType;
  final String? targetValue;
}
