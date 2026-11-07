import 'package:get/get.dart';

import '../constants/api_endpoints.dart';
import '../providers/api_client.dart';

/// Notifications page — `Notifications` sheet (Page 8).
class NotificationService extends GetxService {
  final ApiClient _api = Get.find<ApiClient>();

  /// All notifications. Filter: type (all/offers).
  Future<dynamic> getNotifications({String? type}) => _api.getRequest(
        NotificationEndpoints.notifications,
        query: {'type': type},
      );

  Future<dynamic> markRead(String id) =>
      _api.putRequest(NotificationEndpoints.read(id));

  Future<dynamic> markAllRead() =>
      _api.putRequest(NotificationEndpoints.readAll);

  Future<dynamic> delete(String id) =>
      _api.deleteRequest(NotificationEndpoints.delete(id));

  /// Count of unread notifications — for the bell icon badge.
  Future<dynamic> unreadCount() =>
      _api.getRequest(NotificationEndpoints.unreadCount);
}
