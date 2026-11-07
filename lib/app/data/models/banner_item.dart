/// A promotional banner in the home carousel (`GET /api/banners`).
class BannerItem {
  const BannerItem({
    required this.id,
    required this.title,
    this.imageUrl = '',
    this.ctaLabel = 'Book Now',
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      imageUrl: '${json['imageUrl'] ?? json['image'] ?? ''}',
      ctaLabel: '${json['ctaLabel'] ?? 'Book Now'}',
    );
  }

  final String id;
  final String title;
  final String imageUrl;
  final String ctaLabel;
}
