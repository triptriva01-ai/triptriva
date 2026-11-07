import 'package:get/get.dart';

import '../../../data/providers/api_exception.dart';
import '../../../data/services/notification_service.dart';

/// What a notification is about; drives the icon and whether it carries a
/// banner image.
enum PartnerNotificationKind { booking, payment, offer }

class PartnerNotification {
  const PartnerNotification({
    required this.title,
    required this.message,
    required this.age,
    required this.kind,
    this.imageUrl = '',
  });

  final String title;
  final String message;

  /// Pre-formatted relative time, e.g. "3 hours ago".
  final String age;
  final PartnerNotificationKind kind;

  /// Banner shown instead of body copy on offer notifications.
  final String imageUrl;
}

/// Which slice of the list is showing.
enum NotificationTab { all, offers }

/// Partner-side notification centre, reached from the bell in the header.
class PartnerNotificationsController extends GetxController {
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  final selectedTab = NotificationTab.all.obs;
  final notifications = <PartnerNotification>[].obs;
  final isLoading = false.obs;

  List<PartnerNotification> get visibleNotifications {
    if (selectedTab.value == NotificationTab.offers) {
      return notifications
          .where((item) => item.kind == PartnerNotificationKind.offer)
          .toList();
    }
    return notifications.toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  /// The same inbox as the traveller side — the backend targets partner
  /// notifications (bookings, listing reviews) at this user.
  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final data = await _notificationService.getNotifications(type: 'all');
      final items = data is Map ? data['items'] : null;
      notifications.assignAll(
        items is List
            ? items.whereType<Map>().map(_fromJson).toList()
            : const <PartnerNotification>[],
      );
      // Opening the inbox counts as reading it.
      if (notifications.isNotEmpty) {
        _notificationService.markAllRead().ignore();
      }
    } on ApiException catch (error) {
      Get.log('Partner notifications load failed: $error');
      notifications.clear();
    } finally {
      isLoading.value = false;
    }
  }

  static PartnerNotification _fromJson(Map<dynamic, dynamic> json) {
    final kind = switch ('${json['type'] ?? ''}') {
      'booking' => PartnerNotificationKind.booking,
      'payment' => PartnerNotificationKind.payment,
      'offer' => PartnerNotificationKind.offer,
      _ => PartnerNotificationKind.booking,
    };
    return PartnerNotification(
      title: '${json['title'] ?? ''}',
      message: '${json['body'] ?? ''}',
      age: _timeAgo(DateTime.tryParse('${json['timestamp']}')),
      kind: kind,
      imageUrl: '${json['imageUrl'] ?? ''}',
    );
  }

  /// "Just now", "5 minutes ago", "3 hours ago", "2 days ago", or the date.
  static String _timeAgo(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time.toLocal());
    String plural(int n, String unit) => '$n $unit${n == 1 ? '' : 's'} ago';
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return plural(diff.inMinutes, 'minute');
    if (diff.inDays < 1) return plural(diff.inHours, 'hour');
    if (diff.inDays < 7) return plural(diff.inDays, 'day');
    final local = time.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }

  void selectTab(NotificationTab tab) => selectedTab.value = tab;

  void selectTabAt(int index) => selectTab(NotificationTab.values[index]);

  void goBack() => Get.back();
}
