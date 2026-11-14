import '../constants/api_endpoints.dart';

/// What a notification is about. Drives the icon tile on the left of the row
/// and whether the row belongs under the "Offers" filter.
enum NotificationKind { booking, payment, offer, general }

/// One row on the Notification screen.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    this.message = '',
    this.timeAgo = '',
    this.targetType = '',
    this.imageUrl = '',
    this.kind = NotificationKind.general,
    this.isRead = false,
    this.targetId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final target = json['target'] is Map ? json['target'] as Map : null;
    return AppNotification(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      message: '${json['message'] ?? json['body'] ?? ''}',
      timeAgo: '${json['timeAgo'] ?? _ago(json['timestamp'] ?? json['createdAt'])}',
      imageUrl: ApiConfig.mediaUrl('${json['imageUrl'] ?? json['image'] ?? ''}'),
      kind: _kindFrom('${json['type'] ?? json['kind'] ?? ''}'),
      isRead: json['isRead'] == true || json['read'] == true,
      targetId: (json['targetId'] ?? target?['id']) as String?,
      targetType: '${target?['type'] ?? ''}',
    );
  }

  final String id;
  final String title;
  final String message;

  /// Pre-formatted by the backend ("3 hours ago"); the design never shows a
  /// raw timestamp.
  final String timeAgo;

  /// Offer notifications carry a banner instead of a message.
  final String imageUrl;
  final NotificationKind kind;
  final bool isRead;

  /// Booking or listing this row opens, when it opens anything.
  final String? targetId;

  bool get isOffer => kind == NotificationKind.offer;
  bool get hasImage => imageUrl.isNotEmpty;

  /// What [targetId] refers to: `booking`, `listing`, … (empty when none).
  final String targetType;

  /// "5 min ago", "3 h ago", "2 days ago", from an ISO timestamp.
  static String _ago(dynamic value) {
    final at = DateTime.tryParse('${value ?? ''}');
    if (at == null) return '';
    final diff = DateTime.now().difference(at.toLocal());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays < 1) return '${diff.inHours} h ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${at.day}/${at.month}/${at.year}';
  }

  static NotificationKind _kindFrom(String value) {
    return switch (value.toLowerCase()) {
      'booking' || 'reminder' => NotificationKind.booking,
      'payment' => NotificationKind.payment,
      'offer' || 'offers' => NotificationKind.offer,
      _ => NotificationKind.general,
    };
  }
}
