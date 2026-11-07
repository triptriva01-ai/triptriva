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
    this.imageUrl = '',
    this.kind = NotificationKind.general,
    this.isRead = false,
    this.targetId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      message: '${json['message'] ?? json['body'] ?? ''}',
      timeAgo: '${json['timeAgo'] ?? json['createdAt'] ?? ''}',
      imageUrl: '${json['imageUrl'] ?? json['image'] ?? ''}',
      kind: _kindFrom('${json['type'] ?? json['kind'] ?? ''}'),
      isRead: json['isRead'] == true || json['read'] == true,
      targetId: json['targetId'] as String?,
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

  static NotificationKind _kindFrom(String value) {
    return switch (value.toLowerCase()) {
      'booking' => NotificationKind.booking,
      'payment' => NotificationKind.payment,
      'offer' || 'offers' => NotificationKind.offer,
      _ => NotificationKind.general,
    };
  }
}
