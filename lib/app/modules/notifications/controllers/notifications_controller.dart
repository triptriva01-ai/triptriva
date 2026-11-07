import 'package:get/get.dart';

import '../../../data/models/app_notification.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/services/notification_service.dart';
import '../../../routes/app_pages.dart';
import '../constants/notifications_constants.dart';

/// Which rows the list is showing.
enum NotificationFilter { all, offers }

/// Notification screen.
class NotificationsController extends GetxController {
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  final notifications = <AppNotification>[].obs;
  final selectedFilter = NotificationFilter.all.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final data = await _notificationService.getNotifications(
        type: selectedFilter.value.name,
      );
      notifications.assignAll(
        data is List
            ? data
                .whereType<Map<String, dynamic>>()
                .map(AppNotification.fromJson)
            : const <AppNotification>[],
      );
      // Opening the screen is what "seen" means here.
      unawaitedMarkAllRead();
    } on ApiException catch (error) {
      Get.log('Notifications load failed: $error');
      _loadSampleNotifications();
    } finally {
      isLoading.value = false;
    }
  }

  /// Fire-and-forget: the badge clearing must not hold up the list.
  void unawaitedMarkAllRead() {
    _notificationService.markAllRead().catchError((Object error) {
      Get.log('Mark all read failed: $error');
      return null;
    });
  }

  /// The rows matching the current filter.
  ///
  /// Read this inside an `Obx` builder — the observable reads happen here, so
  /// calling it from the builder body is what registers them.
  List<AppNotification> get visibleNotifications {
    final filter = selectedFilter.value;
    final all = notifications.toList();
    if (filter == NotificationFilter.all) {
      return all;
    }
    return all.where((item) => item.isOffer).toList();
  }

  void selectFilter(NotificationFilter filter) {
    if (filter == selectedFilter.value) return;
    selectedFilter.value = filter;
    loadNotifications();
  }

  void goBack() => Get.back();

  /// Booking rows open the booking; everything else is informational.
  void openNotification(AppNotification item) {
    final target = item.targetId;
    if (item.kind == NotificationKind.booking && target != null) {
      Get.toNamed(Routes.BOOKING_DETAIL, arguments: target);
      return;
    }
    if (item.isOffer) {
      _pending(item.title);
    }
  }

  void _pending(String feature) {
    Get.snackbar(
      NotificationsStrings.pendingTitle,
      NotificationsStrings.pendingMessage(feature),
      duration: NotificationsDurations.snackbar,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ---------------------------------------------------------------------
  // Development placeholder — remove once `GET /api/notifications` serves
  // real data.
  // ---------------------------------------------------------------------

  void _loadSampleNotifications() {
    notifications.assignAll(const [
      AppNotification(
        id: '1',
        title: 'House Boat Booking',
        message: 'Your booking is for the kerala house boat is incomplete.'
            'Hurry up! before the slot filled.',
        timeAgo: '3 hours ago',
        kind: NotificationKind.booking,
      ),
      AppNotification(
        id: '2',
        title: 'Adventure Booking',
        message: 'Your booking for the kayakin is incomplete.'
            'Hurry up! before the slot filled.',
        timeAgo: '3 hours ago',
        kind: NotificationKind.booking,
      ),
      AppNotification(
        id: '3',
        title: 'Successfully paid',
        message: 'Yout have paid ₹500/- for the booking',
        timeAgo: '3 hours ago',
        kind: NotificationKind.payment,
      ),
      AppNotification(
        id: '4',
        title: 'Stay Booking',
        message: 'Your booking for the stay in tent house for 12 june 2026 '
            'is completed.',
        timeAgo: '3 hours ago',
        kind: NotificationKind.booking,
      ),
      AppNotification(
        id: '5',
        title: 'Offers',
        timeAgo: '3 hours ago',
        kind: NotificationKind.offer,
        imageUrl: 'placeholder',
      ),
    ]);
  }
}
