import 'package:get/get.dart';

import '../../../data/models/app_notification.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/services/notification_service.dart';
import '../../../routes/app_pages.dart';

/// Which rows the list is showing.
enum NotificationFilter { all, offers }

/// Notification screen.
class NotificationsController extends GetxController {
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  final notifications = <AppNotification>[].obs;
  final selectedFilter = NotificationFilter.all.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

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
      final items = data is Map ? data['items'] : data;
      notifications.assignAll(
        items is List
            ? items
                .whereType<Map<String, dynamic>>()
                .map(AppNotification.fromJson)
            : const <AppNotification>[],
      );
      errorMessage.value = '';
      // Opening the screen is what "seen" means here.
      unawaitedMarkAllRead();
    } on ApiException catch (error) {
      Get.log('Notifications load failed: $error');
      errorMessage.value = error.message;
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
    // Offers point at a listing.
    if (item.targetType == 'listing' && target != null) {
      Get.toNamed(Routes.LISTING_DETAIL, arguments: target);
    }
  }
}
